# 🔧 Configurar Redirect URLs en Supabase para Reset Password

## 🐛 El Problema Actual

La URL que llega es:
```
http://localhost:8082/?code=07d512e9-28af-4c03-9d1d-00fbec1fea16#/login
```

**Debería ser:**
```
http://localhost:8082/reset-password?code=07d512e9-28af-4c03-9d1d-00fbec1fea16&type=reset
```

**Causa:** Supabase está ignorando el `redirectTo` que enviamos porque:
1. La URL no está en la lista de Redirect URLs permitidas
2. Está usando la URL por defecto configurada en Supabase

## ✅ Solución: Configurar Supabase

### Paso 1: Acceder a Configuración

1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Ve a: **Authentication** → **URL Configuration**

### Paso 2: Configurar Site URL

En el campo **"Site URL"**, configura:

```
https://fct.jualas.es
```

**⚠️ Importante:** 
- No pongas `/` al final
- Usa el dominio de producción

### Paso 3: Configurar Redirect URLs

En la sección **"Redirect URLs"**, añade estas URLs (una por línea):

```
https://fct.jualas.es/**
https://fct.jualas.es/reset-password
https://fct.jualas.es/reset-password?type=reset
http://localhost:8082/**
http://localhost:8082/reset-password
http://localhost:8082/reset-password?type=reset
```

**📸 Debería verse así:**

```
┌─────────────────────────────────────────────┐
│ Redirect URLs                               │
├─────────────────────────────────────────────┤
│ https://fct.jualas.es/**                    │
│ https://fct.jualas.es/reset-password        │
│ https://fct.jualas.es/reset-password?type=reset │
│ http://localhost:8082/**                    │
│ http://localhost:8082/reset-password        │
│ http://localhost:8082/reset-password?type=reset │
└─────────────────────────────────────────────┘
```

### Paso 4: Guardar Cambios

1. Haz clic en **"Save"** o **"Guardar"**
2. Espera unos segundos a que se apliquen los cambios

## 🧪 Probar los Cambios

### Test 1: Verificar Configuración

1. Refresca la página de configuración en Supabase
2. Verifica que las URLs están guardadas correctamente

### Test 2: Solicitar Nuevo Enlace

**⚠️ IMPORTANTE:** Debes solicitar un **NUEVO** enlace. Los enlaces anteriores no funcionarán.

1. Ve a http://localhost:8082/login
2. Haz clic en "¿Olvidaste tu contraseña?"
3. Introduce: `juanantonio.frances.perez@gmail.com`
4. Envía

### Test 3: Verificar el Email

1. Abre el email recibido
2. **NO hagas clic todavía**
3. Pasa el mouse sobre el botón "🔒 Restablecer mi contraseña"
4. En la parte inferior del navegador, verás la URL de destino

**✅ URL correcta (debería ser algo como):**
```
https://fct.jualas.es/reset-password?token=...
```

**O en desarrollo:**
```
http://localhost:8082/reset-password?token=...
```

**❌ URL incorrecta (si ves esto, Supabase aún no tiene la configuración):**
```
http://localhost:8082/?code=...
```

### Test 4: Hacer Clic en el Enlace

1. Abre las DevTools (F12) → Pestaña "Console"
2. Haz clic en el enlace del email

**✅ Deberías ver:**
- URL: `http://localhost:8082/reset-password?code=...&type=reset`
- Pantalla: Formulario de cambio de contraseña
- Logs en consola:
  ```
  🔐 Solicitando reset de contraseña para: juanantonio.frances.perez@gmail.com
  📧 URL de redirect: https://fct.jualas.es/reset-password?type=reset
  ✅ Email de reset de contraseña enviado
  ```

## 🔍 Troubleshooting

### Problema: La URL sigue siendo `/?code=...`

**Causa:** Los cambios en Supabase aún no se aplicaron o la URL no está en la lista.

