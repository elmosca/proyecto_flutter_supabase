# 📧 CONFIGURACIÓN DE EMAILS DEL SISTEMA

## 🎯 **EMAILS AUTÉNTICOS CONFIGURADOS**

### **Usuarios Principales:**
- **Admin**: `admin@jualas.es` (Admin Jualas)
- **Tutor Principal**: `jualas@jualas.es` (Tutor Jualas)
- **Tutor Test**: `jualas@gmail.com` (Tutor Test)
- **Estudiante**: `3850437@alu.murciaeduca.es` (Juan Antonio Francés Pérez)

## 🔄 **FLUJO DE NOTIFICACIONES**

### **1. Comentarios de Tutores → Estudiantes**
- **Trigger**: Cuando un tutor comenta un anteproyecto
- **Destinatario**: Email del estudiante autor del anteproyecto
- **Contenido**: Comentario, sección, enlace al anteproyecto

### **2. Aprobación/Rechazo → Estudiantes**
- **Trigger**: Cuando un tutor aprueba/rechaza un anteproyecto
- **Destinatario**: Email del estudiante autor del anteproyecto
- **Contenido**: Estado, comentarios del tutor, enlace al anteproyecto

### **3. Envío de Anteproyecto → Tutores**
- **Trigger**: Cuando un estudiante envía un anteproyecto para revisión
- **Destinatario**: Email del tutor asignado
- **Contenido**: Notificación de nuevo anteproyecto para revisar

## 🧪 **TESTING DE EMAILS**

### **Emails de Prueba Disponibles:**
- `jualas@jualas.es` - Recibe notificaciones como tutor
- `jualas@gmail.com` - Recibe notificaciones como tutor test
- `3850437@alu.murciaeduca.es` - Recibe notificaciones como estudiante
- `admin@jualas.es` - Recibe notificaciones como admin

## ⚙️ **CONFIGURACIÓN TÉCNICA**

### **Servicio de Email:**
- **Proveedor**: Resend
- **API Key**: Configurada en variables de entorno
- **Dominio**: `onboarding@resend.dev` (temporal)

### **Tipos de Email Soportados:**
1. `comment_notification` - Notificación de comentarios
2. `status_change` - Cambio de estado de anteproyecto
3. `tutor_notification` - Notificación a tutores

## 📝 **NOTAS IMPORTANTES**

- ✅ Todos los emails están configurados y activos
- ✅ El sistema envía emails automáticamente
- ✅ Los emails incluyen enlaces directos a los anteproyectos
- ✅ Formato HTML y texto plano incluidos
- ✅ Logs de envío disponibles en la consola

## 🔧 **SOLUCIÓN DE PROBLEMAS**

### **Si no llegan emails:**
1. Verificar que `RESEND_API_KEY` esté configurada
2. Revisar logs de la Edge Function
3. Verificar que los emails estén en la base de datos
4. Comprobar que las notificaciones se estén creando

### **Para testing:**
1. Crear un comentario como tutor
2. Aprobar/rechazar un anteproyecto
3. Enviar un anteproyecto como estudiante
4. Verificar logs en la consola de Supabase
