# 🚀 GUÍA DE INICIO RÁPIDO - FRONTEND TFG (ACTUALIZADA)
# Sistema de Seguimiento de Proyectos TFG - Flutter + Supabase

## ⚡ **INICIO RÁPIDO (30 minutos)**

### **1. Prerrequisitos**
Asegúrate de tener instalado y configurado:
```bash
flutter --version  # Flutter 3.0+ (Verificar compatibilidad con el SDK ^3.8.1)
dart --version     # Dart 3.0+
git --version      # Git
```

### **2. Clonar y Configurar**
Navega al directorio raíz del proyecto y clona el repositorio. Luego, navega al subdirectorio del frontend:
```bash
cd proyecto_flutter_supabase
git checkout develop # Asegúrate de estar en la rama funcional
cd frontend
flutter pub get      # Instalar todas las dependencias
```

### **3. Configuración de Supabase (Claves de Producción)**
El proyecto utiliza las claves de producción de Supabase definidas en `frontend/lib/config/app_config.dart`.

| Variable | Valor | Uso |
| :--- | :--- | :--- |
| `supabaseUrl` | `https://TU_PROYECTO_ID.supabase.co` | URL del proyecto Supabase. |
| `supabaseAnonKey` | `TU_ANON_KEY_AQUI` | Clave pública de Supabase. |
| `githubGuidesBaseUrl` | `.../develop/docs/guias_usuario` | Base para cargar guías de usuario dinámicamente. |

**Nota Importante:** El código está configurado para cargar guías de usuario desde la rama `develop` de GitHub. Si se desea cambiar la fuente, modificar la variable `githubGuidesBaseUrl` en `app_config.dart`.

### **4. Ejecutar y Probar Multiplataforma**

El proyecto está optimizado para múltiples plataformas, con especial atención a la versión Web.

#### **A. Versión Web (Recomendada para Desarrollo)**
La versión web utiliza `usePathUrlStrategy()` para URLs limpias (sin `#`).

```bash
# Ejecutar en Web
flutter run -d chrome
```
**Verificación:** Accede a la URL en el navegador. Las rutas como `/reset-password` deben funcionar sin el símbolo `#`.

#### **B. Versión Móvil/Escritorio**
```bash
# Ejecutar en Android
flutter run -d android

# Ejecutar en Linux (o Windows/macOS si están configurados)
flutter run -d linux
```

### **5. Lógica de Plataforma y Deep Links**

El código utiliza `kIsWeb` para diferenciar la lógica entre Web y otras plataformas:

*   **Web:** Se utiliza la URL del navegador para manejar el flujo de restablecimiento de contraseña (ej. `https://tfg.app/reset-password?code=...`).
*   **Móvil/Escritorio:** Se utiliza el servicio `DeepLinkService` y el esquema `tfgapp://` para manejar enlaces de restablecimiento de contraseña (ej. `tfgapp://reset-password?code=...`).

**Archivos Clave:**
*   `frontend/lib/main.dart`: Inicializa `usePathUrlStrategy()` y el servicio de Deep Links (solo si `!kIsWeb`).
*   `frontend/lib/services/deep_link_service.dart`: Implementa la lógica de escucha de enlaces, pero está **deshabilitado** si `kIsWeb` es verdadero.

### **6. Credenciales de Prueba**
Las credenciales de prueba están centralizadas en `frontend/lib/config/app_config.dart` y utilizan el dominio `jualas.es`.

| Rol | Email | Contraseña |
| :--- | :--- | :--- |
| **Estudiante** | `laura.sanchez@jualas.es` | `EzmvfdQmijMa` |
| **Tutor** | `jualas@jualas.es` | `password123` |
| **Administrador** | `admin@jualas.es` | `password123` |

---

## ⚙️ ESTRUCTURA DE CÓDIGO Y ARQUITECTURA

### **Gestión de Estado (BLoC)**
El proyecto utiliza el patrón BLoC (Business Logic Component) para la gestión de estado, con los siguientes BLoCs principales:
*   `AuthBloc`: Maneja el estado de autenticación y el perfil del usuario.
*   `AnteprojectsBloc`: Gestiona la lógica de los anteproyectos.
*   `TasksBloc`: Gestiona la lógica de las tareas.

### **Servicios Clave**
*   `AuthService`: Encapsula el inicio/cierre de sesión, la obtención del perfil (`getCurrentUserProfile`) y la lógica de roles.
*   `DeepLinkService`: Maneja los enlaces externos, crucial para el flujo de restablecimiento de contraseña en plataformas que no son web.

### **Lógica de Roles**
La lógica de roles se define en `AuthService` y se basa en la tabla `users` de Supabase.
*   El rol `admin` se asigna explícitamente si el email es `admin@jualas.es` (línea 249 de `auth_service.dart`).
*   Los demás roles (`tutor`, `student`) se obtienen del campo `role` de la tabla `users`.

### **Flujo de Restablecimiento de Contraseña (Web)**
1.  El usuario solicita restablecer la contraseña.
2.  Supabase envía un email con un enlace que redirige a la URL base de la aplicación (Web).
3.  `main.dart` utiliza `Uri.base.path` para detectar si la ruta contiene `/reset-password`.
4.  Si se detecta, se omite la verificación de autenticación y se utiliza `AppRouter.router.go` para navegar a la pantalla de restablecimiento de contraseña, pasando los parámetros `code` y `type` de la URL.
5.  La pantalla de restablecimiento utiliza estos parámetros para completar el proceso con Supabase.

**Esta guía reemplaza la documentación anterior y refleja el estado actual del código en la rama `develop`.**

