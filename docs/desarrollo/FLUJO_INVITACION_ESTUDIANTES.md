# Flujo de Invitación de Estudiantes con Contraseña Visible

## 📋 Resumen

Este documento describe el nuevo flujo de creación de estudiantes donde:
- El tutor/admin genera una contraseña temporal
- El estudiante recibe un email de Supabase Auth con la contraseña visible
- El email incluye toda la información del estudiante y su tutor
- El estudiante puede acceder inmediatamente con la contraseña o mediante un enlace

## 🎯 Ventajas del Nuevo Flujo

✅ **Email confiable** - Usa el sistema de emails de Supabase Auth (no depende de Resend)  
✅ **Contraseña visible** - El tutor y el estudiante pueden ver la contraseña  
✅ **Información completa** - El email incluye datos del tutor y del estudiante  
✅ **Acceso inmediato** - El estudiante puede iniciar sesión de inmediato  
✅ **Cambio opcional** - El estudiante puede cambiar su contraseña después  
✅ **Sin verificación** - No requiere verificación de email adicional  

## 🔄 Flujo Completo

### 1. Creación del Estudiante (Tutor/Admin)

```
Tutor/Admin → Formulario de Creación
  ↓
  - Introduce email del estudiante
  - Genera contraseña automática (o introduce una manual)
  - Ve la contraseña en pantalla
  - Completa datos del estudiante
  ↓
Pulsa "Crear Estudiante"
```

### 2. Procesamiento en la Aplicación

```
AddStudentForm
  ↓
UserManagementService.createStudent()
  ↓
  1. Obtiene información del tutor (si está asignado)
  2. Obtiene información del creador (admin/tutor actual)
  3. Invoca Edge Function 'super-action' con action: 'invite_user'
  ↓
Edge Function 'super-action'
  ↓
  1. Verifica que el email no exista en Auth
  2. Invita al usuario con inviteUserByEmail()
     - Pasa la contraseña en user_metadata.temporary_password
     - Pasa todos los datos del estudiante y tutor
  3. Establece la contraseña con updateUserById()
  4. Supabase Auth envía el email automáticamente
  ↓
UserManagementService.createStudent()
  ↓
  5. Inserta el estudiante en la tabla 'users'
  6. Retorna el estudiante creado
  ↓
AddStudentForm
  ↓
  7. Muestra mensaje de éxito con la contraseña
```

### 3. Email Recibido por el Estudiante

```
Email de Supabase Auth
  ↓
Asunto: 🎓 Bienvenido al Sistema TFG - CIFP Carlos III
  ↓
Contenido:
  - Saludo personalizado con nombre del estudiante
  - Información de quién lo creó (admin/tutor)
  - Datos de su cuenta (email, NRE, teléfono, año académico, especialidad)
  - Información de su tutor (nombre, email, teléfono)
  - CONTRASEÑA TEMPORAL (visible, destacada)
  - Botón "Acceder al Sistema" (enlace con token de autenticación)
  - Instrucciones de próximos pasos
```

### 4. Acceso del Estudiante

El estudiante tiene **dos opciones** para acceder:

#### Opción A: Usar el Enlace del Email (Recomendado)

```
Estudiante → Hace clic en "Acceder al Sistema"
  ↓
Supabase Auth → Autentica automáticamente con el token del enlace
  ↓
Aplicación → Redirige al dashboard del estudiante
  ↓
Estudiante → Ya está dentro, puede cambiar su contraseña desde su perfil
```

#### Opción B: Login Manual

```
Estudiante → Va a la pantalla de login
  ↓
Introduce:
  - Email: (el que recibió en el email)
  - Contraseña: (la contraseña temporal del email)
  ↓
Aplicación → Autentica y redirige al dashboard
  ↓
Estudiante → Ya está dentro, puede cambiar su contraseña desde su perfil
```

## 📊 Diagrama de Secuencia

