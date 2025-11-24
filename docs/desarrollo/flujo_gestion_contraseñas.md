# 🔐 Flujo Completo de Gestión de Contraseñas

## 📋 Resumen del Sistema

El sistema permite a **tutores y administradores** gestionar las contraseñas de los estudiantes de dos formas:

1. **Al crear un estudiante**: Establecer la contraseña inicial
2. **Para estudiantes existentes**: Resetear la contraseña cuando sea necesario

---

## 🆕 Flujo 1: Crear Estudiante con Contraseña

### Opción A: Tutor crea estudiante individual (AddStudentForm)

**Ubicación**: `frontend/lib/screens/forms/add_student_form.dart`

**Flujo**:
1. Tutor navega a "Mis Estudiantes" → Botón "Añadir"
2. Completa el formulario (nombre, email, NRE, etc.)
3. **Sistema genera automáticamente** una contraseña temporal segura (16 caracteres)
4. Se llama a `UserManagementService.createStudent()` con:
   - Email del estudiante
   - Contraseña temporal generada
   - Datos del estudiante
5. **Supabase Auth**:
   - Crea el usuario en `auth.users` con la contraseña
   - Envía email de verificación al estudiante
   - Redirige a `/reset-password?type=setup` después de verificar
6. **Base de datos**:
   - Inserta el registro en la tabla `users`
   - `password_hash` = NULL (las contraseñas están en `auth.users`)
7. **Resultado**:
   - ✅ Estudiante creado con contraseña establecida
   - ✅ Email de verificación enviado
   - ✅ El estudiante puede iniciar sesión con la contraseña generada
   - ℹ️ Mensaje: "El estudiante ha sido creado con la contraseña establecida. Puede iniciar sesión inmediatamente."

**Nota**: El estudiante recibe un email de verificación, pero **ya tiene contraseña** y puede iniciar sesión después de verificar su email.

---

### Opción B: Admin crea estudiante (StudentCreationForm)

**Ubicación**: `frontend/lib/widgets/forms/student_creation_form.dart`

**Flujo**:
1. Admin navega a "Gestión de Usuarios" → Botón "Crear Estudiante"
2. Completa el formulario incluyendo:
   - **Campo de contraseña**: Admin puede establecer la contraseña manualmente
3. Se llama a `UserManagementService.createStudent()` con:
   - Email del estudiante
   - Contraseña establecida por el admin
   - Datos del estudiante
4. **Supabase Auth**:
   - Crea el usuario en `auth.users` con la contraseña establecida
   - Envía email de verificación
5. **Base de datos**:
   - Inserta el registro en la tabla `users`
6. **Resultado**:
   - ✅ Estudiante creado con la contraseña que estableció el admin
   - ✅ El estudiante puede iniciar sesión inmediatamente después de verificar su email

---

### Opción C: Importación desde CSV

**Problema actual**: La importación CSV usa `UserService.createUser()` que **NO crea el usuario en Supabase Auth**, por lo que los estudiantes importados **NO pueden iniciar sesión**.

**Flujos actuales**:

#### CSV por Admin (CsvImportWidget)
- Formato: `email,password,full_name,specialty,academic_year`
- Usa función RPC `import_students_csv` en Supabase
- **Estado**: Los estudiantes se crean con contraseña en la RPC, pero necesitas verificar que la RPC también cree en `auth.users`

#### CSV por Tutor (ImportStudentsCSVScreen)
- Formato: `full_name,email,nre,...`
- Usa `UserService.createUser()` que **solo inserta en la tabla `users`**
- **Problema**: ❌ No crea en `auth.users`, por lo que **NO pueden iniciar sesión**
- **Solución necesaria**: Cambiar a usar `UserManagementService.createStudent()` con contraseña generada

---

## 🔄 Flujo 2: Resetear Contraseña de Estudiante Existente

### Para Tutores

**Ubicación**: `frontend/lib/screens/student/student_list_screen.dart`

**Flujo**:
1. Tutor navega a "Mis Estudiantes"
2. En la lista, hace clic en el menú (⋮) de un estudiante
3. Selecciona **"Restablecer contraseña"**
4. Se abre el diálogo `ResetPasswordDialog`:
   - **Opción 1**: Generar contraseña automáticamente (checkbox marcado por defecto)
     - Sistema genera una contraseña segura de 12 caracteres
     - Botón "Regenerar" para generar otra si no te gusta
   - **Opción 2**: Establecer contraseña manualmente (desmarcar checkbox)
     - Campo de texto para escribir la contraseña deseada
5. Tutor confirma la contraseña
6. Se llama a `UserManagementService.resetStudentPassword()`:
   - Verifica permisos (solo tutor del estudiante o admin)
   - Llama a la **Edge Function `reset-password`** en Supabase
   - La Edge Function actualiza la contraseña en `auth.users` usando Admin API
7. **Notificación**:
   - Se crea una notificación interna para el estudiante
   - Contenido: "Tu contraseña ha sido restablecida por tu tutor. Tu nueva contraseña es: [contraseña]"
