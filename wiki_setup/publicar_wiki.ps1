# Script PowerShell para publicar Wiki de GitHub
# Sistema de Seguimiento de Proyectos TFG

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# Colores para output
function Write-Header {
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  Publicador de Wiki de GitHub" -ForegroundColor Cyan
    Write-Host "  Sistema de Seguimiento de Proyectos TFG" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "> $Message" -ForegroundColor Green
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[X] $Message" -ForegroundColor Red
}

# Configuracion
$REPO_USER = "elmosca"
$REPO_NAME = "proyecto_flutter_supabase"
$REPO_WIKI_URL = "https://github.com/${REPO_USER}/${REPO_NAME}.wiki.git"
$WIKI_DIR = "wiki_temp"
$DOCS_DIR = "..\docs"

# Verificar prerequisitos
function Check-Prerequisites {
    Write-Step "Verificando prerequisitos..."
    
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Err "Git no esta instalado. Por favor instala Git primero."
        exit 1
    }
    
    Write-Success "Prerequisitos verificados"
    Write-Host ""
}

# Clonar o actualizar wiki
function Clone-OrUpdateWiki {
    Write-Step "Clonando o actualizando wiki..."
    
    if (Test-Path $WIKI_DIR) {
        Write-Warn "Directorio wiki_temp ya existe. Actualizando..."
        Push-Location $WIKI_DIR
        try {
            git pull origin master
        } catch {
            Write-Err "Error al actualizar wiki."
            Pop-Location
            exit 1
        }
        Pop-Location
    } else {
        Write-Step "Clonando wiki por primera vez..."
        try {
            git clone $REPO_WIKI_URL $WIKI_DIR
        } catch {
            Write-Err "Error al clonar wiki. Verifica:"
            Write-Host "  1. La URL del repositorio es correcta" -ForegroundColor Gray
            Write-Host "  2. Tienes permisos para acceder al repositorio" -ForegroundColor Gray
            Write-Host "  3. La wiki esta habilitada en GitHub (Settings > Features > Wikis)" -ForegroundColor Gray
            exit 1
        }
    }
    
    Write-Success "Wiki lista para actualizar"
    Write-Host ""
}

# Copiar estructura de wiki
function Copy-WikiStructure {
    Write-Step "Copiando archivos de estructura..."
    
    Push-Location $WIKI_DIR
    
    $files = @(
        @{Source = "..\Home.md"; Dest = "Home.md"},
        @{Source = "..\_Sidebar.md"; Dest = "_Sidebar.md"},
        @{Source = "..\_Footer.md"; Dest = "_Footer.md"},
        @{Source = "..\FAQ.md"; Dest = "FAQ.md"},
        @{Source = "..\Guia-Inicio-Rapido.md"; Dest = "Guia-Inicio-Rapido.md"}
    )
    
    foreach ($file in $files) {
        if (Test-Path $file.Source) {
            Copy-Item $file.Source $file.Dest -Force
            Write-Success "$($file.Dest) copiado"
        }
    }
    
    Pop-Location
    Write-Host ""
}

# Copiar guias de usuario
function Copy-UserGuides {
    Write-Step "Copiando guias de usuario..."
    
    Push-Location $WIKI_DIR
    
    # Copiar las guias completas (versiones largas) si existen, sino las cortas
    $guides = @(
        @{Source = "..\Guia-Estudiantes.md"; Dest = "Guia-Estudiantes.md"; AltSource = "..\Guia_Estudiante.md"},
        @{Source = "..\Guia-Tutores.md"; Dest = "Guia-Tutores.md"; AltSource = "..\Guia_Tutor.md"},
        @{Source = "..\Guia-Administradores.md"; Dest = "Guia-Administradores.md"; AltSource = "..\Guia_Administrador.md"}
    )
    
    foreach ($guide in $guides) {
        if (Test-Path $guide.Source) {
            Copy-Item $guide.Source $guide.Dest -Force
            Write-Success "$($guide.Dest) copiado (version completa)"
        } elseif ($guide.AltSource -and (Test-Path $guide.AltSource)) {
            Copy-Item $guide.AltSource $guide.Dest -Force
            Write-Success "$($guide.Dest) copiado (version corta)"
        } else {
            Write-Warn "$($guide.Dest) no encontrado"
        }
    }
    
    Pop-Location
    Write-Host ""
}

