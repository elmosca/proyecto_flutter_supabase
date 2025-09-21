# 📧 Guía de Configuración de Notificaciones por Email

Esta guía te ayudará a configurar el sistema de notificaciones por email para el sistema de seguimiento de proyectos TFG.

## 🎯 Objetivo

Implementar notificaciones automáticas por correo electrónico que se envíen cuando:
- Un tutor comenta un anteproyecto
- Un anteproyecto es aprobado o rechazado
- Se crean nuevos usuarios (futuro)
- Hay recordatorios importantes (futuro)

## 🛠️ Configuración Paso a Paso

### **Paso 1: Configurar Resend**

1. **Crear cuenta en Resend**:
   - Ve a [https://resend.com](https://resend.com)
   - Crea una cuenta gratuita
   - Verifica tu email

2. **Obtener API Key**:
   - Ve al dashboard de Resend
   - Navega a "API Keys"
   - Crea una nueva API Key
   - Copia la clave (formato: `re_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

### **Paso 2: Configurar Supabase**

1. **Acceder al Dashboard**:
   - Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Selecciona tu proyecto

2. **Configurar Variables de Entorno**:
   - Ve a **Settings > Edge Functions**
   - Haz clic en **"Add new secret"**
   - **Nombre**: `RESEND_API_KEY`
   - **Valor**: `re_2Kk9qch3_97LV7PNRKiL9wHJXPji2cEhf` (tu API key)
   - Haz clic en **"Add secret"**

### **Paso 3: Desplegar Edge Function**

```bash
# Desde la raíz del proyecto
supabase functions deploy send-email
```

### **Paso 4: Aplicar Migraciones**

```bash
# Aplicar las migraciones de base de datos
supabase db push
```

### **Paso 5: Actualizar URLs**

Edita el archivo de migración `backend/supabase/migrations/20241215000002_create_email_notification_triggers.sql` y actualiza las URLs:

```sql
-- Cambiar estas líneas:
anteproject_url := 'https://your-app-domain.com/anteprojects/' || NEW.anteproject_id;
anteproject_url := 'https://your-app-domain.com/anteprojects/' || NEW.id;

-- Por tu dominio real:
anteproject_url := 'https://tu-app.vercel.app/anteprojects/' || NEW.anteproject_id;
anteproject_url := 'https://tu-app.vercel.app/anteprojects/' || NEW.id;
```

### **Paso 6: Probar el Sistema**

1. **Probar manualmente**:
   ```bash
   # Instalar dependencias
   npm install @supabase/supabase-js
   
   # Editar el script de prueba
   # Actualizar SUPABASE_URL y SUPABASE_ANON_KEY en scripts/test-email-notifications.js
   
   # Ejecutar prueba
   node scripts/test-email-notifications.js
   ```

2. **Probar en la aplicación**:
   - Crea un comentario en un anteproyecto
   - Cambia el estado de un anteproyecto
   - Revisa los logs en Supabase Dashboard > Edge Functions

## 📋 Verificación

### **1. Verificar Edge Function**
- Ve a Supabase Dashboard > Edge Functions
- Deberías ver `send-email` en la lista
- Haz clic en "View logs" para ver los logs

### **2. Verificar Triggers**
```sql
-- Ejecutar en el SQL Editor de Supabase
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers 
WHERE trigger_name LIKE '%notify%';
```

### **3. Verificar Variables de Entorno**
```sql
-- Ejecutar en el SQL Editor de Supabase
SELECT current_setting('app.settings.service_role_key', true);
```

## 🎨 Personalización

### **Plantillas de Email**

Las plantillas están en `backend/supabase/functions/send-email/index.ts`. Puedes personalizar:

- **Colores**: Cambia los códigos de color en las plantillas
- **Logo**: Agrega tu logo en el header
- **Contenido**: Modifica los textos y estructura
- **Dominio**: Actualiza el dominio del remitente

### **Tipos de Notificaciones**

Puedes agregar nuevos tipos de notificaciones:

1. **Agregar nuevo tipo en la Edge Function**:
   ```typescript
   case 'nuevo_tipo':
     emailData = generateNuevoTipoEmail(data as NuevoTipoData);
     break;
   ```

2. **Crear función generadora**:
   ```typescript
   function generateNuevoTipoEmail(data: NuevoTipoData): EmailData {
     // Implementar plantilla
   }
   ```

3. **Agregar trigger en la base de datos**:
   ```sql
   CREATE TRIGGER trigger_nuevo_evento
     AFTER INSERT ON tabla_relevante
     FOR EACH ROW
     EXECUTE FUNCTION public.notify_nuevo_evento();
   ```

## 🚨 Troubleshooting

### **Error: "RESEND_API_KEY not found"**
- Verifica que la variable esté configurada en Supabase
- Asegúrate de que la Edge Function esté desplegada

### **Error: "Failed to send email"**
- Verifica que tu API Key de Resend sea válida
- Revisa los logs de Resend para más detalles
- Asegúrate de que el dominio esté configurado en Resend

### **Emails no llegan**
- Verifica la carpeta de spam
- Asegúrate de que el email del destinatario sea válido
- Revisa los logs de la Edge Function

### **Triggers no se ejecutan**
- Verifica que las migraciones se aplicaron correctamente
- Revisa que los triggers estén habilitados
- Comprueba los logs de la base de datos

## 📊 Monitoreo

### **Logs de Edge Function**
- Supabase Dashboard > Edge Functions > send-email > Logs
- Busca errores o warnings
- Verifica el tiempo de respuesta

### **Logs de Resend**
- Dashboard de Resend > Logs
- Verifica el estado de entrega
- Revisa las estadísticas de apertura

### **Métricas de Base de Datos**
```sql
-- Verificar triggers ejecutados
SELECT 
  schemaname,
  tablename,
  triggername,
  triggerdef
FROM pg_triggers 
WHERE triggername LIKE '%notify%';
```

## 🔄 Mantenimiento

### **Actualizaciones Regulares**
- Revisar logs semanalmente
- Verificar que las API keys no expiren
- Actualizar plantillas según feedback

### **Backup de Configuración**
- Exportar variables de entorno
- Documentar cambios en plantillas
- Mantener copias de triggers importantes

## 📈 Próximas Mejoras

- [ ] **Plantillas personalizables** por usuario
- [ ] **Configuración de preferencias** de notificación
- [ ] **Notificaciones push** para móviles
- [ ] **Programación de recordatorios** automáticos
- [ ] **Métricas avanzadas** de entrega y apertura
- [ ] **Integración con calendario** para fechas límite
- [ ] **Notificaciones por SMS** para casos críticos

---

**¡El sistema de notificaciones por email está listo para mejorar la comunicación entre tutores y estudiantes!** 🎉
