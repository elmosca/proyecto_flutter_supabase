# 🔧 Solución: Problema de Email de Verificación No Enviado

## ❌ Problema Identificado

Cuando un tutor creaba un estudiante desde su perfil, el email de verificación **no se enviaba** porque:

1. **`AddStudentForm`** (usado por tutores) estaba usando `UserService.createUser()`
2. Este método **solo inserta** en la tabla `users` de la base de datos
3. **NO crea** el usuario en Supabase Auth
4. Por lo tanto, **NO se envía** el email de verificación

## ✅ Solución Implementada

Se actualizó `AddStudentForm` para que:

1. Use `UserManagementService.createStudent()` en lugar de `UserService.createUser()`
2. Este método:
   - Crea el usuario en Supabase Auth mediante `signUp()`
   - Envía automáticamente el email de verificación
   - Inserta el usuario en la tabla `users`
   - Incluye `emailRedirectTo` para redirigir a `/reset-password?type=setup`

### Cambios Realizados

**Archivo:** `frontend/lib/screens/forms/add_student_form.dart`

**Antes:**
```dart
final userService = UserService();
await userService.createUser(newUser); // ❌ Solo inserta en BD, no crea en Auth
```

**Después:**
```dart
final userManagementService = UserManagementService();
final tempPassword = _generateTempPassword(); // Genera contraseña temporal
await userManagementService.createStudent(
  email: email,
  password: tempPassword, // Contraseña temporal
  fullName: fullName,
  // ... otros campos
); // ✅ Crea en Auth y envía email
```

### Funcionalidad de Contraseña Temporal

Se implementó `_generateTempPassword()` que:
- Genera una contraseña temporal segura de 16 caracteres
- El usuario nunca conoce esta contraseña
- Después de verificar su email, el usuario usará "¿Olvidaste tu contraseña?" para establecer su contraseña personal

## 🔍 Verificación

Para verificar que funciona correctamente:

1. **Crear un estudiante desde el perfil de tutor:**
   - Inicia sesión como tutor (`jualas@jualas.es`)
   - Crea un nuevo estudiante
   - Verifica que aparezca el mensaje de éxito con instrucciones

2. **Verificar el email:**
   - Revisa el buzón del nuevo estudiante
   - Debe recibir un email "Confirm sign up" con:
     - Asunto: "Bienvenido al Sistema de Gestión TFG - Verifica tu Email"
     - Enlace para verificar email
     - Instrucciones para establecer contraseña

3. **Verificar en Supabase:**
   - Ve a **Authentication → Users** en Supabase Dashboard
   - El usuario debe aparecer en la lista con estado "Unconfirmed"
   - Después de verificar email, cambiará a "Confirmed"

## 📝 Nota sobre Importación CSV

El formulario `ImportStudentsCSVScreen` también tiene el mismo problema (usa `UserService.createUser()`). Si necesitas que la importación CSV también envíe emails, se debe actualizar de manera similar. Sin embargo, para importaciones masivas, considera:

- **Opción A:** Actualizar cada creación individual para usar `UserManagementService.createStudent()`
- **Opción B:** Crear una función RPC en Supabase que maneje la creación masiva con Auth

## 🐛 Si el Email Aún No Llega

Si después de estos cambios el email sigue sin llegar, verifica:

1. **Configuración SMTP en Supabase:**
   - Ve a **Authentication → Email Templates**
   - Verifica que el template "Confirm sign up" esté configurado
   - Verifica que SMTP esté configurado (o que el servicio integrado esté funcionando)

2. **Límites de tasa:**
   - El servicio integrado de Supabase tiene límites (30 emails/hora)
   - Si has enviado muchos emails, espera o configura SMTP personalizado

3. **Carpeta de spam:**
   - Revisa la carpeta de spam del destinatario

4. **Logs de Supabase:**
   - Ve a **Authentication → Logs** en Supabase Dashboard
   - Busca eventos de "signup" o errores relacionados

5. **Configuración de email:**
   - Ve a **Authentication → Settings**
   - Verifica que "Confirm email" esté activado (ON)

