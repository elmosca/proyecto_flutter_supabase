# 🔍 Service Role Key Encontrada - Resumen

## ✅ Clave Identificada

**Service Role Key expuesta:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQwOTE2NSwiZXhwIjoyMDcxOTg1MTY1fQ.fPkjQkJHx8q30eMIYcMflqKYmtZ4d2e22cHOwHBGhcA
```

## 📍 Ubicaciones en el Historial

La Service Role Key apareció en los siguientes archivos (ahora eliminados, pero aún en el historial):

1. **`scripts/test-send-password-reset-email-admin.ps1`**
   - Eliminado en commit: `2337afa7626999098925ea47633034607ca22642` (2 dic 2025)
   - Pero todavía existe en el historial anterior

2. **`scripts/check-user-auth.js`**
   - Probablemente también contiene la clave

## 📅 Commits Relevantes

- **Commit donde se eliminó**: `2337afa7626999098925ea47633034607ca22642` (2 dic 2025, 17:57:55)
- **Commits anteriores donde existía**: 
  - `f07b6413a3beda1c83d693c4870b2cdd2867a054` (24 nov 2025)
  - Y posiblemente anteriores

## 🛠️ Próximos Pasos

Para eliminar esta clave del historial completo:

1. **Usar BFG Repo-Cleaner** (recomendado):
   ```powershell
   # Crear archivo replace.txt
   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQwOTE2NSwiZXhwIjoyMDcxOTg1MTY1fQ.fPkjQkJHx8q30eMIYcMflqKYmtZ4d2e22cHOwHBGhcA==>REMOVIDO_POR_SEGURIDAD" | Out-File -FilePath replace.txt -Encoding UTF8
   
   # Ejecutar BFG
   java -jar bfg.jar --replace-text replace.txt
   
   # Limpiar
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   
   # Actualizar remoto
   git push origin --force --all
   git push origin --force --tags
   ```

2. **O usar el script automatizado**:
   ```powershell
   .\scripts\eliminar-service-role-key-historial.ps1 -ServiceRoleKey "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQwOTE2NSwiZXhwIjoyMDcxOTg1MTY1fQ.fPkjQkJHx8q30eMIYcMflqKYmtZ4d2e22cHOwHBGhcA"
   ```

## ⚠️ Nota Importante

- La clave ya no está en el código actual (los archivos fueron eliminados)
- Pero **sigue existiendo en el historial de Git**
- Por eso GitGuardian la detecta
- Necesitas reescribir el historial para eliminarla completamente