```
Tutor/Admin          App (Flutter)              Edge Function           Supabase Auth        Email
     |                     |                          |                        |                |
     |--Crear Estudiante-->|                          |                        |                |
     |                     |                          |                        |                |
     |                     |--invoke('invite_user')-->|                        |                |
     |                     |                          |                        |                |
     |                     |                          |--inviteUserByEmail()-->|                |
     |                     |                          |                        |                |
     |                     |                          |                        |--Envía Email-->|
     |                     |                          |                        |                |
     |                     |                          |<--Usuario Invitado-----|                |
     |                     |                          |                        |                |
     |                     |                          |--updateUserById()----->|                |
     |                     |                          |  (establece password)  |                |
     |                     |                          |                        |                |
     |                     |<--{success: true}--------|                        |                |
     |                     |                          |                        |                |
     |                     |--INSERT users table----->|                        |                |
     |                     |                          |                        |                |
     |<--Estudiante creado-|                          |                        |                |
     |  (con contraseña)   |                          |                        |                |
     |                     |                          |                        |                |
     |                     |                          |                        |          Estudiante
     |                     |                          |                        |                |
     |                     |                          |                        |    <--Lee Email--|
     |                     |                          |                        |                |
     |                     |                          |                        |<--Clic Enlace---|
     |                     |                          |                        |                |
     |                     |<--------------------------Autenticación Automática----------------|
     |                     |                          |                        |                |
     |                     |--Redirige a Dashboard----------------------------------->Estudiante
```

## 🔧 Componentes Técnicos

### 1. Edge Function `super-action`

**Archivo:** `docs/desarrollo/super-action_edge_function_completo.ts`

**Acción:** `invite_user`

**Parámetros:**
```typescript
{
  action: 'invite_user',
  user_data: {
    email: string,
    password: string,
    full_name: string,
    role: 'student',
    tutor_name?: string,
    tutor_email?: string,
    tutor_phone?: string,
    academic_year?: string,
    student_phone?: string,
    student_nre?: string,
    student_specialty?: string,
    created_by: 'administrador' | 'tutor',
    created_by_name: string,
  }
}
```

**Respuesta:**
```typescript
{
  success: true,
  message: 'Usuario invitado exitosamente. Recibirá un email con su contraseña temporal.',
  user_id: string
}
```

### 2. Servicio Flutter

**Archivo:** `frontend/lib/services/user_management_service.dart`

**Método:** `createStudent()`

**Cambios principales:**
- Usa `action: 'invite_user'` en lugar de `action: 'create_user'`
- Obtiene información del tutor y creador antes de invocar la Edge Function
- Pasa todos los datos necesarios para el email
- Ya no envía email personalizado vía `send-email` Edge Function (usa el de Supabase Auth)

### 3. Plantilla de Email

**Archivo:** `docs/desarrollo/plantilla_email_invite_user_supabase.md`

**Ubicación en Supabase:** `Authentication → Email Templates → Invite user`

**Variables clave:**
- `{{ .Data.temporary_password }}` - Contraseña temporal visible
- `{{ .Data.tutor_name }}` - Nombre del tutor
- `{{ .Data.full_name }}` - Nombre del estudiante
- `{{ .ConfirmationURL }}` - Enlace de acceso con token

## 📝 Pasos para Implementar

### 1. Desplegar Edge Function Actualizada

```bash
# Copiar el código de super-action_edge_function_completo.ts
# Ir a Supabase Dashboard → Edge Functions → super-action
# Pegar el código y hacer Deploy
```

### 2. Configurar Plantilla de Email

Sigue la guía: [GUIA_CONFIGURAR_INVITE_USER_SUPABASE.md](./GUIA_CONFIGURAR_INVITE_USER_SUPABASE.md)

### 3. Reconstruir la Aplicación Flutter

```bash
cd frontend
flutter pub get
flutter build web
```

### 4. Probar el Flujo Completo

1. Inicia sesión como tutor o admin
2. Ve a "Mis Estudiantes" (tutor) o "Gestionar Usuarios" (admin)
3. Crea un nuevo estudiante
4. Verifica que aparezca la contraseña en el diálogo de éxito
5. Revisa el email recibido por el estudiante
6. Prueba el acceso del estudiante (enlace o login manual)

## 🆚 Comparación con el Flujo Anterior

| Aspecto | Flujo Anterior (create_user) | Flujo Nuevo (invite_user) |
|---------|------------------------------|---------------------------|
| **Email** | Edge Function `send-email` + Resend | Supabase Auth (integrado) |
| **Contraseña en email** | Sí (pero dependía de Resend) | Sí (siempre funciona) |
| **Verificación de email** | No (email_confirm: true) | No (inviteUserByEmail ya confirma) |
| **Enlace de acceso** | No | Sí ({{ .ConfirmationURL }}) |
| **Dependencia externa** | Resend (problemas con dominio) | Ninguna |
| **Confiabilidad** | Media (problemas con Resend) | Alta (sistema nativo de Supabase) |

## 🔒 Seguridad

### Contraseña Temporal

- ✅ Generada automáticamente (o introducida por admin/tutor)
- ✅ Visible para el tutor/admin al crear el estudiante
- ✅ Enviada por email seguro de Supabase Auth
- ✅ El estudiante puede cambiarla desde su perfil
- ✅ Almacenada de forma segura en Supabase Auth (hash)

