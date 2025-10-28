import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';
import '../../themes/role_themes.dart';
import '../../widgets/navigation/app_top_bar.dart';
import '../../widgets/navigation/app_side_drawer.dart';

class StudentDashboardScreen extends StatefulWidget {
  final User user;

  const StudentDashboardScreen({super.key, required this.user});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String? _guideText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGuide();
  }

  Future<void> _loadGuide() async {
    final locale = Localizations.localeOf(context).languageCode;
    final path = locale == 'en'
        ? 'assets/help/student_guide_en.md'
        : 'assets/help/student_guide_es.md';
    try {
      final text = await rootBundle.loadString(path);
      if (mounted) {
        setState(() => _guideText = text);
      }
    } catch (_) {
      if (mounted) setState(() => _guideText = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(user: widget.user, titleKey: 'dashboardStudent'),
      drawer: AppSideDrawer(user: widget.user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalInfoCard(l10n),
            const SizedBox(height: 24),
            _buildUsageGuideCard(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(AppLocalizations l10n) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: ThemeService.instance.currentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      RoleThemes.getEmojiForRole(widget.user.role),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.user.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${l10n.role}: ${l10n.studentRole}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageGuideCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  l10n.getStarted,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_guideText == null)
              Text(
                l10n.getStartedDescription,
                style: TextStyle(color: Colors.grey.shade700),
              )
            else
              Text(_guideText!, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
