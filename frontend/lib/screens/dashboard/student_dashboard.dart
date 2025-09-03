import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/config.dart';
import '../../models/user.dart';
import '../../blocs/auth_bloc.dart';

class StudentDashboard extends StatefulWidget {
  final User user;

  const StudentDashboard({super.key, required this.user});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simular carga de datos
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
        title: Text(l10n.dashboardStudent),
        backgroundColor: Color(AppConfig.platformColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAnteproject,
        backgroundColor: Color(AppConfig.platformColor),
        tooltip: 'Crear anteproyecto',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboardContent() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del usuario
        _buildUserInfo(),
        const SizedBox(height: 24),

        // Resumen de estadísticas
        _buildStatistics(),
        const SizedBox(height: 24),

        // Anteproyectos
        _buildAnteprojectsSection(),
        const SizedBox(height: 24),

        // Tareas pendientes
        _buildTasksSection(),
        const SizedBox(height: 24),

        // Información del servidor
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
                  'Rol: Estudiante',
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
          'Anteproyectos',
          '0',
          Icons.description,
          Colors.blue,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          'Tareas Pendientes',
          '0',
          Icons.pending,
          Colors.orange,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          'Completadas',
          '0',
          Icons.check_circle,
          Colors.green,
        ),
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

  Widget _buildAnteprojectsSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myAnteprojects,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAllAnteprojects,
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.noAnteprojects,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.pendingTasks,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAllTasks,
              child: Text(l10n.viewAllTasks),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.noPendingTasks,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
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

  void _createAnteproject() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.anteprojectsDev),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewAllAnteprojects() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.anteprojectsListDev),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewAllTasks() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.tasksListDev),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
