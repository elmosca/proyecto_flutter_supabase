# 📧 Servidor MCP para Resend - Integración con Proyecto Flutter + Supabase

## 🎯 Objetivo
Integrar el servidor MCP de Resend con tu proyecto Flutter + Supabase para habilitar el envío de emails directamente desde Cursor, especialmente útil para notificaciones del sistema, reportes y comunicación con usuarios.

## 🏗️ Arquitectura de Integración

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Cursor IDE    │───▶│  MCP Resend      │───▶│   Resend API    │
│                 │    │  Server          │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   Email         │
         │                       │              │   Delivery      │
         │                       │              └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌──────────────────┐
│   Flutter App   │───▶│   Supabase       │
│                 │    │   Functions      │
└─────────────────┘    └──────────────────┘
```

## 📋 Configuración Actual

### Servidores MCP Activos
1. **Supabase**: Gestión de base de datos y autenticación
2. **GitHub**: Control de versiones y gestión de repositorios  
3. **Resend**: Envío de emails transaccionales ✨ (NUEVO)

### Ubicación del Servidor
```
C:\dev\proyecto_flutter_supabase\mcp-resend\
├── build/
│   └── index.js          # Servidor MCP compilado
├── src/                  # Código fuente TypeScript
├── package.json          # Dependencias
├── env.example           # Variables de entorno de ejemplo
├── README_CONFIGURACION.md # Guía de configuración
└── test_mcp.js          # Script de prueba
```

## 🔧 Configuración en Cursor

### Archivo de Configuración
**Ubicación**: `c:\Users\Jualas\.cursor\mcp.json`

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--project-ref=zkririyknhlwoxhsoqih"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "sbp_1d3a91da3f32d0067b960260ab2fba02b4429fed"
      }
    },
    "github": {
      "command": "node",
      "args": [
        "-e",
        "require('@modelcontextprotocol/server-github').main()"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_3sz0D08Uws31vaqwn11Vba1qFvaIR0TUqI6"
      }
    },
    "resend": {
      "command": "node",
      "args": [
        "C:\\dev\\proyecto_flutter_supabase\\mcp-resend\\build\\index.js"
      ],
      "env": {
        "RESEND_API_KEY": "YOUR_RESEND_API_KEY_HERE"
      }
    }
  }
}
```

## 🚀 Pasos para Activar

### 1. Obtener API Key de Resend
1. Ve a [Resend.com](https://resend.com/) y crea una cuenta gratuita
2. Navega a [API Keys](https://resend.com/api-keys)
3. Crea una nueva API Key
4. Copia la clave generada

### 2. Configurar API Key
Reemplaza `YOUR_RESEND_API_KEY_HERE` en el archivo `mcp.json` con tu API key real.

### 3. Reiniciar Cursor
1. Guarda el archivo `mcp.json`
2. Cierra Cursor completamente
3. Abre Cursor nuevamente
4. Verifica que el servidor MCP esté activo

### 4. Probar Configuración
```bash
cd C:\dev\proyecto_flutter_supabase\mcp-resend
node test_mcp.js
```

## 📧 Casos de Uso en tu Proyecto

### 1. Notificaciones de Proyectos
```markdown
Envía un email a estudiante@ejemplo.com notificando que su proyecto 
"App de Gestión de Tareas" ha sido aprobado por el tutor.
```

### 2. Recordatorios de Fechas Límite
```markdown
Envía un recordatorio a todos los estudiantes sobre la fecha límite 
de entrega de proyectos que vence en 3 días.
```

### 3. Reportes Semanales
```markdown
Genera y envía un reporte semanal de actividad del sistema a 
admin@universidad.edu con estadísticas de proyectos y usuarios.
```

### 4. Alertas del Sistema
```markdown
Envía una alerta al administrador sobre un error crítico en el 
sistema de autenticación que requiere atención inmediata.
```

## 🔗 Integración con Supabase

### Función Edge para Email
Puedes crear una función Edge en Supabase que use Resend:

```typescript
// backend/supabase/functions/send-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { to, subject, content, type } = await req.json()
  
  // Lógica de negocio específica
  const emailContent = generateEmailContent(type, content)
  
  // Enviar via Resend (usando MCP desde Cursor)
  // O integrar directamente con Resend API
  
  return new Response(JSON.stringify({ success: true }))
})
```

### Triggers de Base de Datos
```sql
-- Trigger para enviar email cuando se aprueba un proyecto
CREATE OR REPLACE FUNCTION notify_project_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Llamar a función Edge que usa Resend
  PERFORM net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/send-notification',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := json_build_object(
      'to', NEW.student_email,
      'subject', 'Proyecto Aprobado',
      'content', 'Tu proyecto ha sido aprobado',
      'type', 'project_approval'
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 📊 Monitoreo y Métricas

### Dashboard de Resend
- Accede a [Resend Dashboard](https://resend.com/emails) para ver:
  - Emails enviados
  - Tasa de entrega
  - Bounces y errores
  - Métricas de engagement

### Logs del Sistema
```dart
// En tu servicio de notificaciones Flutter
class EmailNotificationService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String content,
  }) async {
    try {
      // Llamar a función Supabase
      await supabase.functions.invoke('send-email', body: {
        'to': to,
        'subject': subject,
        'content': content,
      });
      
      // Log exitoso
      debugPrint('✅ Email enviado a $to');
    } catch (e) {
      // Log error
      debugPrint('❌ Error enviando email: $e');
    }
  }
}
```

## 🔒 Seguridad y Mejores Prácticas

### Variables de Entorno
- **NUNCA** commitees API keys reales
- Usa diferentes keys para desarrollo y producción
- Rota las API keys regularmente

### Rate Limiting
- Resend Plan Gratuito: 3,000 emails/mes, 100 emails/día
- Implementa rate limiting en tu aplicación
- Monitorea el uso en el dashboard de Resend

### Validación de Datos
```dart
class EmailValidator {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidSubject(String subject) {
    return subject.isNotEmpty && subject.length <= 200;
  }
}
```

## 🛠️ Solución de Problemas

### Problemas Comunes

1. **Servidor MCP no aparece en Cursor**
   - Verifica la ruta del archivo `build/index.js`
   - Reinicia Cursor completamente
   - Revisa la consola de Cursor para errores

2. **Error de API Key**
   - Verifica que la API key sea correcta
   - Asegúrate de que tenga permisos de envío

3. **Emails van a spam**
   - Verifica tu dominio en Resend
   - Configura SPF, DKIM y DMARC
   - Usa contenido apropiado

### Comandos de Diagnóstico
```bash
# Verificar que el servidor MCP funciona
cd C:\dev\proyecto_flutter_supabase\mcp-resend
node test_mcp.js

# Verificar dependencias
npm list

# Reconstruir si es necesario
npm run build
```

## 📚 Recursos Adicionales

- [Documentación de Resend](https://resend.com/docs)
- [MCP Documentation](https://docs.anthropic.com/en/docs/agents-and-tools/mcp)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Flutter Email Integration](https://docs.flutter.dev/development/data-and-backend/networking)

## 🎯 Próximos Pasos

1. **Configurar API Key** de Resend
2. **Probar envío** de emails desde Cursor
3. **Integrar** con funciones de Supabase
4. **Implementar** templates de email
5. **Configurar** monitoreo y alertas
6. **Documentar** casos de uso específicos del proyecto

---

**¡El servidor MCP de Resend está listo para usar! 🚀**
