# 📧 Servicio de Notificaciones por Email

Este servicio maneja el envío automático de notificaciones por correo electrónico para el sistema de seguimiento de proyectos TFG.

## 🚀 Configuración

### 1. Configurar Resend

1. Ve a [Resend](https://resend.com) y crea una cuenta
2. Obtén tu API Key desde el dashboard
3. Configura las variables de entorno en Supabase:

```bash
# En el dashboard de Supabase, ve a Settings > Edge Functions
# Agrega la variable de entorno:
RESEND_API_KEY=tu_api_key_aqui
```

### 2. Desplegar la Edge Function

```bash
# Desde el directorio del proyecto
supabase functions deploy send-email
```

### 3. Configurar el dominio (opcional)

Si tienes un dominio personalizado, puedes configurarlo en Resend y actualizar el remitente en el código.

## 📋 Tipos de Notificaciones

### 1. Comentarios Nuevos
- **Trigger**: Cuando un tutor comenta un anteproyecto
- **Destinatario**: Estudiante autor del anteproyecto
- **Contenido**: Comentario, sección, información del tutor

### 2. Cambios de Estado
- **Trigger**: Cuando un anteproyecto es aprobado o rechazado
- **Destinatario**: Estudiante autor del anteproyecto
- **Contenido**: Nuevo estado, comentarios del tutor

### 3. Bienvenida (futuro)
- **Trigger**: Cuando se crea un nuevo usuario
- **Destinatario**: Nuevo usuario
- **Contenido**: Información de bienvenida y acceso

### 4. Recordatorios (futuro)
- **Trigger**: Fechas límite próximas
- **Destinatario**: Usuario correspondiente
- **Contenido**: Recordatorio personalizado

## 🔧 Uso

### Desde el Frontend

```dart
// Enviar notificación de comentario
await EmailNotificationService.sendCommentNotification(
  studentEmail: 'estudiante@ejemplo.com',
  studentName: 'Juan Pérez',
  tutorName: 'Dr. García',
  anteprojectTitle: 'Mi Proyecto',
  commentContent: 'Excelente trabajo...',
  section: 'Descripción',
  anteprojectUrl: 'https://app.com/anteprojects/123',
);

// Enviar notificación de cambio de estado
await EmailNotificationService.sendStatusChangeNotification(
  studentEmail: 'estudiante@ejemplo.com',
  studentName: 'Juan Pérez',
  tutorName: 'Dr. García',
  anteprojectTitle: 'Mi Proyecto',
  newStatus: 'approved',
  tutorComments: 'Proyecto aprobado con algunas sugerencias...',
  anteprojectUrl: 'https://app.com/anteprojects/123',
);
```

### Desde la Base de Datos (Automático)

Los triggers se ejecutan automáticamente cuando:
- Se inserta un nuevo comentario en `anteproject_comments`
- Se actualiza el estado de un anteproyecto en `anteprojects`

## 🎨 Plantillas de Email

Las plantillas incluyen:
- ✅ Diseño responsive
- ✅ Colores del sistema
- ✅ Información contextual
- ✅ Enlaces directos
- ✅ Versión texto plano

## 🔍 Debugging

Para verificar que las notificaciones funcionan:

1. **Logs de la Edge Function**: Ve a Supabase Dashboard > Edge Functions > send-email > Logs
2. **Logs del Frontend**: Los errores se muestran en la consola de debug
3. **Base de Datos**: Los triggers se ejecutan automáticamente

## 🚨 Troubleshooting

### Error: "RESEND_API_KEY not found"
- Verifica que la variable de entorno esté configurada en Supabase
- Asegúrate de que la Edge Function esté desplegada

### Error: "Failed to send email"
- Verifica que tu API Key de Resend sea válida
- Revisa los logs de Resend para más detalles

### Emails no llegan
- Verifica la carpeta de spam
- Asegúrate de que el dominio esté configurado correctamente en Resend

## 📈 Próximas Mejoras

- [ ] Plantillas personalizables
- [ ] Configuración de preferencias de usuario
- [ ] Notificaciones push
- [ ] Programación de recordatorios
- [ ] Métricas de entrega
