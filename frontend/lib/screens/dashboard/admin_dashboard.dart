import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';
import '../../services/admin_stats_service.dart';
import '../../themes/role_themes.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/navigation/app_side_drawer.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  final AdminStatsRepository statsService;
  final bool useOwnScaffold;

  AdminDashboard({
    super.key,
    required this.user,
    AdminStatsRepository? statsService,
    this.useOwnScaffold = true,
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
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboardContent();

    if (!widget.useOwnScaffold) {
      return body;
    }

    return Scaffold(
      appBar: AppTopBar(user: widget.user, titleKey: 'dashboardAdmin'),
      drawer: AppSideDrawer(user: widget.user),
      body: body,
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

  Widget _buildUserInfo() {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(AppConfig.platformColor),
              child: Text(
                widget.user.email.substring(0, 1).toUpperCase(),
                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.email,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${widget.user.id}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(AppConfig.platformColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(AppConfig.platformColor).withOpacity(0.5),
                            ),
                          ),
                        child: Text(
                          l10n.administrator,
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(AppConfig.platformColor),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ),
                        if (widget.user.academicYear != null &&
                            widget.user.academicYear!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                              ),
                            ),
                          child: Text(
                            l10n.courseYear(widget.user.academicYear!),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                title: l10n.configuration,
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
    final textTheme = Theme.of(context).textTheme;

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
                style: textTheme.labelSmall?.copyWith(
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
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.systemStatus,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _viewSystemStatus,
              child: Text(l10n.viewDetails),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusRow(l10n.databaseService, l10n.operational, Colors.green),
                _buildStatusRow(l10n.apiRestService, l10n.operational, Colors.green),
                _buildStatusRow(l10n.authenticationService, l10n.operational, Colors.green),
                _buildStatusRow(l10n.storageService, l10n.operational, Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String service, String status, Color color) {
    final textTheme = Theme.of(context).textTheme;

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
              Text(status, style: textTheme.bodyMedium?.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupabaseSection() {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.supabaseStudio,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
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
                Text(
                  'URL: ${AppConfig.supabaseStudioUrl}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardAdminUsersManagement,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...(_recentUsers.take(5).map(_buildUserPreview)),
      ],
    );
  }

  Widget _buildUserPreview(User user) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.email.substring(0, 1).toUpperCase(),
            style: textTheme.headlineSmall?.copyWith(
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
    return RoleThemes.getPrimaryColorForRole(role);
  }

  IconData _getRoleIcon(UserRole role) {
    return RoleThemes.getIconForRole(role);
  }

  String _getRoleDisplayName(UserRole role) {
    return role.displayName;
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dialogL10n.systemStatus),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRow(dialogL10n.databaseService, dialogL10n.operational, Colors.green),
              _buildStatusRow(dialogL10n.apiRestService, dialogL10n.operational, Colors.green),
              _buildStatusRow(dialogL10n.authenticationService, dialogL10n.operational, Colors.green),
              _buildStatusRow(dialogL10n.storageService, dialogL10n.operational, Colors.green),
              const SizedBox(height: 16),
              Text(
                dialogL10n.lastUpdateTime(DateTime.now().toString().substring(0, 19)),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(dialogL10n.close),
            ),
          ],
        );
      },
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
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(user.email),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dialogL10n.roleLabel(_getRoleDisplayName(user.role))),
              Text(dialogL10n.idLabel(user.id.toString())),
              Text(dialogL10n.createdLabel(user.createdAt.toString().substring(0, 19))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(dialogL10n.close),
            ),
          ],
        );
      },
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
              content: Text(AppLocalizations.of(context)!.couldNotOpenUrl(url.toString())),
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
            content: Text(AppLocalizations.of(context)!.errorOpeningUrl(e.toString())),
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
              content: Text(AppLocalizations.of(context)!.couldNotOpenUrl(url.toString())),
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
            content: Text(AppLocalizations.of(context)!.errorOpeningUrl(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
