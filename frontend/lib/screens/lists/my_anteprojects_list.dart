import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/anteproject.dart';
import '../../models/user.dart';
import '../../services/anteprojects_service.dart';
import '../../services/projects_service.dart';
import '../../services/settings_service.dart';
import '../../services/academic_permissions_service.dart';
import '../anteprojects/anteproject_detail_screen.dart';
import '../forms/anteproject_form.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/read_only_banner.dart';

class MyAnteprojectsList extends StatefulWidget {
  final User? user;

  const MyAnteprojectsList({super.key, this.user});

  @override
  State<MyAnteprojectsList> createState() => _MyAnteprojectsListState();
}

class _MyAnteprojectsListState extends State<MyAnteprojectsList> {
  late AnteprojectsService _anteprojectsService;
  final SettingsService _settingsService = SettingsService();
  final AcademicPermissionsService _academicPermissionsService = AcademicPermissionsService();
  late Future<List<Anteproject>> _anteprojectsFuture;
  int _refreshKey = 0;
  List<Anteproject>? _cachedAnteprojects; // Cache para actualización optimista
  bool? _hasApprovedAnteproject; // null = cargando, true/false = resultado
  bool? _hasDraftAnteproject; // null = cargando, true/false = resultado
  bool? _isWrongAcademicYear; // null = cargando, true/false = resultado
  bool _isReadOnly = false; // Modo solo lectura para años académicos anteriores
  User? _currentUser; // Usuario actualizado con academicYear

  @override
  void initState() {
    super.initState();
    _anteprojectsService = AnteprojectsService();
    debugPrint(
      '🎯 MyAnteprojectsList: initState - Iniciando carga de anteproyectos',
    );
    _loadAnteprojects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar cada vez que volvemos a esta pantalla
    debugPrint(
      '🎯 MyAnteprojectsList: didChangeDependencies - Recargando datos',
    );
    _loadAnteprojects();
  }

  void _loadAnteprojects() {
    if (widget.user != null) {
      debugPrint(
        '🎯 MyAnteprojectsList: Usuario pasado como parámetro: ${widget.user!.email}',
      );
      setState(() {
        _refreshKey++; // Incrementar key para forzar reconstrucción del FutureBuilder
        _cachedAnteprojects = null; // Limpiar cache al recargar
        _anteprojectsFuture = _anteprojectsService.getStudentAnteprojects();
        _hasApprovedAnteproject = null; // Resetear estado
      });
      _checkRestrictions();
    } else {
      // Fallback al AuthBloc si no se pasa usuario
      final authState = context.read<AuthBloc>().state;
      debugPrint('🎯 MyAnteprojectsList: AuthState actual: $authState');

      if (authState is AuthAuthenticated) {
        debugPrint(
          '🎯 MyAnteprojectsList: Usuario autenticado: ${authState.user.email}',
        );
        debugPrint(
          '🎯 MyAnteprojectsList: ID del usuario: ${authState.user.id}',
        );
        setState(() {
          _refreshKey++; // Incrementar key para forzar reconstrucción del FutureBuilder
          _cachedAnteprojects = null; // Limpiar cache al recargar
          _anteprojectsFuture = _anteprojectsService.getStudentAnteprojects();
          _hasApprovedAnteproject = null; // Resetear estado
        });
        _checkRestrictions();
      } else {
        debugPrint(
          '❌ MyAnteprojectsList: Usuario NO autenticado, authState: ${authState.runtimeType}',
        );
        setState(() {
          _refreshKey++; // Incrementar key para forzar reconstrucción del FutureBuilder
          _cachedAnteprojects = null; // Limpiar cache al recargar
          _anteprojectsFuture = Future.error('Usuario no autenticado');
          _hasApprovedAnteproject = false;
        });
      }
    }
  }

