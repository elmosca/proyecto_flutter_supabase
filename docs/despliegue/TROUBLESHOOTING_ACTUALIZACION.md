# 🔧 Solución de Problemas: Contenido No Se Actualiza en VPS

## 🎯 Problema
El contenido en el VPS no se actualiza aunque en local sí está actualizado.

## 🔍 Causas Comunes

### 1. **Caché del Navegador**
El navegador puede estar mostrando una versión en caché.

**Solución:**
- Presiona `Ctrl + Shift + R` (o `Ctrl + F5`) para forzar recarga sin caché
- O abre la aplicación en modo incógnito/privado
- O limpia la caché del navegador completamente

### 2. **Archivos No Se Descomprimieron Correctamente**
El archivo `web-build.zip` puede no haberse descomprimido correctamente.

**Verificación:**
```bash
cd /opt/tfg-frontend/
ls -lh build/web/
# Debe mostrar index.html, main.dart.js, flutter.js, etc.
```

**Solución:**
```bash
cd /opt/tfg-frontend/
rm -rf build/web
mkdir -p build/web
unzip -o web-build.zip -d build/web/
ls -lh build/web/  # Verificar que los archivos están ahí
```

### 3. **Contenedor Docker No Se Reconstruyó**
El contenedor puede estar usando una versión antigua de los archivos.

**Solución:**
```bash
cd /opt/tfg-frontend/

# Detener y eliminar contenedor
docker compose -f docker/docker-compose.yml down

# Reconstruir SIN caché
docker compose -f docker/docker-compose.yml build --no-cache

# Iniciar
docker compose -f docker/docker-compose.yml up -d
```

### 4. **Volumen Docker No Se Actualizó**
Aunque el volumen debería actualizarse automáticamente, a veces necesita reiniciarse.

**Solución:**
```bash
# Reiniciar el contenedor para que recargue el volumen
docker compose -f docker/docker-compose.yml restart frontend-web
```

### 5. **Caché de Nginx**
Nginx puede estar cacheando los archivos.

**Solución:**
La configuración de nginx.conf ya está actualizada para no cachear archivos JS principales.
Si el problema persiste, reinicia el contenedor:
```bash
docker compose -f docker/docker-compose.yml restart frontend-web
```

### 6. **Proxy Reverso (Nginx/Traefik) Cacheando**
Si tienes un proxy reverso delante, puede estar cacheando.

**Solución:**
- Reinicia el proxy reverso
- O configura el proxy para no cachear archivos de Flutter

## ✅ Proceso Completo de Actualización (Recomendado)

Usa el script automatizado:

```bash
cd /opt/tfg-frontend/
chmod +x docs/despliegue/script_actualizar_vps.sh
./docs/despliegue/script_actualizar_vps.sh
```

O manualmente:

```bash
cd /opt/tfg-frontend/

# 1. Detener contenedor
docker compose -f docker/docker-compose.yml down

# 2. Limpiar build anterior
rm -rf build/web
mkdir -p build/web

# 3. Descomprimir nuevo build
unzip -o web-build.zip -d build/web/

# 4. Verificar archivos
ls -lh build/web/ | head -10

# 5. Reconstruir contenedor SIN caché
docker compose -f docker/docker-compose.yml build --no-cache

# 6. Iniciar contenedor
docker compose -f docker/docker-compose.yml up -d

# 7. Verificar
docker ps | grep tfg-frontend-web
curl http://localhost:8082
```

## 🔍 Verificación de Archivos

Para verificar que los archivos se actualizaron correctamente:

```bash
cd /opt/tfg-frontend/build/web/

# Ver fecha de modificación de archivos principales
ls -lh index.html main.dart.js flutter.js

# Ver contenido de index.html (debe tener la versión correcta)
head -20 index.html

# Verificar tamaño de main.dart.js (debe coincidir con el build local)
ls -lh main.dart.js
```

## 🐛 Debugging

Si el problema persiste:

1. **Ver logs del contenedor:**
```bash
docker compose -f docker/docker-compose.yml logs -f frontend-web
```

2. **Verificar que el volumen está montado correctamente:**
```bash
docker exec tfg-frontend-web ls -lh /usr/share/nginx/html/
```

3. **Verificar fecha de archivos dentro del contenedor:**
```bash
docker exec tfg-frontend-web ls -lh /usr/share/nginx/html/main.dart.js
```

4. **Comparar con archivos locales:**
```bash
# En tu máquina local
cd frontend/build/web
ls -lh main.dart.js

# En el VPS
cd /opt/tfg-frontend/build/web
ls -lh main.dart.js
# Las fechas y tamaños deben ser similares
```

## 📝 Notas Importantes

1. **Siempre ejecuta `flutter clean` antes de construir:**
```powershell
cd frontend
flutter clean
flutter pub get
flutter build web --release
```

2. **Verifica que el archivo zip se creó correctamente:**
```powershell
cd frontend/build/web
Compress-Archive -Path * -DestinationPath ..\..\web-build.zip -Force
# Verificar tamaño
ls -lh ..\..\web-build.zip
```

3. **El archivo debe subirse completamente al VPS:**
   - Verifica que el tamaño del archivo en el VPS coincide con el local
   - Usa `scp` o `rsync` para transferir el archivo de forma confiable

4. **Después de actualizar, siempre limpia la caché del navegador**

