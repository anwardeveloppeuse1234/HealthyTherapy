import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/symptom_service.dart';
import '../../services/exercise_service.dart';
import '../../services/appointment_service.dart';
import '../../services/forum_service.dart';
import '../../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final AuthService _authService = AuthService();
  final SymptomService _symptomService = SymptomService();
  final ExerciseService _exerciseService = ExerciseService();
  final AppointmentService _appointmentService = AppointmentService();
  final ForumService _forumService = ForumService();

  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalPatients = 0;
  int _totalProfessionals = 0;
  int _totalSymptoms = 0;
  int _totalExercises = 0;
  int _totalAppointments = 0;
  int _totalForumPosts = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    final users = await _authService.getAllUsers();
    final exercises = await _exerciseService.getAllExercises();
    final posts = await _forumService.getAllPosts();

    // Compter les symptômes de tous les patients
    int symptomsCount = 0;
    int appointmentsCount = 0;
    for (final user in users) {
      if (user.role == UserRole.patient) {
        final symptoms = await _symptomService.getUserSymptoms(user.id);
        symptomsCount += symptoms.length;
      }
      final appointments = await _appointmentService.getUserAppointments(user.id);
      appointmentsCount += appointments.length;
    }

    setState(() {
      _totalUsers = users.length;
      _totalPatients = users.where((u) => u.role == UserRole.patient).length;
      _totalProfessionals =
          users.where((u) => u.role == UserRole.professional).length;
      _totalSymptoms = symptomsCount;
      _totalExercises = exercises.length;
      _totalAppointments = appointmentsCount ~/ 2; // Diviser par 2 car chaque RDV compte pour 2 utilisateurs
      _totalForumPosts = posts.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques globales'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Statistiques principales
                    _buildMainStats(),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Graphique des utilisateurs
                    _buildUsersChart(),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Statistiques détaillées
                    _buildDetailedStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMainStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.people,
                  label: 'Utilisateurs',
                  value: _totalUsers.toString(),
                  color: AppConstants.primaryColor,
                ),
                _StatItem(
                  icon: Icons.person,
                  label: 'Patients',
                  value: _totalPatients.toString(),
                  color: Colors.blue,
                ),
                _StatItem(
                  icon: Icons.medical_services,
                  label: 'Professionnels',
                  value: _totalProfessionals.toString(),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition des utilisateurs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _totalPatients.toDouble(),
                      title: '$_totalPatients',
                      color: Colors.blue,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _totalProfessionals.toDouble(),
                      title: '$_totalProfessionals',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: (_totalUsers - _totalPatients - _totalProfessionals)
                          .toDouble(),
                      title: '${_totalUsers - _totalPatients - _totalProfessionals}',
                      color: Colors.purple,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: Colors.blue, label: 'Patients'),
                _LegendItem(color: Colors.green, label: 'Professionnels'),
                _LegendItem(color: Colors.purple, label: 'Admins'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques détaillées',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _DetailedStatRow(
              icon: Icons.healing,
              label: 'Symptômes enregistrés',
              value: _totalSymptoms.toString(),
              color: Colors.orange,
            ),
            const Divider(),
            _DetailedStatRow(
              icon: Icons.fitness_center,
              label: 'Exercices disponibles',
              value: _totalExercises.toString(),
              color: Colors.teal,
            ),
            const Divider(),
            _DetailedStatRow(
              icon: Icons.calendar_today,
              label: 'Rendez-vous planifiés',
              value: _totalAppointments.toString(),
              color: Colors.indigo,
            ),
            const Divider(),
            _DetailedStatRow(
              icon: Icons.forum,
              label: 'Publications au forum',
              value: _totalForumPosts.toString(),
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DetailedStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailedStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
