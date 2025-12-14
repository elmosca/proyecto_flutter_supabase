import 'package:flutter/material.dart';
import 'dart:async'; // Para StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/project.dart';
import '../../models/anteproject.dart';
import '../../models/conversation_thread.dart';
import '../../models/user.dart';
import '../../services/conversation_threads_service.dart';
import '../../services/anteprojects_service.dart';
import '../../services/academic_permissions_service.dart';
import '../../services/user_service.dart';
import '../../widgets/navigation/app_bar_actions.dart';
import '../../widgets/common/read_only_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_exception.dart';
import 'thread_messages_screen.dart';
import 'create_thread_dialog.dart';

/// Pantalla que muestra la lista de hilos/temas de conversación
/// de un proyecto o anteproyecto específico
class ConversationThreadsScreen extends StatefulWidget {
  final Project? project;
  final Anteproject? anteproject;
  /// Si es false, no usa Scaffold propio (para usar con PersistentScaffold)
  final bool useOwnScaffold;
  /// Si es true, indica que el tutor está viendo datos históricos (año académico pasado)
  /// y no puede crear nuevos temas ni enviar mensajes
  final bool isHistoricalView;

  const ConversationThreadsScreen({
    super.key,
    this.project,
    this.anteproject,
    this.useOwnScaffold = true,
    this.isHistoricalView = false,
  }) : assert(
          project != null || anteproject != null,
          'Debe proporcionar un proyecto o anteproyecto',
        );

  @override
  State<ConversationThreadsScreen> createState() =>
      _ConversationThreadsScreenState();
}

class _ConversationThreadsScreenState extends State<ConversationThreadsScreen> {
  final ConversationThreadsService _threadsService =
      ConversationThreadsService();
  final AnteprojectsService _anteprojectsService = AnteprojectsService();
  final AcademicPermissionsService _academicPermissionsService =
      AcademicPermissionsService();
  final UserService _userService = UserService();

