import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/forum_post.dart';
import '../../services/forum_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();
  final AuthService _authService = AuthService();
  List<ForumPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    final posts = await _forumService.getAllPosts();

    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _createPost() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    ForumCategory selectedCategory = ForumCategory.general;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle publication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Contenu'),
                maxLines: 5,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              DropdownButtonFormField<ForumCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: ForumCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await _forumService.createPost(
        authorId: authProvider.currentUser!.id,
        title: titleController.text,
        content: contentController.text,
        category: selectedCategory,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publication créée'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        _loadPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('Aucune publication'))
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return FutureBuilder(
                        future: _authService.getUserById(post.authorId),
                        builder: (context, snapshot) {
                          final authorName = snapshot.hasData
                              ? snapshot.data!.fullName
                              : 'Utilisateur';

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        child: Text(authorName[0]),
                                      ),
                                      const SizedBox(width: AppConstants.paddingSmall),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              authorName,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Chip(
                                        label: Text(post.category.displayName),
                                        labelStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppConstants.paddingMedium),
                                  Text(
                                    post.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppConstants.paddingSmall),
                                  Text(post.content),
                                  const SizedBox(height: AppConstants.paddingMedium),
                                  Row(
                                    children: [
                                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${post.likes.length}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
