# 📁 Archivos Requeridos para Despliegue

## 🎯 **RESUMEN**

Este documento lista todos los archivos que necesitas transferir a tu VPS Debian para desplegar la aplicación Flutter Web (que se conecta a Supabase Cloud).

---

## 📋 **LISTA COMPLETA DE ARCHIVOS**

### **1. 🐳 ARCHIVOS DOCKER (OBLIGATORIOS)**

#### **Estructura de directorios a crear en el VPS:**
```
/opt/tfg-frontend/
├── docker/
│   ├── docker-compose.yml
│   ├── web/
│   │   └── Dockerfile
│   └── nginx/
│       └── nginx.conf
└── build/
    └── web/ (se genera después del build)
```

#### **Archivos específicos a transferir:**
- `frontend/docker/docker-compose.yml` → `/opt/tfg-frontend/docker/`
- `frontend/docker/web/Dockerfile` → `/opt/tfg-frontend/docker/web/`
- `frontend/docker/nginx/nginx.conf` → `/opt/tfg-frontend/docker/nginx/`

### **2. 📱 APLICACIÓN FLUTTER (OBLIGATORIOS)**

#### **Archivos de configuración:**
- `frontend/pubspec.yaml` → `/opt/tfg-frontend/`
- `frontend/l10n.yaml` → `/opt/tfg-frontend/`
- `frontend/analysis_options.yaml` → `/opt/tfg-frontend/`

#### **Código fuente completo:**
- `frontend/lib/` (todo el directorio) → `/opt/tfg-frontend/lib/`
- `frontend/assets/` (todo el directorio) → `/opt/tfg-frontend/assets/`
- `frontend/web/` (todo el directorio) → `/opt/tfg-frontend/web/`

### **3. 🔧 SCRIPTS DE DESPLIEGUE (RECOMENDADOS)**

#### **Scripts de automatización:**
- `frontend/docker/scripts/recover-web-container.sh` → `/opt/tfg-frontend/scripts/`
- `frontend/docker/scripts/start-docker-web.ps1` → `/opt/tfg-frontend/scripts/` (adaptar para Linux)

### **4. ⚙️ CONFIGURACIÓN DE ENTORNO (OPCIONAL)**

#### **Variables de entorno:**
- `config/cloudflare.env.example` → `/opt/tfg-frontend/.env.example`
- `mcp-server/env.example` → `/opt/tfg-frontend/mcp-server/.env.example`

---

## 🚀 **PROCESO DE TRANSFERENCIA CON MOBAXTERM**

### **Paso 1: Crear estructura en el VPS**
```bash
# Conectar al VPS y crear directorios
sudo mkdir -p /opt/tfg-frontend/{docker/{web,nginx},scripts,lib/config,assets,web}
sudo chown -R $USER:$USER /opt/tfg-frontend
```

### **Paso 2: Transferir archivos con MobaXterm**

#### **A. Archivos Docker (Prioridad 1):**
1. **docker-compose.yml** → `/opt/tfg-frontend/docker/`
2. **Dockerfile** → `/opt/tfg-frontend/docker/web/`
3. **nginx.conf** → `/opt/tfg-frontend/docker/nginx/`

