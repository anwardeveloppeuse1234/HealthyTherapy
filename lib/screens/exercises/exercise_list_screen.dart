import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/exercise.dart';
import '../../services/exercise_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  final bool isProfessional;

  const ExerciseListScreen({super.key, this.isProfessional = false});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  ExerciseCategory? _filterCategory;
  ExerciseDifficulty? _filterDifficulty;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
    });

    List<Exercise> exercises;
    if (_filterCategory != null || _filterDifficulty != null) {
      exercises = await _exerciseService.filterExercises(
        category: _filterCategory,
        difficulty: _filterDifficulty,
      );
    } else {
      exercises = await _exerciseService.getAllExercises();
    }

    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercices'),
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
                      ...ExerciseCategory.values.map((cat) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, cat),
                            child: Text(cat.displayName),
                          )),
                    ],
                  ),
                );
                setState(() {
                  _filterCategory = category;
                });
                _loadExercises();
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
                      ...ExerciseDifficulty.values.map((diff) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, diff),
                            child: Text(diff.displayName),
                          )),
                    ],
                  ),
                );
                setState(() {
                  _filterDifficulty = difficulty;
                });
                _loadExercises();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Aucun exercice disponible',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadExercises,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(
                                exercise: exercise,
                                isProfessional: widget.isProfessional,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadExercises();
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (exercise.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Image.network(
                  exercise.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    exercise.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),

                  // Description
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          exercise.category.displayName,
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.getDifficultyColor(exercise.difficulty.toString().split('.').last).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          exercise.difficulty.displayName,
                          style: TextStyle(
                            color: AppTheme.getDifficultyColor(exercise.difficulty.toString().split('.').last),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.duration} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
