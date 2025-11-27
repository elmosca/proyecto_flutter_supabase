# 🔧 Solución: Email de Invitación No Muestra Todos los Datos

## 🐛 Problema Reportado

El email de invitación llega pero falta información:
- ❌ La contraseña temporal no aparece
- ❌ Los datos del tutor no aparecen  
- ❌ Los datos del estudiante (NRE, teléfono, año académico, especialidad) no aparecen
- ❌ Muestra "administrador" en lugar de "tutor" como creador

## ✅ Solución en 3 Pasos

### Paso 1: Actualizar Edge Function con Logs de Debug

1. Ve a **Supabase Dashboard → Edge Functions → super-action**
2. Reemplaza el código con el actualizado de:
   ```
   docs/desarrollo/super-action_edge_function_completo.ts
   ```
3. Haz clic en **"Deploy"**
4. Los logs ahora mostrarán qué datos se están enviando

### Paso 2: Usar Plantilla de Debug

Para identificar qué variables funcionan:

1. Ve a **Supabase Dashboard → Authentication → Email Templates → Invite user**
2. **Guarda tu plantilla actual** (cópiala a un archivo de texto)
3. Copia el contenido de `docs/desarrollo/plantilla_email_invite_DEBUG.html`
4. Pega en el campo "Body" de la plantilla
5. Haz clic en **"Save"**

### Paso 3: Probar y Verificar

1. **Crea un estudiante de prueba** desde la aplicación
2. **Revisa el email** que llega
3. **Anota qué variables muestran valores** y cuáles están vacías
4. **Revisa los logs** de la Edge Function:
   - Ve a **Edge Functions → super-action → Logs**
   - Busca `📧 Invitando usuario con datos:`
   - Verifica que los datos se estén enviando correctamente

## 🔍 Qué Buscar en el Email de Debug

El email de debug mostrará todas las variables. Anota cuáles tienen valores:

✅ **Variables que deberían funcionar:**
- `{{ .Email }}` - Email del estudiante
- `{{ .Data.full_name }}` - Nombre completo
- `{{ .Data.temporary_password }}` - Contraseña temporal
- `{{ .Data.tutor_name }}` - Nombre del tutor
- `{{ .Data.created_by }}` - "tutor" o "administrador"
- `{{ .Data.created_by_name }}` - Nombre del creador

❌ **Si alguna variable está vacía:**
- Verifica los logs de la Edge Function
- Confirma que los datos se están pasando desde Flutter
- Revisa que el tutor tenga información completa en la base de datos

## 📊 Ejemplo de Email de Debug

Deberías recibir algo como:

```
🐛 DEBUG - Plantilla de Invitación

Variables Básicas
Email: lamoscaproton@gmail.com
SiteURL: https://zkririyknhlwoxhsoqih.supabase.co
RedirectTo: 

Variables de Data ({{ .Data }})
.Data.full_name: El Mosca
.Data.role: student
.Data.temporary_password: TempPass2024!
.Data.tutor_name: Tutor Jualas
.Data.tutor_email: jualas@jualas.es
.Data.tutor_phone: 666123456
.Data.academic_year: 2024-2025
.Data.student_phone: 
.Data.student_nre: 
.Data.student_specialty: 
.Data.created_by: tutor
.Data.created_by_name: Tutor Jualas
```

## 🔧 Posibles Problemas y Soluciones

### Problema 1: Todas las variables de `.Data` están vacías

**Causa:** La Edge Function no está pasando los datos correctamente

**Solución:**
1. Verifica que hayas desplegado la versión actualizada de la Edge Function
2. Revisa los logs: `Edge Functions → super-action → Logs`
3. Busca `📧 Invitando usuario con datos:` en los logs
4. Confirma que los datos se están imprimiendo

### Problema 2: Solo algunas variables están vacías

**Causa:** Los datos no se están recolectando correctamente en Flutter

**Solución:**
1. Verifica que el tutor tenga información completa en la base de datos
2. Confirma que el estudiante tenga datos opcionales (NRE, teléfono, etc.)
3. Revisa `UserManagementService.createStudent()` para confirmar que se están pasando todos los datos

### Problema 3: La contraseña no aparece

**Causa:** La variable puede tener un nombre diferente en tu versión de Supabase

**Solución:**
- En el email de debug, busca qué variable muestra la contraseña
- Si es diferente de `.Data.temporary_password`, actualiza la plantilla final

## 📝 Próximos Pasos

Una vez que hayas identificado qué variables funcionan:

1. **Vuelve a la plantilla original:**
   - Copia tu plantilla guardada
   - Ajusta las variables según lo que funcionó en el debug
   - Guarda la plantilla actualizada

2. **Prueba de nuevo:**
   - Crea otro estudiante de prueba
   - Verifica que ahora aparezcan todos los datos

3. **Si todo funciona:**
   - ✅ El estudiante verá su contraseña temporal
   - ✅ El estudiante verá información de su tutor
   - ✅ El estudiante verá sus datos de registro
   - ✅ El email mostrará quién lo creó (tutor o admin)

## 🆘 Si Sigue Sin Funcionar

Comparte conmigo:

1. **El email de debug que recibiste** (puedes ocultar datos sensibles)
2. **Los logs de la Edge Function** (busca `📧 Invitando usuario con datos:`)
3. **La configuración del estudiante** que intentaste crear:
   - ¿Tiene tutor asignado?
   - ¿Introdujiste datos opcionales (NRE, teléfono, etc.)?

Con esta información podré ayudarte a ajustar la plantilla correctamente.

## 📚 Archivos de Referencia

- **Edge Function actualizada:** `docs/desarrollo/super-action_edge_function_completo.ts`
- **Plantilla de debug:** `docs/desarrollo/plantilla_email_invite_DEBUG.html`
- **Plantilla final:** `docs/desarrollo/GUIA_CONFIGURAR_INVITE_USER_SUPABASE.md`

