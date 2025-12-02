# 🔐 Eliminar Service Role Key del Historial de Git

## 📋 Objetivo

Eliminar la Service Role Key de Supabase del historial completo de Git (local y remoto) **sin rotar la clave**, manteniendo la clave funcionando en tu entorno local.

---

## ⚠️ ADVERTENCIAS IMPORTANTES

Antes de proceder, entiende que:

1. **Se reescribirá todo el historial de Git** - Todos los commits serán modificados
2. **Necesitarás hacer force push** - Esto sobrescribirá el historial en GitHub
3. **Los colaboradores necesitarán re-clonar** - Cualquiera que haya clonado el repo necesitará actualizar
4. **Haz un backup primero** - Asegúrate de tener una copia de seguridad

---

## 🔍 Paso 1: Encontrar la Service Role Key Expuesta

### Opción A: Desde el Email de GitGuardian

El email de GitGuardian debería incluir la clave expuesta. Búscala en el mensaje.

### Opción B: Buscar en el Historial de Git

```powershell
# Buscar commits que modificaron archivos de configuración
git log --all --full-history --source --pretty=format:"%H|%ai|%s" -- "*config*" "*env*" "*app_config*" | Select-Object -First 30

# Revisar un commit específico (reemplaza COMMIT_HASH)
git show COMMIT_HASH

# Buscar específicamente por "service_role" en el contenido
git log -S "service_role" --all --source --pretty=format:"%H %s"
```

### Opción C: Usar el Script de Búsqueda

```powershell
.\scripts\buscar-service-role-key.ps1
```

---

## 🛠️ Paso 2: Elegir el Método de Eliminación

### Método 1: BFG Repo-Cleaner (RECOMENDADO - Más Fácil)

**Ventajas:**
- ✅ Más rápido que git-filter-branch
- ✅ Más fácil de usar
- ✅ Mejor para eliminar secretos

**Pasos:**

1. **Descargar BFG:**
   - Ve a: https://rtyley.github.io/bfg-repo-cleaner/
   - Descarga `bfg.jar`

2. **Crear archivo con la clave a eliminar:**
   ```powershell
   # Crear archivo replace.txt con el formato:
   # CLAVE_ANTIGUA==>REMOVIDO_POR_SEGURIDAD
   "TU_SERVICE_ROLE_KEY_AQUI==>REMOVIDO_POR_SEGURIDAD" | Out-File -FilePath replace.txt -Encoding UTF8
   ```

3. **Ejecutar BFG:**
   ```powershell
   # Asegúrate de estar en la raíz del proyecto
   java -jar ruta/a/bfg.jar --replace-text replace.txt
   ```

4. **Limpiar referencias:**
   ```powershell
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   ```

5. **Actualizar remoto:**
   ```powershell
   git push origin --force --all
   git push origin --force --tags
   ```

### Método 2: git-filter-repo (Alternativa)

**Requisitos:**
```powershell
pip install git-filter-repo
```

**Pasos:**

1. **Crear archivo de reemplazo:**
   ```powershell
   "TU_SERVICE_ROLE_KEY_AQUI==>REMOVIDO_POR_SEGURIDAD" | Out-File -FilePath replace-text.txt -Encoding UTF8
   ```

2. **Ejecutar git-filter-repo:**
   ```powershell
   git filter-repo --replace-text replace-text.txt --force
   ```

3. **Actualizar remoto:**
   ```powershell
   git push origin --force --all
   git push origin --force --tags
   ```

### Método 3: Script Automatizado

Usa el script que creamos:

```powershell
# Modo dry-run (solo muestra qué haría)
.\scripts\eliminar-service-role-key-historial.ps1 -DryRun

# Ejecutar realmente (te pedirá confirmación)
.\scripts\eliminar-service-role-key-historial.ps1 -ServiceRoleKey "TU_CLAVE_AQUI"
```

---

## 📝 Paso 3: Verificar que Funcionó

### Verificar Localmente

```powershell
# Buscar si la clave todavía existe en el historial
git log --all -S "TU_SERVICE_ROLE_KEY" --source

# Si no encuentra nada, ¡perfecto!
```

### Verificar en GitHub

1. Ve a tu repositorio en GitHub
2. Busca la clave en el código (debería estar eliminada)
3. Espera unas horas y verifica que GitGuardian ya no detecta el secreto

---

## ✅ Checklist Final

- [ ] Service Role Key identificada y copiada
- [ ] Backup del repositorio creado
- [ ] Historial local limpiado
- [ ] Verificado que la clave ya no está en el historial local
- [ ] Force push realizado a GitHub
- [ ] Colaboradores notificados (si aplica)
- [ ] Verificado en GitHub que la clave fue eliminada
- [ ] Esperado 24-48 horas para que GitGuardian actualice

---

## 🚨 Solución de Problemas

### Error: "Updates were rejected because the remote contains work"

**Solución:** Necesitas hacer force push:
```powershell
git push origin --force --all
```

### Error: "git-filter-repo: command not found"

**Solución:** Instálalo:
```powershell
pip install git-filter-repo
```

### Los colaboradores tienen problemas

**Solución:** Necesitan re-clonar el repositorio:
```powershell
# Opción 1: Re-clonar
cd ..
rm -rf proyecto_flutter_supabase
git clone https://github.com/elmosca/proyecto_flutter_supabase.git

# Opción 2: Actualizar existente (más complejo)
git fetch origin
git reset --hard origin/main
```

---

## 📞 Recursos Adicionales

- **BFG Repo-Cleaner**: https://rtyley.github.io/bfg-repo-cleaner/
- **git-filter-repo**: https://github.com/newren/git-filter-repo
- **GitGuardian**: https://docs.gitguardian.com/

---

## 💡 Nota Final

Después de eliminar la clave del historial:

1. ✅ Tu Service Role Key actual seguirá funcionando
2. ✅ No necesitas rotarla en Supabase
3. ✅ El archivo `app_config_local.dart` debe seguir en `.gitignore`
4. ✅ GitGuardian dejará de detectar el secreto (puede tardar 24-48 horas)

