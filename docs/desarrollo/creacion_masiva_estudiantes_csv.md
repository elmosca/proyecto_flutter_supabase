# 🚀 Creación Masiva de Estudiantes desde CSV

## 📋 Resumen

Se ha implementado una solución para crear estudiantes masivamente desde CSV **sin los límites de rate limiting del cliente**. La solución utiliza una Edge Function de Supabase que procesa múltiples usuarios desde el servidor con permisos de administrador.

---

## 🎯 Problema Resuelto

### **Antes:**
- ❌ Límite de ~3-5 usuarios por minuto desde el cliente
- ❌ Delay de 2 segundos entre cada creación
- ❌ Para 30-60 estudiantes: **10-20 minutos de espera**
- ❌ Muy tedioso para tutores en época de anteproyectos

### **Ahora:**
- ✅ Creación masiva desde el servidor (sin límites del cliente)
- ✅ Delay reducido a 500ms entre creaciones (solo en el servidor)
- ✅ Para 30-60 estudiantes: **~15-30 segundos**
- ✅ Mucho más eficiente y práctico

---

## ✅ Implementación

### **1. Nueva Acción en Edge Function**

Se añadió la acción `bulk_create_students` en la Edge Function `super-action`:

**Ubicación**: `docs/desarrollo/super-action_edge_function_completo.ts`

**Características:**
- Procesa múltiples estudiantes en una sola llamada
- Delay de 500ms entre creaciones (menos restrictivo que desde el cliente)
- Crea usuarios en Auth y en la tabla `users`
- Envía emails de bienvenida automáticamente
- Retorna resultados detallados (éxitos y errores)

### **2. Nuevo Método en UserManagementService**

Se añadió `bulkCreateStudents()` que llama a la Edge Function:

**Ubicación**: `frontend/lib/services/user_management_service.dart`

```dart
Future<Map<String, dynamic>> bulkCreateStudents({
  required List<Map<String, dynamic>> students,
  int? tutorId,
}) async {
  // Llama a la Edge Function con todos los estudiantes
  // Retorna: { results: [...], errors: [...], summary: {...} }
}
```

### **3. Código de Importación Actualizado**

El código de importación CSV ahora usa creación masiva:

**Ubicación**: `frontend/lib/screens/forms/import_students_csv_screen.dart`

**Cambios:**
- ❌ Eliminado: Loop con delays de 2 segundos
- ✅ Añadido: Preparación de datos y llamada única a `bulkCreateStudents()`
- ✅ Resultados procesados desde la respuesta de la Edge Function

---

## 🔧 Formato de Datos

La Edge Function espera un array de estudiantes con esta estructura:

```typescript
{
  action: 'bulk_create_students',
  students: [
    {
      email: 'usuario@jualas.es',
      password: 'contraseña_generada',
      full_name: 'Nombre Completo',
      academic_year: '2025-2026', // opcional
      phone: '+34 600 111 222', // opcional
      nre: '1234567A', // opcional
      specialty: 'DAM', // opcional
      biography: 'Biografía...' // opcional
    },
    // ... más estudiantes
  ],
  tutor_id: 123 // opcional, ID del tutor
}
```

---

## 📊 Resultados

La Edge Function retorna:

```typescript
{
  success: true,
  message: "Procesados X estudiantes: Y exitosos, Z con errores",
  results: [
    {
      email: 'usuario@jualas.es',
      name: 'Nombre Completo',
      password: 'contraseña_generada',
      user_id: 123,
      auth_id: 'uuid',
      status: 'success'
    }
  ],
  errors: [
    {
      email: 'otro@jualas.es',
      name: 'Otro Nombre',
      error: 'Email ya registrado en el sistema'
    }
  ],
  summary: {
    total: 30,
    successful: 28,
    failed: 2
  }
}
```

---

## 🚀 Despliegue

### **Paso 1: Desplegar Edge Function Actualizada**

La Edge Function debe desplegarse en Supabase con la nueva acción `bulk_create_students`:

1. Ve a **Supabase Dashboard → Edge Functions**
2. Selecciona `super-action`
3. Copia el contenido de `docs/desarrollo/super-action_edge_function_completo.ts`
4. Despliega la función actualizada

### **Paso 2: Verificar Funcionamiento**

1. Importa un CSV pequeño (3-5 estudiantes) para probar
2. Verifica que todos se creen correctamente
3. Revisa los logs de la Edge Function si hay errores

---

## ⚡ Ventajas

1. **Velocidad**: 10-20x más rápido que creación individual
2. **Sin rate limiting**: Procesa desde el servidor con permisos admin
3. **Escalable**: Puede manejar 30-60 estudiantes sin problemas
4. **Robusto**: Maneja errores individuales sin afectar el resto
5. **Feedback detallado**: Muestra resultados por cada estudiante

---

## 📝 Notas Importantes

- **Delay en servidor**: 500ms entre creaciones (suficiente para evitar sobrecarga)
- **Timeout**: 5 minutos para importaciones grandes
- **Límite de emails**: Aún aplica el límite de ~30 emails/hora de Supabase
- **Si hay muchos errores**: La Edge Function continúa procesando el resto

---

## 🔄 Flujo Completo

1. Usuario selecciona CSV y valida datos
2. Sistema prepara array de estudiantes con contraseñas generadas
3. Se llama a `bulkCreateStudents()` con todos los datos
4. Edge Function procesa cada estudiante con delay de 500ms
5. Se crean usuarios en Auth y en tabla `users`
6. Se envían emails de bienvenida
7. Se retornan resultados detallados
8. Se muestra diálogo con resumen y contraseñas generadas

---

## 🐛 Troubleshooting

### **Error: "Edge Function no encontrada"**
- Verifica que la Edge Function `super-action` esté desplegada
- Verifica que incluya la acción `bulk_create_students`

### **Error: "Timeout"**
- Para importaciones muy grandes (>100 estudiantes), divide el CSV en lotes
- El timeout es de 5 minutos

### **Algunos estudiantes no se crean**
- Revisa los errores en el diálogo de resultados
- Los errores más comunes: email duplicado, datos faltantes

---

## 📈 Rendimiento Esperado

| Estudiantes | Tiempo Estimado |
|-------------|----------------|
| 10          | ~5-10 segundos |
| 30          | ~15-20 segundos |
| 60          | ~30-40 segundos |

*Tiempos incluyen creación en Auth, inserción en BD y envío de emails*

