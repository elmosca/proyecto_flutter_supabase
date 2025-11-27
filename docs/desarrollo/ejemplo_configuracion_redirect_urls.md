# 📋 Ejemplo Visual: Configuración de Redirect URLs en Supabase

Esta guía muestra exactamente cómo debe verse la configuración de Redirect URLs en Supabase Dashboard.

## 🎯 Configuración Correcta

### Paso 1: Acceder a la Configuración

1. Ve a tu proyecto en Supabase Dashboard
2. Navega a **Authentication** → **URL Configuration**
3. Verás dos secciones:
   - **Site URL**: URL base de tu aplicación
   - **Redirect URLs**: Lista de URLs permitidas para redirección

### Paso 2: Configurar Site URL

En el campo **"Site URL"**, ingresa la URL base de tu aplicación:

**Desarrollo:**
```
http://localhost:8080
```

**Producción:**
```
https://tu-dominio.com
```

### Paso 3: Añadir Redirect URLs

**Opción A: Configuración Específica (Recomendada para Producción)**

Haz clic en **"Add URL"** o el botón **"+"** y añade cada URL **una por una**:

```
http://localhost:8080/reset-password
http://localhost:8080/reset-password?type=setup
http://localhost:8080/reset-password?type=reset
```

**Opción B: Configuración con Wildcard (Más Simple para Desarrollo)**

Si prefieres una configuración más simple, puedes usar wildcards:

```
http://localhost:8080/**
```

El patrón `**` permite **cualquier ruta y parámetros** bajo ese dominio, incluyendo:
- `http://localhost:8080/reset-password`
- `http://localhost:8080/reset-password?type=setup`
- `http://localhost:8080/reset-password?type=reset`
- `http://localhost:8080/cualquier-otra-ruta`

## ✅ Ejemplo Visual de la Lista

Después de añadir las URLs, deberías ver algo así en la lista de **Redirect URLs**:

```
✓ http://localhost:8080/reset-password
✓ http://localhost:8080/reset-password?type=setup
✓ http://localhost:8080/reset-password?type=reset
✓ http://localhost:8080/**
```

O si usas la opción simple:

```
✓ http://localhost:8080/**
```

## ❌ Errores Comunes

### Error 1: Solo la ruta (sin protocolo y dominio)
```
❌ /reset-password
```

**Por qué está mal:** Supabase necesita la URL completa para validar la redirección.

### Error 2: Solo el dominio (sin protocolo)
```
❌ localhost:8080/reset-password
```

**Por qué está mal:** Falta el protocolo `http://` o `https://`.

### Error 3: Solo el nombre de la ruta
```
❌ reset-password
```

**Por qué está mal:** No es una URL válida.

## ✅ Formato Correcto

Todas las URLs deben seguir este formato:

```
[PROTOCOLO]://[DOMINIO]/[RUTA][?PARÁMETROS_OPCIONALES]
```

**Ejemplos correctos:**

```
http://localhost:8080/reset-password
http://localhost:8080/reset-password?type=setup
https://mi-app.com/reset-password
https://mi-app.com/reset-password?type=reset
```

## 🔍 Verificación

Para verificar que la configuración es correcta:

1. Guarda los cambios haciendo clic en **"Save changes"**
2. Verifica que todas las URLs aparezcan en la lista con un ✓
3. Prueba el flujo:
   - Crea un usuario nuevo
   - Verifica el email
   - Solicita reset de contraseña
   - Verifica que las redirecciones funcionen correctamente

## 📝 Notas Adicionales

- **Para desarrollo local:** Puedes usar `http://localhost:8080/**` para cubrir todas las rutas
- **Para producción:** Es recomendable ser más específico y listar las rutas exactas que necesitas
- **Wildcards:** El patrón `**` funciona como un "comodín" que permite cualquier ruta y parámetros bajo ese dominio
- **Parámetros de query:** Las URLs con `?type=setup` y `?type=reset` son diferentes y deben añadirse por separado (o usar el wildcard)

