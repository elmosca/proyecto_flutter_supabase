# 🚀 INSTRUCCIONES RÁPIDAS - CONTENEDOR WEB FLUTTER

## ⚡ **SOLUCIÓN INMEDIATA**

### **1. INICIAR DOCKER DESKTOP**
- Abre Docker Desktop en Windows
- Espera a que esté completamente iniciado (ícono verde)

### **2. EJECUTAR SCRIPT DE RECUPERACIÓN**
```powershell
cd frontend
.\docker\scripts\start-docker-web.ps1
```

### **3. ACCEDER A LA APLICACIÓN**
- **URL**: http://localhost:8082
- **Health Check**: http://localhost:8082/health

---

## 🔧 **COMANDOS MANUALES (SI EL SCRIPT FALLA)**

### **Paso 1: Construir aplicación Flutter**
```bash
cd frontend
flutter pub get
flutter build web --release
```

### **Paso 2: Iniciar contenedor**
```bash
docker-compose -f docker/docker-compose.yml build --no-cache
docker-compose -f docker/docker-compose.yml up -d
```

### **Paso 3: Verificar**
```bash
docker-compose -f docker/docker-compose.yml ps
curl http://localhost:8082
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Error: Docker Desktop no ejecutándose**
- Inicia Docker Desktop
- Espera a que esté completamente iniciado

### **Error: Puerto 8082 en uso**
```bash
# Verificar qué usa el puerto
netstat -ano | findstr :8082
# Detener proceso o cambiar puerto en docker-compose.yml
```

### **Error: No se puede construir Flutter**
```bash
flutter clean
flutter pub get
flutter build web --release
```

### **Error: Contenedor no inicia**
```bash
# Ver logs
docker-compose -f docker/docker-compose.yml logs -f

# Reconstruir
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml build --no-cache
docker-compose -f docker/docker-compose.yml up -d
```

---

## 📊 **VERIFICACIÓN FINAL**

✅ **Docker Desktop ejecutándose**  
✅ **Aplicación Flutter construida** (`build/web/` existe)  
✅ **Contenedor ejecutándose** (`docker ps | grep tfg-frontend-web`)  
✅ **Puerto 8082 accesible** (`curl http://localhost:8082`)  

---

## 🎯 **RESULTADO ESPERADO**

- **Aplicación web funcionando en**: http://localhost:8082
- **Contenedor**: `tfg-frontend-web`
- **Puerto**: 8082 → 80
- **Servidor**: Nginx optimizado para Flutter Web

---

**¡El contenedor web debería estar funcionando! 🚀**