**Solución:**
1. Espera 1-2 minutos
2. Refresca la configuración en Supabase Dashboard
3. Verifica que las URLs están **exactamente** como se muestran arriba
4. Solicita un **NUEVO** enlace (los antiguos no cambiarán)

### Problema: Error "Invalid Redirect URL"

**Causa:** La URL que intentas usar no está en la lista de Redirect URLs.

**Solución:**
1. Ve a Authentication → URL Configuration
2. Asegúrate de que `http://localhost:8082/reset-password` está en la lista
3. Asegúrate de que `http://localhost:8082/**` está en la lista
4. Guarda y espera unos segundos
5. Solicita un nuevo enlace

### Problema: Sigue redirigiendo a login

**Causa:** Incluso con la URL correcta, el router está interfiriendo.

**Solución:** Ya tenemos esto cubierto en el código. Una vez que la URL sea correcta (`/reset-password` en lugar de `/`), el problema se resolverá.

## 📋 Checklist

- [ ] Site URL configurado: `https://fct.jualas.es`
- [ ] Redirect URLs añadidas:
  - [ ] `https://fct.jualas.es/**`
  - [ ] `https://fct.jualas.es/reset-password`
  - [ ] `https://fct.jualas.es/reset-password?type=reset`
  - [ ] `http://localhost:8082/**`
  - [ ] `http://localhost:8082/reset-password`
  - [ ] `http://localhost:8082/reset-password?type=reset`
- [ ] Cambios guardados en Supabase
- [ ] Esperado 1-2 minutos
- [ ] Solicitado **nuevo** enlace de recuperación
- [ ] Email recibido
- [ ] URL del enlace verificada (pasa mouse sobre botón)
- [ ] URL contiene `/reset-password` (no solo `/?code=...`)

## 🎯 Resultado Esperado

Después de la configuración:

```
Solicitar recuperación
    ↓
Supabase envía email con URL:
https://fct.jualas.es/reset-password?token=abc123&type=reset
    ↓
Usuario hace clic
    ↓
Navegador navega a:
http://localhost:8082/reset-password?code=abc123&type=reset
(si estás en desarrollo local)
    ↓
ResetPasswordScreen se carga
    ↓
✅ Muestra formulario de cambio de contraseña
```

## 📸 Captura de Configuración

Tu configuración en Supabase debería verse así:

```
┌────────────────────────────────────────────────────────┐
│ Authentication Settings                                 │
├────────────────────────────────────────────────────────┤
│ Site URL                                                │
│ ┌────────────────────────────────────────────────────┐ │
│ │ https://fct.jualas.es                              │ │
│ └────────────────────────────────────────────────────┘ │
│                                                          │
│ Redirect URLs                                            │
│ ┌────────────────────────────────────────────────────┐ │
│ │ https://fct.jualas.es/**                           │ │
│ │ https://fct.jualas.es/reset-password               │ │
│ │ https://fct.jualas.es/reset-password?type=reset    │ │
│ │ http://localhost:8082/**                           │ │
│ │ http://localhost:8082/reset-password               │ │
│ │ http://localhost:8082/reset-password?type=reset    │ │
│ └────────────────────────────────────────────────────┘ │
│                                                          │
│ [Save] [Cancel]                                          │
└────────────────────────────────────────────────────────┘
```

## ⚡ Acción Inmediata

**POR FAVOR, HAZ ESTO AHORA:**

1. Ve a Supabase Dashboard: https://supabase.com/dashboard
2. Authentication → URL Configuration
3. Añade las URLs mostradas arriba
4. Guarda
5. Espera 1 minuto
6. Solicita un **NUEVO** enlace de recuperación
7. Verifica que la URL ahora contiene `/reset-password`

---

**Una vez configurado, compárteme la URL que aparece en el email** (pasa el mouse sobre el botón y copia la URL de la esquina inferior del navegador). Así confirmaré que Supabase está usando la configuración correcta.

