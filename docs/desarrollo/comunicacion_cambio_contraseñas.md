# 📧 Comunicación de Cambios de Contraseña

## 📋 Resumen

Este documento explica cómo se comunica a los usuarios (estudiantes, tutores y administradores) cuando se realizan cambios de contraseña en el sistema.

---

## 🎯 Situación Actual

### ✅ Implementado

1. **Notificación interna al estudiante**:
   - Cuando un tutor/admin resetea la contraseña de un estudiante
   - Tipo: `system_notification`
   - Contenido: Incluye la nueva contraseña
   - Dónde se ve: Campana de notificaciones (🔔) en la aplicación

### ❌ No Implementado (Pendiente)

1. **Email al estudiante**: No se envía email automáticamente
2. **Notificación al tutor/admin**: No se notifica al tutor/admin que debe realizar el cambio
3. **Registro de cambios**: No hay historial de quién cambió qué contraseña y cuándo

---

## 🔄 Flujos de Comunicación

### Flujo 1: Tutor/Admin Resetea Contraseña de Estudiante

**Situación actual**:
1. Tutor/Admin resetea la contraseña desde la aplicación
2. Se crea una notificación interna para el estudiante
3. El estudiante ve la notificación cuando inicia sesión

**Mejora propuesta**:
1. Tutor/Admin resetea la contraseña
2. Se crea notificación interna para el estudiante ✅ (implementado)
3. Se envía email al estudiante con la nueva contraseña ⚠️ (pendiente)
4. Se registra el cambio en un log/historial ⚠️ (pendiente)

---

## 📧 Comunicación al Estudiante

### Opción A: Solo Notificación Interna (Actual)

**Ventajas**:
- ✅ Ya implementado
- ✅ Funciona inmediatamente
- ✅ No requiere configuración adicional

**Desventajas**:
- ❌ El estudiante debe iniciar sesión para ver la notificación
- ❌ Si el estudiante no puede iniciar sesión, no verá la notificación
- ❌ No hay recordatorio por email

**Cuándo usar**: Cuando el estudiante puede iniciar sesión con la contraseña anterior o tiene acceso a la aplicación.

---

### Opción B: Notificación Interna + Email (Recomendado)

**Ventajas**:
- ✅ El estudiante recibe la información por email inmediatamente
- ✅ Puede acceder a la información sin iniciar sesión
- ✅ Hay un registro permanente del cambio

**Desventajas**:
- ⚠️ Requiere configurar el servicio de email (Resend)
- ⚠️ Requiere crear un template de email

**Cuándo usar**: Siempre que sea posible, para asegurar que el estudiante recibe la información.

---

## 📝 Implementación: Añadir Email al Estudiante

### Paso 1: Verificar que existe la Edge Function `send-email`

1. Ve a Supabase Dashboard → **Edge Functions**
2. Verifica que existe `send-email`
3. Si no existe, créala siguiendo: `docs/desarrollo/03-guias-tecnicas/notificaciones-email.md`

### Paso 2: Modificar `resetStudentPassword` para enviar email

Añadir después de crear la notificación interna:

```dart
// Enviar email al estudiante
try {
  await EmailNotificationService.sendPasswordResetNotification(
    studentEmail: studentEmail,
    studentName: studentResponse['full_name'] as String,
    newPassword: newPassword,
    resetBy: currentUserRole == 'admin' ? 'administrador' : 'tutor',
    resetByName: currentUserResponse['full_name'] as String,
  );
} catch (e) {
  debugPrint('⚠️ Error enviando email de reset de contraseña: $e');
  // No fallar si el email no se puede enviar
}
```

### Paso 3: Crear método en `EmailNotificationService`

```dart
/// Envía email de notificación cuando se resetea una contraseña
static Future<void> sendPasswordResetNotification({
  required String studentEmail,
  required String studentName,
  required String newPassword,
  required String resetBy, // 'administrador' o 'tutor'
  required String resetByName,
}) async {
  try {
    final response = await _supabase.functions.invoke(
      'send-email',
      body: {
        'type': 'password_reset',
        'data': {
          'studentEmail': studentEmail,
          'studentName': studentName,
          'newPassword': newPassword,
          'resetBy': resetBy,
          'resetByName': resetByName,
        },
      },
    );

    if (response.status == 200) {
      debugPrint('✅ Email de reset de contraseña enviado exitosamente');
    } else {
      debugPrint('❌ Error enviando email de reset: ${response.data}');
    }
  } catch (e) {
    debugPrint('❌ Error en sendPasswordResetNotification: $e');
  }
}
```

### Paso 4: Crear template de email en la Edge Function `send-email`

Añadir el caso `password_reset` en la Edge Function:

```typescript
case 'password_reset':
  return await sendPasswordResetEmail(data);
```

Y crear la función:

