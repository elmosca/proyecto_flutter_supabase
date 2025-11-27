# 🔄 Flujo de Recuperación de Contraseña vía Tutor

## 📋 Descripción del Flujo

Este sistema permite que los estudiantes soliciten un restablecimiento de contraseña que será procesado por su tutor asignado, evitando problemas con enlaces de email y PKCE.

## 🎯 Flujo Completo

```
1. Estudiante va a "¿Olvidaste tu contraseña?"
2. Introduce su email
3. Sistema busca al usuario y su tutor asignado
4. Se crea notificación interna para el tutor
5. Tutor ve la notificación en su panel
6. Tutor accede a "Mis Estudiantes"
7. Tutor busca al estudiante
8. Tutor hace clic en menú → "Restablecer contraseña"
9. Sistema genera contraseña temporal automáticamente
10. Se envía email al estudiante con la nueva contraseña
11. Estudiante inicia sesión con la contraseña temporal
12. ✅ Acceso exitoso
```

## 📸 Capturas del Flujo

### 1. Estudiante Solicita Reset

**Pantalla: Login → "¿Olvidaste tu contraseña?"**

```
┌─────────────────────────────────────┐
│  🔒 Restablecer Contraseña          │
│                                     │
│  Ingresa tu correo electrónico:    │
│  ┌───────────────────────────────┐ │
│  │ alumno@example.com            │ │
│  └───────────────────────────────┘ │
│                                     │
│     [Cancelar]    [Enviar]          │
└─────────────────────────────────────┘
```

### 2. Confirmación (Estudiante con Tutor)

```
┌─────────────────────────────────────┐
│      🔔 Solicitud enviada a tu tutor│
│                                     │
│  Tu tutor Juan Pérez recibirá una  │
│  notificación para generar una     │
│  nueva contraseña temporal.        │
│                                     │
│  Te enviaremos un email con la     │
│  nueva contraseña una vez que tu   │
│  tutor la haya generado.           │
│                                     │
│            [Entendido]              │
└─────────────────────────────────────┘
```

### 3. Tutor Recibe Notificación

**Panel del Tutor:**

```
┌─────────────────────────────────────┐
│ 🔔 Notificaciones                   │
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 🔑 Solicitud de Restablecimiento││
│ │                                 ││
│ │ El estudiante María López ha    ││
│ │ solicitado restablecer su       ││
│ │ contraseña. Por favor, accede a ││
│ │ la gestión de estudiantes para  ││
│ │ generar una nueva contraseña.   ││
│ │                                 ││
│ │ Hace 2 minutos                  ││
│ └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### 4. Tutor Resetea Contraseña

**Mis Estudiantes → Menú del Estudiante:**

```
┌─────────────────────────────────────┐
│  María López                        │
│  alumno@example.com                 │
│                                     │
│  ⋮  [Menú]                          │
│      ├── Editar                     │
│      ├── Ver Anteproyectos          │
│      ├── 🔑 Restablecer contraseña  │◄─
│      └── Eliminar                   │
└─────────────────────────────────────┘
```

### 5. Confirmación de Reset

```
┌─────────────────────────────────────┐
│  🔒 Restablecer contraseña para     │
│      María López                    │
│                                     │
│  Se generará una nueva contraseña   │
│  temporal y se enviará al estudiante│
│  por email.                         │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Nueva contraseña: TempPass123 │ │
│  │ (generada automáticamente)    │ │
│  └───────────────────────────────┘ │
│                                     │
│  [Cancelar]  [Restablecer]          │
└─────────────────────────────────────┘
```

### 6. Estudiante Recibe Email

**Asunto:** 🔒 Tu contraseña ha sido restablecida - Sistema TFG

```
Hola María López,

Tu contraseña ha sido restablecida por Juan Pérez (Tutor).

TU NUEVA CONTRASEÑA:
TempPass123

⚠️ IMPORTANTE:
- Guarda esta contraseña en un lugar seguro
- Puedes cambiarla después de iniciar sesión desde tu perfil
- Si no solicitaste este cambio, contacta a tu tutor

Inicia sesión en: http://localhost:8082/login

---
Sistema TFG - CIFP Carlos III
```

### 7. Estudiante Inicia Sesión

```
┌─────────────────────────────────────┐
│  🎓 Sistema TFG                     │
│                                     │
│  Correo:                           │
│  ┌───────────────────────────────┐ │
│  │ alumno@example.com            │ │
│  └───────────────────────────────┘ │
│                                     │
│  Contraseña:                       │
│  ┌───────────────────────────────┐ │
│  │ TempPass123                   │ │◄─ usa la temporal
│  └───────────────────────────────┘ │
│                                     │
│  [¿Olvidaste tu contraseña?]       │
│                                     │
│            [Iniciar Sesión]         │
└─────────────────────────────────────┘
```

## 🔄 Casos Especiales

### Caso 1: Estudiante Sin Tutor Asignado

Si un estudiante solicita reset pero NO tiene tutor asignado:

```
Sistema → Usa flujo tradicional de Supabase
       → Envía email directo al estudiante con enlace
       → (Este flujo puede fallar por PKCE)
```

**Logs:**
```
⚠️ Usuario sin tutor asignado o no es estudiante.
   Usando flujo tradicional de Supabase.
