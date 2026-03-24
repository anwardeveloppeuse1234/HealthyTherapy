import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../services/exercise_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../exercises/exercise_detail_screen.dart';

class ExercisesManagementScreen extends StatefulWidget {
  const ExercisesManagementScreen({super.key});

  @override
  State<ExercisesManagementScreen> createState() =>
      _ExercisesManagementScreenState();
}

class _ExercisesManagementScreenState extends State<ExercisesManagementScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  bool _isLoading = true;
  ExerciseCategory? _filterCategory;
  ExerciseDifficulty? _filterDifficulty;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    final exercises = await _exerciseService.getAllExercises();

    setState(() {
      _exercises = exercises;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    var filtered = _exercises;

    if (_filterCategory != null) {
      filtered = filtered.where((e) => e.category == _filterCategory).toList();
    }

    if (_filterDifficulty != null) {
      filtered =
          filtered.where((e) => e.difficulty == _filterDifficulty).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(searchQuery) ||
            e.description.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredExercises = filtered;
    });
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer l\'exercice "${exercise.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _exerciseService.deleteExercise(exercise.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercice supprimé'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        _loadExercises();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des exercices'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) async {
              if (value == 'category') {
                final category = await showDialog<ExerciseCategory?>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Filtrer par catégorie'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('Toutes les catégories'),
                      ),
                      ...ExerciseCategory.values.map(
                        (cat) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, cat),
                          child: Text(cat.displayName),
                        ),
                      ),
                    ],
                  ),
                );
                setState(() {
                  _filterCategory = category;
                });
                _applyFilters();
              } else if (value == 'difficulty') {
                final difficulty = await showDialog<ExerciseDifficulty?>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Filtrer par difficulté'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('Toutes les difficultés'),
                      ),
                      ...ExerciseDifficulty.values.map(
                        (diff) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, diff),
                          child: Text(diff.displayName),
                        ),
                      ),
                    ],
                  ),
                );
                setState(() {
                  _filterDifficulty = difficulty;
                });
                _applyFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'category',
                child: Text('Filtrer par catégorie'),
              ),
              const PopupMenuItem(
                value: 'difficulty',
                child: Text('Filtrer par difficulté'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Statistiques
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.fitness_center,
                  label: 'Total',
                  value: _exercises.length.toString(),
                  color: AppConstants.primaryColor,
                ),
                _StatCard(
                  icon: Icons.accessible,
                  label: 'Mobilité',
                  value: _exercises
                      .where((e) => e.category == ExerciseCategory.mobility)
                      .length
                      .toString(),
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.balance,
                  label: 'Équilibre',
                  value: _exercises
                      .where((e) => e.category == ExerciseCategory.balance)
                      .length
                      .toString(),
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Liste des exercices
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? const Center(
                        child: Text('Aucun exercice trouvé'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadExercises,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppConstants.primaryColor,
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  exercise.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppConstants.primaryColor
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadiusSmall,
                                            ),
                                          ),
                                          child: Text(
                                            exercise.category.displayName,
                                            style: const TextStyle(
                                              color: AppConstants.primaryColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.getDifficultyColor(
                                              exercise.difficulty
                                                  .toString()
                                                  .split('.')
                                                  .last,
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadiusSmall,
                                            ),
                                          ),
                                          child: Text(
                                            exercise.difficulty.displayName,
                                            style: TextStyle(
                                              color:
                                                  AppTheme.getDifficultyColor(
                                                exercise.difficulty
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility),
                                          SizedBox(width: 8),
                                          Text('Voir'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: AppConstants.errorColor,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Supprimer',
                                            style: TextStyle(
                                              color: AppConstants.errorColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'view') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ExerciseDetailScreen(
                                            exercise: exercise,
                                            isProfessional: true,
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _deleteExercise(exercise);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
