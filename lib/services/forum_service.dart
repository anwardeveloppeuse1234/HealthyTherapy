import 'package:uuid/uuid.dart';
import '../models/forum_post.dart';
import 'storage_service.dart';

class ForumService {
  static final ForumService _instance = ForumService._internal();
  factory ForumService() => _instance;
  ForumService._internal();

  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  // Créer une publication
  Future<bool> createPost({
    required String authorId,
    required String title,
    required String content,
    required ForumCategory category,
  }) async {
    try {
      final post = ForumPost(
        id: _uuid.v4(),
        authorId: authorId,
        title: title,
        content: content,
        category: category,
        likes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = await _storage.readJson('forum.json');
      final posts = (data['posts'] as List? ?? [])
          .map((p) => ForumPost.fromJson(p))
          .toList();
      
      posts.add(post);
      data['posts'] = posts.map((p) => p.toJson()).toList();

      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors de la création de la publication: $e');
      return false;
    }
  }

  // Récupérer toutes les publications
  Future<List<ForumPost>> getAllPosts() async {
    try {
      final data = await _storage.readJson('forum.json');
      final posts = (data['posts'] as List? ?? [])
          .map((p) => ForumPost.fromJson(p))
          .toList();

      return posts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Erreur lors de la récupération des publications: $e');
      return [];
    }
  }

  // Récupérer les publications par catégorie
  Future<List<ForumPost>> getPostsByCategory(ForumCategory category) async {
    final posts = await getAllPosts();
    return posts.where((p) => p.category == category).toList();
  }

  // Récupérer les publications d'un auteur
  Future<List<ForumPost>> getPostsByAuthor(String authorId) async {
    final posts = await getAllPosts();
    return posts.where((p) => p.authorId == authorId).toList();
  }

  // Récupérer une publication par ID
  Future<ForumPost?> getPostById(String postId) async {
    try {
      final posts = await getAllPosts();
      return posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
  }

  // Liker/Unliker une publication
  Future<bool> togglePostLike(String postId, String userId) async {
    try {
      final data = await _storage.readJson('forum.json');
      final posts = (data['posts'] as List? ?? [])
          .map((p) => ForumPost.fromJson(p))
          .toList();

      final postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return false;

      final post = posts[postIndex];
      final likes = List<String>.from(post.likes);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      posts[postIndex] = post.copyWith(
        likes: likes,
        updatedAt: DateTime.now(),
      );

      data['posts'] = posts.map((p) => p.toJson()).toList();
      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors du like de la publication: $e');
      return false;
    }
  }

  // Mettre à jour une publication
  Future<bool> updatePost(ForumPost post) async {
    try {
      final data = await _storage.readJson('forum.json');
      final posts = (data['posts'] as List? ?? [])
          .map((p) => ForumPost.fromJson(p))
          .toList();

      final postIndex = posts.indexWhere((p) => p.id == post.id);
      if (postIndex == -1) return false;

      posts[postIndex] = post.copyWith(updatedAt: DateTime.now());
      data['posts'] = posts.map((p) => p.toJson()).toList();

      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors de la mise à jour de la publication: $e');
      return false;
    }
  }

  // Supprimer une publication
  Future<bool> deletePost(String postId) async {
    try {
      final data = await _storage.readJson('forum.json');
      
      // Supprimer la publication
      final posts = (data['posts'] as List? ?? [])
          .map((p) => ForumPost.fromJson(p))
          .toList();
      posts.removeWhere((p) => p.id == postId);
      data['posts'] = posts.map((p) => p.toJson()).toList();

      // Supprimer les commentaires associés
      final comments = (data['comments'] as List? ?? [])
          .map((c) => ForumComment.fromJson(c))
          .toList();
      comments.removeWhere((c) => c.postId == postId);
      data['comments'] = comments.map((c) => c.toJson()).toList();

      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors de la suppression de la publication: $e');
      return false;
    }
  }

  // Ajouter un commentaire
  Future<bool> addComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    try {
      final comment = ForumComment(
        id: _uuid.v4(),
        postId: postId,
        authorId: authorId,
        content: content,
        likes: [],
        createdAt: DateTime.now(),
      );

      final data = await _storage.readJson('forum.json');
      final comments = (data['comments'] as List? ?? [])
          .map((c) => ForumComment.fromJson(c))
          .toList();
      
      comments.add(comment);
      data['comments'] = comments.map((c) => c.toJson()).toList();

      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      return false;
    }
  }

  // Récupérer les commentaires d'une publication
  Future<List<ForumComment>> getPostComments(String postId) async {
    try {
      final data = await _storage.readJson('forum.json');
      final comments = (data['comments'] as List? ?? [])
          .map((c) => ForumComment.fromJson(c))
          .toList();

      return comments
          .where((c) => c.postId == postId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      print('Erreur lors de la récupération des commentaires: $e');
      return [];
    }
  }

  // Liker/Unliker un commentaire
  Future<bool> toggleCommentLike(String commentId, String userId) async {
    try {
      final data = await _storage.readJson('forum.json');
      final comments = (data['comments'] as List? ?? [])
          .map((c) => ForumComment.fromJson(c))
          .toList();

      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) return false;

      final comment = comments[commentIndex];
      final likes = List<String>.from(comment.likes);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      comments[commentIndex] = ForumComment(
        id: comment.id,
        postId: comment.postId,
        authorId: comment.authorId,
        content: comment.content,
        likes: likes,
        createdAt: comment.createdAt,
      );

      data['comments'] = comments.map((c) => c.toJson()).toList();
      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors du like du commentaire: $e');
      return false;
    }
  }

  // Supprimer un commentaire
  Future<bool> deleteComment(String commentId) async {
    try {
      final data = await _storage.readJson('forum.json');
      final comments = (data['comments'] as List? ?? [])
          .map((c) => ForumComment.fromJson(c))
          .toList();

      comments.removeWhere((c) => c.id == commentId);
      data['comments'] = comments.map((c) => c.toJson()).toList();

      return await _storage.writeJson('forum.json', data);
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
      return false;
    }
  }
}
