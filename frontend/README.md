# 🚀 Frontend TFG - Flutter Multiplataforma

## 📋 **Descripción del Proyecto**

Aplicación Flutter multiplataforma para el Sistema de Seguimiento de Proyectos TFG, conectada al backend Supabase en servidor de red.

## 🌐 **Configuración del Servidor**

### **Información del Backend**
- **IP del Servidor**: `192.168.1.9`
- **Puerto API**: `54321`
- **URL Base**: `http://192.168.1.9:54321`

### **Servicios Disponibles**
- **API REST**: `http://192.168.1.9:54321`
- **Storage S3**: `http://192.168.1.9:54321/storage/v1/s3`
- **Supabase Studio**: `http://192.168.1.9:54323`
- **Email Testing (Inbucket)**: `http://192.168.1.9:54324`

### **Credenciales de Storage**
- **Access Key**: `625729a08b95bf1b7ff351a663f3a23c`
- **Secret Key**: `850181e4652dd023b7a98c58ae0d2d34bd487ee0cc3254aed6eda37307425907`
- **Región**: `local`

## 🛠️ **Configuración del Entorno**

### **Prerrequisitos**
```bash
# Verificar Flutter
flutter --version

# Verificar dispositivos disponibles
flutter devices

# Habilitar plataformas (si es necesario)
flutter config --enable-web
flutter config --enable-windows
```

### **Instalación de Dependencias**
```bash
# Instalar dependencias
flutter pub get

# Verificar dependencias
flutter pub deps
```

## 🚀 **Ejecución del Proyecto**

### **Web (Recomendado para desarrollo)**
```bash
# Ejecutar en Edge
flutter run -d edge

# Ejecutar en Chrome
flutter run -d chrome

# Ejecutar en puerto específico
flutter run -d edge --web-port=8082
```

### **Windows**
```bash
# Habilitar modo desarrollador primero
start ms-settings:developers

# Ejecutar aplicación
flutter run -d windows
```

### **Android (Configurado)**
```bash
# Requiere Android Studio instalado
flutter run -d android

# Build APK
flutter build apk --debug

# Build App Bundle para Google Play
flutter build appbundle --release
```

## 📱 **Plataformas Soportadas**

| Plataforma | Estado | Prioridad | Comandos |
|------------|--------|-----------|----------|
| **Web** | ✅ Funcional | ALTA | `flutter run -d edge` |
| **Windows** | ✅ Funcional | ALTA | `flutter run -d windows` |
| **Android** | 🟡 Configurado (requiere Android Studio) | ALTA | `flutter run -d android` |
| **iOS** | ⏳ Pendiente | MEDIA | `flutter run -d ios` |
| **macOS** | ⏳ Pendiente | BAJA | `flutter run -d macos` |
| **Linux** | ⏳ Pendiente | BAJA | `flutter run -d linux` |

## 🔧 **Estructura del Proyecto**

```
frontend/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/                   # Modelos de datos
│   ├── services/                 # Servicios de comunicación
│   ├── blocs/                    # Gestión de estado
│   ├── screens/                  # Pantallas de la app
│   │   ├── auth/                 # Autenticación
│   │   ├── student/              # Pantallas de estudiante
│   │   ├── tutor/                # Pantallas de tutor
│   │   └── kanban/               # Tablero Kanban
│   ├── widgets/                  # Widgets reutilizables
│   │   ├── common/               # Widgets comunes
│   │   ├── forms/                # Formularios
│   │   └── platform/             # Widgets específicos por plataforma
│   ├── utils/                    # Utilidades
│   │   └── config.dart           # Configuración del proyecto
│   └── themes/                   # Temas por plataforma
├── web/                          # Configuración específica de web
├── windows/                      # Configuración específica de Windows
└── pubspec.yaml                  # Dependencias
```

## 🔐 **Autenticación**

### **Credenciales de Prueba**
```json
{
  "student": "carlos.lopez@alumno.cifpcarlos3.es",
  "tutor": "maria.garcia@cifpcarlos3.es",
  "admin": "admin@cifpcarlos3.es",
  "password": "password123"
}
```

### **Flujo de Autenticación**
1. **Login**: Usuario introduce credenciales
2. **Validación**: Supabase Auth valida credenciales
3. **Roles**: Sistema determina rol del usuario
4. **Navegación**: Redirige al dashboard correspondiente

## 📊 **Funcionalidades Implementadas**

### **✅ Completadas**
- [x] Configuración multiplataforma
- [x] Conexión con backend en servidor de red
- [x] Pantalla de login funcional
- [x] Detección de plataforma
- [x] Información del servidor
- [x] Credenciales de prueba

### **🔄 En Desarrollo**
- [ ] Navegación por roles
- [ ] Dashboard de estudiante
- [ ] Dashboard de tutor
- [ ] Gestión de anteproyectos
- [ ] Tablero Kanban

### **⏳ Pendientes**
- [ ] Sistema de notificaciones
- [ ] Subida de archivos
- [ ] Generación de PDFs
- [ ] Testing multiplataforma

## 🛠️ **Herramientas de Desarrollo**

### **Supabase Studio**
- **URL**: http://192.168.1.9:54323
- **Uso**: Gestión de base de datos, usuarios, políticas RLS

### **Email Testing (Inbucket)**
- **URL**: http://192.168.1.9:54324
- **Uso**: Pruebas de envío de emails

## 🔧 **Comandos Útiles**

### **Desarrollo**
```bash
# Hot reload
r

# Hot restart
R

# Salir
q

# Ver logs
flutter logs
```

### **Build**
```bash
# Build para web
flutter build web --release

# Build para Windows
flutter build windows --release

# Build para Android
flutter build apk --release
```

### **Testing**
```bash
# Ejecutar tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage
```

### **Análisis**
```bash
# Analizar código
flutter analyze

# Formatear código
flutter format .
```

## 🚨 **Solución de Problemas**

### **Problema: Modo Desarrollador en Windows**
```bash
# Abrir configuración de desarrollador
start ms-settings:developers

# Habilitar "Modo desarrollador"
```

### **Problema: CORS en Web**
```bash
# Verificar configuración de Supabase
# Asegurar que el backend permite CORS desde el dominio
```

### **Problema: Conexión al Servidor**
```bash
# Verificar conectividad
ping 192.168.1.9

# Verificar puerto
telnet 192.168.1.9 54321
```

## 📞 **Soporte**

### **Enlaces Útiles**
- **Backend Status**: http://192.168.1.9:54321/health
- **Supabase Studio**: http://192.168.1.9:54323
- **Email Testing**: http://192.168.1.9:54324

### **Documentación**
- [Plan de Desarrollo](../docs/desarrollo/plan_desarrollo_frontend.md)
- [Guía de Inicio](../docs/desarrollo/guia_inicio_frontend.md)
- [Checklist Semanal](../docs/desarrollo/checklist_frontend_semanal.md)
- [Configuración Android](ANDROID_SETUP_GUIDE.md)

---

**Estado**: ✅ **CONFIGURADO Y FUNCIONAL**  
**Última actualización**: 29 de agosto de 2024  
**Versión**: 1.0.0
