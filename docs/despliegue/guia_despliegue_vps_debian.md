# 🚀 Guía de Despliegue en VPS Debian

Guía simplificada para desplegar aplicación Flutter Web con Docker en VPS Debian.

---

## 📋 **REQUISITOS**

- **OS**: Debian 11+ (Bullseye/Bookworm)
- **RAM**: 1GB mínimo
- **Disco**: 2GB espacio libre
- **Red**: IP pública con puerto 8082 abierto

---

## 🐳 **PASO 1: INSTALAR DOCKER**

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y ca-certificates curl gnupg lsb-release unzip

# Añadir clave GPG de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Añadir repositorio
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Añadir usuario al grupo docker
sudo usermod -aG docker $USER

# Cerrar sesión y reconectar
exit
# Luego: ssh jualas@tu-ip-vps

# Verificar instalación
docker run hello-world
```

---

## 🔥 **PASO 2: CONFIGURAR FIREWALL**

```bash
sudo apt install -y ufw
sudo ufw allow ssh
sudo ufw allow 8082/tcp
sudo ufw enable
```

---

## 📁 **PASO 3: TRANSFERIR ARCHIVOS**

Subir al VPS via MobaXterm (SFTP) a `/opt/tfg-frontend/`:

### **Archivos necesarios:**
- `docker/docker-compose.yml`
- `docker/web/Dockerfile`
- `docker/nginx/nginx.conf`
- `lib/` (directorio completo)
- `assets/` (directorio completo)
- `pubspec.yaml`
- `l10n.yaml`

```bash
# En el VPS, crear estructura
sudo mkdir -p /opt/tfg-frontend
sudo chown -R $USER:$USER /opt/tfg-frontend
```

---

## 🚀 **PASO 4: CONSTRUIR Y COMPRIMIR EN WINDOWS**

```powershell
# Construir aplicación
cd C:\dev\proyecto_flutter_supabase\frontend
flutter clean
flutter pub get
flutter build web --release

# Comprimir build/web/
cd build\web
Compress-Archive -Path * -DestinationPath ..\..\web-build.zip -Force
cd ..\..
```

---

## 📤 **PASO 5: SUBIR Y DESCOMPRIMIR EN VPS**

```bash
# Subir web-build.zip a /opt/tfg-frontend/ via MobaXterm

# En el VPS
cd /opt/tfg-frontend/
mkdir -p build/web
unzip -o web-build.zip -d build/web/
rm web-build.zip
```

---

## 🐳 **PASO 6: INICIAR CONTENEDOR DOCKER**

```bash
cd /opt/tfg-frontend/

# Construir y ejecutar
docker compose -f docker/docker-compose.yml build --no-cache
docker compose -f docker/docker-compose.yml up -d

# Verificar
docker ps | grep tfg-frontend-web
curl http://localhost:8082
```

---

## 🔄 **ACTUALIZAR APLICACIÓN**

**IMPORTANTE**: Siempre ejecuta `flutter clean` antes de construir para producción:

```powershell
# En Windows - PASO COMPLETO
cd C:\dev\proyecto_flutter_supabase\frontend

# 1. Limpiar build anterior
flutter clean

# 2. Obtener dependencias actualizadas
flutter pub get

# 3. Construir para producción
flutter build web --release

# 4. Comprimir
cd build\web
Compress-Archive -Path * -DestinationPath ..\..\web-build.zip -Force
cd ..\..
```

```bash
# En VPS - MÉTODO RECOMENDADO (Script Automatizado)
cd /opt/tfg-frontend/

# Dar permisos de ejecución al script
chmod +x docs/despliegue/script_actualizar_vps.sh

# Ejecutar script de actualización
./docs/despliegue/script_actualizar_vps.sh
```

**O manualmente:**

```bash
# En VPS - PASO COMPLETO (Manual)
cd /opt/tfg-frontend/

# 1. Detener contenedor
docker compose -f docker/docker-compose.yml down

# 2. Limpiar build anterior COMPLETAMENTE
rm -rf build/web
mkdir -p build/web

# 3. Descomprimir nuevo build
unzip -o web-build.zip -d build/web/

# 4. Verificar que se descomprimió correctamente
ls -lh build/web/ | head -10

# 5. Reconstruir contenedor SIN caché (IMPORTANTE)
docker compose -f docker/docker-compose.yml build --no-cache

