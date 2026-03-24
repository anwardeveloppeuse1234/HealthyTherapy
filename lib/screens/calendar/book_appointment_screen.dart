import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../models/user.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  User? _selectedProfessional;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  AppointmentType _selectedType = AppointmentType.consultation;
  List<User> _professionals = [];
  List<String> _availableSlots = [];
  bool _isLoadingProfessionals = true;
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionals() async {
    setState(() {
      _isLoadingProfessionals = true;
    });

    final professionals = await _authService.getProfessionals();

    setState(() {
      _professionals = professionals;
      _isLoadingProfessionals = false;
    });
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedProfessional == null) return;

    setState(() {
      _isLoadingSlots = true;
      _selectedTimeSlot = null;
    });

    final slots = await _appointmentService.getAvailableTimeSlots(
      _selectedProfessional!.id,
      _selectedDate,
    );

    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
    });

    if (slots.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun créneau disponible pour cette date'),
          backgroundColor: AppConstants.warningColor,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailableSlots();
    }
  }

  String _calculateEndTime(String startTime) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final endMinute = minute + 30;
    final endHour = endMinute >= 60 ? hour + 1 : hour;
    final finalMinute = endMinute >= 60 ? endMinute - 60 : endMinute;

    return '${endHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}';
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProfessional == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un professionnel'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un créneau horaire'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final endTime = _calculateEndTime(_selectedTimeSlot!);

    // Vérifier une dernière fois la disponibilité
    final isAvailable = await _appointmentService.isTimeSlotAvailable(
      _selectedProfessional!.id,
      _selectedDate,
      _selectedTimeSlot!,
      endTime,
    );

    if (!isAvailable && mounted) {
      setState(() {
        _isBooking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce créneau n\'est plus disponible'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      _loadAvailableSlots();
      return;
    }

    final success = await _appointmentService.createAppointment(
      patientId: authProvider.currentUser!.id,
      professionalId: _selectedProfessional!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      startTime: _selectedTimeSlot!,
      endTime: endTime,
      type: _selectedType,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() {
      _isBooking = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous réservé avec succès'),
          backgroundColor: AppConstants.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réservation'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE dd MMMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre rendez-vous'),
      ),
      body: _isLoadingProfessionals
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sélection du professionnel
                    Text(
                      'Professionnel de santé',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    DropdownButtonFormField<User>(
                      value: _selectedProfessional,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Sélectionner un professionnel',
                      ),
                      items: _professionals.map((professional) {
                        return DropdownMenuItem(
                          value: professional,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(professional.fullName),
                              if (professional.specialization != null)
                                Text(
                                  professional.specialization!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProfessional = value;
                          _availableSlots = [];
                          _selectedTimeSlot = null;
                        });
                        if (value != null) {
                          _loadAvailableSlots();
                        }
                      },
                      validator: (value) => value == null
                          ? 'Sélectionnez un professionnel'
                          : null,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Sélection de la date
                    Text(
                      'Date du rendez-vous',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    InkWell(
                      onTap: _selectedProfessional != null ? _selectDate : null,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          enabled: _selectedProfessional != null,
                        ),
                        child: Text(
                          dateFormat.format(_selectedDate),
                          style: TextStyle(
                            color: _selectedProfessional != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Créneaux disponibles
                    if (_selectedProfessional != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Créneaux disponibles',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_isLoadingSlots)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      if (_availableSlots.isEmpty && !_isLoadingSlots)
                        Container(
                          padding:
                              const EdgeInsets.all(AppConstants.paddingLarge),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                          child: const Text(
                            'Aucun créneau disponible pour cette date.\nVeuillez sélectionner une autre date.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (!_isLoadingSlots)
                        Wrap(
                          spacing: AppConstants.paddingSmall,
                          runSpacing: AppConstants.paddingSmall,
                          children: _availableSlots.map((slot) {
                            final isSelected = _selectedTimeSlot == slot;
                            return ChoiceChip(
                              label: Text(slot),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTimeSlot = selected ? slot : null;
                                });
                              },
                              selectedColor: AppConstants.primaryColor,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: AppConstants.paddingLarge),
                    ],

                    // Type de rendez-vous
                    Text(
                      'Type de rendez-vous',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    DropdownButtonFormField<AppointmentType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppointmentType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Titre
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre du rendez-vous',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Titre requis' : null,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description / Motif',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Description requise' : null,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Lieu
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu (optionnel)',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes additionnelles (optionnel)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 2),

                    // Bouton de réservation
                    ElevatedButton(
                      onPressed: _isBooking ? null : _bookAppointment,
                      child: _isBooking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Réserver le rendez-vous'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
