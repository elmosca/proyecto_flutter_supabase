# Script para probar el envío de email de password reset
# usando la Edge Function super-action con service_role

$SUPABASE_URL = "https://zkririyknhlwoxhsoqih.supabase.co"
$SUPABASE_SERVICE_ROLE_KEY = "REMOVIDO_POR_SEGURIDAD"

Write-Host "🧪 Probando envío de email de password reset..." -ForegroundColor Cyan
Write-Host ""

# Datos de prueba
$body = @{
    action = "send_password_reset_email"
    user_email = "lamoscaproton@gmail.com"
    new_password = "TestPass123!"
    user_data = @{
        student_name = "El Mosca"
        student_email = "lamoscaproton@gmail.com"
        reset_by = "Tutor"
        reset_by_name = "Tutor Jualas"
    }
} | ConvertTo-Json -Depth 10

Write-Host "📧 Enviando solicitud a Edge Function..." -ForegroundColor Yellow
Write-Host "URL: $SUPABASE_URL/functions/v1/super-action"
Write-Host "Email: lamoscaproton@gmail.com"
Write-Host ""

try {
    $response = Invoke-RestMethod `
        -Uri "$SUPABASE_URL/functions/v1/super-action" `
        -Method Post `
        -Headers @{
            "Authorization" = "Bearer $SUPABASE_SERVICE_ROLE_KEY"
            "Content-Type" = "application/json"
            "apikey" = $SUPABASE_SERVICE_ROLE_KEY
        } `
        -Body $body `
        -TimeoutSec 30

    Write-Host "✅ Respuesta recibida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host
    Write-Host ""

    if ($response.success -eq $true) {
        Write-Host "🎉 ¡Email enviado exitosamente!" -ForegroundColor Green
        Write-Host "📬 Revisa la bandeja de entrada de: lamoscaproton@gmail.com" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "⏰ El email debería llegar en 1-2 minutos" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📧 Asunto esperado:" -ForegroundColor Cyan
        Write-Host '   "🔒 Tu contraseña ha sido restablecida - Sistema TFG"'
        Write-Host ""
        Write-Host "⚠️ Si no llega:" -ForegroundColor Yellow
        Write-Host "1. Revisa la carpeta de spam"
        Write-Host "2. Verifica los logs en Supabase Dashboard"
        Write-Host "3. Verifica que el template 'Magic Link' esté configurado"
    } else {
        Write-Host "❌ Error en la respuesta:" -ForegroundColor Red
        $response | ConvertTo-Json -Depth 10 | Write-Host
    }
} catch {
    Write-Host "❌ Error al llamar Edge Function:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Host ""
        Write-Host "📄 Detalles del error:" -ForegroundColor Yellow
        Write-Host $responseBody
    }
    
    Write-Host ""
    Write-Host "💡 Posibles causas:" -ForegroundColor Yellow
    Write-Host "1. La Edge Function no tiene la acción 'send_password_reset_email'"
    Write-Host "2. Error en el código de la Edge Function"
    Write-Host "3. Usuario no existe en Supabase Auth"
    Write-Host ""
    Write-Host "🔧 Solución:" -ForegroundColor Cyan
    Write-Host "1. Ve a Supabase Dashboard → Edge Functions → super-action → Logs"
    Write-Host "2. Busca el error específico"
    Write-Host "3. Verifica que el código esté actualizado con la nueva acción"
}

Write-Host ""
Write-Host "📊 Ver logs en Supabase:" -ForegroundColor Cyan
Write-Host "https://supabase.com/dashboard/project/zkririyknhlwoxhsoqih/functions/super-action/logs"

