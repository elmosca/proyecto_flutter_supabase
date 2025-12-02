# Script para eliminar Service Role Key usando BFG Repo-Cleaner
# Requiere: Java y BFG Repo-Cleaner descargado

$serviceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQwOTE2NSwiZXhwIjoyMDcxOTg1MTY1fQ.fPkjQkJHx8q30eMIYcMflqKYmtZ4d2e22cHOwHBGhcA"

Write-Host "🔧 Eliminando Service Role Key usando BFG Repo-Cleaner" -ForegroundColor Cyan
Write-Host ""

# Crear archivo de reemplazo
$replaceFile = "replace-bfg.txt"
"$serviceKey==>REMOVIDO_POR_SEGURIDAD" | Out-File -FilePath $replaceFile -Encoding UTF8 -NoNewline

Write-Host "📝 Archivo de reemplazo creado: $replaceFile" -ForegroundColor Green
Write-Host ""
Write-Host "📥 Para continuar:" -ForegroundColor Yellow
Write-Host "1. Descarga BFG Repo-Cleaner desde: https://rtyley.github.io/bfg-repo-cleaner/" -ForegroundColor White
Write-Host "2. Guarda bfg.jar en una carpeta accesible" -ForegroundColor White
Write-Host "3. Ejecuta:" -ForegroundColor White
Write-Host "   java -jar ruta/a/bfg.jar --replace-text $replaceFile" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Luego ejecuta:" -ForegroundColor White
Write-Host "   git reflog expire --expire=now --all" -ForegroundColor Gray
Write-Host "   git gc --prune=now --aggressive" -ForegroundColor Gray
Write-Host "   git push origin --force --all" -ForegroundColor Gray
Write-Host "   git push origin --force --tags" -ForegroundColor Gray

