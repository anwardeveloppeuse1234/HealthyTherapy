import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final bool isProfessional;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.isProfessional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'exercice'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (exercise.imageUrl != null)
              Image.network(
                exercise.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    exercise.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Badges
                  Row(
                    children: [
                      _Badge(
                        label: exercise.category.displayName,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      _Badge(
                        label: exercise.difficulty.displayName,
                        color: AppTheme.getDifficultyColor(
                          exercise.difficulty.toString().split('.').last,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      _Badge(
                        label: '${exercise.duration} min',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Instructions
                  if (exercise.instructions.isNotEmpty) ...[
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ...exercise.instructions.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(entry.value),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppConstants.paddingLarge),
                  ],

                  // Bénéfices
                  if (exercise.benefits.isNotEmpty) ...[
                    Text(
                      'Bénéfices',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ...exercise.benefits.map((benefit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppConstants.successColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Expanded(child: Text(benefit)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppConstants.paddingLarge),
                  ],

                  // Précautions
                  if (exercise.precautions.isNotEmpty) ...[
                    Text(
                      'Précautions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ...exercise.precautions.map((precaution) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning,
                              color: AppConstants.warningColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Expanded(child: Text(precaution)),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
