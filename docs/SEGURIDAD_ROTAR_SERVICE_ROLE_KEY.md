# 🔐 Guía de Emergencia: Rotar Service Role Key de Supabase

## ⚠️ PROBLEMA DETECTADO

GitGuardian ha detectado que tu **Service Role Key** de Supabase fue expuesta en el repositorio público de GitHub.

**Fecha de exposición**: 2 de diciembre de 2025, 17:00:50 UTC

## 🚨 ACCIÓN INMEDIATA REQUERIDA

### Paso 1: Rotar la Service Role Key en Supabase (URGENTE)

1. **Accede a tu Dashboard de Supabase**:
   - Ve a: https://supabase.com/dashboard/project/zkririyknhlwoxhsoqih/settings/api

2. **Genera una nueva Service Role Key**:
   - En la sección "Project API keys"
   - Busca la clave "service_role" (secret)
   - Haz clic en "Reset" o "Regenerate"
   - **COPIA LA NUEVA CLAVE INMEDIATAMENTE** (solo se muestra una vez)

3. **Actualiza todas las Edge Functions**:
   - Ve a: Supabase Dashboard → Edge Functions
   - Para cada Edge Function que use `SUPABASE_SERVICE_ROLE_KEY`:
     - Ve a Settings → Secrets
     - Actualiza el secret `SUPABASE_SERVICE_ROLE_KEY` con la nueva clave

4. **Verifica que las Edge Functions funcionen**:
   - Prueba cada Edge Function después de actualizar el secret
   - Revisa los logs para asegurarte de que no hay errores

### Paso 2: Limpiar el Historial de Git

**IMPORTANTE**: La clave antigua sigue estando en el historial de Git aunque ya no esté en el código actual.

#### Opción A: Usar git-filter-repo (Recomendado)

```bash
# Instalar git-filter-repo si no lo tienes
pip install git-filter-repo

# Eliminar la clave del historial completo
# Reemplaza 'TU_SERVICE_ROLE_KEY_EXPUESTA' con la clave real que fue expuesta
git filter-repo --invert-paths --path frontend/lib/config/app_config_local.dart --force

# O si la clave está en otro archivo, especifica ese archivo
```

#### Opción B: Usar BFG Repo-Cleaner (Alternativa)

```bash
# Descargar BFG: https://rtyley.github.io/bfg-repo-cleaner/

# Crear un archivo con la clave a eliminar
echo "TU_SERVICE_ROLE_KEY_EXPUESTA" > keys-to-remove.txt

# Limpiar el repositorio
java -jar bfg.jar --replace-text keys-to-remove.txt

# Limpiar referencias
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

#### Opción C: Forzar Push (Último recurso - CUIDADO)

⚠️ **SOLO si trabajas solo o tienes permiso del equipo**:

```bash
# Esto reescribe el historial - todos los colaboradores necesitarán re-clonar
git push origin --force --all
git push origin --force --tags
```

### Paso 3: Verificar que no queden secretos

1. **Buscar en el código actual**:
   ```bash
   # Buscar posibles JWT tokens
   grep -r "eyJ" --include="*.dart" --include="*.ts" --include="*.js" frontend/
   ```

2. **Verificar .gitignore**:
   - Asegúrate de que `app_config_local.dart` está en `.gitignore`
   - Verifica que no hay archivos `.env` con credenciales

3. **Usar GitGuardian CLI**:
   ```bash
   # Instalar ggshield
   pip install ggshield

   # Escanear el repositorio
   ggshield scan repo .
   ```

### Paso 4: Prevenir futuros problemas

1. **Usar GitHub Secrets para CI/CD**:
   - Ve a: GitHub → Settings → Secrets and variables → Actions
   - Añade `SUPABASE_SERVICE_ROLE_KEY` como secret
   - Nunca hardcodees secretos en el código

2. **Usar pre-commit hooks**:
   ```bash
   # Instalar pre-commit
   pip install pre-commit

   # Configurar ggshield en .pre-commit-config.yaml
   ```

3. **Revisar antes de hacer commit**:
   - Nunca hagas commit de archivos con credenciales
   - Usa `git status` antes de `git add`
   - Verifica que `.gitignore` funciona correctamente

## 📋 Checklist de Verificación

- [ ] Service Role Key rotada en Supabase Dashboard
- [ ] Todas las Edge Functions actualizadas con la nueva clave
- [ ] Edge Functions probadas y funcionando correctamente
- [ ] Historial de Git limpiado (o planificado)
- [ ] Código actual verificado (sin secretos)
- [ ] `.gitignore` verificado y actualizado
- [ ] Colaboradores notificados (si aplica)
- [ ] GitGuardian verificado (la alerta debería desaparecer)

## 🔍 Cómo encontrar la clave expuesta en el historial

Si necesitas encontrar exactamente dónde se expuso:

```bash
# Buscar en todo el historial de Git
git log -S "eyJ" --all --source --full-history --pretty=format:"%H %ai %s" -- frontend/lib/config/

# Ver el contenido de un commit específico
git show <commit-hash>:frontend/lib/config/app_config_local.dart
```

## ⚠️ Notas Importantes

1. **La clave antigua sigue siendo válida** hasta que la rotes en Supabase
2. **Cualquiera que haya clonado el repo antes de limpiar el historial** todavía tiene acceso
3. **Considera rotar también la Anon Key** si fue expuesta (aunque es menos crítica)
4. **Revisa los logs de Supabase** para detectar accesos no autorizados

## 📞 Soporte

- **Supabase**: https://supabase.com/support
- **GitGuardian**: https://docs.gitguardian.com/
- **GitHub Security**: https://docs.github.com/en/code-security

