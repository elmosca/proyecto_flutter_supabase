# Configurar URL de Producción en Supabase

## 📝 Cambio Realizado

La plantilla de email ahora usa:
- **URL de login:** `https://fct.jualas.es/login`

## 🔧 Configuración Necesaria en Supabase

Para que todo funcione correctamente (especialmente el enlace de acceso rápido), necesitas configurar las URLs en Supabase:

### Paso 1: Configurar Site URL

1. **Ve a:** Supabase Dashboard → Authentication → URL Configuration
2. **En "Site URL"**, configura:
   ```
   https://fct.jualas.es
   ```
3. **Guarda** los cambios

### Paso 2: Configurar Redirect URLs

En la sección **"Redirect URLs"**, añade:

```
https://fct.jualas.es/**
https://fct.jualas.es/dashboard/student
https://fct.jualas.es/dashboard/tutor
https://fct.jualas.es/dashboard/admin
http://localhost:8082/**
```

**Nota:** He incluido también `localhost:8082` para que funcione durante el desarrollo local.

### Paso 3: Verificar CORS (si aplica)

Si tienes configurado CORS en alguna Edge Function, asegúrate de incluir:
```
https://fct.jualas.es
```

## 🧪 Probar

### Durante Desarrollo Local

1. **Acceso manual:** El estudiante usará `https://fct.jualas.es/login`
2. **Enlace rápido:** Puede que no funcione en local, pero el acceso manual sí

### En Producción

1. **Acceso manual:** `https://fct.jualas.es/login` ✅
2. **Enlace rápido:** Debería funcionar correctamente ✅

## 📊 Flujo Completo

```
Email enviado a estudiante
    ↓
Estudiante lee email
    ↓
Opción 1 (Recomendada):
    ↓
Va a: https://fct.jualas.es/login
    ↓
Introduce email y contraseña del correo
    ↓
✅ Acceso exitoso

Opción 2 (Enlace rápido):
    ↓
Hace clic en "Acceso Rápido"
    ↓
Si URLs configuradas correctamente en Supabase:
    ↓
✅ Acceso automático a fct.jualas.es
```

## ⚙️ Configuración para Diferentes Entornos

Si quieres que funcione tanto en desarrollo como en producción, puedes usar variables condicionales en la plantilla, pero **para simplificar, es mejor usar la URL de producción** (`fct.jualas.es`) ya que:

✅ Funciona siempre (en desarrollo y producción)  
✅ No requiere cambios según el entorno  
✅ Los estudiantes solo necesitan una URL para recordar  

## 🔄 Actualizar la Plantilla en Supabase

1. **Ve a:** Authentication → Email Templates → Invite user
2. **Copia** el contenido actualizado de: `docs/desarrollo/plantilla_email_invite_FINAL.html`
3. **Pega** y **Guarda**

## 📝 Ejemplo de Email Final

El estudiante verá:

```
🔐 Cómo acceder al sistema:
1. Ve a la página de inicio de sesión: fct.jualas.es/login
2. Inicia sesión con:
   • Email: estudiante@example.com
   • Contraseña: MiContraseña123

[Acceso Rápido (enlace directo)]

El enlace de acceso rápido expira en 1 hora. 
Si da error, usa el login manual arriba.
```

## ✅ Checklist de Configuración

- [ ] URL de login en plantilla: `https://fct.jualas.es/login` ✅ (ya hecho)
- [ ] Site URL en Supabase: `https://fct.jualas.es`
- [ ] Redirect URLs en Supabase: `https://fct.jualas.es/**`
- [ ] Plantilla actualizada en Supabase
- [ ] Probar creando un estudiante

---

**Una vez configurado todo, el sistema estará 100% funcional en producción.**

