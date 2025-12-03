# Variables de Entorno para Tests

Este documento describe las variables de entorno que se pueden usar para configurar los tests de integración.

## Variables de Supabase

### `SUPABASE_URL`
URL del proyecto de Supabase para los tests.

**Ejemplo:**
```bash
--dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co
```

**Por defecto:** `http://localhost:54321` (Supabase local)

### `SUPABASE_ANON_KEY`
Anon Key (clave pública) del proyecto de Supabase para los tests.

**Ejemplo:**
```bash
--dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Por defecto:** Key de demo de Supabase local

## Variables de Usuario de Prueba

### `TEST_USER_EMAIL`
Email del usuario de prueba para tests de autenticación.

**Ejemplo:**
```bash
--dart-define=TEST_USER_EMAIL=test@example.com
```

**Por defecto:** `carlos.lopez@alumno.cifpcarlos3.es` (en algunos tests)

### `TEST_USER_PASSWORD`
Contraseña del usuario de prueba para tests de autenticación.

**Ejemplo:**
```bash
--dart-define=TEST_USER_PASSWORD=password123
```

**Por defecto:** `password123` (en algunos tests)

## Cómo Usar

### Ejecutar tests con variables de entorno

```bash
# Desde el directorio frontend
flutter test test/integration/auth_integration_test.dart \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_anon_key \
  --dart-define=TEST_USER_EMAIL=test@example.com \
  --dart-define=TEST_USER_PASSWORD=password123
```

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

## Notas Importantes

1. **Seguridad**: Nunca subas credenciales reales a GitHub. Usa secrets en CI/CD.

2. **Valores por defecto**: Los valores por defecto están pensados para desarrollo local con Supabase local. Para producción o CI/CD, siempre usa variables de entorno.

3. **Prioridad**: Las variables de entorno tienen prioridad sobre los valores por defecto.

4. **Tests de integración**: Los tests de integración que requieren conexión real a Supabase necesitan estas variables configuradas correctamente.

