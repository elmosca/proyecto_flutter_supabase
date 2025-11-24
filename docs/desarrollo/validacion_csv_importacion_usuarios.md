# 📊 Validación de CSV para Importación Masiva de Usuarios

## 📋 Resumen

Se ha implementado un sistema completo de validación de emails y datos para la importación masiva de usuarios mediante archivos CSV. El sistema valida cada fila del CSV antes de la importación y muestra un resumen detallado con mensajes de conformidad o error para cada registro.

---

## 🎯 Objetivo

Permitir que tutores y administradores importen usuarios masivamente desde CSV con:
- ✅ Validación exhaustiva de emails antes de importar
- ✅ Mensajes claros de error por cada fila inválida
- ✅ Resumen visual de filas válidas vs. errores
- ✅ Diálogo detallado con resultados de la importación

---

## ✅ Implementación

### **1. Validación de Emails en CSV**

Se utiliza el validador mejorado `Validators.email()` para validar cada email del CSV antes de procesarlo.

#### **Validaciones Aplicadas por Fila:**

1. **Número de columnas**: Verifica que la fila tenga el número correcto de columnas
2. **Nombre completo**: Obligatorio y no vacío
3. **Email**: 
   - Obligatorio
   - Validación exhaustiva con `Validators.email()`
   - Mensajes específicos de error si el formato es inválido
4. **NRE** (para estudiantes): Obligatorio
5. **Contraseña** (para formato admin): Obligatoria

---

### **2. Archivos Actualizados**

#### **✅ `import_students_csv_screen.dart`** (Para Tutores)

**Mejoras implementadas:**
- ✅ Validación de emails con `Validators.email()`
- ✅ Clase `_CsvRowValidation` para rastrear estado de cada fila
- ✅ Resumen visual de validación (filas válidas vs. errores)
- ✅ Vista previa detallada con estado de cada fila
- ✅ Diálogo de resultados post-importación con detalle por usuario
- ✅ Iconos visuales (✅ verde para válido, ❌ rojo para error)

#### **✅ `csv_import_widget.dart`** (Para Administradores)

**Mejoras implementadas:**
- ✅ Validación de emails con `Validators.email()`
- ✅ Clase `_CsvRowValidation` para rastrear estado de cada fila
- ✅ Resumen visual de validación
- ✅ Vista previa detallada con estado de cada fila
- ✅ Botón de importación adaptativo (verde si todo válido, naranja si hay errores)

---

## 📊 Flujo de Validación

### **Paso 1: Selección de Archivo**
1. Usuario selecciona archivo CSV
2. Sistema parsea el archivo línea por línea

### **Paso 2: Validación por Fila**
Para cada fila del CSV:
1. ✅ Verifica número de columnas
2. ✅ Valida campos obligatorios (nombre, email, NRE/contraseña)
3. ✅ Valida formato de email con `Validators.email()`
4. ✅ Crea objeto `_CsvRowValidation` con resultado

### **Paso 3: Visualización de Resultados**
1. **Resumen de Validación**: Muestra contador de filas válidas y errores
2. **Vista Previa Detallada**: Lista cada fila con:
   - ✅ Icono verde si es válida
   - ❌ Icono rojo si tiene error
   - 📧 Email con color según validación
   - 📝 Mensaje de error específico si aplica

### **Paso 4: Importación**
1. Solo se importan las filas válidas
2. Se omiten automáticamente las filas con errores
3. Se muestra diálogo con resultados detallados

### **Paso 5: Diálogo de Resultados**
Muestra:
- ✅ Resumen: X usuarios creados, Y errores
- 📋 Lista detallada de cada usuario:
  - ✅ Nombre y email si se creó exitosamente
  - ❌ Nombre, email y mensaje de error si falló

---

## 🎨 Interfaz de Usuario

### **Resumen de Validación**

```
┌─────────────────────────────────────┐
│ ⚠️  Resumen de Validación          │
│                                     │
│ ✅ 15 filas válidas                 │
│ ❌ 3 errores                        │
└─────────────────────────────────────┘
```

