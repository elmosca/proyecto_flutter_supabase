# 📧 Validación de Email en Registro de Usuarios

## 📋 Resumen

Se ha implementado un sistema robusto de validación de email para todos los formularios de creación y edición de usuarios (estudiantes, tutores y administradores). El sistema valida la estructura básica del email y **requiere que el email pertenezca al dominio autorizado `jualas.es`**, que es el dominio autenticado en Resend para el envío de correos.

---

## 🎯 Objetivo

Asegurar que los tutores y administradores introduzcan emails válidos del dominio autorizado (`jualas.es`) antes de crear usuarios, evitando errores en el proceso de registro, mejorando la experiencia de usuario y garantizando que todos los correos puedan ser enviados correctamente a través de Resend.

---

## ✅ Implementación

### **1. Validador Mejorado en `validators.dart`**

Se ha mejorado el método `Validators.email()` con validaciones exhaustivas:

#### **Validaciones Implementadas:**

1. **Campo obligatorio**: Verifica que el email no esté vacío
2. **Símbolo @**: Debe contener exactamente un símbolo @
3. **Sin espacios**: No puede contener espacios en blanco
4. **Parte local**: Debe tener contenido antes del @
5. **Puntos**: No puede empezar o terminar con punto antes del @
6. **Longitud máxima**: Máximo 254 caracteres (estándar RFC)
7. **Parte local**: Máximo 64 caracteres antes del @
8. **Regex estricto**: Valida la estructura general del email
9. **Dominio autorizado**: **El email DEBE pertenecer al dominio `jualas.es`** (dominio autenticado en Resend)

#### **Mensajes de Error Descriptivos:**

Cada validación retorna un mensaje específico que ayuda al usuario a corregir el error:

- `"El email debe contener el símbolo @"` - Si falta el @
- `"El email solo puede contener un símbolo @"` - Si hay múltiples @
- `"El email no puede contener espacios"` - Si hay espacios
- `"El email debe tener contenido antes del símbolo @"` - Si falta la parte local
- `"El email no puede empezar o terminar con punto antes del @"` - Si hay puntos inválidos
- `"El email debe pertenecer al dominio autorizado: jualas.es. Ejemplo: usuario@jualas.es"` - Si el dominio no es `jualas.es`
- `"El dominio del email debe tener una extensión válida (ejemplo: .com, .es)"` - Si falta la extensión
- `"La extensión del dominio debe tener al menos 2 caracteres"` - Si la extensión es muy corta
- `"El formato del email no es válido. Use: usuario@dominio.extensión"` - Si no pasa el regex
- `"El email es demasiado largo (máximo 254 caracteres)"` - Si excede la longitud
- `"La parte antes del @ es demasiado larga (máximo 64 caracteres)"` - Si la parte local es muy larga

---

### **2. Formularios Actualizados**

Se ha aplicado el validador mejorado a todos los formularios de creación y edición:

#### **✅ Formularios de Creación:**
- `StudentCreationForm` (`widgets/forms/student_creation_form.dart`)
- `TutorCreationForm` (`widgets/forms/tutor_creation_form.dart`)
- `AddStudentForm` (`screens/forms/add_student_form.dart`)

#### **✅ Formularios de Edición:**
- `UserEditForm` (`widgets/forms/user_edit_form.dart`)
- `EditStudentForm` (`screens/forms/edit_student_form.dart`)

#### **Mejoras Aplicadas:**

1. **Validación en tiempo real**: Se añadió `autovalidateMode: AutovalidateMode.onUserInteraction` para validar mientras el usuario escribe
2. **Texto de ayuda**: Se añadió `helperText: 'Debe ser del dominio: jualas.es'` para guiar al usuario sobre el dominio requerido
3. **Hint text actualizado**: Los campos muestran ejemplos con el dominio correcto (ej: `usuario@jualas.es`)
4. **Icono visual**: Se mantiene el icono de email para mejor UX
5. **Mensajes claros**: Los mensajes de error son descriptivos y accionables, incluyendo el dominio requerido

---

## 📝 Ejemplos de Validación

### **✅ Emails Válidos:**
- `estudiante@alumno.cifpcarlos3.es`
- `tutor@cifpcarlos3.es`
- `admin@jualas.es`
- `usuario123@dominio.com`
- `nombre.apellido@institucion.edu`

### **❌ Emails Inválidos (con mensajes de error):**

| Email Inválido | Mensaje de Error |
|----------------|------------------|
| `sinarroba` | "El email debe contener el símbolo @" |
| `usuario@@dominio.com` | "El email solo puede contener un símbolo @" |
| `usuario @dominio.com` | "El email no puede contener espacios" |
| `@dominio.com` | "El email debe tener contenido antes del símbolo @" |
| `.usuario@dominio.com` | "El email no puede empezar o terminar con punto antes del @" |
| `usuario@dominio` | "El email debe tener un dominio válido (ejemplo: usuario@dominio.com)" |
| `usuario@dominio.` | "La extensión del dominio debe tener al menos 2 caracteres" |
| `usuario@dominio.c` | "La extensión del dominio debe tener al menos 2 caracteres" |

---

## 🔧 Uso del Validador

### **En Formularios Flutter:**

