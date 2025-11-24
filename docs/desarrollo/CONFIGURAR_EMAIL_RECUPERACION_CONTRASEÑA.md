# Configurar Email de Recuperación de Contraseña

## 🐛 Problema

Al hacer clic en el enlace "🔒 Restablecer mi contraseña" del email, el usuario es redirigido al login en lugar de a la pantalla de cambio de contraseña.

## 🔍 Causa

El enlace `{{ .ConfirmationURL }}` de Supabase está usando la URL base incorrecta o no está configurado para redirigir a `/reset-password`.

## ✅ Solución

### Paso 1: Configurar URLs en Supabase

1. **Ve a:** Supabase Dashboard → Authentication → URL Configuration

2. **Site URL:** Configura tu URL principal
   ```
   https://fct.jualas.es
   ```

3. **Redirect URLs:** Añade estas URLs permitidas:
   ```
   https://fct.jualas.es/**
   https://fct.jualas.es/reset-password
   https://fct.jualas.es/reset-password?type=reset
   http://localhost:8082/**
   http://localhost:8082/reset-password
   ```

4. **Guarda** los cambios

### Paso 2: Actualizar el Email de Recuperación en Supabase

1. **Ve a:** Authentication → Email Templates → **Reset Password** (o "Change Email Address")

2. **Actualiza la plantilla HTML** para que sea más clara:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Restablecer Contraseña</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333333;
      background-color: #f4f4f4;
      margin: 0;
      padding: 0;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 8px;
      overflow: hidden;
    }
    .header {
      background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
      color: #ffffff;
      padding: 30px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 600;
    }
    .content {
      padding: 30px 20px;
    }
    .button-container {
      text-align: center;
      margin: 30px 0;
    }
    .button {
      display: inline-block;
      background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
      color: #ffffff;
      padding: 14px 28px;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      font-size: 16px;
      box-shadow: 0 4px 6px rgba(33, 150, 243, 0.3);
    }
    .warning-box {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 25px 0;
      border-radius: 4px;
    }
    .info-box {
      background-color: #e7f3ff;
      border-left: 4px solid #2196F3;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .footer {
      background-color: #f8f9fa;
      padding: 20px;
      text-align: center;
      font-size: 12px;
      color: #999999;
      border-top: 1px solid #e9ecef;
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🔒 Restablecer Contraseña</h1>
    </div>
    
    <div class="content">
      <p>Hola{{ if .Data.full_name }} <strong>{{ .Data.full_name }}</strong>{{ else if .Email }} <strong>{{ .Email }}</strong>{{ end }},</p>
      
      <p>Recibimos una solicitud para restablecer la contraseña de tu cuenta en el <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.</p>
      
      <div class="button-container">
        <a href="{{ .ConfirmationURL }}" class="button">🔒 Restablecer mi contraseña</a>
      </div>
      
      <div class="info-box">
        <strong>📝 Qué pasará al hacer clic:</strong>
        <p>1. Serás redirigido a una página segura</p>
        <p>2. Podrás ingresar tu nueva contraseña</p>
        <p>3. Deberás confirmar la contraseña ingresándola de nuevo</p>
        <p>4. Tu contraseña será actualizada inmediatamente</p>
      </div>
      
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul style="margin: 10px 0; padding-left: 20px;">
          <li>Este enlace expira en <strong>1 hora</strong> por seguridad</li>
          <li>Si no solicitaste este cambio, puedes ignorar este email</li>
          <li>Tu contraseña actual seguirá siendo válida si no haces clic en el enlace</li>
        </ul>
      </div>
      
      <p style="font-size: 14px; color: #666;">Si tienes problemas con el enlace, copia y pega esta URL en tu navegador:</p>
      <p style="font-size: 12px; color: #999; word-break: break-all;">{{ .ConfirmationURL }}</p>
    </div>
    
    <div class="footer">
      <p><strong>Sistema de Gestión de Proyectos TFG</strong></p>
      <p>CIFP Carlos III</p>
      <p>Este es un email automático, por favor no respondas.</p>
    </div>
  </div>
</body>
</html>
```

### Paso 3: Verificar la Configuración de redirectTo en AuthService

Revisa que tu `AuthService.resetPasswordForEmail` esté pasando el `redirectTo` correcto:

```dart
Future<void> resetPasswordForEmail(String email) async {
  try {
    final baseUrl = Uri.base.origin; // O usa 'https://fct.jualas.es'
    final redirectTo = '$baseUrl/reset-password?type=reset';
    
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  } catch (e) {
    // manejo de errores
  }
}
```

## 🧪 Probar el Flujo Completo

### 1. Solicitar Recuperación de Contraseña

1. Ve al login
2. Haz clic en "¿Olvidaste tu contraseña?"
3. Introduce el email
4. Envía la solicitud

### 2. Verificar el Email

Deberías recibir un email con:
- ✅ Botón "🔒 Restablecer mi contraseña"
- ✅ Instrucciones claras
- ✅ Advertencia de que expira en 1 hora
- ✅ URL completa al final (por si el botón no funciona)

### 3. Hacer Clic en el Enlace

Al hacer clic, deberías:
- ✅ Ser redirigido a `https://fct.jualas.es/reset-password?type=reset&token=...`
- ✅ Ver un formulario para ingresar la nueva contraseña
- ✅ Poder confirmar la contraseña
- ✅ Recibir confirmación de que la contraseña fue cambiada

## 🔍 Troubleshooting

### Problema: Sigo siendo redirigido al login

**Causa:** La URL de redirect no está en la lista de Redirect URLs permitidas.

**Solución:** Verifica que `https://fct.jualas.es/reset-password` esté en las Redirect URLs de Supabase.

### Problema: El enlace muestra "otp_expired"

**Causa:** El enlace expiró (1 hora) o ya fue usado.

**Solución:** Solicita un nuevo enlace de recuperación.

### Problema: Error "access_denied"

**Causa:** La URL de Site no coincide con tu dominio.

**Solución:** Configura Site URL en Supabase como `https://fct.jualas.es`

## 📝 Checklist de Configuración

- [ ] Site URL en Supabase: `https://fct.jualas.es`
- [ ] Redirect URLs incluyen: `https://fct.jualas.es/reset-password`
- [ ] Plantilla de email actualizada en Supabase
- [ ] `redirectTo` en `AuthService` usa la URL correcta
- [ ] Ruta `/reset-password` existe en el router (ya existe ✅)
- [ ] `ResetPasswordScreen` procesa el token correctamente (ya lo hace ✅)

## 🎯 Resultado Esperado

```
Usuario solicita recuperación
    ↓
Email enviado con enlace
    ↓
Usuario hace clic en el enlace
    ↓
Redirigido a: https://fct.jualas.es/reset-password?type=reset&token=...
    ↓
ResetPasswordScreen procesa el token
    ↓
Muestra formulario de nueva contraseña
    ↓
Usuario ingresa y confirma nueva contraseña
    ↓
Contraseña actualizada en Supabase Auth
    ↓
Usuario redirigido al login
    ↓
Usuario inicia sesión con nueva contraseña
    ↓
✅ Acceso exitoso
```

