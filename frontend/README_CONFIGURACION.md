# 🔧 Configuración de Credenciales de Supabase

## 📋 Instrucciones para Nuevos Desarrolladores

Para que la aplicación funcione, necesitas configurar tus credenciales de Supabase.

### Paso 1: Obtener Credenciales de Supabase

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto (o crea uno nuevo)
3. Ve a **Settings** → **API**
4. Copia los siguientes valores:
   - **Project URL**: `https://TU_PROYECTO_ID.supabase.co`
   - **anon public key**: La clave que empieza con `eyJ...`

### Paso 2: Configurar Credenciales Localmente

**Opción A: Usar el script automático (Recomendado)**

```powershell
# Desde la raíz del proyecto
powershell -ExecutionPolicy Bypass -File scripts/setup-local-config.ps1
```

Luego edita `frontend/lib/config/app_config_local.dart` y completa los valores.

**Opción B: Manual**

1. Copia `frontend/lib/config/app_config_template.dart` a `frontend/lib/config/app_config_local.dart`
2. Abre `frontend/lib/config/app_config_local.dart`
3. Reemplaza:
   - `TU_PROYECTO` → Tu Project ID de Supabase
   - `TU_ANON_KEY_AQUI` → Tu anon key de Supabase
   - `TU_PROYECTO_ID` → Tu Project ID (en las URLs)

### Paso 3: Verificar Configuración

Ejecuta la aplicación:

```bash
cd frontend
flutter run
```

Si todo está correcto, la aplicación se conectará a Supabase sin problemas.

---

## 🔒 Seguridad

- ✅ El archivo `app_config_local.dart` **NO se sube a GitHub** (está en `.gitignore`)
- ✅ En GitHub solo aparecen valores placeholder seguros
- ✅ Cada desarrollador tiene sus propias credenciales localmente

---

## 🚨 Solución de Problemas

### Error: "Cannot find module 'app_config_local.dart'"

**Solución:** Crea el archivo desde la plantilla:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup-local-config.ps1
```

### Error de conexión a Supabase

**Verifica:**
1. Las credenciales en `app_config_local.dart` son correctas
2. Tu proyecto de Supabase está activo
3. La URL tiene el formato correcto: `https://PROYECTO_ID.supabase.co`

---

## 📝 Notas

- Las **credenciales de prueba de login** (estudiante, tutor, admin) **SÍ están visibles** en el código - esto es intencional y no es un problema de seguridad
- Solo las credenciales de **conexión a Supabase** están ocultas

