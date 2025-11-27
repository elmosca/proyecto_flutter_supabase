# 🚀 Estrategia de Merge a Producción (main)

## 🎯 Objetivo

Hacer merge selectivo desde `develop` a `main`, incluyendo solo archivos esenciales para producción y excluyendo documentación de desarrollo interno, tests, y artefactos de build.

---

## ✅ Archivos INCLUIDOS en Producción

### **1. Aplicación Flutter (Código Fuente Completo)**
- ✅ `frontend/lib/` - Todo el código fuente de la aplicación
- ✅ `frontend/pubspec.yaml` - Dependencias
- ✅ `frontend/pubspec.lock` - Versiones bloqueadas
- ✅ `frontend/l10n.yaml` - Configuración de internacionalización
- ✅ `frontend/analysis_options.yaml` - Configuración de análisis
- ✅ `frontend/dartdoc_options.yaml` - Configuración de documentación

### **2. Assets y Recursos**
- ✅ `frontend/assets/` - Todos los assets (imágenes, fuentes, etc.)

### **3. Configuración de Plataformas**
- ✅ `frontend/web/` - Configuración web
- ✅ `frontend/windows/` - Configuración Windows Desktop
- ✅ `frontend/android/` - Configuración Android

### **4. Docker y Despliegue**
- ✅ `frontend/docker/` - Configuración Docker completa
- ✅ `frontend/scripts/build-windows-release.ps1` - Script de construcción Windows
- ✅ `frontend/scripts/README.md` - Documentación de scripts

### **5. Wiki del Proyecto**
- ✅ `wiki_setup/` - **Wiki completa del proyecto** (documentación para usuarios)
  - Guías de inicio rápido
  - Guías por rol (estudiantes, tutores)
  - FAQ y documentación general

### **6. Documentación de Desarrollo Esencial**
- ✅ `docs/desarrollo/01-configuracion/` - **Guías esenciales de setup para desarrolladores**
  - `guia_inicio_frontend.md` - Guía de inicio rápida
  - `android_setup.md` - Configuración Android
  - `CLEAN_STATE_GUIDE.md` - Mejores prácticas
- ✅ `docs/desarrollo/README.md` - Índice de documentación de desarrollo

### **7. Tests (Documentación Viva)**
- ✅ `frontend/test/` - **Tests del proyecto**
  - Ejemplos de uso de servicios y widgets
  - Validación de funcionalidades
  - Documentación viva del comportamiento esperado

### **8. Base de Datos**
- ✅ `docs/base_datos/migraciones/` - **Todas las migraciones SQL**
- ✅ `docs/base_datos/modelo_datos.md` - **Modelo de datos completo**

### **9. Documentación Esencial**
- ✅ `docs/guias_usuario/` - Guías para usuarios finales (estudiantes, tutores, admin)
- ✅ `docs/despliegue/` - Guías de despliegue y troubleshooting
- ✅ `docs/arquitectura/login.md` - Arquitectura de login
- ✅ `docs/arquitectura/registro_usuarios_por_roles.md` - Arquitectura de registro

### **10. Ejemplos y Templates**
- ✅ `ejemplos_csv/` - Ejemplos de CSV para importación masiva

### **11. Edge Functions**
- ✅ `supabase/functions/` - Edge Functions de Supabase

### **12. Archivos de Configuración Raíz**
- ✅ `README.md` - **Documentación principal del proyecto**
- ✅ `LICENSE` - **Licencia del proyecto**
- ✅ `.gitignore` - Configuración de Git
- ✅ `config/*.example` - Ejemplos de configuración (sin valores reales)

---

## ❌ Archivos EXCLUIDOS de Producción

### **1. Builds y Artefactos**
- ❌ `frontend/build/` - Builds de Flutter
- ❌ `frontend/dist/` - Distribuciones compiladas
- ❌ `frontend/web-build.zip` - ZIP de build web
- ❌ `build/` - Builds temporales

### **2. Tests (Parcialmente Incluido)**
- ✅ `frontend/test/` - **Tests incluidos** (documentación viva del comportamiento)
- ❌ `docs/pruebas/` - Documentación de pruebas (excluida)

