# ✅ Solución: Enlace del Email Expira o Da Error

## 🐛 Problema

Al hacer clic en "Acceder al Sistema" del email, aparece:
```
error=access_denied&error_code=otp_expired
error_description=Email link is invalid or has expired
```

## 🎯 Solución Implementada

He modificado el email para que el **login manual sea más prominente** que el enlace:

### Nuevo Diseño del Email

1. **Sección destacada en verde** con instrucciones de login manual:
   ```
   🔐 Cómo acceder al sistema:
   1. Ve a la página de inicio de sesión: http://localhost:8082/login
   2. Inicia sesión con:
      • Email: lamoscaproton@gmail.com
      • Contraseña: Miscojones-123
   ```

2. **Botón de acceso rápido** (opcional):
   ```
   [Acceso Rápido (enlace directo)]
   
   El enlace de acceso rápido expira en 1 hora. 
   Si da error, usa el login manual arriba.
   ```

### Ventajas

✅ **El estudiante siempre puede acceder** con email + contraseña  
✅ **No depende de enlaces que expiran**  
✅ **Más claro y directo**  
✅ **El enlace rápido es opcional** (por si funciona)  

## 📝 Pasos Adicionales (Opcional)

### 1. Configurar URLs en Supabase

Para que el enlace funcione mejor:

1. **Ve a:** Supabase Dashboard → Authentication → URL Configuration

2. **Site URL:** Configura según tu entorno
   - **Desarrollo:** `http://localhost:8082`
   - **Producción:** `https://tu-dominio.com`

3. **Redirect URLs:** Añade:
   ```
   http://localhost:8082/**
   http://localhost:8082/dashboard/student
   http://localhost:8082/dashboard/tutor
   http://localhost:8082/dashboard/admin
   ```

4. **Guarda** los cambios

### 2. Aumentar Tiempo de Expiración (Opcional)

Si quieres que los enlaces duren más:

1. **Ve a:** Supabase Dashboard → Authentication → Settings
2. **Busca:** "Email OTP Expiry" o "Magic Link Expiry"
3. **Aumenta** el tiempo (por defecto: 3600 segundos = 1 hora)
4. **Guarda** los cambios

## 🔄 Actualizar la Plantilla

1. **Ve a:** Supabase Dashboard → Authentication → Email Templates → Invite user

2. **Copia TODO** el contenido actualizado de:
   ```
   docs/desarrollo/plantilla_email_invite_FINAL.html
   ```

3. **Pega** en el campo "Body"

4. **Guarda**

## 🧪 Probar

Crea un nuevo estudiante y verifica que el email:

1. ✅ Muestra las instrucciones de login manual destacadas en verde
2. ✅ Incluye el email y contraseña listos para copiar
3. ✅ Tiene el enlace como opción secundaria
4. ✅ Explica que el enlace expira en 1 hora

## 📊 Flujo del Estudiante

### Escenario 1: Login Manual (Recomendado)
```
Email recibido
    ↓
Lee instrucciones verdes
    ↓
Va a http://localhost:8082/login
    ↓
Copia email del correo
    ↓
Copia contraseña del correo
    ↓
Inicia sesión
    ↓
✅ Acceso exitoso
```

### Escenario 2: Enlace Rápido
```
Email recibido
    ↓
Hace clic en "Acceso Rápido"
    ↓
Si el enlace es válido:
    ↓
✅ Acceso automático
    
Si el enlace expiró:
    ↓
Ve error "otp_expired"
    ↓
Vuelve al email
    ↓
Usa login manual
    ↓
✅ Acceso exitoso
```

## 🎨 Vista Previa del Nuevo Email

```
┌─────────────────────────────────────────┐
│ 🎓 ¡Bienvenido al Sistema TFG!          │
├─────────────────────────────────────────┤
│                                         │
│ Hola El Mosca,                          │
│                                         │
│ Has sido añadido al Sistema...          │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📋 Información de tu cuenta:        │ │
│ │ Email: lamoscaproton@gmail.com      │ │
│ │ NRE: 12345678                       │ │
│ │ ...                                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 👨‍🏫 Tu Tutor Asignado               │ │
│ │ Nombre: Tutor Jualas                │ │
│ │ Email: jualas@jualas.es             │ │
│ │ ...                                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │      Tu Contraseña                  │ │
│ │                                     │ │
│ │      Miscojones-123                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ⚠️ Importante:                          │
│ • Esta es tu contraseña...              │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🔐 Cómo acceder al sistema: ◄──────┼─┤ DESTACADO
│ │                                     │ │ EN VERDE
│ │ 1. Ve a: localhost:8082/login       │ │
│ │ 2. Inicia sesión con:               │ │
│ │    • Email: lamoscaproton@...       │ │
│ │    • Contraseña: Miscojones-123     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│    [Acceso Rápido (enlace directo)]    │
│                                         │
│ El enlace expira en 1 hora.            │
│ Si da error, usa el login manual.      │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 💡 Próximos pasos:                  │ │
│ │ 1. Accede con tu email/contraseña   │ │
│ │ 2. Comienza tu Anteproyecto TFG     │ │
│ │ 3. Contacta a tu tutor...           │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## ✨ Resumen

**Antes:**
- ❌ Solo enlace (expira y da error)
- ❌ Usuario no sabe qué hacer si el enlace falla
- ❌ Contraseña visible pero no se usa

**Ahora:**
- ✅ Login manual destacado (siempre funciona)
- ✅ Instrucciones claras con email y contraseña
- ✅ Enlace opcional (por si funciona)
- ✅ Mensaje claro si el enlace expira

---

**Resultado:** Los estudiantes podrán acceder **siempre**, independientemente de si el enlace funciona o no.