#### **B. Aplicación Flutter (Prioridad 2):**
1. **pubspec.yaml** → `/opt/tfg-frontend/`
2. **l10n.yaml** → `/opt/tfg-frontend/`
3. **analysis_options.yaml** → `/opt/tfg-frontend/`
4. **Directorio lib/** → `/opt/tfg-frontend/lib/`
5. **Directorio assets/** → `/opt/tfg-frontend/assets/`
6. **Directorio web/** → `/opt/tfg-frontend/web/`

#### **C. Scripts (Prioridad 3):**
1. **recover-web-container.sh** → `/opt/tfg-frontend/scripts/`

### **Paso 3: Verificar archivos transferidos**
```bash
# Verificar estructura
ls -la /opt/tfg-frontend/
ls -la /opt/tfg-frontend/docker/
ls -la /opt/tfg-frontend/docker/web/
ls -la /opt/tfg-frontend/docker/nginx/

# Verificar archivos críticos
cat /opt/tfg-frontend/docker/docker-compose.yml
cat /opt/tfg-frontend/pubspec.yaml
```

---

## 📊 **TAMAÑOS APROXIMADOS**

### **Archivos Docker:**
- `docker-compose.yml`: ~2KB
- `Dockerfile`: ~1KB
- `nginx.conf`: ~5KB
- **Total Docker**: ~8KB

### **Aplicación Flutter:**
- `pubspec.yaml`: ~5KB
- `l10n.yaml`: ~1KB
- `analysis_options.yaml`: ~2KB
- `lib/` (directorio completo): ~500KB
- `assets/` (directorio completo): ~100KB
- `web/` (directorio completo): ~50KB
- **Total Flutter**: ~657KB

### **Scripts:**
- `recover-web-container.sh`: ~3KB
- **Total Scripts**: ~3KB

### **TOTAL APROXIMADO**: ~668KB

---

## ✅ **CHECKLIST DE TRANSFERENCIA**

### **Archivos Docker:**
- [ ] `docker-compose.yml` transferido
- [ ] `Dockerfile` transferido
- [ ] `nginx.conf` transferido

### **Aplicación Flutter:**
- [ ] `pubspec.yaml` transferido
- [ ] `l10n.yaml` transferido
- [ ] `analysis_options.yaml` transferido
- [ ] Directorio `lib/` transferido
- [ ] Directorio `assets/` transferido
- [ ] Directorio `web/` transferido

### **Scripts:**
- [ ] `recover-web-container.sh` transferido

### **Verificación:**
- [ ] Estructura de directorios creada
- [ ] Permisos configurados correctamente
- [ ] Archivos críticos verificados

---

## 🔧 **COMANDOS DE VERIFICACIÓN**

### **Verificar estructura de directorios:**
```bash
tree /opt/tfg-frontend/ -L 3
```

### **Verificar archivos críticos:**
```bash
# Verificar docker-compose.yml
cat /opt/tfg-frontend/docker/docker-compose.yml | head -20

# Verificar pubspec.yaml
cat /opt/tfg-frontend/pubspec.yaml | head -20

# Verificar que lib/ existe
ls -la /opt/tfg-frontend/lib/ | head -10
```

### **Verificar permisos:**
```bash
# Verificar permisos de directorios
ls -la /opt/tfg-frontend/

# Verificar permisos de scripts
ls -la /opt/tfg-frontend/scripts/
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problema: Archivo no encontrado**
```bash
# Verificar que el archivo existe
ls -la /ruta/al/archivo

# Verificar permisos
ls -la /ruta/al/archivo
```

### **Problema: Permisos incorrectos**
```bash
# Corregir permisos
chmod 755 /opt/tfg-frontend/
chmod +x /opt/tfg-frontend/scripts/*.sh
```

### **Problema: Estructura de directorios incorrecta**
```bash
# Recrear estructura
sudo rm -rf /opt/tfg-frontend/
sudo mkdir -p /opt/tfg-frontend/{docker/{web,nginx},scripts,lib,assets,web}
sudo chown -R $USER:$USER /opt/tfg-frontend
```

---

## 📝 **NOTAS IMPORTANTES**

1. **Orden de transferencia**: Transferir archivos Docker primero, luego Flutter
2. **Permisos**: Asegurarse de que los scripts tengan permisos de ejecución
3. **Verificación**: Siempre verificar que los archivos se transfirieron correctamente
4. **Backup**: Hacer backup de la configuración antes de hacer cambios

---

**¡Transferencia completada! 🚀**

Una vez transferidos todos los archivos, puedes proceder con la construcción y despliegue siguiendo la [Guía de Despliegue en VPS Debian](guia_despliegue_vps_debian.md).
