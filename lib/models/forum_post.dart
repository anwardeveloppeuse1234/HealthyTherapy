class ForumPost {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final ForumCategory category;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.category,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'content': content,
      'category': category.toString().split('.').last,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      authorId: json['authorId'],
      title: json['title'],
      content: json['content'],
      category: ForumCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      likes: List<String>.from(json['likes'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  ForumPost copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    ForumCategory? category,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForumPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ForumComment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final List<String> likes;
  final DateTime createdAt;

  ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.likes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'],
      postId: json['postId'],
      authorId: json['authorId'],
      content: json['content'],
      likes: List<String>.from(json['likes'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum ForumCategory {
  general,
  tips,
  support,
  questions,
}

extension ForumCategoryExtension on ForumCategory {
  String get displayName {
    switch (this) {
      case ForumCategory.general:
        return 'Général';
      case ForumCategory.tips:
        return 'Conseils';
      case ForumCategory.support:
        return 'Soutien';
      case ForumCategory.questions:
        return 'Questions';
    }
  }
}
