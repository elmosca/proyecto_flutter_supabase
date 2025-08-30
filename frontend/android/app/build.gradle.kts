plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cifpcarlos3.tfg.frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.cifpcarlos3.tfg.frontend"
        // Configuración específica para el proyecto TFG
        minSdk = 21 // Android 5.0 (API level 21)
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
        
        // Configuración para múltiples idiomas
        resConfigs("es", "en")
        
        // Configuración de rendimiento
        multiDexEnabled = true
    }

    buildTypes {
        debug {
            // Configuración para desarrollo
            debuggable = true
            minifyEnabled = false
            shrinkResources = false
        }
        
        release {
            // Configuración para producción
            debuggable = false
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Configuración para diferentes densidades de pantalla
    splits {
        abi {
            enable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            universalApk = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Soporte para múltiples DEX files
    implementation("androidx.multidex:multidex:2.0.1")
}
