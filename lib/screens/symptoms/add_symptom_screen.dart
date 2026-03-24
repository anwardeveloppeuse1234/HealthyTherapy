import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/symptom.dart';
import '../../services/symptom_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class AddSymptomScreen extends StatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  final SymptomService _symptomService = SymptomService();
  
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _triggerController = TextEditingController();
  
  SymptomType _selectedType = SymptomType.fatigue;
  double _severity = 5;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _triggers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    _triggerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addTrigger() {
    if (_triggerController.text.isNotEmpty) {
      setState(() {
        _triggers.add(_triggerController.text.trim());
        _triggerController.clear();
      });
    }
  }

  void _removeTrigger(int index) {
    setState(() {
      _triggers.removeAt(index);
    });
  }

  Future<void> _saveSymptom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser!.id;

    final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final success = await _symptomService.addSymptom(
      userId: userId,
      type: _selectedType,
      severity: _severity.round(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      time: timeString,
      duration: _durationController.text.isNotEmpty
          ? int.tryParse(_durationController.text)
          : null,
      triggers: _triggers,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptôme enregistré'),
          backgroundColor: AppConstants.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un symptôme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type de symptôme
              Text(
                'Type de symptôme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              DropdownButtonFormField<SymptomType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                ),
                items: SymptomType.values.map((type) {
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
              const SizedBox(height: AppConstants.paddingLarge),

              // Sévérité
              Text(
                'Sévérité: ${_severity.round()}/10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _severity,
                min: 1,
                max: 10,
                divisions: 9,
                label: _severity.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _severity = value;
                  });
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormat.format(_selectedDate)),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Heure
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Heure',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(_selectedTime.format(context)),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Durée
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée (minutes) - Optionnel',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // Déclencheurs
              Text(
                'Déclencheurs',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _triggerController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un déclencheur',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTrigger,
                  ),
                ],
              ),
              if (_triggers.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingSmall),
                Wrap(
                  spacing: AppConstants.paddingSmall,
                  children: _triggers.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      onDeleted: () => _removeTrigger(entry.key),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppConstants.paddingLarge * 2),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSymptom,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
