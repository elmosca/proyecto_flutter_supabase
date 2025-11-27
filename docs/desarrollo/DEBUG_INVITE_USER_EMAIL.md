# 🐛 Debug: Email de Invitación No Muestra Todos los Datos

## Problema Reportado

El email de invitación llega pero:
- ❌ La contraseña temporal no aparece
- ❌ Los datos del tutor no aparecen
- ❌ Los datos del estudiante (NRE, teléfono, etc.) no aparecen
- ❌ Muestra "administrador" en lugar de "tutor" como creador

## Causa Probable

En Supabase Auth, cuando usas `inviteUserByEmail()`, hay una diferencia entre cómo se pasan los datos y cómo se accede a ellos en la plantilla de email.

### Problema 1: Sintaxis de Acceso a Datos

Supabase Auth usa `user_metadata` para almacenar datos personalizados, pero en las plantillas de email, la forma de acceder puede variar según la versión de Supabase.

**Posibles sintaxis:**
- `{{ .UserMetaData.temporary_password }}` (versión antigua)
- `{{ .Data.temporary_password }}` (versión nueva)
- `{{ .user_metadata.temporary_password }}` (alternativa)

### Problema 2: Verificar Datos en Edge Function

Necesitamos confirmar que la Edge Function está enviando los datos correctamente.

## 🔍 Pasos de Debug

### 1. Verificar Logs de Edge Function

1. Ve a **Supabase Dashboard → Edge Functions → super-action → Logs**
2. Busca la última invocación con `action: 'invite_user'`
3. Verifica que los datos se estén enviando:
   ```json
   {
     "action": "invite_user",
     "user_data": {
       "email": "lamoscaproton@gmail.com",
       "password": "...",
       "full_name": "El Mosca",
       "tutor_name": "...",
       "created_by": "tutor",
       "created_by_name": "..."
     }
   }
   ```

### 2. Probar Sintaxis Alternativas en la Plantilla

Supabase puede estar usando una sintaxis diferente. Prueba estas variantes:

#### Opción A: UserMetaData (con mayúsculas)
```html
<div class="password-value">{{ .UserMetaData.temporary_password }}</div>
```

#### Opción B: user_metadata (con guión bajo)
```html
<div class="password-value">{{ .user_metadata.temporary_password }}</div>
```

#### Opción C: Acceso directo sin Data
```html
<div class="password-value">{{ .temporary_password }}</div>
```

### 3. Verificar en Documentación de Supabase

La sintaxis puede depender de la versión de Supabase Auth que estés usando.

## 🔧 Soluciones a Probar

### Solución 1: Añadir Logs a Edge Function

Modifica la Edge Function para imprimir los datos que se están enviando:

```typescript
console.log('📧 Invitando usuario con datos:', {
  email: user_data.email,
  full_name: user_data.full_name,
  temporary_password: user_data.password,
  tutor_name: user_data.tutor_name,
  created_by: user_data.created_by,
  created_by_name: user_data.created_by_name,
});

const { data: invitedUser, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
  user_data.email,
  {
    data: {
      full_name: user_data.full_name || '',
      role: user_data.role || 'student',
      temporary_password: user_data.password,
      tutor_name: user_data.tutor_name || '',
      // ... resto de datos
    },
  }
);

console.log('✅ Usuario invitado, respuesta:', invitedUser);
```

### Solución 2: Usar Plantilla Simplificada de Prueba

Crea una versión mínima de la plantilla para verificar qué variables funcionan:

```html
<!DOCTYPE html>
<html>
<body>
  <h1>Debug Template</h1>
  <p>Email: {{ .Email }}</p>
  <p>Data.full_name: {{ .Data.full_name }}</p>
  <p>Data.temporary_password: {{ .Data.temporary_password }}</p>
  <p>UserMetaData.full_name: {{ .UserMetaData.full_name }}</p>
  <p>UserMetaData.temporary_password: {{ .UserMetaData.temporary_password }}</p>
  <p>user_metadata.full_name: {{ .user_metadata.full_name }}</p>
  <p>user_metadata.temporary_password: {{ .user_metadata.temporary_password }}</p>
</body>
</html>
```

Guarda esta plantilla, crea un estudiante de prueba y verifica cuál de las sintaxis muestra los datos correctamente.

### Solución 3: Verificar Versión de Supabase

Diferentes versiones de Supabase pueden usar diferentes sintaxis. Verifica:

1. Ve a **Project Settings → General**
2. Anota la versión de Supabase
3. Busca en la documentación oficial la sintaxis correcta para esa versión

## 📋 Checklist de Verificación

- [ ] Los datos llegan correctamente a la Edge Function (verificar logs)
- [ ] La Edge Function invoca `inviteUserByEmail` sin errores
- [ ] La plantilla está guardada en Supabase
- [ ] La sintaxis de las variables es correcta para tu versión de Supabase
- [ ] El email llega al destinatario (aunque sin todos los datos)

## 🎯 Próximos Pasos

1. **Revisa los logs de la Edge Function** para confirmar que los datos se están enviando
2. **Prueba la plantilla simplificada** para identificar la sintaxis correcta
3. **Actualiza la plantilla** con la sintaxis correcta una vez identificada

## 📚 Referencias

- [Supabase Auth Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Go Template Language](https://pkg.go.dev/text/template) (usado por Supabase para templates)

