# 🔐 Plan de Gestión de Credenciales de Supabase

## 📋 Objetivo

Mover las credenciales de Supabase (URL y Anon Key) fuera del código fuente para que **NO aparezcan en GitHub**, mientras se mantienen las credenciales de prueba de login (estudiante, tutor, admin) visibles en el código.

---

## 🎯 Estado Actual

### ❌ Problema Actual
- Las credenciales de Supabase estaban **hardcodeadas** en `frontend/lib/config/app_config.dart`:
  - `supabaseUrl`: `https://TU_PROYECTO_ID.supabase.co`
  - `supabaseAnonKey`: JWT token completo
- Estas credenciales aparecen en el código y se suben a GitHub
- Cualquiera que vea el código puede acceder a nuestra instancia de Supabase

### ✅ Lo que SÍ queremos mantener
- Credenciales de prueba de login (estudiante, tutor, admin) - **NO son sensibles**
- Estas son solo para facilitar el login durante desarrollo/pruebas

---

## 💡 Solución Propuesta

### Opción 1: Archivo de Configuración Local (RECOMENDADA)

**Ventajas:**
- ✅ Simple y directo
- ✅ No requiere paquetes adicionales
- ✅ Fácil de mantener
- ✅ Las credenciales solo existen localmente

**Implementación:**
1. Crear `frontend/lib/config/app_config_local.dart` (en `.gitignore`)
2. Este archivo contiene las credenciales reales
3. `app_config.dart` importa y usa valores de `app_config_local.dart` si existe
4. Si no existe, usa valores placeholder seguros

### Opción 2: Variables de Entorno con --dart-define

**Ventajas:**
- ✅ Estándar de Flutter
- ✅ Flexible para diferentes entornos

**Desventajas:**
- ⚠️ Requiere pasar parámetros cada vez que se ejecuta
- ⚠️ Más complejo para desarrollo diario

### Opción 3: Paquete flutter_dotenv

**Ventajas:**
- ✅ Lee archivos .env automáticamente
- ✅ Estándar en desarrollo

**Desventajas:**
- ⚠️ Requiere añadir dependencia
- ⚠️ Archivo .env debe estar en assets (complicado)

---

## 🚀 Implementación Recomendada: Opción 1

### Estructura de Archivos

```
frontend/lib/config/
├── app_config.dart              # Código público (en GitHub)
├── app_config_local.dart        # Credenciales reales (LOCAL, en .gitignore)
└── app_config_template.dart     # Plantilla para nuevos desarrolladores
```

### Flujo de Trabajo

1. **Desarrollo Local:**
   - Desarrollador crea `app_config_local.dart` con credenciales reales
   - La app funciona normalmente
   - Este archivo NO se sube a GitHub (está en .gitignore)

2. **GitHub/Repositorio Público:**
   - Solo existe `app_config.dart` con valores placeholder
   - Nuevos desarrolladores copian la plantilla y añaden sus credenciales

3. **Build/Deploy:**
   - En CI/CD, se pueden usar variables de entorno
   - O crear el archivo local con credenciales del entorno

---

## 📝 Plan de Implementación Paso a Paso

### Paso 1: Crear Archivo de Configuración Local

**Archivo:** `frontend/lib/config/app_config_local.dart`
```dart
// Este archivo contiene las credenciales reales de Supabase
// NO se sube a GitHub (está en .gitignore)
// Copia este archivo desde app_config_template.dart y completa con tus credenciales

class AppConfigLocal {
  // Credenciales reales de Supabase
  static const String supabaseUrl = 'https://TU_PROYECTO_ID.supabase.co';
  static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';
  
  // URLs de servicios
  static const String supabaseStudioUrl = 'https://supabase.com/dashboard/project/TU_PROYECTO_ID';
  static const String storageUrl = 'https://TU_PROYECTO_ID.supabase.co/storage/v1/s3';
}
```

### Paso 2: Modificar app_config.dart

**Cambios:**
- Intentar importar `app_config_local.dart`
- Si existe, usar valores de `AppConfigLocal`
- Si no existe, usar valores placeholder seguros
- Mantener credenciales de prueba de login visibles

### Paso 3: Crear Plantilla para Nuevos Desarrolladores

**Archivo:** `frontend/lib/config/app_config_template.dart`
```dart
// PLANTILLA: Copia este archivo a app_config_local.dart y completa con tus credenciales
// Obtén tus credenciales en: https://app.supabase.com/project/_/settings/api

class AppConfigLocal {
  static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';
  static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';
  static const String supabaseStudioUrl = 'https://supabase.com/dashboard/project/TU_PROYECTO_ID';
  static const String storageUrl = 'https://TU_PROYECTO.supabase.co/storage/v1/s3';
}
```

### Paso 4: Actualizar .gitignore

Añadir:
```
# Configuración local con credenciales reales
frontend/lib/config/app_config_local.dart
```

### Paso 5: Actualizar Documentación

- README.md con instrucciones para nuevos desarrolladores
- Guía de configuración inicial

---

## 🔧 Scripts de Automatización

### Script: setup-local-config.ps1
Crea `app_config_local.dart` desde la plantilla si no existe.

### Script: verify-config.ps1
Verifica que existe `app_config_local.dart` antes de ejecutar la app.

---

## ✅ Checklist de Implementación

- [ ] Crear `app_config_local.dart` con credenciales reales (local)
- [ ] Modificar `app_config.dart` para usar configuración local si existe
- [ ] Crear `app_config_template.dart` como plantilla
- [ ] Actualizar `.gitignore` para excluir `app_config_local.dart`
- [ ] Crear scripts de automatización
- [ ] Actualizar documentación (README.md)
- [ ] Probar que la app funciona localmente
- [ ] Verificar que en GitHub solo aparecen placeholders
- [ ] Eliminar credenciales hardcodeadas del historial (opcional, avanzado)

---

## 🚨 Seguridad Adicional

### Si las credenciales ya están en el historial de Git:

1. **Rotar credenciales en Supabase:**
   - Generar nuevas Anon Keys
   - Las antiguas dejarán de funcionar

2. **Limpiar historial (Opcional, Avanzado):**
   - Usar `git filter-branch` o `git filter-repo`
   - **ADVERTENCIA:** Requiere coordinación con todo el equipo

---

## 📚 Documentación para Desarrolladores

### Para Nuevos Desarrolladores:

1. Clonar el repositorio
2. Copiar `app_config_template.dart` a `app_config_local.dart`
3. Obtener credenciales de Supabase:
   - Ir a https://app.supabase.com
   - Seleccionar proyecto
   - Settings → API
   - Copiar URL y Anon Key
4. Completar `app_config_local.dart` con las credenciales
5. Ejecutar la aplicación normalmente

### Para CI/CD:

Usar variables de entorno:
```bash
flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

---

## 🎯 Resultado Final

### En GitHub:
- ✅ Solo placeholders seguros
- ✅ Credenciales de prueba de login visibles (OK)
- ✅ Instrucciones claras para nuevos desarrolladores

### Localmente:
- ✅ Credenciales reales en archivo local
- ✅ App funciona normalmente
- ✅ Archivo local NO se sube a GitHub

---

**Fecha de creación:** 2025-01-29  
**Estado:** Pendiente de implementación

