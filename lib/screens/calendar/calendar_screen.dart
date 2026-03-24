import 'package:flutter/material.dart';
import 'package:healthy_therapy_ms/models/user.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'book_appointment_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Appointment> _appointments = [];
  List<Appointment> _selectedDayAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser!.id;

    final appointments = await _appointmentService.getUserAppointments(userId);

    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });

    _updateSelectedDayAppointments();
  }

  void _updateSelectedDayAppointments() {
    if (_selectedDay == null) {
      _selectedDayAppointments = [];
      return;
    }

    _selectedDayAppointments = _appointments.where((appointment) {
      return appointment.date.year == _selectedDay!.year &&
          appointment.date.month == _selectedDay!.month &&
          appointment.date.day == _selectedDay!.day;
    }).toList();

    setState(() {});
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _appointments.where((appointment) {
      return appointment.date.year == day.year &&
          appointment.date.month == day.month &&
          appointment.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isPatient = authProvider.currentUser!.role == UserRole.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendrier
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _updateSelectedDayAppointments();
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppConstants.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                  ),
                ),
                const Divider(),

                // Liste des rendez-vous du jour sélectionné
                Expanded(
                  child: _selectedDayAppointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(
                                  height: AppConstants.paddingMedium),
                              Text(
                                'Aucun rendez-vous ce jour',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.all(AppConstants.paddingMedium),
                          itemCount: _selectedDayAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _selectedDayAppointments[index];
                            return _AppointmentCard(appointment: appointment);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: isPatient
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BookAppointmentScreen(),
                  ),
                );
                if (result == true) {
                  _loadAppointments();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouveau RDV'),
            )
          : null,
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getAppointmentStatusColor(
                      appointment.status.toString().split('.').last,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    appointment.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${appointment.startTime} - ${appointment.endTime}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              appointment.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              appointment.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (appointment.location != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    appointment.location!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
