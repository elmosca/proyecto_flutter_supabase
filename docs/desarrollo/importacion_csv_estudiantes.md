# Importación de Estudiantes mediante CSV

## 📋 Resumen

El sistema permite importar estudiantes desde archivos CSV de dos formas distintas, dependiendo de quién realiza la importación:

1. **Admin**: Usa `CsvImportWidget` con función RPC `import_students_csv`
2. **Tutor**: Usa `ImportStudentsCSVScreen` que asigna automáticamente a ese tutor

---

## 🔧 Formato del Archivo CSV

### Formato 1: Para `CsvImportWidget` (Admin)

**Encabezados requeridos:**
```csv
email,password,full_name,specialty,academic_year
```

**Ejemplo:**
```csv
email,password,full_name,specialty,academic_year
ejemplo@alumno.cifpcarlos3.es,password123,Juan Pérez,DAM,2024-2025
maria@alumno.cifpcarlos3.es,password456,María García,ASIR,2024-2025
```

**Campos:**
- `email`: Obligatorio - Email del estudiante
- `password`: Obligatorio - Contraseña inicial (mínimo 6 caracteres)
- `full_name`: Obligatorio - Nombre completo
- `specialty`: Obligatorio - Especialidad (DAM, ASIR, DAW, etc.)
- `academic_year`: Obligatorio - Año académico (ej: 2024-2025)

**⚠️ Nota**: Este formato NO asigna tutor automáticamente. Los estudiantes se crean sin `tutor_id`.

---

### Formato 2: Para `ImportStudentsCSVScreen` (Tutor)

**Encabezados requeridos:**
```csv
full_name,email,nre
```

**Encabezados opcionales:**
```csv
full_name,email,nre,phone,biography,specialty,academic_year
```

**Ejemplo:**
```csv
full_name,email,nre,specialty,academic_year
Juan Antonio Francés Pérez,juan.frances@alumno.cifpcarlos3.es,12345678A,Desarrollo de Aplicaciones Multiplataforma,2024-2025
María García López,maria.garcia@alumno.cifpcarlos3.es,87654321B,Desarrollo de Aplicaciones Multiplataforma,2024-2025
```

**Campos:**
- `full_name`: Obligatorio - Nombre completo
- `email`: Obligatorio - Email del estudiante
- `nre`: Obligatorio - Número de Registro del Estudiante
- `phone`: Opcional - Teléfono
- `biography`: Opcional - Biografía
- `specialty`: Opcional - Especialidad (por defecto: "Desarrollo de Aplicaciones Multiplataforma")
- `academic_year`: Opcional - Año académico (por defecto: "2024-2025")

**✅ Característica**: Este formato **asigna automáticamente** todos los estudiantes importados al tutor que realiza la importación (`tutorId` se pasa como parámetro).

---

## 🔄 Flujo de Importación

### Opción 1: Admin usando `CsvImportWidget`

**Ubicación**: `frontend/lib/widgets/forms/csv_import_widget.dart`

**Proceso:**
1. Admin selecciona archivo CSV con formato 1
2. El widget parsea el CSV y valida los encabezados
3. Muestra vista previa de los estudiantes a importar
4. Al confirmar, llama a `UserManagementService.importStudentsFromCsv()`
5. Esta función llama a la RPC `import_students_csv` en Supabase
6. **Resultado**: Estudiantes creados **SIN tutor asignado** (tutor_id = null)

**Código relevante:**
```dart
// frontend/lib/widgets/forms/csv_import_widget.dart
final result = await _userManagementService.importStudentsFromCsv(
  studentsData: _parsedData,
);
```

---

### Opción 2: Tutor usando `ImportStudentsCSVScreen`

**Ubicación**: `frontend/lib/screens/forms/import_students_csv_screen.dart`

**Proceso:**
1. Tutor navega a la pantalla de importación (se pasa su `tutorId`)
2. Selecciona archivo CSV con formato 2
3. El sistema parsea y valida el CSV
4. Muestra vista previa y errores si los hay
5. Al confirmar, crea cada estudiante uno por uno usando `UserService.createUser()`
6. **Resultado**: Todos los estudiantes se crean **CON el tutor asignado** (`tutorId: widget.tutorId`)

