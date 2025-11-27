$supabaseUrl = "https://zkririyknhlwoxhsoqih.supabase.co"
$anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg"
$email = "juanantonio.frances.perez@gmail.com"

$body = @{
    action = "delete_user"
    user_email = $email
} | ConvertTo-Json

$headers = @{
    "Content-Type" = "application/json"
    "apikey" = $anonKey
    "Authorization" = "Bearer $anonKey"
}

Write-Host "🔐 Eliminando usuario de Auth: $email"

try {
    $response = Invoke-RestMethod -Uri "$supabaseUrl/functions/v1/super-action" -Method Post -Headers $headers -Body $body
    Write-Host "✅ Usuario eliminado exitosamente de Auth"
    Write-Host "Respuesta: $($response | ConvertTo-Json)"
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)"
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalles: $($_.ErrorDetails.Message)"
    }
}

