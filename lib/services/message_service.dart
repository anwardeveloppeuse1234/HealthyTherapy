import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import 'storage_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  // StreamController pour le chat en temps réel
  final _messagesController = StreamController<List<Message>>.broadcast();
  Stream<List<Message>> get messagesStream => _messagesController.stream;

  Timer? _pollingTimer;

  // Démarrer le polling pour le temps réel
  void startRealtimePolling(String conversationId, {Duration interval = const Duration(seconds: 2)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) async {
      final messages = await getConversationMessages(conversationId);
      _messagesController.add(messages);
    });
  }

  // Arrêter le polling
  void stopRealtimePolling() {
    _pollingTimer?.cancel();
  }

  // Créer ou récupérer une conversation
  Future<Conversation?> getOrCreateConversation(
    String userId1,
    String userId2,
  ) async {
    try {
      final data = await _storage.readJson('messages.json');
      final conversations = (data['conversations'] as List? ?? [])
          .map((c) => Conversation.fromJson(c))
          .toList();

      // Chercher une conversation existante
      try {
        return conversations.firstWhere((c) {
          return c.participants.contains(userId1) &&
              c.participants.contains(userId2);
        });
      } catch (e) {
        // Créer une nouvelle conversation
        final conversation = Conversation(
          id: _uuid.v4(),
          participants: [userId1, userId2],
          unreadCount: {userId1: 0, userId2: 0},
          createdAt: DateTime.now(),
        );

        conversations.add(conversation);
        data['conversations'] = conversations.map((c) => c.toJson()).toList();
        await _storage.writeJson('messages.json', data);

        return conversation;
      }
    } catch (e) {
      print('Erreur lors de la création de la conversation: $e');
      return null;
    }
  }

  // Récupérer toutes les conversations d'un utilisateur
  Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      final data = await _storage.readJson('messages.json');
      final conversations = (data['conversations'] as List? ?? [])
          .map((c) => Conversation.fromJson(c))
          .toList();

      return conversations
          .where((c) => c.participants.contains(userId))
          .toList()
        ..sort((a, b) {
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });
    } catch (e) {
      print('Erreur lors de la récupération des conversations: $e');
      return [];
    }
  }

  // Envoyer un message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    try {
      final message = Message(
        id: _uuid.v4(),
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        mediaUrl: mediaUrl,
        read: false,
        sentAt: DateTime.now(),
      );

      final data = await _storage.readJson('messages.json');
      
      // Ajouter le message
      final messages = (data['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList();
      messages.add(message);
      data['messages'] = messages.map((m) => m.toJson()).toList();

      // Mettre à jour la conversation
      final conversations = (data['conversations'] as List? ?? [])
          .map((c) => Conversation.fromJson(c))
          .toList();
      
      final convIndex = conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        final conv = conversations[convIndex];
        final unreadCount = Map<String, int>.from(conv.unreadCount);
        unreadCount[receiverId] = (unreadCount[receiverId] ?? 0) + 1;

        conversations[convIndex] = conv.copyWith(
          lastMessage: content,
          lastMessageTime: DateTime.now(),
          unreadCount: unreadCount,
        );
      }

      data['conversations'] = conversations.map((c) => c.toJson()).toList();
      
      final success = await _storage.writeJson('messages.json', data);
      
      // Notifier les listeners
      if (success) {
        final updatedMessages = await getConversationMessages(conversationId);
        _messagesController.add(updatedMessages);
      }
      
      return success;
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      return false;
    }
  }

  // Récupérer les messages d'une conversation
  Future<List<Message>> getConversationMessages(String conversationId) async {
    try {
      final data = await _storage.readJson('messages.json');
      final messages = (data['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList();

      return messages
          .where((m) => m.conversationId == conversationId)
          .toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    } catch (e) {
      print('Erreur lors de la récupération des messages: $e');
      return [];
    }
  }

  // Marquer les messages comme lus
  Future<bool> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      final data = await _storage.readJson('messages.json');
      
      // Marquer les messages comme lus
      final messages = (data['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList();

      for (var i = 0; i < messages.length; i++) {
        if (messages[i].conversationId == conversationId &&
            messages[i].receiverId == userId &&
            !messages[i].read) {
          messages[i] = messages[i].copyWith(read: true);
        }
      }

      data['messages'] = messages.map((m) => m.toJson()).toList();

      // Réinitialiser le compteur de non-lus
      final conversations = (data['conversations'] as List? ?? [])
          .map((c) => Conversation.fromJson(c))
          .toList();

      final convIndex = conversations.indexWhere((c) => c.id == conversationId);
      if (convIndex != -1) {
        final conv = conversations[convIndex];
        final unreadCount = Map<String, int>.from(conv.unreadCount);
        unreadCount[userId] = 0;

        conversations[convIndex] = conv.copyWith(unreadCount: unreadCount);
      }

      data['conversations'] = conversations.map((c) => c.toJson()).toList();

      return await _storage.writeJson('messages.json', data);
    } catch (e) {
      print('Erreur lors du marquage des messages comme lus: $e');
      return false;
    }
  }

  // Obtenir le nombre de messages non lus
  Future<int> getUnreadCount(String userId) async {
    try {
      final conversations = await getUserConversations(userId);
      int total = 0;
      for (final conv in conversations) {
        total += conv.unreadCount[userId] ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // Supprimer un message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final data = await _storage.readJson('messages.json');
      final messages = (data['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList();

      messages.removeWhere((m) => m.id == messageId);
      data['messages'] = messages.map((m) => m.toJson()).toList();

      return await _storage.writeJson('messages.json', data);
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      return false;
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _messagesController.close();
  }
}
