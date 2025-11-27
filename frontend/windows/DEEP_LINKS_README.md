# Deep Links en Windows - Recuperación de Contraseña

Este documento explica cómo funcionan los deep links (`tfgapp://`) en la aplicación Windows para permitir la recuperación de contraseña desde emails.

## 🔧 Configuración Inicial

### 1. Compilar la aplicación

Primero, compila la aplicación para generar el ejecutable:

```powershell
cd frontend
flutter build windows --debug
```

O para versión Release:

```powershell
flutter build windows --release
```

### 2. Registrar el protocolo `tfgapp://`

Ejecuta el script de registro desde PowerShell:

```powershell
# Para Debug
cd frontend/windows
.\register_deep_link.ps1 -BuildType Debug

# Para Release
.\register_deep_link.ps1 -BuildType Release
```

El script registrará el protocolo `tfgapp://` en el registro de Windows (HKEY_CURRENT_USER), permitiendo que Windows abra la aplicación cuando se haga clic en enlaces como `tfgapp://reset-password?code=...`.

## 📧 Flujo de Recuperación de Contraseña

### 1. Usuario solicita recuperación

El usuario hace clic en "¿Olvidaste tu contraseña?" en la pantalla de login.

### 2. App envía email

La aplicación llama a `AuthService.resetPasswordForEmail(email)` que:
- En **web**: Genera URL → `https://tuapp.com/reset-password?code=...`
- En **desktop**: Genera URL → `tfgapp://reset-password?code=...&type=reset`

### 3. Usuario recibe email

Supabase envía un email con un enlace que contiene el código de recuperación.

### 4. Usuario hace clic en el enlace

- **Windows detecta** el protocolo `tfgapp://`
- **Abre la aplicación** automáticamente
- **Pasa los parámetros** (code, type) a la app

### 5. App procesa el deep link

```dart
// En main.dart
_deepLinkService.onLinkReceived = (Uri uri) {
  if (uri.host == 'reset-password') {
    final code = uri.queryParameters['code'];
    final type = uri.queryParameters['type'];
    
    // Navegar a la pantalla de reset
    AppRouter.router.go('/reset-password', extra: {
      'code': code,
      'type': type,
    });
  }
};
```

### 6. Usuario cambia su contraseña

La aplicación muestra el formulario de cambio de contraseña ya autenticado con el código recibido.

## 🧪 Probar Deep Links

### Desde PowerShell

```powershell
# Probar enlace de reset de contraseña
Start-Process 'tfgapp://reset-password?code=test123&type=reset'

# Probar enlace simple
Start-Process 'tfgapp://test'
```

### Desde navegador

Crea un archivo HTML de prueba:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Prueba Deep Link</title>
</head>
<body>
    <h1>Probar Deep Links</h1>
    <a href="tfgapp://reset-password?code=test123&type=reset">
        Abrir App - Reset Password
    </a>
</body>
</html>
```

Ábrelo en un navegador y haz clic en el enlace.

## 📝 Configuración de Supabase

### Configurar redirect URLs

En el panel de Supabase, agrega las URLs de redirección:

1. Ve a **Authentication > URL Configuration**
2. Agrega en **Redirect URLs**:
   ```
   tfgapp://reset-password
   tfgapp://login
   ```

## 🐛 Troubleshooting

### El enlace no abre la aplicación

1. **Verifica el registro**:
   ```powershell
   Get-ItemProperty "HKCU:\Software\Classes\tfgapp\shell\open\command"
   ```

2. **Re-registra el protocolo**:
   ```powershell
   .\register_deep_link.ps1 -BuildType Debug
   ```

3. **Verifica que el ejecutable existe**:
   ```powershell
   Test-Path "build\windows\x64\runner\Debug\frontend.exe"
   ```

### La app se abre pero no navega

1. **Verifica los logs** en la consola de Flutter
2. **Asegúrate** de que el servicio de deep links está inicializado:
   ```dart
   await _deepLinkService.initialize();
   ```

### Error "Protocol not registered"

Ejecuta el script de registro como administrador:
```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-File register_deep_link.ps1 -BuildType Debug"
```

## 🔒 Seguridad

- Los códigos de recuperación **expiran** después de 1 hora (configurable en Supabase)
- Los códigos son **de un solo uso**
- La aplicación **valida** el código con Supabase antes de permitir el cambio
- El protocolo `tfgapp://` solo puede ser registrado por una aplicación a la vez

## 📚 Referencias

- [app_links package](https://pub.dev/packages/app_links)
- [Supabase Auth - Password Recovery](https://supabase.com/docs/guides/auth/passwords)
- [Windows URL Protocol](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/aa767914(v=vs.85))

