# 🔍 Análisis de Limpieza del Repositorio GitHub

## 📋 Resumen Ejecutivo

Este documento analiza qué archivos y directorios están actualmente en el repositorio de GitHub y cuáles deberían mantenerse para que un desarrollador pueda reproducir la aplicación.

**Fecha de análisis**: 2025-01-29

---

## ✅ **ARCHIVOS/DIRECTORIOS QUE DEBEN MANTENERSE**

### 1. **`frontend/`** - Aplicación Flutter Completa
**✅ MANTENER TODO** (excepto builds)
- `frontend/lib/` - Código fuente completo
- `frontend/pubspec.yaml` y `pubspec.lock` - Dependencias
- `frontend/android/`, `frontend/web/`, `frontend/windows/` - Configuración de plataformas
- `frontend/assets/` - Recursos (imágenes, fuentes, etc.)
- `frontend/test/` - Tests (documentación viva del comportamiento)
- `frontend/docker/` - Configuración Docker para despliegue
- `frontend/scripts/` - Scripts de build y utilidades
- `frontend/l10n.yaml` - Configuración de internacionalización
- `frontend/analysis_options.yaml` - Configuración de análisis de código

**❌ ELIMINAR:**
- `frontend/dist/` - Builds compilados (18 archivos: .dll, .exe, .so, .bin, .zip)
- `frontend/web-build.zip` - Build web comprimido
- `frontend/build/` - Builds temporales de Flutter
- `frontend/node_modules/` - Dependencias de Node (si existen)

### 2. **`docs/`** - Documentación
**✅ MANTENER:**
- `docs/base_datos/` - **CRÍTICO**: Migraciones y modelo de datos
- `docs/guias_usuario/` - Guías para usuarios finales
- `docs/despliegue/` - Guías de despliegue
- `docs/arquitectura/` - Documentación de arquitectura
- `docs/interfaz_api/` - Documentación de API

**⚠️ REVISAR (puede tener documentación desalineada):**
- `docs/desarrollo/` - Documentación de desarrollo interno
  - Mantener: `docs/desarrollo/01-configuracion/` (guías esenciales de setup)
  - Considerar eliminar: `docs/desarrollo/02-progreso/`, `03-guias-tecnicas/`, `04-despliegue/`, `05-historicos/` si están desactualizados

**❌ ELIMINAR:**
- `docs/Anteproyecto DAM-Juan Antonio Frances.pdf` - PDF grande, no esencial
- `docs/pruebas/` - Documentación de pruebas (opcional)

### 3. **`docs/base_datos/migraciones/`** - Migraciones SQL
**✅ MANTENER:**
- Todas las migraciones principales (46 archivos .sql)
- Scripts de rollback (útil para troubleshooting)
- `INDICE_MIGRACIONES.md` y `README.md` - Documentación

**⚠️ LIMPIAR:**
- `20250129000002_update_rls_policies_for_project_files_ALTERNATIVA_SEGURA.sql` - **Archivo alternativo, eliminar**
- `20250129000002_update_rls_policies_for_project_files_PUBLIC.sql` - **Archivo alternativo, eliminar**
- Mantener solo: `20250129000002_update_rls_policies_for_project_files.sql` (versión principal)

**💡 RECOMENDACIÓN:**
- Crear un script SQL unificado que aplique todas las migraciones en orden
- O documentar claramente el orden de ejecución

### 4. **`supabase/functions/`** - Edge Functions
**✅ MANTENER:**
- `supabase/functions/send-email/` - Edge function para envío de emails
- Necesario para funcionalidad de recuperación de contraseñas

### 5. **Archivos de Configuración Raíz**
**✅ MANTENER:**
- `README.md` - Documentación principal
- `LICENSE` - Licencia del proyecto
- `.gitignore` - Configuración de Git
- `CONTRIBUTING.md` - Guía de contribución
- `.cspell.json` - Configuración de corrección ortográfica

### 6. **Otros Directorios Útiles**
**✅ MANTENER:**
- `config/` - Solo contiene `.env.example` (sin valores reales)
- `ejemplos_csv/` - Ejemplos de CSV para importación masiva
- `wiki_setup/` - Wiki del proyecto (documentación estructurada)

---

## ❌ **ARCHIVOS/DIRECTORIOS QUE DEBEN ELIMINARSE**

### 1. **Builds y Artefactos Compilados**
- `frontend/dist/` - **18 archivos** (binarios compilados)
- `frontend/web-build.zip` - Build web comprimido
- `build/` (en raíz) - Builds temporales de CMake
- Cualquier otro archivo `.zip`, `.dll`, `.exe`, `.so`, `.bin` en el repositorio

