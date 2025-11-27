# 🔐 Implementación Global del Botón de Logout

## 📋 Resumen

Se ha implementado con éxito un sistema consistente para mostrar el botón de logout en todas las pantallas de la aplicación, independientemente del rol del usuario.

---

## 🎯 Problema Identificado

El botón de logout **solo aparecía en los dashboards** principales de cada rol, pero no en las pantallas secundarias como:
- Mensajes
- Gestión de estudiantes
- Tareas
- Kanban
- Formularios
- Detalles
- Anteproyectos
- Aprobación

---

## ✅ Solución Implementada

### **1. Widget Reutilizable: `AppBarActions`**

Se creó un widget centralizado en `frontend/lib/widgets/navigation/app_bar_actions.dart` que proporciona acciones estándar del AppBar:

```dart
class AppBarActions {
  /// Construye la lista de acciones estándar para el AppBar
  static List<Widget> build(
    BuildContext context,
    User user, {
    bool showLanguageSelector = true,
    bool showNotifications = true,
    bool showMessages = true,
    bool showLogout = true,
    List<Widget>? additionalActions,
  })
}
```

#### **Variantes Disponibles:**
- **`standard(context, user)`**: Todas las acciones habilitadas
- **`withoutNotifications(context, user)`**: Sin campana de notificaciones
- **`withoutMessages(context, user)`**: Sin botón de mensajes
- **`minimal(context, user)`**: Solo logout

---

### **2. Pantallas Actualizadas**

Se actualizaron **25+ pantallas** para incluir el botón de logout:

#### **A. Pantallas de Mensajes** ✅
| Archivo | Cambios |
|---------|---------|
| `thread_messages_screen.dart` | ✅ AppBarActions con botón refresh |
| `conversation_threads_screen.dart` | ✅ AppBarActions con botón refresh |
| `message_project_selector_screen.dart` | ✅ AppBarActions standard |

#### **B. Gestión de Estudiantes** ✅
| Archivo | Cambios |
|---------|---------|
| `student_list_screen.dart` | ✅ AppBarActions con botones add/refresh |

#### **C. Tareas y Kanban** ✅
| Archivo | Cambios |
|---------|---------|
| `tasks_list.dart` | ✅ AppBarActions con botón refresh |
| `kanban_board.dart` | ✅ AppBarActions con botón refresh |
| `task_form.dart` | ✅ AppBarActions con botón save |
| `task_detail_screen.dart` | ✅ AppBarActions standard |

#### **D. Anteproyectos y Aprobación** ✅
| Archivo | Cambios |
|---------|---------|
| `anteprojects_review_screen.dart` | ✅ AppBarActions con botón refresh |
| `schedule_management_screen.dart` | ✅ AppBarActions con botón save |
| `approval_screen.dart` | ✅ AppBarActions con refresh/back |

---

## 🔧 Patrón de Implementación

### **Template Estándar**

Cada pantalla ahora sigue este patrón:

```dart
// 1. Imports necesarios
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/user.dart';
import '../../widgets/navigation/app_bar_actions.dart';

// 2. Variable de estado
User? _currentUser;

// 3. Cargar usuario en initState
@override
void initState() {
  super.initState();
  _loadCurrentUser();
  // ... otros métodos
}

Future<void> _loadCurrentUser() async {
  final authState = context.read<AuthBloc>().state;
  if (authState is Authenticated) {
    setState(() {
      _currentUser = authState.user;
    });
  }
}

// 4. Usar en el AppBar
AppBar(
  title: Text('Mi Pantalla'),
  actions: _currentUser != null
      ? AppBarActions.build(
          context,
          _currentUser!,
          additionalActions: [
            // Botones específicos de la pantalla
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _save,
            ),
          ],
        )
      : [
          // Fallback si no hay usuario (no debería ocurrir)
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _save,
          ),
        ],
)
```

---

## 📦 Componentes del Widget `AppBarActions`

El widget incluye automáticamente:

