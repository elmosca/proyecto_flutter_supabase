# Archivos CSV de Ejemplo para Importación de Estudiantes

## 📋 Descripción

Este directorio contiene archivos CSV de ejemplo para probar la funcionalidad de importación masiva de estudiantes.

## 📁 Archivos

- **`estudiantes_ejemplo.csv`**: Archivo CSV con 3 estudiantes de ejemplo para pruebas

## 🔧 Formato del CSV

El archivo CSV debe tener las siguientes columnas (en este orden):

| Columna | Requerido | Descripción | Ejemplo |
|---------|-----------|-------------|---------|
| `full_name` | ✅ Sí | Nombre completo del estudiante | `Ana García López` |
| `email` | ✅ Sí | Correo electrónico del estudiante (debe ser del dominio `jualas.es`) | `ana.garcia@jualas.es` |
| `nre` | ❌ No | Número de Registro del Estudiante | `1234567A` |
| `phone` | ❌ No | Teléfono de contacto | `+34 600 111 222` |
| `biography` | ❌ No | Biografía del estudiante | `Estudiante de DAM...` |
| `specialty` | ❌ No | Especialidad del estudiante | `DAM`, `ASIR`, `DAW` |
| `academic_year` | ❌ No | Año académico | `2024-2025` |

### ⚠️ Notas Importantes

1. **Encabezados**: La primera fila debe contener los nombres de las columnas exactamente como se muestran arriba (case-insensitive).
2. **Separador**: El archivo debe usar comas (`,`) como separador.
3. **Email**: Debe ser un email válido del dominio autorizado `jualas.es` (dominio autenticado en Resend para el envío de correos).
4. **Encoding**: El archivo debe estar en UTF-8.

## 🚀 ¿Qué sucede al importar?

Cuando importas estudiantes desde CSV:

### ✅ **Sí se crean en Supabase Auth**
- Los estudiantes se crean en `auth.users` de Supabase
- Pueden autenticarse inmediatamente después de la importación

### ✅ **Sí se envía correo de bienvenida**
- Cada estudiante recibe un email de bienvenida con:
  - Información de acceso
  - Contraseña temporal (generada automáticamente)
  - Instrucciones para el primer acceso

### ✅ **Contraseñas generadas automáticamente**
- Se genera una contraseña segura de 12 caracteres para cada estudiante
- Las contraseñas se muestran en el diálogo de resultados después de la importación
- Puedes copiar cada contraseña haciendo clic en el icono de copiar

### ✅ **Creación en base de datos**
- Los estudiantes también se crean en la tabla `users` de la base de datos
- Se asocian automáticamente al tutor que realiza la importación (si aplica)

## 📝 Ejemplo de Uso

1. Abre la pantalla de importación de estudiantes (como tutor o administrador)
2. Selecciona el archivo `estudiantes_ejemplo.csv`
3. Revisa la validación previa (se mostrarán errores si los hay)
4. Haz clic en "Importar Estudiantes"
5. Revisa el diálogo de resultados:
   - Verás las contraseñas generadas para cada estudiante
   - Podrás copiar cada contraseña si es necesario
   - Se mostrará un mensaje confirmando que el email de bienvenida fue enviado

## 🔒 Seguridad

- Las contraseñas generadas son aleatorias y seguras
- Se recomienda que los estudiantes cambien su contraseña en el primer acceso
- Las contraseñas se muestran solo una vez en el diálogo de resultados

## ⚠️ Errores Comunes

1. **Email duplicado**: Si un email ya está registrado, se mostrará un error específico
2. **Formato inválido**: Si el CSV no tiene el formato correcto, se mostrarán errores de validación
3. **Columnas faltantes**: Si faltan columnas requeridas, la importación fallará

## 📧 Configuración de Emails

Para que los emails de bienvenida se envíen correctamente, asegúrate de que:

1. La Edge Function `super-action` esté desplegada en Supabase
2. La configuración de email de Supabase esté correctamente configurada
3. Los templates de email estén configurados en Supabase Dashboard

## 🔍 Verificación

Después de importar, puedes verificar:

1. **En Supabase Dashboard**:
   - Ve a Authentication > Users
   - Verifica que los usuarios se hayan creado
   - Revisa que el email esté confirmado

2. **En la aplicación**:
   - Los estudiantes deberían aparecer en la lista de estudiantes
   - Deberían poder iniciar sesión con su email y la contraseña generada