### **Vista Previa por Fila**

```
┌─────────────────────────────────────┐
│ 📋 Validación por Fila (18 filas)   │
│                                     │
│ ✅ Línea 2: Juan Pérez García      │
│    Email: juan@alumno.cifpcarlos3.es│
│                                     │
│ ❌ Línea 3: María López             │
│    Email: maria@invalido             │
│    Error: Email inválido: El email  │
│    debe tener un dominio válido     │
│                                     │
│ ✅ Línea 4: Pedro Sánchez          │
│    Email: pedro@alumno.cifpcarlos3.es│
└─────────────────────────────────────┘
```

### **Diálogo de Resultados Post-Importación**

```
┌─────────────────────────────────────┐
│ ✅ Importación Completada           │
│                                     │
│ ┌───────────────────────────────┐   │
│ │ ✅ 15 usuarios creados        │   │
│ │ ❌ 3 errores                  │   │
│ └───────────────────────────────┘   │
│                                     │
│ Detalle por usuario:                │
│                                     │
│ ✅ Juan Pérez García                │
│    juan@alumno.cifpcarlos3.es       │
│                                     │
│ ❌ María López                      │
│    maria@invalido                   │
│    Email ya registrado en el sistema│
└─────────────────────────────────────┘
```

---

## 📝 Ejemplos de Mensajes de Error

### **Errores de Validación de Email:**

| Email Inválido | Mensaje Mostrado |
|----------------|------------------|
| `sinarroba` | "Email inválido: El email debe contener el símbolo @" |
| `usuario@@dominio.com` | "Email inválido: El email solo puede contener un símbolo @" |
| `usuario @dominio.com` | "Email inválido: El email no puede contener espacios" |
| `@dominio.com` | "Email inválido: El email debe tener contenido antes del símbolo @" |
| `usuario@dominio` | "Email inválido: El email debe tener un dominio válido (ejemplo: usuario@dominio.com)" |
| `usuario@dominio.c` | "Email inválido: La extensión del dominio debe tener al menos 2 caracteres" |

### **Otros Errores:**

| Error | Mensaje |
|-------|---------|
| Fila con columnas incorrectas | "Línea X: Número de columnas incorrecto" |
| Nombre vacío | "Línea X: Nombre completo es obligatorio" |
| Email vacío | "Línea X: Email es obligatorio" |
| NRE vacío | "Línea X: NRE es obligatorio" |
| Contraseña vacía | "Línea X: Contraseña es obligatoria" |

---

## 🔧 Estructura de Datos

### **Clase `_CsvRowValidation`**

```dart
class _CsvRowValidation {
  final int lineNumber;        // Número de línea en el CSV
  final Map<String, dynamic> data;  // Datos de la fila
  final bool isValid;          // Si la fila es válida
  final String? errorMessage;  // Mensaje de error si hay
  final bool emailValid;       // Si el email es válido
}
```

### **Resultado de Importación**

```dart
{
  'email': 'usuario@dominio.com',
  'name': 'Nombre Completo',
  'status': 'success' | 'error',
  'message': 'Mensaje descriptivo'
}
```

---

## 🎯 Beneficios

### **Para Tutores y Administradores:**

1. **Feedback Inmediato**: Ven qué filas son válidas antes de importar
2. **Mensajes Claros**: Entienden exactamente qué está mal en cada fila
3. **Ahorro de Tiempo**: No necesitan corregir errores después de importar
4. **Control Total**: Deciden si importar solo las válidas o corregir el CSV primero

### **Para el Sistema:**

1. **Datos Limpios**: Solo se importan usuarios con datos válidos
2. **Menos Errores**: Se previenen errores antes de llegar al backend
3. **Mejor UX**: La experiencia es fluida y profesional
4. **Trazabilidad**: Se registra qué se importó y qué falló

---

## 📊 Estadísticas de Validación