  List<ConversationThread> _threads = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;
  bool? _hasApprovedAnteproject; // null = cargando, true/false = resultado
  bool? _isReadOnly; // null = verificando, true/false = resultado
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Suscribirse a cambios del AuthBloc para mantener el usuario actualizado
    _authSubscription = context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthAuthenticated && mounted) {
        if (_currentUser != state.user) {
          debugPrint('🔄 ConversationThreadsScreen: Usuario actualizado desde AuthBloc');
          setState(() {
            _currentUser = state.user;
          });
          _checkReadOnlyStatus(state.user);
        }
      }
    });

    _loadCurrentUser();
    _loadThreads();
    _checkApprovedAnteproject();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkApprovedAnteproject() async {
    // Solo verificar si es un anteproyecto
    if (widget.anteproject != null) {
      try {
        final hasApproved = await _anteprojectsService.hasApprovedAnteproject();
        if (mounted) {
          setState(() {
            _hasApprovedAnteproject = hasApproved;
          });
        }
      } catch (e) {
        debugPrint('Error al verificar anteproyecto aprobado: $e');
        if (mounted) {
          setState(() {
            _hasApprovedAnteproject = false; // En caso de error, permitir intentar
          });
        }
      }
    } else {
      // Si es un proyecto, no hay restricción
      _hasApprovedAnteproject = false;
    }
  }

  Future<void> _loadCurrentUser() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      setState(() {
        _currentUser = user;
      });
      await _checkReadOnlyStatus(user);
    }
  }

  Future<void> _checkReadOnlyStatus(User user) async {
    if (user.role == UserRole.student) {
      // Si el año académico es nulo o vacío, intentar recargarlo desde la API
      if (user.academicYear == null || user.academicYear!.isEmpty) {
        debugPrint('⚠️ ConversationThreads: Usuario sin año académico, intentando recargar desde API...');
        try {
          final refreshedUser = await _userService.getUserById(user.id);
          if (refreshedUser != null && mounted) {
            debugPrint('✅ Usuario recargado con año académico: ${refreshedUser.academicYear}');
            // Actualizar el usuario local y el AuthBloc
            setState(() {
              _currentUser = refreshedUser;
            });
            context.read<AuthBloc>().add(AuthUserChanged(user: refreshedUser));
            // Ahora verificar permisos con el usuario completo
            if (refreshedUser.academicYear != null && refreshedUser.academicYear!.isNotEmpty) {
              final isReadOnly = await _academicPermissionsService.isReadOnly(refreshedUser);
              if (mounted) {
                setState(() {
                  _isReadOnly = isReadOnly;
                });
              }
            }
          } else {
            debugPrint('❌ No se pudo recargar el usuario');
          }
        } catch (e) {
          debugPrint('❌ Error al recargar usuario: $e');
        }
        return; 
      }

      final isReadOnly = await _academicPermissionsService.isReadOnly(user);
      if (mounted) {
        setState(() {
          _isReadOnly = isReadOnly;
        });
      }
    } else {
      // Tutores y admins nunca están en modo solo lectura
      if (mounted) {
        setState(() {
          _isReadOnly = false;
        });
      }
    }
  }

  /// Determina si se debe ocultar el botón de crear nuevo tema
  bool _shouldHideCreateButton() {
    // Ocultar si no hay usuario cargado todavía
    if (_currentUser == null) {
      return true;
    }
    
    // Ocultar si es vista histórica (tutor viendo año pasado)
    if (widget.isHistoricalView) {
      return true;
    }
    
    // Ocultar si es estudiante y aún no se ha verificado el estado de solo lectura
    if (_currentUser?.role == UserRole.student && _isReadOnly == null) {
      return true;
    }
    // Ocultar si está en modo solo lectura
    if (_isReadOnly == true) {
      return true;
    }
    // Ocultar si hay anteproyecto aprobado
    if (widget.anteproject != null && (_hasApprovedAnteproject ?? false)) {
      return true;
    }
    return false;
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<ConversationThread> threads;
      
      if (widget.project != null) {
        threads = await _threadsService.getProjectThreads(widget.project!.id);
      } else {
        threads =
            await _threadsService.getAnteprojectThreads(widget.anteproject!.id);
      }

      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar hilos: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.errorLoadingConversations(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewThread() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Verificar si es vista histórica (tutor viendo año pasado)
    if (widget.isHistoricalView) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotPerformActionReadOnly),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Verificar si está en modo solo lectura
    if (_isReadOnly == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotPerformActionReadOnly),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Verificar si hay anteproyecto aprobado antes de permitir crear hilo
    if (widget.anteproject != null && (_hasApprovedAnteproject ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotCreateThreadWithApprovedAnteproject),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final title = await showDialog<String>(
      context: context,
      builder: (context) => const CreateThreadDialog(),
    );

    if (title != null && title.trim().isNotEmpty) {
      try {
        setState(() => _isLoading = true);

        final thread = await _threadsService.createThread(
          projectId: widget.project?.id,
          anteprojectId: widget.anteproject?.id,
          title: title.trim(),
        );

        if (mounted) {
          // Abrir el nuevo hilo automáticamente
          _openThread(thread);
          // Recargar la lista
          _loadThreads();
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          // Verificar si es el error específico de anteproyecto aprobado
          if (e is ValidationException && 
              (e.code == 'cannot_create_thread_with_approved_anteproject' ||
               e.toString().contains('cannot_create_thread_with_approved_anteproject'))) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.cannotCreateThreadWithApprovedAnteproject),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorLoadingConversations(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _openThread(ConversationThread thread) {
    if (_currentUser == null) return;

    // Navegación simplificada: directamente a ThreadMessagesScreen
    // ThreadMessagesScreen gestiona su propio Scaffold cuando useOwnScaffold es true
    // Esto evita el anidamiento de PersistentScaffold que causa AppBars duplicadas
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreadMessagesScreen(
          thread: thread,
          project: widget.project,
          anteproject: widget.anteproject,
          useOwnScaffold: true, // Esta pantalla ahora gestiona su propio Scaffold
          isHistoricalView: widget.isHistoricalView,
        ),
      ),
    ).then((_) {
      // Recargar al volver para actualizar contadores
      _loadThreads();
    });
  }

  Widget _buildBody() {
    final textTheme = Theme.of(context).textTheme;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? _buildErrorState()
            : _threads.isEmpty
                ? _buildEmptyState()
                : _buildThreadsList();

    // Mostrar banner de solo lectura si aplica (estudiante en año pasado)
    if (_isReadOnly == true && _currentUser?.role == UserRole.student) {
      return Column(
        children: [
          ReadOnlyBanner(academicYear: _currentUser?.academicYear ?? ''),
          Expanded(child: content),
        ],
      );
    }

    // Mostrar banner para vista histórica (tutor viendo año pasado)
    if (widget.isHistoricalView) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modo solo lectura: Visualizando conversaciones históricas.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = widget.project != null
        ? widget.project!.title
        : widget.anteproject!.title;

    // Para tutores, siempre usar verde. Para estudiantes, usar verde para proyectos y azul para anteproyectos
    final color = _currentUser?.role == UserRole.tutor 
        ? Colors.green 
        : (widget.project != null ? Colors.green : Colors.blue);

    if (!widget.useOwnScaffold) {
      // Cuando se usa dentro de PersistentScaffold, solo retornar el body
      return Stack(
        children: [
          _buildBody(),
          Positioned(
            bottom: 16,
            right: 16,
            // Ocultar si hay anteproyecto aprobado, está en modo solo lectura, o aún se está verificando
            child: _shouldHideCreateButton()
                ? const SizedBox.shrink()
                : FloatingActionButton.extended(
                    onPressed: _createNewThread,
              backgroundColor: color,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newTopic),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.conversations),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: _currentUser != null
            ? AppBarActions.build(
                context,
                _currentUser!,
                additionalActions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadThreads,
                    tooltip: AppLocalizations.of(context)!.update,
                  ),
                ],
              )
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadThreads,
                  tooltip: AppLocalizations.of(context)!.update,
                ),
              ],
      ),
      body: _buildBody(),
      // Ocultar FAB si hay anteproyecto aprobado, está en modo solo lectura, o aún se está verificando
      floatingActionButton: _shouldHideCreateButton()
          ? null
          : FloatingActionButton.extended(
        onPressed: _createNewThread,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tema'),
      ),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
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
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadThreads,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noConversationsYet,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createNewTopicToStart,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.useButtonBelow,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _threads.length,
      itemBuilder: (context, index) {
        final thread = _threads[index];
        return _buildThreadCard(thread);
      },
    );
  }

  Widget _buildThreadCard(ConversationThread thread) {
    final hasUnread = (thread.unreadCount ?? 0) > 0;
    // Para tutores, siempre usar verde. Para estudiantes, usar verde para proyectos y azul para anteproyectos
    final color = _currentUser?.role == UserRole.tutor 
        ? Colors.green 
        : (widget.project != null ? Colors.green : Colors.blue);
    
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasUnread ? 4 : 2,
      child: InkWell(
        onTap: () => _openThread(thread),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.forum,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      thread.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Fecha último mensaje
                    Text(
                      _formatDate(context, thread.lastMessageAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge de no leídos y flecha
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${thread.unreadCount}',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return l10n.agoDaysShort(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.agoHoursShort(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.agoMinutesShort(difference.inMinutes);
    } else {
      return l10n.now;
    }
  }
}