### Enlace de Acceso

- ✅ Token de un solo uso generado por Supabase Auth
- ✅ Expira después de un tiempo (configurable en Supabase)
- ✅ Autentica automáticamente al estudiante
- ✅ No requiere introducir contraseña manualmente

### Datos Personales

- ✅ Email enviado solo al estudiante
- ✅ Información del tutor incluida para facilitar comunicación
- ✅ Datos almacenados de forma segura en Supabase

## 🐛 Solución de Problemas

### El email no llega

1. **Verifica la plantilla en Supabase:**
   - `Authentication → Email Templates → Invite user`
   - Asegúrate de que esté guardada correctamente

2. **Revisa los logs de Supabase:**
   - `Authentication → Logs`
   - Busca errores relacionados con el envío de emails

3. **Verifica la Edge Function:**
   - `Edge Functions → super-action → Logs`
   - Comprueba que la invitación se haya realizado correctamente

### La contraseña no aparece en el email

1. **Verifica la variable en la plantilla:**
   - Busca `{{ .Data.temporary_password }}` en el HTML
   - Asegúrate de que esté correctamente escrita

2. **Revisa los logs de la Edge Function:**
   - Verifica que `temporary_password` se esté pasando en el objeto `data`

### El estudiante no puede iniciar sesión

1. **Verifica que la contraseña sea correcta:**
   - La contraseña del email debe coincidir con la generada

2. **Comprueba que el usuario exista en Auth:**
   - `Authentication → Users`
   - Busca el email del estudiante

3. **Verifica que el usuario esté en la tabla `users`:**
   - `Table Editor → users`
   - Busca el email del estudiante

### El enlace del email no funciona

1. **Verifica la configuración de URLs:**
   - `Authentication → URL Configuration`
   - Asegúrate de que `Site URL` y `Redirect URLs` estén correctamente configuradas

2. **Comprueba que el token no haya expirado:**
   - Los tokens de invitación tienen un tiempo de expiración
   - El estudiante debe usar el enlace dentro del tiempo límite

## 📚 Documentación Relacionada

- [GUIA_CONFIGURAR_INVITE_USER_SUPABASE.md](./GUIA_CONFIGURAR_INVITE_USER_SUPABASE.md) - Guía paso a paso para configurar la plantilla
- [plantilla_email_invite_user_supabase.md](./plantilla_email_invite_user_supabase.md) - Plantilla completa con explicaciones
- [super-action_edge_function_completo.ts](./super-action_edge_function_completo.ts) - Código de la Edge Function
- [edge_function_super_action_crear_usuario_sin_verificacion.md](./edge_function_super_action_crear_usuario_sin_verificacion.md) - Documentación de la Edge Function

## 🎓 Ejemplo de Email Recibido

```
De: Sistema TFG <noreply@mail.app.supabase.com>
Para: estudiante@example.com
Asunto: 🎓 Bienvenido al Sistema TFG - CIFP Carlos III

[Email con diseño HTML profesional]

Hola Juan Pérez,

Has sido añadido al Sistema de Gestión de Proyectos TFG del CIFP Carlos III por María García (Tutor).

📋 Información de tu cuenta:
Email: estudiante@example.com
NRE: 12345678
Teléfono: 666123456
Año académico: 2024-2025
Especialidad: Desarrollo de Aplicaciones Web

👨‍🏫 Tu Tutor Asignado
Nombre: María García
Email: maria.garcia@cifp.es
Teléfono: 666987654

💬 Puedes contactar a tu tutor directamente por email o teléfono para cualquier consulta sobre tu proyecto TFG.

┌─────────────────────────────────┐
│   Tu Contraseña Temporal        │
│                                 │
│      TempPass2024!              │
└─────────────────────────────────┘

⚠️ Importante:
• Esta es tu contraseña temporal para acceder al sistema
• Guárdala en un lugar seguro
• Puedes cambiarla después de iniciar sesión desde tu perfil
• Por seguridad, no compartas esta contraseña con nadie

[Botón: Acceder al Sistema]

💡 Próximos pasos:
1. Haz clic en el botón "Acceder al Sistema"
2. Inicia sesión con tu email y la contraseña temporal
3. Cambia tu contraseña desde tu perfil (recomendado)
4. Completa tu perfil si es necesario
5. Comienza a trabajar en tu proyecto TFG
6. Contacta a tu tutor María García si tienes alguna pregunta

---
Sistema de Gestión de Proyectos TFG
CIFP Carlos III
```