# Copiar documentacion tecnica
function Copy-TechnicalDocs {
    Write-Step "Copiando documentacion tecnica..."
    
    Push-Location $WIKI_DIR
    
    # Las rutas son relativas desde wiki_temp/
    $docs = @(
        @{Source = "..\..\docs\01_ARQUITECTURA.md"; Dest = "01-Arquitectura.md"},
        @{Source = "..\..\docs\02_BASE_DE_DATOS.md"; Dest = "02-Base-de-Datos.md"},
        @{Source = "..\..\docs\03_GUIA_DESARROLLO.md"; Dest = "03-Guia-Desarrollo.md"},
        @{Source = "..\..\docs\04_ESTRUCTURA_CODIGO.md"; Dest = "04-Estructura-Codigo.md"}
    )
    
    foreach ($doc in $docs) {
        if (Test-Path $doc.Source) {
            Copy-Item $doc.Source $doc.Dest -Force
            Write-Success "$($doc.Dest) copiado"
        } else {
            Write-Warn "$($doc.Dest) no encontrado en $($doc.Source)"
        }
    }
    
    Pop-Location
    Write-Host ""
}

# Copiar documentacion de ciclos de vida
function Copy-LifecycleDocs {
    Write-Step "Copiando documentacion de ciclos de vida..."
    
    Push-Location $WIKI_DIR
    
    # Los archivos estan en ..\ (un nivel arriba, que es wiki_setup/)
    $lifecycleDocs = @(
        @{Source = "..\Ciclo-Vida-Login.md"; Dest = "Ciclo-Vida-Login.md"},
        @{Source = "..\Ciclo-Vida-Administrador.md"; Dest = "Ciclo-Vida-Administrador.md"},
        @{Source = "..\Ciclo-Vida-Tutor.md"; Dest = "Ciclo-Vida-Tutor.md"},
        @{Source = "..\Ciclo-Vida-Estudiante.md"; Dest = "Ciclo-Vida-Estudiante.md"},
        @{Source = "..\Ciclo-Vida-Anteproyecto.md"; Dest = "Ciclo-Vida-Anteproyecto.md"},
        @{Source = "..\Ciclo-Vida-Proyecto.md"; Dest = "Ciclo-Vida-Proyecto.md"},
        @{Source = "..\Ciclo-Vida-Tarea.md"; Dest = "Ciclo-Vida-Tarea.md"}
    )
    
    foreach ($doc in $lifecycleDocs) {
        if (Test-Path $doc.Source) {
            Copy-Item $doc.Source $doc.Dest -Force
            Write-Success "$($doc.Dest) copiado"
        } else {
            Write-Warn "$($doc.Dest) no encontrado"
        }
    }
    
    Pop-Location
    Write-Host ""
}

# Commit y push
function Commit-AndPush {
    Write-Step "Publicando cambios a GitHub..."
    
    Push-Location $WIKI_DIR
    
    # Verificar si hay cambios
    $status = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($status)) {
        Write-Warn "No hay cambios para publicar"
        Pop-Location
        return
    }
    
    # Agregar todos los archivos
    git add .
    
    # Commit con timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    git commit -m "Actualizar documentacion - $timestamp"
    
    # Push a GitHub
    try {
        git push origin master
        Write-Success "Cambios publicados exitosamente!"
    } catch {
        Write-Err "Error al publicar. Verifica tu conexion y permisos."
        Pop-Location
        exit 1
    }
    
    Pop-Location
    Write-Host ""
}

# Mostrar resumen
function Show-Summary {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  Wiki Actualizada Exitosamente" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Tu wiki esta disponible en:" -ForegroundColor Cyan
    Write-Host "https://github.com/${REPO_USER}/${REPO_NAME}/wiki" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Paginas publicadas:" -ForegroundColor Cyan
    Write-Host "  - Home (pagina principal)" -ForegroundColor White
    Write-Host "  - Guia de Estudiantes" -ForegroundColor White
    Write-Host "  - Guia de Tutores" -ForegroundColor White
    Write-Host "  - Guia de Administradores" -ForegroundColor White
    Write-Host "  - Arquitectura (01)" -ForegroundColor White
    Write-Host "  - Base de Datos (02)" -ForegroundColor White
    Write-Host "  - Guia de Desarrollo (03)" -ForegroundColor White
    Write-Host "  - Estructura de Codigo (04)" -ForegroundColor White
    Write-Host "  - Ciclo de Vida del Login" -ForegroundColor White
    Write-Host "  - Ciclo de Vida del Administrador" -ForegroundColor White
    Write-Host "  - Ciclo de Vida del Tutor" -ForegroundColor White
    Write-Host "  - Ciclo de Vida del Estudiante" -ForegroundColor White
    Write-Host "  - Ciclo de Vida del Anteproyecto" -ForegroundColor White
    Write-Host "  - Ciclo de Vida del Proyecto" -ForegroundColor White
    Write-Host "  - Ciclo de Vida de la Tarea" -ForegroundColor White
    Write-Host "  - FAQ" -ForegroundColor White
    Write-Host "  - Guia de Inicio Rapido" -ForegroundColor White
    Write-Host ""
}

# Script principal
function Main {
    Write-Header
    Check-Prerequisites
    Clone-OrUpdateWiki
    Copy-WikiStructure
    Copy-UserGuides
    Copy-TechnicalDocs
    Copy-LifecycleDocs
    Commit-AndPush
    Show-Summary
}

# Ejecutar
Main
