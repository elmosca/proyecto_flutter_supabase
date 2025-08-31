# 📱 Guía de Configuración Android Studio - TFG

## 🎯 **Objetivo**
Completar la configuración de Android Studio para el desarrollo de la aplicación Flutter del proyecto TFG.

## ✅ **Estado Actual**
- ✅ Android Studio instalado en `C:\Program Files\Android\Android Studio`
- ✅ Flutter configurado para Android
- ⚠️ **Android SDK pendiente de configuración**
- ⚠️ **Emuladores pendientes de creación**

---

## 🛠️ **Pasos para Completar la Configuración**

### **Paso 1: Configuración Inicial de Android Studio**

1. **Abrir Android Studio** (ya abierto)
2. **Seguir el Setup Wizard**:
   - Seleccionar "Standard" setup
   - Elegir tema (Light/Dark)
   - Instalar Android SDK automáticamente

### **Paso 2: Configurar Android SDK**

1. **Ir a**: `File > Settings > Appearance & Behavior > System Settings > Android SDK`
2. **Instalar los siguientes componentes**:

#### **SDK Platforms**
- ✅ Android 14.0 (API 34)
- ✅ Android 13.0 (API 33) - **Recomendado**
- ✅ Android 12.0 (API 31)
- ✅ Android 11.0 (API 30)

#### **SDK Tools**
- ✅ Android SDK Build-Tools
- ✅ Android SDK Platform-Tools
- ✅ Android Emulator
- ✅ Android SDK Tools
- ✅ Intel x86 Emulator Accelerator (HAXM installer)

### **Paso 3: Crear Emuladores**

1. **Ir a**: `Tools > AVD Manager`
2. **Crear Virtual Device**:

#### **Emulador Principal (Recomendado)**
- **Device**: Pixel 6
- **API Level**: 33 (Android 13)
- **RAM**: 2GB
- **Internal Storage**: 4GB
- **SD Card**: 2GB

#### **Emuladores Adicionales**
- **Device**: Pixel 4 (API 30) - Para testing compatibilidad
- **Device**: Nexus 5 (API 28) - Para testing versiones antiguas

### **Paso 4: Verificar Configuración**

Una vez completada la configuración, ejecutar:

```bash
# Verificar estado completo
flutter doctor -v

# Verificar dispositivos disponibles
flutter devices

# Verificar emuladores
flutter emulators
```

---

## 🔧 **Configuración de Variables de Entorno**

### **Variables del Sistema**
```bash
# Añadir al PATH del sistema:
ANDROID_HOME=C:\Users\[Usuario]\AppData\Local\Android\Sdk
ANDROID_SDK_ROOT=C:\Users\[Usuario]\AppData\Local\Android\Sdk

# Añadir al PATH:
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
```

### **Configurar Flutter**
```bash
# Configurar SDK
flutter config --android-sdk "C:\Users\[Usuario]\AppData\Local\Android\Sdk"

# Configurar Android Studio
flutter config --android-studio-dir "C:\Program Files\Android\Android Studio"
```

---

## 📱 **Testing de la Configuración**

### **Paso 1: Verificar Emuladores**
```bash
# Listar emuladores disponibles
flutter emulators

# Iniciar emulador
flutter emulators --launch Pixel6_API33
```

### **Paso 2: Ejecutar Aplicación**
```bash
# Ejecutar en emulador
flutter run -d android

# Build APK de debug
flutter build apk --debug

# Build APK de release
flutter build apk --release
```

### **Paso 3: Testing en Dispositivo Físico**
1. **Habilitar opciones de desarrollador** en el dispositivo Android
2. **Habilitar depuración USB**
3. **Conectar dispositivo** y autorizar
4. **Ejecutar**: `flutter run -d [device-id]`

---

## 🐛 **Solución de Problemas Comunes**

### **Error: Android SDK no encontrado**
```bash
# Verificar ruta del SDK
flutter config --android-sdk "C:\Users\[Usuario]\AppData\Local\Android\Sdk"

# Verificar configuración
flutter doctor
```

### **Error: Emulador no disponible**
```bash
# Crear emulador desde línea de comandos
avdmanager create avd -n "Pixel6_API33" -k "system-images;android-33;google_apis;x86_64"

# Iniciar emulador
flutter emulators --launch Pixel6_API33
```

### **Error: Build fallido**
```bash
# Limpiar cache
flutter clean
flutter pub get

# Verificar dependencias
flutter doctor --android-licenses
```

### **Error: Permisos de red**
- Verificar `network_security_config.xml`
- Asegurar que el dominio del servidor esté incluido
- Verificar permisos en `AndroidManifest.xml`

---

## 📊 **Verificación Final**

### **Checklist de Configuración**
- [ ] Android Studio instalado y configurado
- [ ] Android SDK instalado con API 33
- [ ] Emuladores creados (Pixel 6 API 33)
- [ ] Variables de entorno configuradas
- [ ] Flutter doctor sin errores
- [ ] Aplicación ejecutándose en emulador
- [ ] Build APK funcionando

### **Comandos de Verificación**
```bash
# Verificar estado completo
flutter doctor -v

# Verificar dispositivos
flutter devices

# Verificar emuladores
flutter emulators

# Probar build
flutter build apk --debug
```

---

## 🎯 **Próximos Pasos**

### **Una vez completada la configuración:**
1. ✅ Probar aplicación en emulador Android
2. ✅ Verificar funcionalidad de login
3. ✅ Probar navegación por roles
4. ✅ Testing en diferentes tamaños de pantalla
5. ✅ Optimizar para Android específicamente

### **Optimizaciones para Android:**
1. ✅ Configurar iconos específicos de Android
2. ✅ Optimizar rendimiento para móviles
3. ✅ Configurar notificaciones push
4. ✅ Preparar para Google Play Store

---

## 📞 **Recursos Útiles**

### **Documentación Oficial**
- [Flutter Android Setup](https://flutter.dev/docs/get-started/install/windows#android-setup)
- [Android Studio Setup](https://developer.android.com/studio/intro)
- [Android SDK Setup](https://developer.android.com/studio#command-tools)

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

# Ejecutar en Android
flutter run -d android
```

---

**Estado**: 🟡 **EN CONFIGURACIÓN**  
**Última actualización**: 29 de agosto de 2024  
**Responsable**: Equipo Frontend
