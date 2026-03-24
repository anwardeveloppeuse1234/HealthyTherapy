import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessageService _messageService = MessageService();
  final AuthService _authService = AuthService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser!.id;

    final conversations = await _messageService.getUserConversations(userId);

    setState(() {
      _conversations = conversations;
      _isLoading = false;
    });
  }

  Future<User?> _getOtherUser(Conversation conversation) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser!.id;

    final otherUserId = conversation.participants.firstWhere(
      (id) => id != currentUserId,
    );

    return await _authService.getUserById(otherUserId);
  }

  Future<void> _startNewConversation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser!;

    // Récupérer la liste des utilisateurs selon le rôle
    List<User> users;
    if (currentUser.role == UserRole.patient) {
      users = await _authService.getProfessionals();
    } else {
      users = await _authService.getPatients();
    }

    if (!mounted) return;

    final selectedUser = await showDialog<User>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Nouvelle conversation'),
        children: users.map((user) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(user),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.firstName[0]),
              ),
              title: Text(user.fullName),
              subtitle: Text(user.role == UserRole.professional
                  ? user.specialization ?? 'Professionnel'
                  : 'Patient'),
            ),
          );
        }).toList(),
      ),
    );

    if (selectedUser != null && mounted) {
      final conversation = await _messageService.getOrCreateConversation(
        currentUser.id,
        selectedUser.id,
      );

      if (conversation != null && mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversation: conversation,
              otherUser: selectedUser,
            ),
          ),
        );

        if (result == true) {
          _loadConversations();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Aucune conversation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Commencez une nouvelle conversation',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return FutureBuilder<User?>(
                        future: _getOtherUser(conversation),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final otherUser = snapshot.data!;
                          final unreadCount =
                              conversation.unreadCount[currentUserId] ?? 0;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppConstants.primaryColor,
                              child: Text(
                                otherUser.firstName[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              otherUser.fullName,
                              style: TextStyle(
                                fontWeight: unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              conversation.lastMessage ?? 'Aucun message',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (conversation.lastMessageTime != null)
                                  Text(
                                    DateFormat('HH:mm')
                                        .format(conversation.lastMessageTime!),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    conversation: conversation,
                                    otherUser: otherUser,
                                  ),
                                ),
                              );

                              if (result == true) {
                                _loadConversations();
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        child: const Icon(Icons.add),
      ),
    );
  }
}
