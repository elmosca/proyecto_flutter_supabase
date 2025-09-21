# Directorio de Pruebas

Este directorio contiene archivos y documentación relacionados con las pruebas de funcionalidad de la aplicación.

## 📁 Archivos Incluidos

### **estudiantes_prueba.csv**
Archivo CSV de ejemplo para probar la funcionalidad de importación de estudiantes por tutores.

**Formato:**
```csv
email,password,full_name,specialty,academic_year
maria.garcia@alumno.cifpcarlos3.es,password123,María García López,DAM,2024-2025
carlos.rodriguez@alumno.cifpcarlos3.es,password456,Carlos Rodríguez Martín,ASIR,2024-2025
```

**Uso:**
1. Login como tutor en la aplicación
2. Ir a la sección de importación de estudiantes
3. Seleccionar este archivo CSV
4. Verificar que los estudiantes se importen correctamente

### **prueba_importacion_csv.md**
Documentación detallada de la prueba de importación CSV realizada, incluyendo:
- Resultados de la prueba
- Funcionalidades verificadas
- Estado de la base de datos
- Credenciales de prueba

## 🔧 Funcionalidades Probadas

- ✅ Importación de estudiantes desde CSV
- ✅ Creación de usuarios en `users` y `auth.users`
- ✅ Asignación automática de tutor
- ✅ Validación de datos
- ✅ Manejo de errores
- ✅ Relaciones tutor-estudiante
- ✅ **NUEVO**: Campo año académico
- ✅ **NUEVO**: Validación de duplicados por año
- ✅ **NUEVO**: Calendario académico para tutores
- ✅ **NUEVO**: Filtrado de estudiantes por año

## 📋 Próximas Pruebas

- [ ] Probar importación desde la UI de Flutter
- [ ] Verificar auto-asignación de tutores a anteproyectos
- [ ] Probar creación de tutores desde admin
- [ ] Verificar gestión de estudiantes por tutores

## 🔑 Credenciales de Prueba

### **Tutor:**
- Email: `tutor.test@cifpcarlos3.es`
- Password: `tutor_password`

### **Estudiantes (después de importación):**
- **María García**: `maria.garcia@alumno.cifpcarlos3.es` / `password123`
- **Carlos Rodríguez**: `carlos.rodriguez@alumno.cifpcarlos3.es` / `password456`
