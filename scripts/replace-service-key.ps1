# Script para reemplazar Service Role Key en archivos
$serviceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQwOTE2NSwiZXhwIjoyMDcxOTg1MTY1fQ.fPkjQkJHx8q30eMIYcMflqKYmtZ4d2e22cHOwHBGhcA"
$replacement = "REMOVIDO_POR_SEGURIDAD"

Get-ChildItem -Recurse -File -Include *.ps1,*.js,*.ts,*.dart,*.md,*.txt,*.env -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match [regex]::Escape($serviceKey)) {
            $newContent = $content -replace [regex]::Escape($serviceKey), $replacement
            Set-Content $_.FullName -Value $newContent -NoNewline -ErrorAction SilentlyContinue
        }
    } catch {
        # Ignorar errores
    }
}