8. **Resultado**:
   - ✅ Contraseña actualizada en Supabase Auth
   - ✅ Notificación enviada al estudiante
   - ✅ El estudiante puede iniciar sesión con la nueva contraseña

---

### Para Administradores

**Ubicación**: `frontend/lib/screens/admin/users_management_screen.dart`

**Flujo**:
1. Admin navega a "Gestión de Usuarios" → Pestaña "Estudiantes"
2. En la lista, hace clic en el botón de **candado con flecha** (🔒↻) de un estudiante
3. Se abre el mismo diálogo `ResetPasswordDialog`
4. El proceso es idéntico al de tutores
5. La notificación dice: "Tu contraseña ha sido restablecida por un administrador..."

---

## 🔍 Flujo Técnico Detallado

### Crear Estudiante (createStudent)

```
1. Tutor/Admin completa formulario
   ↓
2. Se genera/establece contraseña
   ↓
3. UserManagementService.createStudent()
   ↓
4. Supabase Auth: signUp(email, password, metadata)
   ├─ Crea usuario en auth.users
   ├─ Envía email de verificación
   └─ Redirige a /reset-password?type=setup
   ↓
5. Insertar en tabla users
   ├─ email, full_name, role, etc.
   └─ password_hash = NULL (gestionado en auth.users)
   ↓
6. ✅ Estudiante creado con contraseña
```

### Resetear Contraseña (resetStudentPassword)

```
1. Tutor/Admin selecciona "Restablecer contraseña"
   ↓
2. ResetPasswordDialog
   ├─ Genera/establece nueva contraseña
   └─ Valida contraseña (mínimo 6 caracteres)
   ↓
3. UserManagementService.resetStudentPassword()
   ├─ Verifica permisos (admin o tutor del estudiante)
   └─ Obtiene información del estudiante
   ↓
4. Llamada a Edge Function 'reset-password'
   ├─ Parámetros: { user_email, new_password }
   └─ Edge Function usa Admin API con service_role
   ↓
5. Edge Function actualiza auth.users
   ├─ Busca usuario por email
   └─ updateUserById(userId, { password: new_password })
   ↓
6. Crear notificación interna
   ├─ Tipo: 'system_notification'
   ├─ Título: 'Contraseña restablecida'
   └─ Mensaje: Incluye la nueva contraseña
   ↓
7. ✅ Contraseña actualizada y notificación enviada
```

---

## 📧 Notificaciones

### Cuando se resetea la contraseña

**Tipo**: Notificación interna (en la aplicación)

**Contenido**:
- **Título**: "Contraseña restablecida"
- **Mensaje**: "Tu contraseña ha sido restablecida por [tutor/admin]. Tu nueva contraseña es: [contraseña]"
- **Acción**: Link a `/login`

**Dónde se ve**: 
- El estudiante verá la notificación en la campana de notificaciones (🔔) cuando inicie sesión

---

## ⚠️ Problemas Conocidos y Soluciones

### Problema 1: Importación CSV no crea en Auth

**Síntoma**: Estudiantes importados desde CSV no pueden iniciar sesión

**Causa**: `ImportStudentsCSVScreen` usa `UserService.createUser()` que solo inserta en la tabla `users`

**Solución**: Cambiar a usar `UserManagementService.createStudent()` con contraseña generada

### Problema 2: Email de verificación vs Contraseña establecida

**Situación**: Cuando se crea un estudiante, Supabase envía un email de verificación, pero el estudiante ya tiene contraseña.

**Comportamiento actual**:
- El estudiante recibe email de verificación
- Después de verificar, puede iniciar sesión inmediatamente con la contraseña establecida
- No necesita usar "¿Olvidaste tu contraseña?"

**Recomendación**: Actualizar el template de email de verificación para indicar que ya tiene contraseña establecida.

---

## ✅ Checklist de Funcionalidades

- [x] Tutor puede crear estudiante con contraseña generada automáticamente
- [x] Admin puede crear estudiante con contraseña establecida manualmente
- [x] Tutor puede resetear contraseña de sus estudiantes
- [x] Admin puede resetear contraseña de cualquier estudiante
- [x] Se envía notificación al estudiante cuando se resetea contraseña
- [x] Edge Function creada para actualizar contraseñas
- [ ] Importación CSV crea usuarios en Auth (pendiente de corregir)
- [ ] Template de email de verificación actualizado (opcional)

---

## 🎯 Resumen Ejecutivo

**Flujo Principal**:
1. **Crear estudiante** → Tutor/Admin establece contraseña → Estudiante puede iniciar sesión
2. **Resetear contraseña** → Tutor/Admin resetea → Notificación al estudiante → Puede iniciar sesión

**Ventajas del sistema actual**:
- ✅ Control total por parte de tutores/admins
- ✅ No depende de enlaces de email que pueden expirar
- ✅ Notificaciones internas inmediatas
- ✅ El estudiante siempre sabe su contraseña (a través de notificaciones)

**Pendiente**:
- Corregir importación CSV para que también cree en Supabase Auth

