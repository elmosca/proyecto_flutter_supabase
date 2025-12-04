# Variables de Entorno para Tests

Este documento describe las variables de entorno que se pueden usar para configurar los tests de integración.

## Configuración de Supabase

Las credenciales de Supabase se cargan desde un archivo `.env` ubicado en el directorio `frontend/`. Este archivo contiene las credenciales necesarias para conectarse al proyecto de Supabase.

### Archivo `.env`

Crea un archivo `.env` en el directorio `frontend/` con el siguiente formato:

```bash
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anon_key_completa_aqui
```

**⚠️ Importante - Seguridad:**
- El archivo `.env` está en `.gitignore` y no se sube a GitHub
- **Nunca incluyas credenciales reales en el repositorio o en la documentación**
- Para desarrollo local, copia el archivo `.env.example` (si existe) y completa con tus credenciales reales
- Obtén tus credenciales reales desde el dashboard de Supabase (Settings > API)
- Aunque la anon key es pública por diseño, trata todas las credenciales con cuidado

### Variables de Supabase

#### `SUPABASE_URL`
URL del proyecto de Supabase para los tests.

**Ejemplo:**
```bash
SUPABASE_URL=https://tu-proyecto.supabase.co
```

**Por defecto:** `http://localhost:54321` (Supabase local)

#### `SUPABASE_ANON_KEY`
Anon Key (clave pública) del proyecto de Supabase para los tests.

**⚠️ Nota de Seguridad:** Aunque la anon key está diseñada para ser pública (se expone en el frontend), nunca uses claves reales en ejemplos o documentación. Siempre usa placeholders.

**Ejemplo:**
```bash
SUPABASE_ANON_KEY=tu_clave_anon_key_aqui_completa
```

**Formato esperado:** La anon key es un token JWT. Puedes encontrarla en el dashboard de Supabase en Settings > API.

**Por defecto:** Key de demo de Supabase local (solo para desarrollo local)

## Variables de Usuario de Prueba

### `TEST_USER_EMAIL`
Email del usuario de prueba para tests de autenticación.

**⚠️ Restricción de Dominio:** El sistema está configurado para aceptar únicamente emails del dominio `jualas.es`. Todos los usuarios de prueba deben tener un email de este dominio.

**Ejemplo:**
```bash
--dart-define=TEST_USER_EMAIL=usuario@jualas.es
```

**Por defecto:** `laura.sanchez@jualas.es` (en algunos tests)

### `TEST_USER_PASSWORD`
Contraseña del usuario de prueba para tests de autenticación.

**Ejemplo:**
```bash
--dart-define=TEST_USER_PASSWORD=password123
```

**Por defecto:** `password123` (en algunos tests)

## Restricción de Dominio

El sistema tiene implementada una restricción que **solo permite el registro de usuarios con emails del dominio `jualas.es`**. Esta validación se aplica tanto en el frontend como en el backend.

**Emails válidos:**
- ✅ `usuario@jualas.es`
- ✅ `estudiante@jualas.es`
- ✅ `tutor@jualas.es`

**Emails inválidos:**
- ❌ `usuario@example.com`
- ❌ `test@gmail.com`
- ❌ Cualquier otro dominio que no sea `jualas.es`

Esta restricción asegura que solo miembros de la institución puedan registrarse en el sistema.

## Cómo Usar

### Opción 1: Usar archivo `.env` (Recomendado)

1. Crea el archivo `.env` en `frontend/` con tus credenciales
2. Ejecuta los tests normalmente:

```bash
# Desde el directorio frontend
flutter test test/integration/auth_integration_test.dart
```

Las credenciales se cargarán automáticamente desde el archivo `.env`.

### Opción 2: Variables de entorno con `--dart-define`

Si prefieres pasar las variables directamente al comando:

```bash
# Desde el directorio frontend
flutter test test/integration/auth_integration_test.dart \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_clave_anon_key_completa \
  --dart-define=TEST_USER_EMAIL=usuario@jualas.es \
  --dart-define=TEST_USER_PASSWORD=password123
```

**Nota:** Recuerda que `TEST_USER_EMAIL` debe ser del dominio `jualas.es`.

### Ejecutar tests con Supabase local (por defecto)

```bash
# No necesitas pasar variables, se usan valores por defecto
flutter test test/integration/auth_integration_test.dart
```

### Configurar en CI/CD

En GitHub Actions o similar, puedes configurar las variables como secrets:

```yaml
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
  TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
```

Y luego pasarlas al comando:

```yaml
run: |
  flutter test test/integration/auth_integration_test.dart \
    --dart-define=SUPABASE_URL=${{ env.SUPABASE_URL }} \
    --dart-define=SUPABASE_ANON_KEY=${{ env.SUPABASE_ANON_KEY }} \
    --dart-define=TEST_USER_EMAIL=${{ env.TEST_USER_EMAIL }} \
    --dart-define=TEST_USER_PASSWORD=${{ env.TEST_USER_PASSWORD }}
```

**Importante:** Asegúrate de que `TEST_USER_EMAIL` en los secrets sea del dominio `jualas.es`.

## Notas Importantes

1. **Seguridad**: Nunca subas credenciales reales a GitHub. Usa secrets en CI/CD y mantén el archivo `.env` en `.gitignore`.

2. **Valores por defecto**: Los valores por defecto están pensados para desarrollo local con Supabase local. Para producción o CI/CD, siempre usa variables de entorno o el archivo `.env`.

3. **Prioridad**: Las variables de entorno pasadas con `--dart-define` tienen prioridad sobre el archivo `.env`, y este tiene prioridad sobre los valores por defecto.

4. **Tests de integración**: Los tests de integración que requieren conexión real a Supabase necesitan estas variables configuradas correctamente.

5. **Dominio autorizado**: Todos los usuarios de prueba deben tener emails del dominio `jualas.es`. Esta es una restricción de seguridad del sistema.