```

### Caso 2: Tutor o Admin Solicita Reset

Si un tutor o administrador solicita reset:

```
Sistema → Usa flujo tradicional de Supabase
       → Envía email directo con enlace
```

### Caso 3: Usuario No Encontrado

```
❌ Error: No se encontró un usuario con ese email
```

## 🔧 Implementación Técnica

### Archivos Modificados

1. **`frontend/lib/services/auth_service.dart`**
   - Método `resetPasswordForEmail()` modificado
   - Ahora retorna `Map<String, dynamic>` con info del tutor
   - Crea notificación interna si es estudiante con tutor

2. **`frontend/lib/widgets/dialogs/forgot_password_dialog.dart`**
   - Actualizado para mostrar mensaje diferente según flujo
   - Muestra nombre del tutor cuando aplica

3. **`frontend/lib/l10n/app_es.arb` y `app_en.arb`**
   - `resetPasswordRequestSent`: "Solicitud enviada a tu tutor"
   - `resetPasswordRequestSentDescription`: Mensaje detallado
   - `userNotFound`: "No se encontró un usuario con ese email"

4. **`frontend/lib/utils/error_translator.dart`**
   - Añadido mapeo para `user_not_found`

### Base de Datos

**Tabla `notifications`:**

```sql
INSERT INTO notifications (
  user_id,
  type,
  title,
  message,
  read,
  created_at
) VALUES (
  <tutor_id>,
  'password_reset_request',
  'Solicitud de Restablecimiento de Contraseña',
  'El estudiante <nombre> (<email>) ha solicitado...',
  false,
  NOW()
);
```

## 📊 Ventajas del Nuevo Flujo

### ✅ Ventajas

1. **No depende de PKCE**: Evita el problema del `code_verifier`
2. **No requiere enlaces de email**: El estudiante recibe directamente la contraseña
3. **Control del tutor**: El tutor decide cuándo y cómo resetear
4. **Notificación interna**: El tutor ve la solicitud en su panel
5. **Trazabilidad**: Se registra quién realizó el cambio
6. **UX simple**: Estudiante solo necesita iniciar sesión con la nueva contraseña

### ⚠️ Consideraciones

1. **Requiere tutor asignado**: Los estudiantes sin tutor usan el flujo tradicional
2. **Dos pasos**: El tutor debe intervenir (no es automático)
3. **Contraseña en email**: La contraseña temporal va en texto plano por email

## 🧪 Pruebas

### Prueba 1: Estudiante con Tutor

```
1. Crear usuario estudiante con tutor asignado
2. Login → "¿Olvidaste tu contraseña?"
3. Introduce email del estudiante
4. ✅ Debería mostrar "Solicitud enviada a tu tutor"
5. ✅ Tutor debería recibir notificación
6. Tutor → Mis Estudiantes → Menú → Restablecer contraseña
7. ✅ Estudiante debería recibir email con nueva contraseña
8. Estudiante inicia sesión con la nueva contraseña
9. ✅ Acceso exitoso
```

### Prueba 2: Estudiante sin Tutor

```
1. Crear usuario estudiante SIN tutor
2. Login → "¿Olvidaste tu contraseña?"
3. Introduce email
4. ✅ Debería mostrar "A password reset link has been sent..."
5. ✅ Debería recibir email de Supabase con enlace
```

### Prueba 3: Usuario No Existente

```
1. Login → "¿Olvidaste tu contraseña?"
2. Introduce email que NO existe
3. ✅ Debería mostrar error "No se encontró un usuario con ese email"
```

## 📝 Logs Esperados

### Estudiante con Tutor

```
🔐 Solicitando reset de contraseña para: alumno@example.com
👤 Usuario encontrado: María López (ID: 15, Rol: student)
👨‍🏫 Buscando tutor con ID: 5
✅ Tutor encontrado: Juan Pérez (juan@example.com)
✅ Notificación interna creada para el tutor
✅ Solicitud enviada al tutor.
```

### Estudiante sin Tutor

```
🔐 Solicitando reset de contraseña para: alumno@example.com
👤 Usuario encontrado: Pedro Sánchez (ID: 20, Rol: student)
⚠️ Usuario sin tutor asignado o no es estudiante.
   Usando flujo tradicional de Supabase.
✅ Email de reset de contraseña enviado
```

## 🔜 Mejoras Futuras (Opcional)

### Opción 1: Email al Tutor

Descomentar en `auth_service.dart`:

```dart
await EmailNotificationService.sendPasswordResetRequestToTutor(
  tutorEmail: tutorEmail,
  tutorName: tutorName,
  studentEmail: email,
  studentName: userFullName,
);
```

Y crear el método en `EmailNotificationService`.

### Opción 2: Pantalla de Perfil para Cambiar Contraseña

Implementar una pantalla donde el estudiante pueda cambiar su contraseña temporal:

```
Dashboard → Perfil → Cambiar Contraseña
```

### Opción 3: Forzar Cambio de Contraseña

Añadir campo `must_change_password` en la tabla `users` y forzar el cambio en el primer login con contraseña temporal.

---

**Estado:** ✅ Implementado y Listo para Pruebas  
**Última actualización:** 2025-01-10  
**Versión:** 1.0