### **Antes de la Implementación:**
- ❌ Validación básica: solo verificaba si el email contenía `@`
- ❌ Errores solo al intentar crear el usuario
- ❌ Mensajes genéricos
- ❌ No había vista previa de validación

### **Después de la Implementación:**
- ✅ Validación exhaustiva con 10+ reglas de email
- ✅ Validación antes de importar
- ✅ Mensajes específicos y descriptivos
- ✅ Vista previa completa con estado de cada fila
- ✅ Resumen visual claro
- ✅ Diálogo detallado post-importación

---

## 🧪 Casos de Prueba

### **CSV con Emails Válidos:**
```
full_name,email,nre
Juan Pérez,juan@alumno.cifpcarlos3.es,123456
María García,maria@alumno.cifpcarlos3.es,789012
```
**Resultado esperado**: ✅ 2 filas válidas, 0 errores

### **CSV con Emails Inválidos:**
```
full_name,email,nre
Juan Pérez,juan@invalido,123456
María García,sinarroba,789012
Pedro Sánchez,pedro@dominio.c,345678
```
**Resultado esperado**: ❌ 0 filas válidas, 3 errores con mensajes específicos

### **CSV Mixto:**
```
full_name,email,nre
Juan Pérez,juan@alumno.cifpcarlos3.es,123456
María García,maria@invalido,789012
Pedro Sánchez,pedro@alumno.cifpcarlos3.es,345678
```
**Resultado esperado**: ✅ 2 filas válidas, 1 error (María)

---

## 📚 Archivos Modificados

| Archivo | Cambios |
|---------|---------|
| `frontend/lib/screens/forms/import_students_csv_screen.dart` | ✅ Validación de emails, resumen visual, diálogo de resultados |
| `frontend/lib/widgets/forms/csv_import_widget.dart` | ✅ Validación de emails, resumen visual, vista previa detallada |
| `frontend/lib/utils/validators.dart` | ✅ Validador de email mejorado (ya existía) |

---

## 🚀 Uso

### **Para Tutores:**

1. Navegar a "Importar Estudiantes CSV"
2. Seleccionar archivo CSV con formato:
   ```
   full_name,email,nre,phone,biography,specialty,academic_year
   ```
3. Ver resumen de validación automáticamente
4. Revisar vista previa de cada fila
5. Si hay errores, corregir el CSV y volver a cargar
6. Hacer clic en "Importar" (solo se importan las válidas)
7. Ver diálogo con resultados detallados

### **Para Administradores:**

1. Usar `CsvImportWidget` en la pantalla de gestión
2. Seleccionar archivo CSV con formato:
   ```
   email,password,full_name,specialty,academic_year
   ```
3. Ver validación y vista previa
4. Importar solo las filas válidas

---

## 🔮 Posibles Mejoras Futuras

### **1. Exportar Errores a CSV**
Permitir exportar las filas con errores a un nuevo CSV para corregirlas fácilmente.

### **2. Corrección Automática**
Sugerir correcciones automáticas para errores comunes:
- `usuario@dominio,com` → `usuario@dominio.com`
- `usuario @dominio.com` → `usuario@dominio.com`

### **3. Validación de Duplicados**
Detectar emails duplicados dentro del mismo CSV antes de importar.

### **4. Vista Previa Expandible**
Permitir expandir/colapsar la vista previa para archivos grandes.

### **5. Progreso de Importación**
Mostrar barra de progreso durante la importación de muchos usuarios.

---

## 📞 Soporte

Si encuentras problemas con la validación de CSV:

1. Verifica el formato del CSV según la documentación
2. Revisa los mensajes de error específicos para cada fila
3. Asegúrate de que los emails cumplan con el formato válido
4. Consulta `docs/desarrollo/validacion_email_registro_usuarios.md` para reglas de email

---

**Fecha de Implementación**: 15 de noviembre de 2025  
**Versión**: Flutter + Supabase FCT v1.0  
**Estado**: ✅ Implementado y Probado

