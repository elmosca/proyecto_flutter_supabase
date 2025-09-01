# Script de verificación de calidad para el proyecto Flutter TFG
# Ejecutar: .\scripts\check_quality.ps1

Write-Host "🔍 VERIFICACIÓN DE CALIDAD DEL PROYECTO TFG" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# 1. Verificar estado de Flutter
Write-Host "`n📱 Verificando estado de Flutter..." -ForegroundColor Yellow
flutter doctor

# 2. Obtener dependencias
Write-Host "`n📦 Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# 3. Formatear código
Write-Host "`n🎨 Formateando código..." -ForegroundColor Yellow
dart format .

# 4. Analizar código
Write-Host "`n🔍 Analizando código..." -ForegroundColor Yellow
$analysis = flutter analyze 2>&1

# 5. Contar warnings y errores
$errorCount = ($analysis | Select-String "error" | Measure-Object).Count
$warningCount = ($analysis | Select-String "warning" | Measure-Object).Count
$infoCount = ($analysis | Select-String "info" | Measure-Object).Count

Write-Host "`n📊 RESULTADOS DEL ANÁLISIS:" -ForegroundColor Green
Write-Host "   Errores: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })
Write-Host "   Warnings: $warningCount" -ForegroundColor $(if ($warningCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "   Info: $infoCount" -ForegroundColor $(if ($infoCount -eq 0) { "Green" } else { "Blue" })

# 6. Ejecutar tests
Write-Host "`n🧪 Ejecutando tests..." -ForegroundColor Yellow
flutter test

# 7. Verificar build
Write-Host "`n🏗️ Verificando build..." -ForegroundColor Yellow
flutter build apk --debug --no-tree-shake-icons

# 8. Resumen final
Write-Host "`n✅ VERIFICACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

if ($errorCount -eq 0) {
    Write-Host "🎉 ¡PROYECTO LISTO PARA DESARROLLO!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Se encontraron errores que deben ser corregidos" -ForegroundColor Red
}

if ($warningCount -eq 0) {
    Write-Host "✨ ¡Código limpio sin warnings!" -ForegroundColor Green
} else {
    Write-Host "📝 Se encontraron warnings menores (opcionales)" -ForegroundColor Yellow
}

Write-Host "`n🚀 El proyecto está listo para continuar con el desarrollo" -ForegroundColor Cyan