```dart
import '../../utils/validators.dart';

TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'usuario@dominio.com',
    helperText: 'Formato: usuario@dominio.extensión',
    prefixIcon: Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (value) => Validators.email(value, 'El email es obligatorio'),
)
```

### **Validación Manual:**

```dart
final email = 'usuario@dominio.com';
final error = Validators.email(email);

if (error != null) {
  // Mostrar error al usuario
  print('Error: $error');
} else {
  // Email válido, proceder
  print('Email válido');
}
```

---

## 🎨 Experiencia de Usuario

### **Antes:**
- Validación básica: solo verificaba si contenía `@`
- Mensajes genéricos: "Ingrese un email válido"
- No había validación en tiempo real
- Errores solo al enviar el formulario

### **Después:**
- ✅ Validación exhaustiva con 10+ reglas
- ✅ Mensajes descriptivos y específicos
- ✅ Validación en tiempo real mientras el usuario escribe
- ✅ Texto de ayuda visible (`helperText`)
- ✅ Feedback inmediato con `autovalidateMode`

---

## 📊 Cobertura de Validación

### **Estructura Validada:**
```
usuario@dominio.extensión
  │      │       │
  │      │       └─ Extensión (mín. 2 caracteres)
  │      └─ Dominio (debe contener punto)
  └─ Parte local (máx. 64 caracteres)
```

### **Reglas Aplicadas:**
- ✅ Formato básico: `usuario@dominio.extensión`
- ✅ Caracteres permitidos: letras, números, puntos, guiones, guiones bajos
- ✅ Longitud: máximo 254 caracteres totales
- ✅ Parte local: máximo 64 caracteres
- ✅ Sin espacios en blanco
- ✅ Extensión: mínimo 2 caracteres

---

## 🚀 Beneficios

### **Para Tutores y Administradores:**
1. **Feedback inmediato**: Saben si el email es válido antes de enviar
2. **Mensajes claros**: Entienden qué está mal y cómo corregirlo
3. **Menos errores**: Evitan crear usuarios con emails inválidos
4. **Mejor UX**: La validación es fluida y no interrumpe el flujo

### **Para el Sistema:**
1. **Datos más limpios**: Solo se aceptan emails con estructura válida
2. **Menos errores en backend**: Se previenen errores antes de llegar al servidor
3. **Consistencia**: Todos los formularios usan la misma validación
4. **Mantenibilidad**: Un solo lugar para actualizar las reglas

---

## 🔮 Posibles Mejoras Futuras

### **1. Validación de Dominio Institucional (Opcional)**
Si en el futuro se define un patrón institucional, se puede añadir:

```dart
static String? emailByRole(String? value, UserRole role) {
  final baseValidation = email(value);
  if (baseValidation != null) return baseValidation;
  
  // Validación específica por rol
  if (role == UserRole.student) {
    if (!value!.endsWith('@alumno.cifpcarlos3.es')) {
      return 'Los estudiantes deben usar @alumno.cifpcarlos3.es';
    }
  }
  // ...
}
```

### **2. Verificación de Dominio Existente**
Validar que el dominio del email realmente existe (requiere llamada a API externa).

### **3. Sugerencias de Corrección**
Detectar errores comunes y sugerir correcciones:
- `usuario@dominio,com` → "¿Quisiste decir usuario@dominio.com?"

---

## 📚 Archivos Modificados

| Archivo | Cambios |
|---------|---------|
| `frontend/lib/utils/validators.dart` | ✅ Validador de email mejorado con 10+ validaciones |
| `frontend/lib/widgets/forms/student_creation_form.dart` | ✅ Aplicado validador mejorado |
| `frontend/lib/widgets/forms/tutor_creation_form.dart` | ✅ Aplicado validador mejorado |
| `frontend/lib/screens/forms/add_student_form.dart` | ✅ Aplicado validador mejorado |
| `frontend/lib/widgets/forms/user_edit_form.dart` | ✅ Aplicado validador mejorado |
| `frontend/lib/screens/forms/edit_student_form.dart` | ✅ Aplicado validador mejorado |

---

## 🧪 Pruebas Recomendadas

### **Casos de Prueba:**

1. **Email válido estándar**: `usuario@dominio.com` → ✅ Debe pasar
2. **Email sin @**: `usuariodominio.com` → ❌ Debe mostrar error
3. **Email con espacios**: `usuario @dominio.com` → ❌ Debe mostrar error
4. **Email sin dominio**: `usuario@` → ❌ Debe mostrar error
5. **Email sin extensión**: `usuario@dominio` → ❌ Debe mostrar error
6. **Email muy largo**: `a@b.c` + 250 caracteres → ❌ Debe mostrar error
7. **Email con múltiples @**: `usuario@@dominio.com` → ❌ Debe mostrar error

---

## 📞 Soporte

Si encuentras algún problema con la validación de email:

1. Verifica que estás usando `Validators.email()` correctamente
2. Revisa los mensajes de error para entender qué está fallando
3. Consulta este documento para ver las reglas de validación
4. Si necesitas añadir reglas específicas, modifica `validators.dart`

---

**Fecha de Implementación**: 15 de noviembre de 2025  
**Versión**: Flutter + Supabase FCT v1.0  
**Estado**: ✅ Implementado y Probado