### **3. Documentación de Desarrollo (Parcialmente Incluida)**
- ✅ `docs/desarrollo/01-configuracion/` - **Guías esenciales de setup** (incluidas)
- ✅ `docs/desarrollo/README.md` - **Índice de documentación** (incluido)
- ❌ `docs/desarrollo/02-progreso/` - Seguimiento interno (excluido)
- ❌ `docs/desarrollo/03-guias-tecnicas/` - Guías técnicas internas (excluido)
- ❌ `docs/desarrollo/04-despliegue/` - Despliegue interno (excluido, usar docs/despliegue/)
- ❌ `docs/desarrollo/05-historicos/` - Documentos históricos (excluido)
- ❌ Archivos sueltos en `docs/desarrollo/` - Troubleshooting interno (excluido)
- ❌ `docs/Anteproyecto*.pdf` - Documentos de anteproyecto (excluido)

### **4. Scripts de Desarrollo**
- ❌ `scripts/` - Scripts de desarrollo y testing (excepto scripts de despliegue)
- ❌ `refactor_*.py` - Scripts de refactorización

### **5. Archivos Temporales**
- ❌ `*.log` - Logs
- ❌ `frontend/*.iml` - Archivos de IDE
- ❌ `frontend/untranslated_messages.txt` - Archivos temporales

### **7. Dependencias**
- ❌ `node_modules/` - Dependencias de Node.js
- ❌ `frontend/node_modules/` - Dependencias de frontend

### **8. Configuración Local**
- ❌ `config/*.env` - Variables de entorno (solo mantener .example)

---

## 🔄 Proceso de Merge

### **Opción 1: Script Automatizado (Recomendado)**

```powershell
# 1. Ver qué se haría (dry-run)
.\scripts\merge-to-production.ps1 -DryRun

# 2. Ejecutar el merge selectivo
.\scripts\merge-to-production.ps1

# 3. Revisar los cambios
git diff develop..production-merge-*

# 4. Si todo está bien, merge a main
git checkout main
git merge production-merge-* --no-ff -m "chore: Merge a producción - versión limpia"

# 5. Push a main
git push origin main

# 6. Eliminar rama temporal
git branch -d production-merge-*
```

### **Opción 2: Manual (Cherry-pick Selectivo)**

```powershell
# 1. Crear rama desde main
git checkout main
git pull origin main
git checkout -b production-merge

# 2. Merge selectivo de archivos específicos
git checkout develop -- frontend/lib/
git checkout develop -- frontend/pubspec.yaml
git checkout develop -- frontend/docker/
git checkout develop -- docs/guias_usuario/
git checkout develop -- docs/despliegue/
# ... etc

# 3. Commit
git commit -m "chore: Merge selectivo a producción"

# 4. Merge a main
git checkout main
git merge production-merge --no-ff
git push origin main
```

---

## 📊 Comparación de Tamaños

### **Rama develop (completa):**
- Archivos totales: ~500+ archivos
- Tamaño aproximado: ~100 MB (con builds)

### **Rama main (producción limpia):**
- Archivos totales: ~280-330 archivos (incluye wiki, base de datos, docs desarrollo esenciales y tests)
- Tamaño aproximado: ~10-15 MB (sin builds)

**Reducción:** ~90% menos archivos, ~90% menos tamaño

---

## ✅ Checklist Pre-Merge

Antes de hacer merge a main, verificar:

- [ ] Todos los tests pasan en develop
- [ ] La aplicación funciona correctamente en develop
- [ ] No hay archivos sensibles (contraseñas, keys) en el código
- [ ] La documentación de usuario está actualizada
- [ ] Las guías de despliegue están actualizadas
- [ ] Los scripts de construcción funcionan
- [ ] Se ha probado la construcción para Windows/Web

---

## 🔍 Verificación Post-Merge

Después del merge, verificar:

```bash
# Verificar que main tiene los archivos correctos
git checkout main
git ls-files | wc -l  # Debe ser ~200-250

# Verificar que no hay builds
git ls-files | grep -E "(build/|dist/|\.zip$)"  # No debe haber resultados

# Verificar estructura
tree -L 2 -I 'node_modules|build|dist'  # Ver estructura limpia
```

---

## 📝 Notas Importantes

1. **No hacer merge directo:** Siempre usar una rama intermedia para revisar
2. **Revisar cambios:** Siempre revisar `git diff` antes de mergear
3. **Tags de versión:** Considerar crear un tag después del merge: `git tag v1.0.0`
4. **Documentación:** Mantener solo documentación relevante para producción
5. **Historial:** El historial de commits se mantiene, solo se eliminan archivos

---

## 🚨 Rollback

Si algo sale mal:

```bash
# Revertir el merge
git checkout main
git reset --hard origin/main

# O revertir el commit de merge
git revert -m 1 <commit-hash>
```

---

**Última actualización:** Enero 2025

