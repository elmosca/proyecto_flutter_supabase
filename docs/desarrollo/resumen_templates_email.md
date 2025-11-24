# 📧 Resumen de Templates de Email - Sistema TFG

Este documento proporciona una referencia rápida de los templates de email configurados en Supabase.

## 📋 Templates Configurados

### 1. "Confirm sign up" - Verificación de Email

**Cuándo se envía:** Cuando un administrador o tutor crea un nuevo usuario.

**Propósito:** Verificar el email del usuario y dar instrucciones para establecer su contraseña.

**Subject:** `Bienvenido al Sistema de Gestión TFG - Verifica tu Email`

**Variables usadas:**
- `{{ .Data.full_name }}` - Nombre completo del usuario
- `{{ .Email }}` - Email del usuario (fallback)
- `{{ .ConfirmationURL }}` - Enlace para verificar el email

**Ubicación en Supabase:** Authentication → Emails → Templates → "Confirm sign up"

---

### 2. "Reset password" - Restablecer Contraseña

**Cuándo se envía:** Cuando un usuario hace clic en "¿Olvidaste tu contraseña?" en la pantalla de login.

**Propósito:** Permitir al usuario restablecer su contraseña olvidada o establecer una nueva contraseña.

**Subject:** `Restablecer Contraseña - Sistema TFG`

**Variables usadas:**
- `{{ .Data.full_name }}` - Nombre completo del usuario
- `{{ .Email }}` - Email del usuario (fallback)
- `{{ .ConfirmationURL }}` - Enlace para restablecer la contraseña

**Ubicación en Supabase:** Authentication → Emails → Templates → "Reset password"

**Validez:** El enlace expira en 1 hora por seguridad.

---

## 🔄 Flujo de Uso de los Templates

### Flujo 1: Usuario Nuevo (Creado por Admin/Tutor)

1. **Admin/Tutor crea usuario** → Se envía email "Confirm sign up"
2. **Usuario verifica email** → Click en enlace de verificación
3. **Usuario usa "¿Olvidaste tu contraseña?"** → Se envía email "Reset password"
4. **Usuario establece contraseña** → Puede iniciar sesión

### Flujo 2: Usuario Existente Olvida Contraseña

1. **Usuario hace click en "¿Olvidaste tu contraseña?"** → Se envía email "Reset password"
2. **Usuario recibe email** → Click en enlace de restablecimiento
3. **Usuario establece nueva contraseña** → Puede iniciar sesión

---

## 📝 Variables Disponibles en Templates

| Variable | Descripción | Disponible en |
|---------|-------------|---------------|
| `{{ .Email }}` | Email del usuario | Todos los templates |
| `{{ .Data.full_name }}` | Nombre completo (desde metadatos) | Todos los templates |
| `{{ .Data.role }}` | Rol del usuario (desde metadatos) | Todos los templates |
| `{{ .ConfirmationURL }}` | URL de confirmación/reset | Confirm sign up, Reset password |
| `{{ .SiteURL }}` | URL base del sitio | Todos los templates |
| `{{ .Token }}` | Token de verificación | Confirm sign up |
| `{{ .TokenHash }}` | Hash del token (PKCE) | Confirm sign up (PKCE flow) |

---

## ✅ Checklist de Configuración

- [ ] Template "Confirm sign up" configurado
- [ ] Template "Reset password" configurado
- [ ] Variables `{{ .Data.full_name }}` funcionan correctamente
- [ ] Enlaces de confirmación funcionan
- [ ] Enlaces de reset funcionan
- [ ] Subject headings son descriptivos
- [ ] Instrucciones son claras para los usuarios
- [ ] Preview muestra correctamente el contenido

---

## 🔍 Verificación de Metadatos

Para que `{{ .Data.full_name }}` funcione, el código debe pasar los metadatos en `signUp()`:

```dart
await _supabase.auth.signUp(
  email: email,
  password: password,
  data: {
    'full_name': fullName,  // ← Esto hace que {{ .Data.full_name }} funcione
    'role': 'student',
  },
);
```

**Verificar metadatos:**
1. Supabase Dashboard → Authentication → Users
2. Selecciona un usuario
3. Busca "User Metadata" o "Raw User Meta Data"
4. Deberías ver: `{"full_name": "Juan Pérez", "role": "student"}`

---

## 📚 Documentación Relacionada

- [Guía Paso a Paso de Configuración](./guia_configuracion_supabase_paso_a_paso.md)
- [Variables de Templates](./variables_template_email_supabase.md)
- [Configuración de Email de Verificación](./configuracion_email_verificacion.md)