  Future<void> _checkRestrictions() async {
    try {
      // Obtener el usuario más actualizado posible
      // Prioridad: 1) AuthBloc (puede tener datos más frescos), 2) widget.user
      User? currentUser = widget.user;
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Si el AuthBloc tiene el academicYear y widget.user no, usar AuthBloc
        if ((currentUser?.academicYear == null || currentUser!.academicYear!.isEmpty) &&
            authState.user.academicYear != null && 
            authState.user.academicYear!.isNotEmpty) {
          currentUser = authState.user;
          debugPrint('🔄 MyAnteprojectsList: Usando usuario del AuthBloc con academicYear: ${currentUser.academicYear}');
        }
      }
      
      // Guardar referencia al usuario actualizado para el banner
      _currentUser = currentUser;
      
      // Verificar todas las restricciones en paralelo
      final results = await Future.wait([
        _anteprojectsService.hasApprovedAnteproject(),
        _anteprojectsService.hasDraftAnteproject(),
        _settingsService.getStringSetting('academic_year'),
      ]);
      
      final hasApproved = results[0] as bool;
      final hasDraft = results[1] as bool;
      final activeAcademicYear = results[2] as String?;
      
      // Verificar año académico - solo marcar como incorrecto si el usuario tiene año asignado
      bool wrongAcademicYear = false;
      if (activeAcademicYear != null && 
          activeAcademicYear.isNotEmpty &&
          currentUser?.academicYear != null &&
          currentUser!.academicYear!.isNotEmpty &&
          currentUser.academicYear != activeAcademicYear) {
        wrongAcademicYear = true;
      }
      
      // Verificar si está en modo solo lectura usando el servicio
      // Solo si el usuario tiene academicYear definido
      bool isReadOnly = false;
      if (currentUser != null && 
          currentUser.academicYear != null && 
          currentUser.academicYear!.isNotEmpty) {
        isReadOnly = await _academicPermissionsService.isReadOnly(currentUser);
      }
      
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = hasApproved;
          _hasDraftAnteproject = hasDraft;
          _isWrongAcademicYear = wrongAcademicYear;
          _isReadOnly = isReadOnly;
        });
      }
    } catch (e) {
      debugPrint('Error al verificar restricciones de anteproyecto: $e');
      if (mounted) {
        setState(() {
          _hasApprovedAnteproject = false; // En caso de error, permitir crear
          _hasDraftAnteproject = false;
          _isWrongAcademicYear = false;
          _isReadOnly = false;
        });
      }
    }
  }

  void _loadAndNavigateToProject(
    BuildContext context,
    Anteproject anteproject,
  ) {
    // Si el anteproyecto no tiene projectId, mostrar directamente el anteproyecto
    if (anteproject.projectId == null) {
      debugPrint(
        '🎯 MyAnteprojectsList: Anteproyecto aprobado sin proyecto asociado, mostrando anteproyecto en modo solo lectura',
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              AnteprojectDetailScreen(anteproject: anteproject, project: null),
        ),
      );
      return;
    }

    // Intentar cargar el proyecto, pero si falla, mostrar el anteproyecto igualmente
    final projectsService = ProjectsService();
    projectsService
        .getProject(anteproject.projectId!)
        .then((project) {
          // Si el proyecto existe, mostrar con ambos (anteproject y project)
          // Si no existe, mostrar solo el anteproyecto (modo solo lectura)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnteprojectDetailScreen(
                anteproject: anteproject,
                project: project, // Puede ser null
              ),
            ),
          );
        })
        .catchError((error) {
          debugPrint(
            '⚠️ MyAnteprojectsList: Error al cargar el proyecto, mostrando anteproyecto en modo solo lectura: $error',
          );
          // Aun así, mostrar el anteproyecto en modo solo lectura
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnteprojectDetailScreen(
                anteproject: anteproject,
                project: null,
              ),
            ),
          );
        });
  }

  Future<void> _navigateToCreateAnteproject(BuildContext context) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      
      // Verificar si el estudiante está en el año académico activo
      if (_isWrongAcademicYear == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotCreateAnteprojectWrongAcademicYear),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // Verificar si el estudiante ya tiene un anteproyecto aprobado
      final hasApproved = _hasApprovedAnteproject ?? 
          await _anteprojectsService.hasApprovedAnteproject();
      
      if (hasApproved) {
        // Buscar el anteproyecto aprobado
        final anteprojects = _cachedAnteprojects ?? 
            await _anteprojectsService.getStudentAnteprojects();
        final approvedAnteproject = anteprojects.firstWhere(
          (ap) => ap.status == AnteprojectStatus.approved,
          orElse: () => anteprojects.first,
        );
        
        // Mostrar SnackBar con mensaje
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotCreateAnteprojectWithApproved),
              duration: const Duration(seconds: 5),
            ),
          );
          
          // Navegar al proyecto o anteproyecto aprobado
          if (approvedAnteproject.projectId != null) {
            Navigator.of(context).pushNamed(
              '/projects/${approvedAnteproject.projectId}',
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AnteprojectDetailScreen(
                  anteproject: approvedAnteproject,
                  project: null,
                ),
              ),
            );
          }
        }
        return;
      }
      
      // Verificar si el estudiante ya tiene un borrador
      final hasDraft = _hasDraftAnteproject ?? 
          await _anteprojectsService.hasDraftAnteproject();
      
      if (hasDraft) {
        // Buscar el borrador existente
        final anteprojects = _cachedAnteprojects ?? 
            await _anteprojectsService.getStudentAnteprojects();
        final draftAnteproject = anteprojects.firstWhere(
          (ap) => ap.status == AnteprojectStatus.draft,
          orElse: () => anteprojects.first,
        );
        
        // Mostrar SnackBar con mensaje
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotCreateAnteprojectWithDraft),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: l10n.goToDraft,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AnteprojectDetailScreen(
                        anteproject: draftAnteproject,
                        project: null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return;
      }
      
      // Si no tiene restricciones, navegar al formulario de creación
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AnteprojectForm(),
            ),
          ).then((_) {
            // Recargar la lista al volver
            _loadAnteprojects();
          });
      }
    } catch (e) {
      debugPrint('Error al verificar restricciones de anteproyecto: $e');
      // Si hay error, permitir navegar de todas formas
      // El servicio lanzará la excepción si realmente hay restricciones
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AnteprojectForm(),
          ),
        ).then((_) {
          // Recargar la lista al volver
          _loadAnteprojects();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final listContent = FutureBuilder<List<Anteproject>>(
        key: ValueKey<int>(_refreshKey),
        future: _anteprojectsFuture,
        builder: (context, snapshot) {
          debugPrint(
            '🎯 MyAnteprojectsList: FutureBuilder estado: ${snapshot.connectionState}',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('🎯 MyAnteprojectsList: Cargando...');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('❌ MyAnteprojectsList: Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAnteprojects,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('🎯 MyAnteprojectsList: Sin anteproyectos');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes anteproyectos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer anteproyecto para comenzar',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<bool>(
                    future: _anteprojectsService.hasApprovedAnteproject(),
                    builder: (context, snapshot) {
                      final hasApproved = snapshot.data ?? false;
                      if (hasApproved) {
                        return Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.orange[300],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.cannotCreateAnteprojectWithApproved,
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }
                      return ElevatedButton.icon(
                        onPressed: () => _navigateToCreateAnteproject(context),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.anteprojectFormTitle),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          // Usar cache si está disponible, sino usar datos del snapshot
          final anteprojects = _cachedAnteprojects ?? snapshot.data!;
          debugPrint(
            '🎯 MyAnteprojectsList: Mostrando ${anteprojects.length} anteproyectos',
          );
          for (final ap in anteprojects) {
            debugPrint('🎯 MyAnteprojectsList: - ${ap.title} (ID: ${ap.id})');
          }
          
          // Actualizar cache con los datos del snapshot
          if (snapshot.hasData && _cachedAnteprojects == null) {
            _cachedAnteprojects = snapshot.data;
          }

        return RefreshIndicator(
          onRefresh: () async {
            debugPrint(
              '🎯 MyAnteprojectsList: Refrescando por pull-to-refresh',
            );
            _loadAnteprojects();
            // Esperar a que se cargue
            await _anteprojectsFuture;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: anteprojects.length,
            itemBuilder: (context, index) {
              final anteproject = anteprojects[index];
              final isApproved = anteproject.status.isApproved;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.description,
                    color: isApproved ? Colors.green : Colors.blue,
                  ),
                  title: Text(anteproject.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(anteproject.status.displayName),
                      if (isApproved && anteproject.projectId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Proyecto: #${anteproject.projectId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de eliminar (solo para borradores)
                      // Botón de eliminar solo para borradores y si no está en modo solo lectura
                      if (anteproject.status == AnteprojectStatus.draft && !_isReadOnly)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(anteproject),
                          tooltip: 'Eliminar anteproyecto',
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
                        ),
                      // Icono de estado o flecha
                      isApproved
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward),
                    ],
                  ),
                  onTap: () {
                    if (isApproved) {
                      debugPrint(
                        '🎯 Anteproyecto aprobado, cargando proyecto ${anteproject.projectId}',
                      );
                      _loadAndNavigateToProject(context, anteproject);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AnteprojectDetailScreen(anteproject: anteproject),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
        },
    );
    
    // Envolver con banner de solo lectura si aplica
    // Solo mostrar si _isReadOnly Y el usuario tiene academicYear definido
    final showReadOnlyBanner = _isReadOnly && 
        _currentUser?.academicYear != null && 
        _currentUser!.academicYear!.isNotEmpty;
    
    final body = showReadOnlyBanner
        ? Column(
            children: [
              ReadOnlyBanner(
                academicYear: _currentUser?.academicYear ?? '',
              ),
              Expanded(child: listContent),
            ],
          )
        : listContent;
    
    return Scaffold(
      body: body,
      floatingActionButton: (_hasApprovedAnteproject == true || _hasDraftAnteproject == true || _isWrongAcademicYear == true || _isReadOnly)
          ? null // Ocultar botón si hay restricciones o modo solo lectura
          : FloatingActionButton.extended(
              onPressed: () => _navigateToCreateAnteproject(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.anteprojectFormTitle),
              tooltip: l10n.anteprojectFormTitle,
            ),
    );
  }

  void _showDeleteDialog(Anteproject anteproject) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.anteprojectDeleteTitle),
          content: Text(
            '¿Estás seguro de que quieres eliminar el anteproyecto "${anteproject.title}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Actualizar optimísticamente la lista inmediatamente
                _optimisticDelete(anteproject);
                // Luego hacer la eliminación real
                _deleteAnteproject(anteproject);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.anteprojectDeleteButton),
            ),
          ],
        );
      },
    );
  }

  void _optimisticDelete(Anteproject anteproject) {
    // Remover el anteproyecto de la lista cacheada inmediatamente
    if (_cachedAnteprojects != null) {
      setState(() {
        _cachedAnteprojects = _cachedAnteprojects!
            .where((ap) => ap.id != anteproject.id)
            .toList();
      });
    }
  }

  Future<void> _deleteAnteproject(Anteproject anteproject) async {
    try {
      await _anteprojectsService.deleteAnteproject(anteproject.id);
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.anteprojectDeletedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiar cache y recargar la lista para sincronizar con el servidor
        setState(() {
          _cachedAnteprojects = null;
        });
        _loadAnteprojects();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingAnteproject(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
        
        // Si hay error, restaurar la lista desde el servidor
        setState(() {
          _cachedAnteprojects = null;
        });
        _loadAnteprojects();
      }
    }
  }
}