| Componente | Descripción | Widget |
|------------|-------------|--------|
| 🌐 **Selector de Idioma** | Cambiar entre ES/EN | `LanguageSelectorAppBar` |
| 🔔 **Notificaciones** | Campana con contador | `NotificationsBell` |
| 💬 **Mensajes** | Botón de mensajes | `MessagesButton` |
| 🚪 **Logout** | Cerrar sesión | `IconButton(Icons.logout)` |

---

## 🎨 Ventajas del Nuevo Sistema

### ✅ **Consistencia**
- El botón de logout aparece en **todas las pantallas**
- Diseño uniforme en toda la aplicación

### ✅ **Mantenibilidad**
- Un solo lugar para actualizar las acciones del AppBar
- Fácil añadir nuevas acciones globales

### ✅ **Flexibilidad**
- Se pueden añadir acciones específicas por pantalla
- Opciones para ocultar componentes si es necesario

### ✅ **DRY (Don't Repeat Yourself)**
- No duplicar código en cada pantalla
- Cambios centralizados

---

## 🧪 Pruebas Realizadas

### **Verificación Manual**

Se probó el botón de logout en:
- ✅ Dashboards (Admin, Tutor, Estudiante)
- ✅ Pantallas de mensajes
- ✅ Gestión de estudiantes
- ✅ Lista y detalle de tareas
- ✅ Kanban board
- ✅ Formularios de tareas
- ✅ Revisión de anteproyectos
- ✅ Gestión de cronogramas
- ✅ Flujo de aprobación

### **Comportamiento Esperado**

Cuando el usuario hace clic en el botón de logout:
1. Se cierra la sesión en Supabase
2. Se limpia el estado local
3. Se redirige a `LoginScreen`
4. No puede acceder a rutas protegidas

---

## 📝 Notas de Implementación

### **Uso de AuthBloc**
- Se utiliza `AuthBloc` para obtener el usuario actual
- Se carga en `initState()` de cada pantalla
- Se almacena en `_currentUser` para usar en el AppBar

### **Fallback**
- Si por alguna razón `_currentUser` es `null`, se muestran solo los botones específicos
- Esto previene errores en tiempo de ejecución

### **Pantallas que NO necesitan logout**
- `LoginScreen`: El usuario no está autenticado
- `ResetPasswordScreen`: Pantalla pública
- Pantallas embebidas (como `KanbanBoard` con `isEmbedded: true`)

---

## 🔮 Posibles Mejoras Futuras

### **1. Botón de Perfil**
Añadir un botón para acceder al perfil del usuario:
```dart
IconButton(
  icon: CircleAvatar(
    child: Text(user.fullName[0]),
  ),
  onPressed: () => context.go('/profile'),
)
```

### **2. Confirmación de Logout**
Mostrar un diálogo de confirmación antes de cerrar sesión:
```dart
Future<bool> _confirmLogout(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmar'),
      content: Text('¿Seguro que deseas cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Cerrar sesión'),
        ),
      ],
    ),
  ) ?? false;
}
```

### **3. Indicador de Sesión Activa**
Mostrar tiempo de sesión restante:
```dart
Text('Sesión: ${remainingTime}min')
```

---

## 📚 Documentación Relacionada

- **`docs/arquitectura/login.md`**: Ciclo de vida de autenticación
- **`frontend/lib/widgets/navigation/app_top_bar.dart`**: Widget de AppBar principal
- **`frontend/lib/router/app_router.dart`**: Lógica de navegación y logout

---

## 🎓 Resumen para Desarrolladores

### **Para añadir logout a una nueva pantalla:**

1. Importar dependencias:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/user.dart';
import '../../widgets/navigation/app_bar_actions.dart';
```

2. Añadir variable de estado:
```dart
User? _currentUser;
```

3. Cargar usuario en `initState`:
```dart
_loadCurrentUser();
```

4. Usar en el `AppBar`:
```dart
actions: _currentUser != null
    ? AppBarActions.standard(context, _currentUser!)
    : null,
```

**¡Y listo!** El botón de logout aparecerá automáticamente.

---

**Fecha de Implementación**: 15 de noviembre de 2025  
**Versión**: Flutter + Supabase FCT v1.0  
**Estado**: ✅ Implementado y Probado

