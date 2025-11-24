import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';
import '../../services/admin_stats_service.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/navigation/app_side_drawer.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  final AdminStatsRepository statsService;

  AdminDashboard({
    super.key,
    required this.user,
    AdminStatsRepository? statsService,
  }) : statsService = statsService ?? AdminStatsService();

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;

  // Datos del dashboard
  AdminStats? _stats;
  List<User> _recentUsers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Cargar datos en paralelo
      final futures = await Future.wait([
        widget.statsService.getSystemStats(),
        widget.statsService.getRecentUsers(),
      ]);

      if (mounted) {
        setState(() {
          _stats = futures[0] as AdminStats;
          _recentUsers = futures[1] as List<User>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al cargar datos del admin dashboard: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(user: widget.user, titleKey: 'dashboardAdmin'),
      drawer: AppSideDrawer(user: widget.user),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _navigateToApprovalWorkflow,
            backgroundColor: ThemeService.instance.currentPrimaryColor,
            tooltip: l10n.approvalWorkflow,
            heroTag: 'approval',
            child: const Icon(Icons.gavel, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _manageUsers,
            backgroundColor: ThemeService.instance.currentAccentColor,
            tooltip: l10n.dashboardAdminUsersManagement,
            heroTag: 'users',
            child: const Icon(Icons.people_alt, color: Colors.white),
          ),
        ],
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
        _buildQuickAccessSection(),
        const SizedBox(height: 24),
        _buildSystemSection(),
        const SizedBox(height: 24),
        _buildSupabaseSection(),
        const SizedBox(height: 24),
        _buildUsersSection(),
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
            backgroundColor: const Color(AppConfig.platformColor),
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
                const Text(
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

  Widget _buildStatistics() {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.totalUsers,
            _stats?.totalUsers.toString() ?? '0',
            Icons.people,
            Colors.blue,
            onTap: _viewAllUsers,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            l10n.activeProjects,
            _stats?.activeAnteprojects.toString() ?? '0',
            Icons.work,
            Colors.green,
            onTap: _viewAllAnteprojects,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            l10n.tutors,
            _stats?.totalTutors.toString() ?? '0',
            Icons.school,
            Colors.orange,
            onTap: _viewAllTutors,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos Rápidos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                title: l10n.dashboardAdminUsersManagement,
                icon: Icons.people_alt,
                color: Colors.blue,
                onTap: _manageUsers,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAccessCard(
                title: l10n.approvalWorkflow,
                icon: Icons.gavel,
                color: Colors.orange,
                onTap: _navigateToApprovalWorkflow,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAccessCard(
                title: 'Configuración',
                icon: Icons.settings,
                color: Colors.green,
                onTap: _navigateToSettings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

  Widget _buildSupabaseSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.supabaseStudio,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.supabaseStudioDescription,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openSupabaseStudio,
                        icon: const Icon(Icons.storage),
                        label: Text(l10n.openSupabaseStudio),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openInbucket,
                        icon: const Icon(Icons.email),
                        label: Text(l10n.openInbucket),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'URL: ${AppConfig.supabaseStudioUrl}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardAdminUsersManagement,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: _viewAllUsers, child: Text(l10n.viewAll)),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentUsers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noUsers,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...(_recentUsers.take(5).map(_buildUserPreview)),
      ],
    );
  }

  Widget _buildUserPreview(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.email.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.email),
        subtitle: Text(_getRoleDisplayName(user.role)),
        trailing: Icon(
          _getRoleIcon(user.role),
          color: _getRoleColor(user.role),
        ),
        onTap: () => _viewUserDetails(user),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.tutor:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.tutor:
        return Icons.school;
      case UserRole.student:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.student:
        return 'Estudiante';
    }
  }

  // Logout ahora gestionado por AppTopBar

  void _manageUsers() {
    context.go('/admin/users', extra: widget.user);
  }

  void _navigateToApprovalWorkflow() {
    context.go('/admin/approval-workflow', extra: widget.user);
  }

  void _navigateToSettings() {
    context.go('/admin/settings', extra: widget.user);
  }

  void _viewSystemStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.systemStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow('Base de datos', 'Operativo', Colors.green),
            _buildStatusRow('API REST', 'Operativo', Colors.green),
            _buildStatusRow('Autenticación', 'Operativo', Colors.green),
            _buildStatusRow('Almacenamiento', 'Operativo', Colors.green),
            const SizedBox(height: 16),
            Text(
              'Última actualización: ${DateTime.now().toString().substring(0, 19)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _viewAllUsers() {
    context.go('/admin/users', extra: widget.user);
  }

  void _viewAllAnteprojects() {
    // Navegar a la pantalla de anteproyectos (filtrada para admin)
    context.go('/anteprojects', extra: widget.user);
  }

  void _viewAllTutors() {
    // Los tutores se pueden ver desde la gestión de usuarios con filtro
    context.go('/admin/users', extra: widget.user);
  }

  void _viewUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.email),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rol: ${_getRoleDisplayName(user.role)}'),
            Text('ID: ${user.id}'),
            Text('Creado: ${user.createdAt.toString().substring(0, 19)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Future<void> _openSupabaseStudio() async {
    final Uri url = Uri.parse(AppConfig.supabaseStudioUrl);

    // Debug: Mostrar información del entorno y URL
    debugPrint('🔧 Debug - Entorno detectado: ${AppConfig.environment}');
    debugPrint(
      '🔧 Debug - URL Supabase Studio: ${AppConfig.supabaseStudioUrl}',
    );
    debugPrint('🔧 Debug - URL completa: $url');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('✅ Supabase Studio abierto exitosamente');
      } else {
        debugPrint('❌ No se pudo abrir Supabase Studio: $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir Supabase Studio: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error al abrir Supabase Studio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir Supabase Studio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInbucket() async {
    final Uri url = Uri.parse(AppConfig.inbucketUrl);

    // Debug: Mostrar información del entorno y URL
    debugPrint('🔧 Debug - Entorno detectado: ${AppConfig.environment}');
    debugPrint('🔧 Debug - URL Inbucket/Resend: ${AppConfig.inbucketUrl}');
    debugPrint('🔧 Debug - URL completa: $url');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('✅ Inbucket/Resend abierto exitosamente');
      } else {
        debugPrint('❌ No se pudo abrir Inbucket/Resend: $url');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir Inbucket/Resend: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error al abrir Inbucket/Resend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir Inbucket/Resend: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
