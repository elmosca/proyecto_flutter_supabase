# Configurar URLs para Enlaces de Invitación

## Problema

El enlace del email de invitación muestra:
```
error=access_denied&error_code=otp_expired&error_description=Email+link+is+invalid+or+has+expired
```

## Soluciones

### Solución 1: Configurar URLs en Supabase (RECOMENDADO)

#### Paso 1: Configurar Site URL

1. Ve a **Supabase Dashboard → Authentication → URL Configuration**
2. En **Site URL**, configura:
   - **Para desarrollo local:** `http://localhost:8082`
   - **Para producción:** Tu dominio real (ej: `https://tfg.jualas.es`)

#### Paso 2: Añadir Redirect URLs

En **Redirect URLs**, añade:
- `http://localhost:8082/**` (para desarrollo)
- `http://localhost:8082/dashboard/**`
- Tu URL de producción cuando la tengas

#### Paso 3: Configurar Tiempo de Expiración

1. Ve a **Authentication → Settings**
2. Busca **"Email OTP Expiry"** o **"Magic Link Expiry"**
3. Aumenta el tiempo si es necesario (por defecto suele ser 3600 segundos = 1 hora)

### Solución 2: Modificar la Edge Function para Incluir redirect_to

Actualiza la Edge Function para pasar explícitamente la URL de redirección:

```typescript
const { data: invitedUser, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
  user_data.email,
  {
    data: {
      // ... datos actuales ...
    },
    redirectTo: 'http://localhost:8082/dashboard/student', // URL específica
  }
);
```

### Solución 3: Login Manual como Alternativa (MÁS SIMPLE)

Ya que el email incluye la contraseña, el estudiante puede simplemente:

1. **Ignorar el enlace si da error**
2. **Ir directamente a la página de login** (`http://localhost:8082/login`)
3. **Iniciar sesión** con:
   - Email: el que recibió
   - Contraseña: la que aparece en el email

**Esta es la solución más práctica y no requiere cambios.**

### Solución 4: Usar OTP en lugar de enlace

Modificar el sistema para enviar un código OTP de 6 dígitos en lugar de un enlace.

## 🎯 Recomendación

**Para tu caso, recomiendo:**

1. **Inmediato:** Indica a los estudiantes que usen **login manual** (email + contraseña del correo)
   - Es más simple
   - No depende de enlaces que expiran
   - Ya tienen la contraseña en el email

2. **Configuración:** Ajusta las URLs en Supabase para evitar el error

3. **Opcional:** Modifica el email para enfatizar el login manual:

```html
<div class="info-box">
  <strong>💡 Cómo acceder:</strong>
  <p><strong>Opción 1 (Recomendada):</strong> Ve a <a href="http://localhost:8082/login">la página de login</a> y usa tu email y contraseña</p>
  <p><strong>Opción 2:</strong> Haz clic en el botón "Acceder al Sistema" (el enlace expira en 1 hora)</p>
</div>
```

## 📝 Modificar la Plantilla de Email

Para enfatizar el login manual sobre el enlace:

