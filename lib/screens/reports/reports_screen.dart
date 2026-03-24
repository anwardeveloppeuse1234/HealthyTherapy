import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../utils/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser!.id;

    final reports = await _reportService.getUserReports(userId);

    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  Future<void> _generateReport(ReportType type) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser!.id;

    Report? report;
    if (type == ReportType.weekly) {
      report = await _reportService.generateWeeklyReport(userId);
    } else if (type == ReportType.monthly) {
      report = await _reportService.generateMonthlyReport(userId);
    }

    if (report != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport généré avec succès'),
          backgroundColor: AppConstants.successColor,
        ),
      );
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
        actions: [
          PopupMenuButton<ReportType>(
            icon: const Icon(Icons.add),
            onSelected: _generateReport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ReportType.weekly,
                child: Text('Rapport hebdomadaire'),
              ),
              const PopupMenuItem(
                value: ReportType.monthly,
                child: Text('Rapport mensuel'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Aucun rapport',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Générez votre premier rapport',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return _ReportCard(report: report);
                    },
                  ),
                ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    report.type.displayName,
                    style: const TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(report.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Période: ${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: AppConstants.paddingLarge),
            _StatRow(
              icon: Icons.health_and_safety,
              label: 'Symptômes enregistrés',
              value: report.data.symptomsCount.toString(),
            ),
            _StatRow(
              icon: Icons.fitness_center,
              label: 'Exercices complétés',
              value: report.data.exercisesCompleted.toString(),
            ),
            _StatRow(
              icon: Icons.trending_up,
              label: 'Sévérité moyenne',
              value: report.data.averageSeverity.toStringAsFixed(1),
            ),
            if (report.data.mostCommonSymptom != null)
              _StatRow(
                icon: Icons.warning,
                label: 'Symptôme le plus fréquent',
                value: report.data.mostCommonSymptom!,
              ),
            _StatRow(
              icon: Icons.show_chart,
              label: 'Progrès',
              value: '${report.data.progressPercentage.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryColor),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
