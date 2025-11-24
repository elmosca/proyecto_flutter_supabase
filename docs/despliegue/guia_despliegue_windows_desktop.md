# 🪟 Guía de Despliegue - Versión Escritorio Windows

## 📋 Resumen

Esta guía explica cómo construir y distribuir la aplicación Flutter para Windows Desktop.

---

## ✅ Requisitos Previos

### **1. Flutter SDK**
```powershell
# Verificar versión de Flutter
flutter --version

# Verificar que Windows está habilitado
flutter config --enable-windows
flutter doctor
```

### **2. Herramientas Necesarias**
- **Visual Studio 2022** (Community Edition es suficiente)
  - Con el workload "Desktop development with C++"
  - O al menos: MSVC v143, Windows 10/11 SDK
- **CMake** (generalmente incluido con Visual Studio)
- **Git** (para Flutter)

### **3. Verificar Configuración**
```powershell
flutter doctor -v
# Debe mostrar que Windows está configurado correctamente
```

---

## 🔨 Construcción de la Aplicación

### **PASO 1: Preparar el Entorno**

```powershell
# Navegar al directorio del proyecto
cd C:\dev\proyecto_flutter_supabase\frontend

# Limpiar builds anteriores
flutter clean

# Obtener dependencias actualizadas
flutter pub get
```

### **PASO 2: Construir para Windows (Release)**

```powershell
# Construir aplicación en modo release
flutter build windows --release

# El ejecutable se generará en:
# build\windows\x64\runner\Release\frontend.exe
```

### **PASO 3: Verificar el Build**

```powershell
# Verificar que el ejecutable existe
Test-Path build\windows\x64\runner\Release\frontend.exe

# Ejecutar la aplicación para probar
.\build\windows\x64\runner\Release\frontend.exe
```

---

## 📦 Preparación para Distribución

### **Opción 1: Distribuir Carpeta Completa (Recomendado para distribución interna)**

La carpeta `build\windows\x64\runner\Release\` contiene todos los archivos necesarios:
- `frontend.exe` - Ejecutable principal
- `data\` - Recursos de la aplicación
- `flutter_windows.dll` y otras DLLs necesarias

**Proceso:**
```powershell
# 1. Construir la aplicación
flutter build windows --release

# 2. Comprimir la carpeta Release completa
cd build\windows\x64\runner
Compress-Archive -Path Release\* -DestinationPath ..\..\..\..\frontend-windows-release.zip -Force
cd ..\..\..\..\..
```

**Distribución:**
- El usuario debe descomprimir el ZIP
- Ejecutar `frontend.exe` desde la carpeta descomprimida
- Todos los archivos deben estar en la misma carpeta

### **Opción 2: Crear Instalador con Inno Setup (Recomendado para distribución externa)**

Para crear un instalador profesional, puedes usar **Inno Setup** (gratuito).

**Instalación de Inno Setup:**
1. Descargar desde: https://jrsoftware.org/isdl.php
2. Instalar Inno Setup

**Script de Inno Setup básico:**

Crea un archivo `installer.iss` en la raíz del proyecto:

```inno
[Setup]
AppName=TFG Sistema Multiplataforma
AppVersion=1.0.0
DefaultDirName={pf}\TFG Sistema
DefaultGroupName=TFG Sistema
OutputDir=dist
OutputBaseFilename=TFG-Sistema-Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\TFG Sistema"; Filename: "{app}\frontend.exe"
Name: "{commondesktop}\TFG Sistema"; Filename: "{app}\frontend.exe"

[Run]
Filename: "{app}\frontend.exe"; Description: "Ejecutar TFG Sistema"; Flags: nowait postinstall skipifsilent
```

**Compilar el instalador:**
1. Abrir Inno Setup Compiler
2. Cargar el archivo `installer.iss`
3. Compilar (Build > Compile)
4. El instalador se generará en `dist\TFG-Sistema-Setup.exe`

---

## 🚀 Script Automatizado de Construcción

Crea un script PowerShell para automatizar el proceso:

**`scripts/build-windows-release.ps1`:**

```powershell
# Script para construir y empaquetar aplicación Windows
# Uso: .\scripts\build-windows-release.ps1

Write-Host "🚀 CONSTRUYENDO APLICACIÓN WINDOWS" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Ejecuta este script desde el directorio frontend/" -ForegroundColor Red
    exit 1
}

# Paso 1: Limpiar
Write-Host "`n📋 Paso 1: Limpiando builds anteriores..." -ForegroundColor Yellow
flutter clean

# Paso 2: Obtener dependencias
Write-Host "`n📋 Paso 2: Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# Paso 3: Construir aplicación
Write-Host "`n📋 Paso 3: Construyendo aplicación Windows (Release)..." -ForegroundColor Yellow
flutter build windows --release

