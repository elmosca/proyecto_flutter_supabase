# 📱 Configuración de Android - Proyecto TFG

## 🎯 **Objetivo**
Configurar Android como plataforma de desarrollo para la aplicación Flutter del Sistema de Seguimiento de TFG.

## ✅ **Estado Actual**
- ✅ **Proyecto Flutter configurado** para Android
- ✅ **AndroidManifest.xml** configurado con permisos necesarios
- ✅ **Network Security Config** configurado para servidor local
- ✅ **build.gradle** optimizado para el proyecto TFG
- ✅ **MainActivity** actualizado con paquete correcto
- ⚠️ **Android Studio** - Pendiente de instalación
- ⚠️ **Emuladores** - Pendiente de configuración

---

## 🛠️ **Configuración Requerida**

### **1. Instalar Android Studio**
```bash
# Descargar desde:
https://developer.android.com/studio
```

**Pasos de instalación:**
1. Descargar Android Studio
2. Ejecutar el instalador
3. Seguir el asistente de configuración
4. Instalar Android SDK durante la configuración
5. Configurar variables de entorno

### **2. Configurar Variables de Entorno**
```bash
# Añadir al PATH:
ANDROID_HOME=C:\Users\[Usuario]\AppData\Local\Android\Sdk
ANDROID_SDK_ROOT=C:\Users\[Usuario]\AppData\Local\Android\Sdk

# Añadir al PATH:
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
```

### **3. Configurar Android SDK**
```bash
# Abrir Android Studio
# Ir a: Tools > SDK Manager
# Instalar:
- Android SDK Platform-Tools
- Android SDK Build-Tools
- Android SDK Platform (API 33 o superior)
- Android Emulator
- Android SDK Tools
```

---

## 📱 **Configuración de Emuladores**

### **Crear AVD (Android Virtual Device)**
```bash
# En Android Studio:
# Tools > AVD Manager > Create Virtual Device

# Configuración recomendada:
- Device: Pixel 6 (o similar)
- API Level: 33 (Android 13)
- RAM: 2GB
- Internal Storage: 4GB
- SD Card: 2GB
```

### **Emuladores Recomendados**
| Dispositivo | API Level | Uso |
|-------------|-----------|-----|
| Pixel 6 | 33 | Desarrollo principal |
| Pixel 4 | 30 | Testing compatibilidad |
| Nexus 5 | 28 | Testing versiones antiguas |

---

## 🔧 **Configuración del Proyecto**

### **Estructura de Archivos Android**
```
android/
├── app/
│   ├── src/main/
│   │   ├── kotlin/com/cifpcarlos3/tfg/frontend/
│   │   │   └── MainActivity.kt
│   │   ├── res/
│   │   │   ├── xml/
│   │   │   │   └── network_security_config.xml
│   │   │   └── values/
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── build.gradle.kts
└── settings.gradle.kts
```

### **Configuraciones Específicas**

#### **AndroidManifest.xml**
- ✅ Permisos de Internet
- ✅ Permisos de almacenamiento
- ✅ Configuración de seguridad de red
- ✅ Nombre de aplicación: "TFG Sistema"

#### **build.gradle.kts**
- ✅ Application ID: `com.cifpcarlos3.tfg.frontend`
- ✅ Min SDK: 21 (Android 5.0)
- ✅ MultiDex habilitado
- ✅ Configuración de splits para diferentes ABIs

#### **Network Security Config**
- ✅ Conexiones HTTP permitidas a servidor local
- ✅ Dominios configurados: 192.168.1.9, localhost, 127.0.0.1

---

## 🚀 **Comandos de Desarrollo**

### **Verificar Configuración**
```bash
# Verificar estado de Android
flutter doctor

# Verificar dispositivos disponibles
flutter devices

# Verificar emuladores
flutter emulators
```

### **Ejecutar en Android**
```bash
# Ejecutar en emulador
flutter run -d android

# Ejecutar en dispositivo físico
flutter run -d [device-id]

# Build APK de debug
flutter build apk --debug

# Build APK de release
flutter build apk --release

# Build App Bundle para Google Play
flutter build appbundle --release
```

### **Testing en Android**
```bash
# Ejecutar tests
flutter test

# Ejecutar tests específicos de Android
flutter test --platform android
```

---

## 📊 **Optimizaciones de Rendimiento**

### **Configuraciones de Build**
```kotlin
// build.gradle.kts
android {
    defaultConfig {
        minSdk = 21
        multiDexEnabled = true
        resConfigs("es", "en")
    }
    
    buildTypes {
        release {
            minifyEnabled = true
            shrinkResources = true
        }
    }
    
    splits {
        abi {
            enable = true
            include("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }
}
```

### **Configuraciones de Red**
```xml
<!-- network_security_config.xml -->
<domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">192.168.1.9</domain>
    <domain includeSubdomains="true">localhost</domain>
</domain-config>
```

---

## 🐛 **Solución de Problemas**

### **Error: Android SDK no encontrado**
```bash
# Configurar ruta del SDK
flutter config --android-sdk C:\Users\[Usuario]\AppData\Local\Android\Sdk
```

### **Error: Emulador no disponible**
```bash
# Crear AVD desde línea de comandos
avdmanager create avd -n "Pixel6_API33" -k "system-images;android-33;google_apis;x86_64"
```

### **Error: Permisos de red**
```bash
# Verificar network_security_config.xml
# Asegurar que el dominio del servidor esté incluido
```

### **Error: Build fallido**
```bash
# Limpiar cache
flutter clean
flutter pub get

# Verificar dependencias
flutter doctor --android-licenses
```

---

## 📱 **Testing en Dispositivos Físicos**

### **Configurar Dispositivo Android**
1. Habilitar **Opciones de desarrollador**
   - Configuración > Acerca del teléfono > Tocar 7 veces en "Número de compilación"

2. Habilitar **Depuración USB**
   - Opciones de desarrollador > Depuración USB

3. Conectar dispositivo y autorizar

### **Verificar Conexión**
```bash
# Verificar dispositivos conectados
adb devices

# Instalar APK directamente
flutter install
```

---

## 🎯 **Próximos Pasos**

### **Inmediatos**
1. ✅ Instalar Android Studio
2. ✅ Configurar Android SDK
3. ✅ Crear emuladores
4. ✅ Probar aplicación en Android

### **A corto plazo**
1. ✅ Optimizar rendimiento
2. ✅ Configurar signing para release
3. ✅ Testing en múltiples dispositivos
4. ✅ Preparar para Google Play Store

### **A medio plazo**
1. ✅ Implementar notificaciones push
2. ✅ Optimizar para diferentes tamaños de pantalla
3. ✅ Configurar CI/CD para Android
4. ✅ Publicar en Google Play Store

---

## 📞 **Recursos Útiles**

### **Documentación Oficial**
- [Flutter Android Setup](https://flutter.dev/docs/get-started/install/windows#android-setup)
- [Android Studio](https://developer.android.com/studio)
- [Android SDK](https://developer.android.com/studio#command-tools)

### **Comandos Útiles**
```bash
# Verificar configuración completa
flutter doctor -v

# Listar dispositivos
flutter devices

# Listar emuladores
flutter emulators

# Iniciar emulador
flutter emulators --launch Pixel6_API33
```

---

**Estado**: 🟡 **EN CONFIGURACIÓN**  
**Última actualización**: 29 de agosto de 2024  
**Responsable**: Equipo Frontend
