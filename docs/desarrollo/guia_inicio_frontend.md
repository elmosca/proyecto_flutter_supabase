# 🚀 GUÍA DE INICIO RÁPIDO - FRONTEND TFG
# Sistema de Seguimiento de Proyectos TFG - Flutter + Supabase

## ⚡ **INICIO RÁPIDO (30 minutos)**

### **1. Prerrequisitos**
```bash
# Verificar que tienes instalado:
flutter --version  # Flutter 3.0+
dart --version     # Dart 3.0+
git --version      # Git
```

### **2. Crear Proyecto Flutter**
```bash
# Navegar al directorio del proyecto
cd /opt/proyecto_flutter_supabase

# Crear proyecto Flutter
flutter create frontend
cd frontend

# Verificar que funciona
flutter run
```

### **3. Configurar Dependencias**
```bash
# Añadir dependencias al pubspec.yaml
flutter pub add supabase_flutter
flutter pub add flutter_bloc
flutter pub add go_router
flutter pub add json_annotation
flutter pub add build_runner
flutter pub add json_serializable

# Instalar dependencias
flutter pub get
```

### **4. Configurar Supabase**
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'http://localhost:54321',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFG Sistema',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
```

### **5. Probar Conexión**
```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login TFG')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _login() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login exitoso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

### **6. Ejecutar y Probar**
```bash
# Ejecutar la aplicación
flutter run

# Usar credenciales de prueba:
# Email: carlos.lopez@alumno.cifpcarlos3.es
# Password: password123
```

---

## 📁 **ESTRUCTURA DE CARPETAS RECOMENDADA**

```
frontend/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── app.dart                  # Configuración de la app
│   ├── models/                   # Modelos de datos
│   │   ├── user.dart
│   │   ├── anteproject.dart
│   │   ├── task.dart
│   │   └── notification.dart
│   ├── services/                 # Servicios de comunicación
│   │   ├── auth_service.dart
│   │   ├── anteprojects_service.dart
│   │   ├── tasks_service.dart
│   │   └── notifications_service.dart
│   ├── blocs/                    # Gestión de estado
│   │   ├── auth_bloc.dart
│   │   ├── anteprojects_bloc.dart
│   │   └── tasks_bloc.dart
│   ├── screens/                  # Pantallas de la app
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── student/
│   │   │   ├── student_dashboard.dart
│   │   │   └── anteproject_form.dart
│   │   ├── tutor/
│   │   │   ├── tutor_dashboard.dart
│   │   │   └── approval_screen.dart
│   │   └── kanban/
│   │       ├── kanban_board.dart
│   │       └── task_card.dart
│   ├── widgets/                  # Widgets reutilizables
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   └── forms/
│   │       ├── anteproject_form.dart
│   │       └── task_form.dart
│   └── utils/                    # Utilidades
│       ├── constants.dart
│       ├── validators.dart
│       └── helpers.dart
├── test/                         # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
└── pubspec.yaml                  # Dependencias
```

---

## 🔧 **COMANDOS ÚTILES**

### **Desarrollo Diario**
```bash
# Verificar dependencias
flutter pub get

# Ejecutar aplicación
flutter run

# Ejecutar en modo debug
flutter run --debug

# Ejecutar en modo release
flutter run --release

# Hot reload (durante desarrollo)
# Presionar 'r' en la terminal
```

### **Testing**
```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/unit/auth_service_test.dart

# Ejecutar tests con cobertura
flutter test --coverage
```

### **Análisis de Código**
```bash
# Analizar código
flutter analyze

# Formatear código
flutter format .

# Limpiar proyecto
flutter clean
```

### **Generación de Código**
```bash
# Generar código para modelos JSON
flutter packages pub run build_runner build

# Generar código en modo watch
flutter packages pub run build_runner watch
```

---

## 📱 **USUARIOS DE PRUEBA**

### **Estudiante**
```json
{
  "email": "carlos.lopez@alumno.cifpcarlos3.es",
  "password": "password123",
  "role": "student",
  "full_name": "Carlos López"
}
```

### **Tutor**
```json
{
  "email": "maria.garcia@cifpcarlos3.es",
  "password": "password123",
  "role": "tutor",
  "full_name": "María García"
}
```

### **Administrador**
```json
{
  "email": "admin@cifpcarlos3.es",
  "password": "password123",
  "role": "admin",
  "full_name": "Administrador"
}
```

---

## 🛠️ **APIs DISPONIBLES**

### **1. Anteprojects API**
```dart
// Obtener anteproyectos del usuario
final response = await supabase.functions.invoke(
  'anteprojects-api',
  method: 'GET',
);

// Crear anteproyecto
final response = await supabase.functions.invoke(
  'anteprojects-api',
  method: 'POST',
  body: anteproject.toJson(),
);
```

### **2. Tasks API**
```dart
// Obtener tareas del proyecto
final response = await supabase.functions.invoke(
  'tasks-api',
  method: 'GET',
  queryParams: {'project_id': projectId.toString()},
);

// Crear tarea
final response = await supabase.functions.invoke(
  'tasks-api',
  method: 'POST',
  body: task.toJson(),
);
```

### **3. Approval API**
```dart
// Aprobar anteproyecto
final response = await supabase.functions.invoke(
  'approval-api',
  method: 'POST',
  queryParams: {'action': 'approve'},
  body: {'anteproject_id': anteprojectId},
);
```

---

## 🎯 **PRÓXIMOS PASOS**

### **Semana 1: Configuración**
1. ✅ Crear proyecto Flutter
2. ✅ Configurar dependencias
3. ✅ Implementar login básico
4. ✅ Probar conexión con backend

### **Semana 2: Autenticación**
1. Crear modelos de datos
2. Implementar servicios
3. Configurar gestión de estado
4. Implementar navegación por roles

### **Semana 3: Dashboards**
1. Crear dashboard para estudiantes
2. Crear dashboard para tutores
3. Implementar widgets comunes
4. Configurar navegación principal

---

## 📞 **SOPORTE**

### **En caso de problemas:**
1. **Verificar backend**: `supabase status` en `/backend/supabase`
2. **Revisar logs**: `flutter run --verbose`
3. **Verificar dependencias**: `flutter pub deps`
4. **Limpiar cache**: `flutter clean && flutter pub get`

### **Documentación adicional:**
- [Plan de desarrollo completo](plan_desarrollo_frontend.md)
- [Checklist semanal](checklist_frontend_semanal.md)
- [Entrega del backend](../backend/supabase/ENTREGA_BACKEND_FRONTEND.md)

---

**¡LISTO PARA COMENZAR! 🚀**

**Fecha de creación**: 17 de agosto de 2024  
**Responsable**: Equipo Frontend  
**Estado**: ✅ **LISTO PARA INICIAR**