# Verificar que el build fue exitoso
$exePath = "build\windows\x64\runner\Release\frontend.exe"
if (-not (Test-Path $exePath)) {
    Write-Host "`n❌ Error: No se encontró el ejecutable en $exePath" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Build completado exitosamente" -ForegroundColor Green
Write-Host "   Ejecutable: $exePath" -ForegroundColor Cyan

# Paso 4: Obtener información del ejecutable
$exeInfo = Get-Item $exePath
Write-Host "`n📊 Información del ejecutable:" -ForegroundColor Yellow
Write-Host "   Tamaño: $([math]::Round($exeInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host "   Fecha: $($exeInfo.LastWriteTime)" -ForegroundColor Cyan

# Paso 5: Crear ZIP para distribución
Write-Host "`n📋 Paso 4: Creando paquete ZIP para distribución..." -ForegroundColor Yellow

$zipPath = "dist\frontend-windows-release.zip"
$releaseDir = "build\windows\x64\runner\Release"

# Crear directorio dist si no existe
if (-not (Test-Path "dist")) {
    New-Item -ItemType Directory -Path "dist" | Out-Null
}

# Eliminar ZIP anterior si existe
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Comprimir carpeta Release
Compress-Archive -Path "$releaseDir\*" -DestinationPath $zipPath -Force

if (Test-Path $zipPath) {
    $zipInfo = Get-Item $zipPath
    Write-Host "`n✅ Paquete ZIP creado exitosamente" -ForegroundColor Green
    Write-Host "   Archivo: $zipPath" -ForegroundColor Cyan
    Write-Host "   Tamaño: $([math]::Round($zipInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠️  Advertencia: No se pudo crear el ZIP" -ForegroundColor Yellow
}

Write-Host "`n✅ PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host "`n📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Probar el ejecutable: .\$exePath" -ForegroundColor Cyan
Write-Host "   2. Distribuir el ZIP: $zipPath" -ForegroundColor Cyan
Write-Host "   3. O crear un instalador con Inno Setup" -ForegroundColor Cyan
Write-Host ""
```

---

## 📤 Distribución

### **Para Tutores/Administradores (Distribución Interna)**

1. **Construir la aplicación:**
   ```powershell
   .\scripts\build-windows-release.ps1
   ```

2. **Distribuir el ZIP:**
   - El archivo `dist\frontend-windows-release.zip` contiene todo lo necesario
   - Los tutores/administradores pueden descomprimir y ejecutar `frontend.exe`

3. **Instrucciones para el usuario final:**
   ```
   INSTRUCCIONES DE INSTALACIÓN
   ============================
   
   1. Descomprime el archivo frontend-windows-release.zip
   2. Abre la carpeta descomprimida
   3. Ejecuta frontend.exe
   4. (Opcional) Crea un acceso directo en el escritorio
   ```

### **Para Distribución Externa (Con Instalador)**

1. **Construir la aplicación:**
   ```powershell
   flutter build windows --release
   ```

2. **Crear instalador con Inno Setup:**
   - Usar el script `installer.iss` proporcionado
   - Compilar en Inno Setup Compiler
   - Distribuir el `.exe` generado

---

## 🔍 Verificación y Testing

### **Verificar el Ejecutable**

```powershell
# 1. Verificar que existe
Test-Path build\windows\x64\runner\Release\frontend.exe

# 2. Verificar dependencias
# Abrir PowerShell en la carpeta Release y ejecutar:
Get-ChildItem *.dll | Select-Object Name, Length

# 3. Probar ejecución
.\build\windows\x64\runner\Release\frontend.exe
```

### **Verificar Funcionalidad**

1. ✅ La aplicación se abre correctamente
2. ✅ El login funciona
3. ✅ La navegación funciona
4. ✅ Las funcionalidades principales están operativas
5. ✅ No hay errores en la consola

---

## 🐛 Solución de Problemas

### **Error: "Windows desktop support not enabled"**

```powershell
flutter config --enable-windows
flutter doctor
```

### **Error: "Visual Studio not found"**

- Instalar Visual Studio 2022 Community
- Asegurarse de instalar el workload "Desktop development with C++"

### **Error: "CMake not found"**

- CMake generalmente viene con Visual Studio
- O instalar CMake desde: https://cmake.org/download/

### **La aplicación no inicia**

1. Verificar que todas las DLLs están presentes
2. Verificar los logs de Windows Event Viewer
3. Ejecutar desde la línea de comandos para ver errores:
   ```powershell
   cd build\windows\x64\runner\Release
   .\frontend.exe
   ```

### **La aplicación se ve mal o tiene problemas de UI**

- Verificar que la resolución de pantalla es adecuada
- Verificar que los assets se cargaron correctamente
- Revisar logs de la aplicación

---

## 📝 Notas Importantes

1. **Versión de Flutter:** Asegúrate de usar una versión estable de Flutter
2. **Dependencias:** Todas las dependencias deben estar actualizadas
3. **Configuración:** Verifica que `app_config.dart` tiene las URLs correctas
4. **Testing:** Siempre prueba la aplicación en un entorno limpio antes de distribuir
5. **Actualizaciones:** Para actualizar, simplemente reconstruye y redistribuye

---

## 🔄 Proceso de Actualización

Cuando necesites actualizar la aplicación:

```powershell
# 1. Actualizar código
git pull

# 2. Reconstruir
.\scripts\build-windows-release.ps1

# 3. Distribuir nuevo ZIP o instalador
```

---

## 📦 Estructura del Paquete Final

```
frontend-windows-release.zip
├── frontend.exe
├── data\
│   ├── flutter_assets\
│   └── ...
├── flutter_windows.dll
├── (otras DLLs necesarias)
└── ...
```

**Tamaño típico:** 50-100 MB (comprimido: 20-40 MB)

---

## ✅ Checklist de Despliegue

- [ ] Flutter SDK configurado correctamente
- [ ] Visual Studio instalado con C++ tools
- [ ] Aplicación construida en modo Release
- [ ] Ejecutable probado localmente
- [ ] ZIP creado y verificado
- [ ] Instrucciones de instalación preparadas
- [ ] Aplicación probada en máquina limpia (opcional pero recomendado)

---

**Última actualización:** Enero 2025
**Versión Flutter:** 3.x
**Plataforma:** Windows 10/11 (x64)

