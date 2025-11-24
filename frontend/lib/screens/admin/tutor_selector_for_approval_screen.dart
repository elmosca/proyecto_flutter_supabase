import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../services/user_management_service.dart';
import '../../blocs/approval_bloc.dart';
import '../../screens/approval/approval_screen.dart';

/// Pantalla para que el administrador seleccione un tutor
/// y luego visualice su flujo de aprobación.
class TutorSelectorForApprovalScreen extends StatefulWidget {
  final User adminUser;

  const TutorSelectorForApprovalScreen({super.key, required this.adminUser});

  @override
  State<TutorSelectorForApprovalScreen> createState() =>
      _TutorSelectorForApprovalScreenState();
}

class _TutorSelectorForApprovalScreenState
    extends State<TutorSelectorForApprovalScreen> {
  final UserManagementService _service = UserManagementService();
  List<User> _tutors = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      developer.log('🔍 [TutorSelector] Iniciando carga de tutores...', name: 'TutorSelector');
      final tutors = await _service.getTutors();
      developer.log('✅ [TutorSelector] Tutores cargados: ${tutors.length}', name: 'TutorSelector');
      
      if (mounted) {
        setState(() {
          _tutors = tutors;
          _loading = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('❌ [TutorSelector] Error cargando tutores: $e', name: 'TutorSelector', error: e, stackTrace: stackTrace);
      developer.log('📍 Stack trace: $stackTrace', name: 'TutorSelector');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Error cargando tutores: $e';
          _loading = false;
        });
        
        // Mostrar el error también en un SnackBar para que el usuario lo vea
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _selectTutor(User tutor) {
    developer.log('✅ [TutorSelector] Tutor seleccionado: ${tutor.fullName} (ID: ${tutor.id})', name: 'TutorSelector');
    
    // Usar GoRouter para navegar (navegación declarativa)
    // Necesitamos pasar tanto el admin como el tutor seleccionado
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PersistentScaffold(
          title: 'Flujo de Aprobación',
          titleKey: 'approvalWorkflow',
          user: widget.adminUser,
          body: BlocProvider<ApprovalBloc>(
            create: (_) =>
                ApprovalBloc()..add(LoadPendingApprovals(tutorId: tutor.id)),
            child: ApprovalScreen(
              selectedTutorId: tutor.id,
              showBackButton: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentScaffold(
      title: 'Seleccionar Tutor',
      titleKey: 'approvalWorkflow',
      user: widget.adminUser,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTutors,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _tutors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay tutores disponibles',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : _buildTutorsList(),
    );
  }

  Widget _buildTutorsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Selecciona un tutor para ver su flujo de aprobación:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tutors.length,
            itemBuilder: (context, index) {
              final tutor = _tutors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.school, color: Colors.blue.shade700),
                  ),
                  title: Text(
                    tutor.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tutor.email),
                      if (tutor.specialty != null &&
                          tutor.specialty!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            tutor.specialty!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  onTap: () => _selectTutor(tutor),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
