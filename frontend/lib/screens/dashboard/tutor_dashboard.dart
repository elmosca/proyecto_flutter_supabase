import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../blocs/approval_bloc.dart';
import '../../services/theme_service.dart';
import '../../themes/role_themes.dart';
import '../../services/user_service.dart';
import '../../services/anteprojects_service.dart';
import '../../models/anteproject.dart';
import '../approval/approval_screen.dart';
import '../anteprojects/anteprojects_review_screen.dart';
import '../student/student_list_screen.dart';
import '../../widgets/dialogs/add_students_dialog.dart';
import '../../widgets/common/language_selector.dart';
import '../../router/app_router.dart';

class TutorDashboard extends StatefulWidget {
  final User user;

  const TutorDashboard({super.key, required this.user});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  bool _isLoading = true;
  Timer? _loadingTimer;
  List<User> _students = [];
  List<Anteproject> _anteprojects = [];
  String _selectedAcademicYear = '2024-2025';
  final UserService _userService = UserService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Cargar estudiantes y anteproyectos del tutor en paralelo
      final futures = await Future.wait([
        _userService.getStudentsByTutor(widget.user.id),
        _anteprojectsService.getTutorAnteprojects(),
      ]);
      
      final students = futures[0] as List<User>;
      final anteprojects = futures[1] as List<Anteproject>;
      
      if (mounted) {
        setState(() {
          _students = students;
          _anteprojects = anteprojects;
          
          // Inicializar el año académico seleccionado si no está disponible
          final availableYears = <String>{};
          for (final student in students) {
            if (student.academicYear != null && student.academicYear!.isNotEmpty) {
              availableYears.add(student.academicYear!);
            }
          }
          for (final anteproject in anteprojects) {
            availableYears.add(anteproject.academicYear);
          }
          
          // Solo cambiar el año si no hay datos para el año actual
          if (availableYears.isNotEmpty && !availableYears.contains(_selectedAcademicYear)) {
            // Buscar el año más reciente que tenga datos
            final sortedYears = availableYears.toList()..sort((a, b) => b.compareTo(a));
            _selectedAcademicYear = sortedYears.first;
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<User> get _filteredStudents {
    return _students.where((student) {
      return student.academicYear == _selectedAcademicYear;
    }).toList();
  }

  List<Anteproject> get _pendingAnteprojects {
    return _anteprojects.where((anteproject) {
      return anteproject.status == AnteprojectStatus.submitted || 
             anteproject.status == AnteprojectStatus.underReview;
    }).toList();
  }

  List<Anteproject> get _reviewedAnteprojects {
    return _anteprojects.where((anteproject) {
      return anteproject.status == AnteprojectStatus.approved || 
             anteproject.status == AnteprojectStatus.rejected;
    }).toList();
  }

  List<String> get _availableAcademicYears {
    final years = <String>{};
    
    // Añadir años de estudiantes
    for (final student in _students) {
      if (student.academicYear != null && student.academicYear!.isNotEmpty) {
        years.add(student.academicYear!);
      }
    }
    
    // Añadir años de anteproyectos
    for (final anteproject in _anteprojects) {
      years.add(anteproject.academicYear);
    }
    
    // Si no hay años, usar el año actual por defecto
    if (years.isEmpty) {
      final currentYear = DateTime.now().year;
      years.add('$currentYear-${currentYear + 1}');
    }
    
    // Ordenar años de más reciente a más antiguo
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    return sortedYears;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(RoleThemes.getEmojiForRole(widget.user.role)),
            const SizedBox(width: 8),
            Text(l10n.tutorDashboardDev),
          ],
        ),
        backgroundColor: ThemeService.instance.currentPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          const LanguageSelectorAppBar(),
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
            onPressed: _reviewAnteprojects,
            backgroundColor: ThemeService.instance.currentAccentColor,
            tooltip: l10n.dashboardTutorMyAnteprojects,
            heroTag: 'review',
            child: const Icon(Icons.assignment, color: Colors.white),
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
        _buildStudentsSection(),
      ],
    ),
  );

  Widget _buildUserInfo() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
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
                    '${l10n.tutorRole}: ${l10n.tutor}',
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
  }

  Widget _buildStatistics() {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: l10n.pendingAnteprojects,
            value: _pendingAnteprojects.length.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            onTap: _reviewAnteprojects,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: l10n.assignedStudents,
            value: _students.length.toString(),
            icon: Icons.people,
            color: Colors.blue,
            onTap: _viewAllStudents,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: l10n.reviewed,
            value: _reviewedAnteprojects.length.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: _viewAllAnteprojects,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
      ),
    );
  }


  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.assignedStudents,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                // Filtro por año académico dinámico
                DropdownButton<String>(
                  value: _availableAcademicYears.contains(_selectedAcademicYear) 
                      ? _selectedAcademicYear 
                      : (_availableAcademicYears.isNotEmpty ? _availableAcademicYears.first : null),
                  items: _availableAcademicYears.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAcademicYear = value;
                      });
                      // Recargar datos cuando cambie el año académico
                      _loadData();
                    }
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _viewAllStudents,
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Botón principal para añadir estudiantes
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showAddStudentsDialog,
            icon: const Icon(Icons.person_add),
            label: Text(AppLocalizations.of(context)!.addStudents),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Información de estudiantes actuales
        if (_filteredStudents.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.studentsAssignedInfo(
                      _filteredStudents.length,
                      _filteredStudents.length == 1 ? '' : 's',
                      _selectedAcademicYear,
                    ),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAddStudentsDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStudentsDialog(tutorId: widget.user.id),
    ).then((_) => _loadData()); // Recargar datos al cerrar el diálogo
  }



  Future<void> _logout() async {
    try {
      // Usar el router para logout
      AppRouter.logout(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al cerrar sesión: $e');
      }
    }
  }

  void _navigateToApprovalWorkflow() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ApprovalBloc(),
          child: const ApprovalScreen(),
        ),
      ),
    );
  }

  void _reviewAnteprojects() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnteprojectsReviewScreen(initialFilter: 'pending'),
      ),
    ).then((_) => _loadData()); // Recargar datos al volver
  }

  void _viewAllAnteprojects() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnteprojectsReviewScreen(initialFilter: 'reviewed'),
      ),
    ).then((_) => _loadData()); // Recargar datos al volver
  }

  void _viewAllStudents() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentListScreen(tutorId: widget.user.id),
      ),
    ).then((_) => _loadData()); // Recargar datos al volver
  }

}
