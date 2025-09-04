import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/config.dart';
import '../../models/user.dart';
import '../../blocs/auth_bloc.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboardDev),
        backgroundColor: Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _manageUsers,
        backgroundColor: Color(AppConfig.platformColor),
        tooltip: l10n.dashboardAdminUsersManagement,
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboardContent() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 24),
        _buildStatistics(),
        const SizedBox(height: 24),
        _buildSystemSection(),
        const SizedBox(height: 24),
        _buildUsersSection(),
        const SizedBox(height: 24),
        _buildServerInfo(),
      ],
    ),
  );

  Widget _buildUserInfo() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(AppConfig.platformColor),
            child: Text(
              widget.user.email.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${widget.user.id}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Rol: Administrador',
                  style: TextStyle(
                    color: Color(AppConfig.platformColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStatistics() => Row(
    children: [
      Expanded(
        child: _buildStatCard(
          'Usuarios Totales',
          '0',
          Icons.people,
          Colors.blue,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          'Proyectos Activos',
          '0',
          Icons.work,
          Colors.green,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard('Tutores', '0', Icons.school, Colors.orange),
      ),
    ],
  );

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estado del Sistema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewSystemStatus,
              child: Text(AppLocalizations.of(context)!.viewDetails),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusRow('Base de datos', 'Operativo', Colors.green),
                _buildStatusRow('API REST', 'Operativo', Colors.green),
                _buildStatusRow('Autenticación', 'Operativo', Colors.green),
                _buildStatusRow('Almacenamiento', 'Operativo', Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String service, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service),
          Row(
            children: [
              Icon(Icons.circle, color: color, size: 12),
              const SizedBox(width: 8),
              Text(status, style: TextStyle(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAllUsers,
              child: Text(AppLocalizations.of(context)!.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Panel de administración de usuarios en desarrollo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerInfo() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  l10n.systemInfo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.backendLabel(AppConfig.supabaseUrl), ''),
            _buildInfoRow(l10n.platformLabel(AppConfig.platformName), ''),
            _buildInfoRow(l10n.versionLabel(AppConfig.appVersion), ''),
            _buildInfoRow(l10n.emailLabel, widget.user.email),
            const SizedBox(height: 8),
            Text(
              l10n.connectedToServer,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Usar nuestro AuthBloc para logout
      context.read<AuthBloc>().add(AuthLogoutRequested());
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al cerrar sesión: $e');
      }
    }
  }

  void _manageUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.userManagementInDevelopment),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewSystemStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.systemStatusInDevelopment),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewAllUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.usersListInDevelopment),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