```typescript
async function sendPasswordResetEmail(data: any) {
  const { studentEmail, studentName, newPassword, resetBy, resetByName } = data;
  
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .password-box { background-color: #fff; border: 2px solid #4CAF50; padding: 15px; margin: 20px 0; text-align: center; font-size: 18px; font-weight: bold; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🔒 Contraseña Restablecida</h1>
        </div>
        <div class="content">
          <p>Hola <strong>${studentName}</strong>,</p>
          <p>Tu contraseña ha sido restablecida por <strong>${resetByName}</strong> (${resetBy}).</p>
          <p>Tu nueva contraseña es:</p>
          <div class="password-box">
            ${newPassword}
          </div>
          <p><strong>⚠️ Importante:</strong></p>
          <ul>
            <li>Guarda esta contraseña en un lugar seguro</li>
            <li>Puedes cambiarla después de iniciar sesión</li>
            <li>Si no solicitaste este cambio, contacta a tu tutor o administrador</li>
          </ul>
          <p style="text-align: center; margin-top: 30px;">
            <a href="${APP_URL}/login" style="background-color: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
              Iniciar Sesión
            </a>
          </p>
        </div>
        <div class="footer">
          <p>Sistema de Gestión de Proyectos TFG - CIFP Carlos III</p>
          <p>Este es un email automático, por favor no respondas.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const text = `
Contraseña Restablecida

Hola ${studentName},

Tu contraseña ha sido restablecida por ${resetByName} (${resetBy}).

Tu nueva contraseña es: ${newPassword}

Importante:
- Guarda esta contraseña en un lugar seguro
- Puedes cambiarla después de iniciar sesión
- Si no solicitaste este cambio, contacta a tu tutor o administrador

Inicia sesión en: ${APP_URL}/login

Sistema de Gestión de Proyectos TFG - CIFP Carlos III
Este es un email automático, por favor no respondas.
  `;

  return await resend.emails.send({
    from: 'Sistema TFG <noreply@cifpcarlos3.es>',
    to: studentEmail,
    subject: '🔒 Tu contraseña ha sido restablecida',
    html: html,
    text: text,
  });
}
```

---

## 👨‍🏫 Comunicación al Tutor/Administrador

### Situación: Tutor/Admin necesita saber que debe resetear una contraseña

**Escenarios**:
1. Estudiante olvida su contraseña y solicita ayuda
2. Estudiante no puede iniciar sesión
3. Contraseña comprometida y necesita ser cambiada

### Opción A: Solicitud Manual del Estudiante

**Proceso actual**:
1. Estudiante contacta al tutor/admin por email/telefónicamente
2. Tutor/admin resetea la contraseña desde la aplicación
3. Se notifica al estudiante

**Mejora propuesta**: Crear un sistema de solicitud de reset de contraseña

### Opción B: Sistema de Solicitud de Reset (Pendiente de Implementar)

**Flujo propuesto**:
1. Estudiante hace clic en "¿Olvidaste tu contraseña?" en la pantalla de login
2. Estudiante ingresa su email
3. Se crea una notificación para el tutor del estudiante (o admin si no tiene tutor)
4. Tutor/admin recibe notificación: "El estudiante [nombre] ha solicitado reset de contraseña"
5. Tutor/admin puede resetear la contraseña directamente desde la notificación
6. Se notifica al estudiante (interna + email)

**Implementación pendiente**: Ver `docs/desarrollo/solicitud_reset_contraseña_estudiante.md` (crear)

---

## 📊 Registro de Cambios

### Implementación: Historial de Cambios de Contraseña

**Propuesta**: Crear tabla `password_reset_history`:

```sql
CREATE TABLE password_reset_history (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id),
  reset_by_id INTEGER NOT NULL REFERENCES users(id),
  reset_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reset_reason TEXT,
  notification_sent BOOLEAN DEFAULT FALSE,
  email_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Uso**:
- Registrar cada cambio de contraseña
- Ver historial de cambios por estudiante
- Verificar que las notificaciones se enviaron correctamente
- Auditoría de seguridad

---

## ✅ Checklist de Implementación

### Comunicación al Estudiante

- [x] Notificación interna (implementado)
- [ ] Email automático (pendiente)
- [ ] Template de email (pendiente)
- [ ] Verificación de envío de email (pendiente)

### Comunicación al Tutor/Admin

- [ ] Sistema de solicitud de reset (pendiente)
- [ ] Notificación cuando estudiante solicita reset (pendiente)
- [ ] Acción rápida desde notificación (pendiente)

### Registro y Auditoría

- [ ] Tabla de historial de cambios (pendiente)
- [ ] Registro automático de cambios (pendiente)
- [ ] Vista de historial para admin (pendiente)

---

## 🎯 Recomendaciones

### Prioridad Alta

1. **Añadir email al estudiante**: Mejora significativamente la experiencia del usuario
2. **Template de email profesional**: Da confianza y claridad

### Prioridad Media

3. **Sistema de solicitud de reset**: Facilita el proceso para estudiantes
4. **Notificación al tutor**: Mejora la comunicación

### Prioridad Baja

5. **Historial de cambios**: Útil para auditoría pero no crítico
6. **Dashboard de estadísticas**: Nice to have

---

## 📝 Notas Adicionales

### Seguridad

- ⚠️ **Nunca enviar contraseñas por email sin cifrar** (aunque el email ya está cifrado en tránsito)
- ⚠️ **Considerar expiración de contraseñas temporales**: Forzar cambio después del primer login
- ⚠️ **Limitar intentos de reset**: Prevenir abuso

### Privacidad

- ⚠️ **No mostrar contraseñas en logs**: Solo registrar que se cambió
- ⚠️ **Permitir que estudiantes cambien su contraseña**: Después del primer login

---

## 🔗 Referencias

- `docs/desarrollo/flujo_gestion_contraseñas.md` - Flujo completo
- `docs/desarrollo/03-guias-tecnicas/notificaciones-email.md` - Configuración de email
- `frontend/lib/services/user_management_service.dart` - Código actual
- `frontend/lib/services/email_notification_service.dart` - Servicio de email

