import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/config.dart';

class TutorDashboard extends StatefulWidget {
  final User user;

  const TutorDashboard({super.key, required this.user});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
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
        title: Text(l10n.tutorDashboardDev),
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
        onPressed: _reviewAnteprojects,
        backgroundColor: Color(AppConfig.platformColor),
        tooltip: 'Revisar anteproyectos',
        child: const Icon(Icons.assignment, color: Colors.white),
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
        _buildAnteprojectsSection(),
        const SizedBox(height: 24),
        _buildStudentsSection(),
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
              widget.user.email?.substring(0, 1).toUpperCase() ?? 'T',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.email ?? 'Tutor',
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
                  'Rol: Tutor',
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
          'Anteproyectos Pendientes',
          '0',
          Icons.pending_actions,
          Colors.orange,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          'Estudiantes Asignados',
          '0',
          Icons.people,
          Colors.blue,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildStatCard(
          'Revisados',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Anteproyectos Pendientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAllAnteprojects,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No hay anteproyectos pendientes de revisión.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estudiantes Asignados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewAllStudents,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No tienes estudiantes asignados actualmente.',
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
            _buildInfoRow(l10n.emailLabel, widget.user.email ?? 'N/A'),
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
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al cerrar sesión: $e');
      }
    }
  }

  void _reviewAnteprojects() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Funcionalidad de revisión de anteproyectos en desarrollo',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewAllAnteprojects() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lista de anteproyectos en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewAllStudents() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lista de estudiantes en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
