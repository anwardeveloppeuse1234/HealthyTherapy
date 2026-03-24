/*
===========================================================
=                USERS MANAGEMENT SCREEN                  =
===========================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final AuthService _authService = AuthService();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  UserRole? _filterRole;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final users = await _authService.getAllUsers();

    setState(() {
      _users = users;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    var filtered = _users;

    if (_filterRole != null) {
      filtered = filtered.where((u) => u.role == _filterRole).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((u) {
        return u.fullName.toLowerCase().contains(searchQuery) ||
            u.email.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  Future<void> _toggleUserStatus(User user) async {
    final newStatus = !user.isActive;
    final updatedUser = user.copyWith(isActive: newStatus);

    final success = await _authService.updateUser(updatedUser);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Utilisateur activé' : 'Utilisateur désactivé',
          ),
          backgroundColor: AppConstants.successColor,
        ),
      );
      _loadUsers();
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer l\'utilisateur ${user.fullName} ?',
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
      final success = await _authService.deleteUser(user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur supprimé'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        _loadUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        actions: [
          PopupMenuButton<UserRole?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (role) {
              setState(() {
                _filterRole = role;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tous les rôles'),
              ),
              ...UserRole.values.map((role) => PopupMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last.toUpperCase()),
                  )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email...',
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

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.people,
                  label: 'Total',
                  value: _users.length.toString(),
                  color: AppConstants.primaryColor,
                ),
                _StatCard(
                  icon: Icons.person,
                  label: 'Patients',
                  value: _users
                      .where((u) => u.role == UserRole.patient)
                      .length
                      .toString(),
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.medical_services,
                  label: 'Professionnels',
                  value: _users
                      .where((u) => u.role == UserRole.professional)
                      .length
                      .toString(),
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text('Aucun utilisateur trouvé'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return Card(
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: user.isActive
                                      ? AppConstants.primaryColor
                                      : Colors.grey,
                                  child: Text(
                                    user.firstName[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  user.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: user.isActive
                                        ? null
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.email),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(user.role)
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadiusSmall,
                                            ),
                                          ),
                                          child: Text(
                                            user.role
                                                .toString()
                                                .split('.')
                                                .last
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: _getRoleColor(user.role),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (!user.isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppConstants.errorColor
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppConstants.borderRadiusSmall,
                                              ),
                                            ),
                                            child: const Text(
                                              'INACTIF',
                                              style: TextStyle(
                                                color: AppConstants.errorColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      AppConstants.paddingMedium,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _InfoRow(
                                          icon: Icons.phone,
                                          label: 'Téléphone',
                                          value: user.phone,
                                        ),
                                        if (user.dateOfBirth != null)
                                          _InfoRow(
                                            icon: Icons.cake,
                                            label: 'Date de naissance',
                                            value: dateFormat
                                                .format(user.dateOfBirth!),
                                          ),
                                        if (user.specialization != null)
                                          _InfoRow(
                                            icon: Icons.work,
                                            label: 'Spécialisation',
                                            value: user.specialization!,
                                          ),
                                        _InfoRow(
                                          icon: Icons.calendar_today,
                                          label: 'Inscrit le',
                                          value:
                                              dateFormat.format(user.createdAt),
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _toggleUserStatus(user),
                                              icon: Icon(
                                                user.isActive
                                                    ? Icons.block
                                                    : Icons.check_circle,
                                              ),
                                              label: Text(
                                                user.isActive
                                                    ? 'Désactiver'
                                                    : 'Activer',
                                              ),
                                            ),
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _deleteUser(user),
                                              icon: const Icon(
                                                Icons.delete,
                                                color: AppConstants.errorColor,
                                              ),
                                              label: const Text(
                                                'Supprimer',
                                                style: TextStyle(
                                                  color:
                                                      AppConstants.errorColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Colors.blue;
      case UserRole.professional:
        return Colors.green;
      case UserRole.admin:
        return Colors.purple;
    }
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

===========================================================
=                     END OF COMMENT                       =
===========================================================
*/