# 6. Iniciar contenedor
docker compose -f docker/docker-compose.yml up -d

# 7. Verificar
docker ps | grep tfg-frontend-web
curl http://localhost:8082

# 8. Limpiar archivo zip
rm -f web-build.zip
```

**⚠️ IMPORTANTE:** Si el contenido no se actualiza, consulta `TROUBLESHOOTING_ACTUALIZACION.md`

---

## 🗄️ **VERIFICAR Y ACTUALIZAR BASE DE DATOS (SUPABASE)**

**IMPORTANTE**: Si la base de datos es la misma para local y producción, verifica que el esquema esté actualizado:

### **PASO 1: Verificar Estado del Enum**

1. **Acceder a Supabase Dashboard**
   - Ir a https://app.supabase.com
   - Seleccionar tu proyecto
   - Ir a `SQL Editor`

2. **Ejecutar Consulta de Verificación**
   ```sql
   -- Verificar valores del enum attachable_type
   SELECT unnest(enum_range(NULL::attachable_type));
   ```

3. **Resultado Esperado**: Debe mostrar: `task`, `comment`, `anteproject`, `project`

### **PASO 2: Aplicar Migraciones (Si Faltan)**

Si el enum NO incluye `project`, aplica estas migraciones en orden:

**Migración 1**: `20250129000001_add_project_to_attachable_type.sql`
```sql
ALTER TYPE attachable_type ADD VALUE IF NOT EXISTS 'project';
```

**Migración 2**: `20250129000002_update_rls_policies_for_project_files.sql`
- Ver archivo completo en `docs/base_datos/migraciones/`

### **PASO 3: Limpiar Caché del Navegador**

Después de actualizar el código, limpia la caché:

```bash
# En el navegador (Chrome/Edge):
# Ctrl+Shift+Delete → Seleccionar "Caché" → Limpiar

# O forzar recarga sin caché:
# Ctrl+Shift+R (Windows/Linux)
# Cmd+Shift+R (Mac)
```

### **Solución de Problemas Comunes**

**Error 400 en consultas de archivos:**
- ✅ Verificar que el enum tenga 'project' (Paso 1)
- ✅ Aplicar migraciones si faltan (Paso 2)
- ✅ Limpiar caché del navegador (Paso 3)
- ✅ Reconstruir y redesplegar la aplicación (Paso 4)

---

## ✅ **VERIFICACIÓN**

```bash
# Ver contenedor
docker ps | grep tfg-frontend-web

# Probar aplicación
curl http://localhost:8082

# Ver logs
docker compose -f docker/docker-compose.yml logs -f
```

---

## 🌐 **ACCESO**

- **Local**: `http://tu-ip-vps:8082`
- **Health Check**: `http://tu-ip-vps:8082/health`

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Contenedor no inicia**
```bash
docker compose -f docker/docker-compose.yml down
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml logs
```

### **Archivos no se ven**
```bash
# Verificar archivos en host
ls -la /opt/tfg-frontend/build/web/index.html

# Verificar archivos en contenedor
docker exec -it tfg-frontend-web ls -la /usr/share/nginx/html/
```

### **Puerto no accesible**
```bash
sudo ufw status
sudo ufw allow 8082
```

### **Error 400 en consultas de archivos**
```bash
# 1. Verificar que el código esté actualizado
#    (reconstruir con flutter clean + flutter build web --release)

# 2. Verificar enum en Supabase
#    Ir a SQL Editor y ejecutar:
#    SELECT unnest(enum_range(NULL::attachable_type));
#    Debe incluir: task, comment, anteproject, project

# 3. Limpiar caché del navegador
#    Ctrl+Shift+R (forzar recarga sin caché)

# 4. Verificar logs del contenedor
docker compose -f docker/docker-compose.yml logs -f
```

### **Código no se actualiza en producción**
```bash
# Forzar reconstrucción completa
cd /opt/tfg-frontend/
docker compose -f docker/docker-compose.yml down
docker compose -f docker/docker-compose.yml build --no-cache
docker compose -f docker/docker-compose.yml up -d

# Verificar que los archivos estén actualizados
ls -la build/web/main.dart.js
# Comparar fecha de modificación con el archivo local
```

---

**¡Despliegue completado!** 🎉