### 2. **Scripts de Desarrollo Temporal**
- `refactor_anteprojects.py`
- `refactor_files.py`
- `refactor_remaining_services.py`
- `refactor_tasks.py`
- `scripts/` - Scripts de desarrollo interno (no necesarios para reproducir la app)

### 3. **Dependencias y Módulos**
- `node_modules/` (en raíz o en subdirectorios)
- `mcp-resend/` - Ya está en `.gitignore`, pero verificar que no esté rastreado
- `mcp-server/` - Ya está en `.gitignore`, pero verificar que no esté rastreado

### 4. **Archivos Duplicados**
- `estudiantes_ejemplo.csv` (en raíz) - Ya existe en `ejemplos_csv/`

### 5. **Archivos de Configuración No Necesarios**
- `package.json` y `package-lock.json` (en raíz) - No se usa Node.js en el proyecto principal

### 6. **Migraciones Alternativas**
- `20250129000002_update_rls_policies_for_project_files_ALTERNATIVA_SEGURA.sql`
- `20250129000002_update_rls_policies_for_project_files_PUBLIC.sql`

---

## 📊 **ESTADÍSTICAS**

### Archivos Problemáticos Encontrados:
- **Builds rastreados**: 18 archivos en `frontend/dist/` + 1 archivo `.zip`
- **Scripts temporales**: 4 archivos Python de refactorización
- **Migraciones alternativas**: 2 archivos SQL duplicados
- **Archivos duplicados**: 1 CSV en raíz

### Ramas Afectadas:
- ✅ `main` - Contiene archivos de build
- ✅ `develop` - Contiene archivos de build
- ✅ `backup-supabase-local` - No contiene builds (limpia)

---

## 🎯 **PLAN DE ACCIÓN RECOMENDADO**

### Fase 1: Actualizar `.gitignore`
1. Añadir reglas para ignorar:
   - `**/dist/`
   - `**/*-build.zip`
   - `**/*.zip` (o ser más específico)
   - `build/` (en raíz)

### Fase 2: Limpiar Archivos en Repositorio
1. Eliminar archivos de build rastreados
2. Eliminar scripts temporales de refactorización
3. Eliminar migraciones alternativas
4. Eliminar archivos duplicados

### Fase 3: Unificar Migraciones (Opcional)
1. Crear un script SQL maestro que ejecute todas las migraciones en orden
2. O documentar claramente el orden de ejecución en `README.md`

### Fase 4: Limpiar Historial de Git (Opcional, Avanzado)
1. Usar `git filter-branch` o `git filter-repo` para eliminar archivos grandes del historial
2. **ADVERTENCIA**: Esto reescribe el historial y requiere coordinación con todos los colaboradores

---

## 📝 **ESTRUCTURA FINAL RECOMENDADA**

```
proyecto_flutter_supabase/
├── .gitignore
├── .cspell.json
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── config/
│   ├── .gitkeep
│   ├── cloudflare.env.example
│   └── db.env.example
├── frontend/              # ✅ COMPLETO (sin builds)
│   ├── lib/
│   ├── test/
│   ├── android/
│   ├── web/
│   ├── windows/
│   ├── assets/
│   ├── docker/
│   ├── scripts/
│   ├── pubspec.yaml
│   └── ...
├── docs/
│   ├── base_datos/
│   │   ├── migraciones/   # ✅ Todas las migraciones (sin alternativas)
│   │   └── modelo_datos.md
│   ├── guias_usuario/
│   ├── despliegue/
│   ├── arquitectura/
│   └── desarrollo/         # ⚠️ Revisar y limpiar
├── supabase/
│   └── functions/
│       └── send-email/
├── ejemplos_csv/
├── wiki_setup/
└── [Ningún otro archivo/directorio]
```

---

## ⚠️ **ADVERTENCIAS**

1. **No eliminar archivos sin hacer backup**: Asegúrate de tener una copia local antes de eliminar
2. **Coordinación con equipo**: Si trabajas en equipo, coordina la limpieza
3. **Historial de Git**: Eliminar archivos del historial requiere reescritura y puede afectar a otros colaboradores
4. **Migraciones**: No eliminar migraciones que ya se han aplicado en producción sin verificar primero

---

## 🔄 **PRÓXIMOS PASOS**

1. ✅ Revisar este análisis
2. ⏳ Actualizar `.gitignore`
3. ⏳ Eliminar archivos de build rastreados
4. ⏳ Limpiar migraciones alternativas
5. ⏳ Revisar documentación desalineada en `docs/desarrollo/`
6. ⏳ (Opcional) Crear script SQL unificado para migraciones

---

**Última actualización**: 2025-01-29

