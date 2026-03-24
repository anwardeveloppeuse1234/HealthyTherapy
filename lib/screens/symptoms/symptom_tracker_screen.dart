import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/symptom.dart';
import '../../services/symptom_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'add_symptom_screen.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final SymptomService _symptomService = SymptomService();
  List<Symptom> _symptoms = [];
  bool _isLoading = true;
  SymptomType? _filterType;

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser!.id;

    List<Symptom> symptoms;
    if (_filterType != null) {
      symptoms = await _symptomService.getSymptomsByType(userId, _filterType!);
    } else {
      symptoms = await _symptomService.getUserSymptoms(userId);
    }

    setState(() {
      _symptoms = symptoms;
      _isLoading = false;
    });
  }

  Future<void> _deleteSymptom(String symptomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce symptôme ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _symptomService.deleteSymptom(symptomId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Symptôme supprimé'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        _loadSymptoms();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des symptômes'),
        actions: [
          PopupMenuButton<SymptomType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _filterType = type;
              });
              _loadSymptoms();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tous les symptômes'),
              ),
              ...SymptomType.values.map((type) => PopupMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  )),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _symptoms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Aucun symptôme enregistré',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Commencez à suivre vos symptômes',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSymptoms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: _symptoms.length,
                    itemBuilder: (context, index) {
                      final symptom = _symptoms[index];
                      return _SymptomCard(
                        symptom: symptom,
                        onDelete: () => _deleteSymptom(symptom.id),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddSymptomScreen(),
            ),
          );
          if (result == true) {
            _loadSymptoms();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final Symptom symptom;
  final VoidCallback onDelete;

  const _SymptomCard({
    required this.symptom,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                    color: AppTheme.getSeverityColor(symptom.severity),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    symptom.type.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Sévérité: ${symptom.severity}/10',
                  style: TextStyle(
                    color: AppTheme.getSeverityColor(symptom.severity),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppConstants.errorColor),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              symptom.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(symptom.date)} à ${symptom.time}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (symptom.duration != null) ...[
                  const SizedBox(width: AppConstants.paddingMedium),
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${symptom.duration} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            if (symptom.triggers.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Wrap(
                spacing: AppConstants.paddingSmall,
                children: symptom.triggers
                    .map((trigger) => Chip(
                          label: Text(trigger),
                          labelStyle: const TextStyle(fontSize: 12),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