**Código relevante:**
```dart
// frontend/lib/screens/forms/import_students_csv_screen.dart
final newUser = app_user.User(
  // ... otros campos ...
  tutorId: widget.tutorId,  // ← Se asigna automáticamente
  // ...
);
await userService.createUser(newUser);
```

---

## 🎯 Asignación de Tutores

### Escenario 1: Importación por Admin (CsvImportWidget)

**Problema actual**: Los estudiantes se crean **sin tutor asignado** (`tutor_id = null`)

**Solución requerida**: 
- Opción A: Añadir columna `tutor_id` o `tutor_email` en el CSV
- Opción B: Permitir seleccionar un tutor antes de importar
- Opción C: Asignar manualmente después de la importación usando la funcionalidad de "Reasignar tutor"

### Escenario 2: Importación por Tutor (ImportStudentsCSVScreen)

**✅ Funciona correctamente**: Todos los estudiantes se asignan automáticamente al tutor que importa.

---

## 📝 Ejemplo de Archivo CSV Completo

### Para Admin (necesita mejorarse para asignar tutores):

```csv
email,password,full_name,specialty,academic_year
estudiante1@alumno.cifpcarlos3.es,pass123,Ana Martínez,DAM,2024-2025
estudiante2@alumno.cifpcarlos3.es,pass456,Carlos López,ASIR,2024-2025
```

### Para Tutor (funciona con asignación automática):

```csv
full_name,email,nre,specialty,academic_year
Ana Martínez Sánchez,ana.martinez@alumno.cifpcarlos3.es,44332211D,Desarrollo de Aplicaciones Multiplataforma,2024-2025
David López García,david.lopez@alumno.cifpcarlos3.es,55667788E,Desarrollo de Aplicaciones Multiplataforma,2024-2025
```

---

## 🔍 Dónde se Usa

1. **CsvImportWidget**: 
   - Usado por administradores
   - Llama a función RPC `import_students_csv` (implementación en Supabase)

2. **ImportStudentsCSVScreen**:
   - Usado por tutores desde `AddStudentsDialog`
   - Crea estudiantes uno por uno con `UserService.createUser()`
   - Asigna automáticamente al tutor que importa

---

## 💡 Mejoras Sugeridas

### Para Admin - Permitir asignar tutor en CSV

**Opción 1**: Añadir columna `tutor_email` al CSV
```csv
email,password,full_name,specialty,academic_year,tutor_email
estudiante1@alumno.cifpcarlos3.es,pass123,Ana Martínez,DAM,2024-2025,tutor1@cifpcarlos3.es
```

**Opción 2**: Permitir seleccionar tutor antes de importar
- Añadir un `DropdownButton` con lista de tutores en `CsvImportWidget`
- Pasar `tutorId` seleccionado a la función RPC

**Opción 3**: Permitir importar sin tutor y asignar después
- Usar la funcionalidad existente de "Reasignar tutor" desde la pantalla de gestión

---

## 📚 Archivos Relacionados

- `frontend/lib/widgets/forms/csv_import_widget.dart` - Widget de importación para admin
- `frontend/lib/screens/forms/import_students_csv_screen.dart` - Pantalla de importación para tutor
- `frontend/lib/services/user_management_service.dart` - Servicio con método `importStudentsFromCsv()`
- `frontend/lib/widgets/dialogs/add_students_dialog.dart` - Diálogo que ofrece ambas opciones
- `estudiantes_ejemplo.csv` - Archivo de ejemplo en formato 2

---

## 🚀 Uso Rápido

### Como Admin:
1. Ir a Gestión de Usuarios (`/admin/users`)
2. Clic en "Añadir Alumno"
3. Seleccionar "Importar desde CSV" (si está disponible)
4. Seleccionar archivo CSV con formato 1
5. **⚠️ Importante**: Después de importar, asignar tutores manualmente usando "Reasignar tutor"

### Como Tutor:
1. Ir al Dashboard de Tutor
2. Clic en "Añadir Estudiantes"
3. Seleccionar "Importar desde CSV"
4. Seleccionar archivo CSV con formato 2
5. **✅ Automático**: Todos los estudiantes se asignan a ti como tutor

