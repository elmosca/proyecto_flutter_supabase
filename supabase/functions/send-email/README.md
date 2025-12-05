# Edge Function: send-email

Edge Function de Supabase para el envío de notificaciones por email mediante Resend API.

## 📋 Descripción

Esta función maneja diferentes tipos de notificaciones por email:
- Notificaciones de comentarios nuevos
- Notificaciones de cambio de estado de anteproyectos
- Notificaciones de bienvenida para estudiantes
- Notificaciones de mensajes entre tutor y estudiante
- Solicitudes de restablecimiento de contraseña

## 🔧 Configuración

### Variables de Entorno

La función requiere la siguiente variable de entorno configurada en Supabase:

- `RESEND_API_KEY`: Clave API de Resend (formato: `re_...`)

### Configurar en Supabase Dashboard

1. Ve a **Supabase Dashboard** > **Edge Functions** > **send-email**
2. Ve a la pestaña **Settings**
3. Agrega la variable de entorno:
   - **Name**: `RESEND_API_KEY`
   - **Value**: Tu clave API de Resend

## 🚀 Despliegue

### Opción 1: Desde Supabase Dashboard

1. Copia el contenido de `index.ts`
2. Ve a **Supabase Dashboard** > **Edge Functions** > **send-email**
3. Pega el código en el editor
4. Haz clic en **Deploy**

### Opción 2: Desde CLI (Recomendado)

```bash
# Instalar Supabase CLI si no lo tienes
npm install -g supabase

# Iniciar sesión
supabase login

# Vincular proyecto
supabase link --project-ref tu-project-ref

# Desplegar función
supabase functions deploy send-email
```

## 📧 Tipos de Email Soportados

| Tipo | Descripción | Datos Requeridos |
|------|-------------|------------------|
| `comment_notification` | Notificación de comentario nuevo | `studentEmail`, `studentName`, `tutorName`, `anteprojectTitle`, `commentContent`, `section`, `anteprojectUrl` |
| `status_change` | Cambio de estado de anteproyecto | `studentEmail`, `studentName`, `tutorName`, `anteprojectTitle`, `newStatus`, `anteprojectUrl`, `tutorComments` (opcional) |
| `student_welcome` | Bienvenida a nuevo estudiante | `studentEmail`, `studentName`, `password`, `createdBy`, `createdByName`, `academicYear` (opcional), `tutorName` (opcional), etc. |
| `message_to_tutor` | Mensaje de estudiante a tutor | `tutorEmail`, `tutorName`, `studentName`, `studentEmail`, `anteprojectTitle`, `messageContent` |
| `message_to_student` | Mensaje de tutor a estudiante | `studentEmail`, `studentName`, `tutorName`, `anteprojectTitle`, `messageContent` |
| `password_reset_request_to_tutor` | Solicitud de reset de contraseña | `tutorEmail`, `tutorName`, `studentEmail`, `studentName` |

## 🔒 Seguridad

- ✅ **No contiene información sensible**: Las claves API se obtienen de variables de entorno
- ✅ **Seguro para versionar**: El código puede estar en el repositorio sin problemas
- ✅ **CORS configurado**: Permite llamadas desde el frontend

## 📝 Notas

- El remitente de los emails es: `Sistema TFG <noreply@fct.jualas.es>`
- Todos los emails incluyen versión HTML y texto plano
- Los emails están diseñados para ser responsive y compatibles con la mayoría de clientes de email

## 🧪 Testing

Para probar la función, puedes usar el test manual:

```bash
cd frontend
flutter test test/manual/manual_email_test.dart \
  --dart-define=TEST_EMAIL_RECIPIENT=tu-email@ejemplo.com
```

