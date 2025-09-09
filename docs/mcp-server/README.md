# Servidor MCP para Supabase

Este servidor MCP (Model Context Protocol) permite una comunicación ágil y directa con Supabase desde Cursor, facilitando el desarrollo y la gestión de la base de datos.

## 🚀 Instalación

### Windows
```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup-mcp-server.ps1
```

### Linux/macOS
```bash
chmod +x scripts/setup-mcp-server.sh
./scripts/setup-mcp-server.sh
```

## ⚙️ Configuración

### 1. Configurar Cursor

Agrega la siguiente configuración a tu archivo `mcp-config.json` en Cursor:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "node",
      "args": ["mcp-server/dist/index.js"],
      "env": {
        "SUPABASE_URL": "http://192.168.1.9:54321",
        "SUPABASE_ANON_KEY": "tu_clave_anonima",
        "SUPABASE_SERVICE_KEY": "tu_clave_de_servicio"
      }
    }
  }
}
```

### 2. Reiniciar Cursor

Después de configurar el archivo, reinicia Cursor para cargar el servidor MCP.

## 🛠️ Herramientas Disponibles

### 1. `supabase_query`
Ejecuta consultas SQL en Supabase.

**Parámetros:**
- `operation`: Tipo de operación (`select`, `insert`, `update`, `delete`, `custom`)
- `table`: Nombre de la tabla (opcional)
- `query`: Consulta SQL personalizada (opcional)
- `data`: Datos para insertar/actualizar (opcional)
- `filters`: Filtros para la consulta (opcional)

**Ejemplos:**
```javascript
// Seleccionar usuarios
{
  "operation": "select",
  "table": "users",
  "filters": {"role": "student"}
}

// Insertar nuevo usuario
{
  "operation": "insert",
  "table": "users",
  "data": {
    "email": "nuevo@ejemplo.com",
    "full_name": "Nuevo Usuario",
    "role": "student"
  }
}
```

### 2. `supabase_auth`
Operaciones de autenticación.

**Parámetros:**
- `action`: Acción a realizar (`signup`, `signin`, `signout`, `get_user`, `list_users`)
- `email`: Email del usuario (opcional)
- `password`: Contraseña del usuario (opcional)
- `userData`: Datos adicionales del usuario (opcional)

**Ejemplos:**
```javascript
// Crear nuevo usuario
{
  "action": "signup",
  "email": "usuario@ejemplo.com",
  "password": "contraseña123",
  "userData": {"role": "student"}
}

// Listar usuarios
{
  "action": "list_users"
}
```

### 3. `supabase_storage`
Operaciones con Supabase Storage.

**Parámetros:**
- `action`: Acción a realizar (`upload`, `download`, `list`, `delete`, `get_public_url`)
- `bucket`: Nombre del bucket
- `path`: Ruta del archivo
- `file`: Contenido del archivo en base64 (para upload)

**Ejemplos:**
```javascript
// Listar archivos en un bucket
{
  "action": "list",
  "bucket": "documents"
}

// Obtener URL pública
{
  "action": "get_public_url",
  "bucket": "documents",
  "path": "archivo.pdf"
}
```

### 4. `supabase_rpc`
Ejecuta funciones RPC en Supabase.

**Parámetros:**
- `function`: Nombre de la función RPC
- `params`: Parámetros para la función

**Ejemplos:**
```javascript
// Ejecutar función de login personalizada
{
  "function": "login_user",
  "params": {
    "user_email": "usuario@ejemplo.com",
    "user_password": "contraseña123"
  }
}
```

### 5. `supabase_schema`
Obtiene información del esquema de la base de datos.

**Parámetros:**
- `action`: Acción a realizar (`list_tables`, `describe_table`, `list_functions`, `describe_function`)
- `table`: Nombre de la tabla (opcional)
- `function`: Nombre de la función (opcional)

**Ejemplos:**
```javascript
// Listar todas las tablas
{
  "action": "list_tables"
}

// Describir una tabla específica
{
  "action": "describe_table",
  "table": "users"
}
```

## 🔧 Uso desde Cursor

Una vez configurado, puedes usar las herramientas directamente desde Cursor:

1. **Abre el chat de Cursor**
2. **Menciona las herramientas disponibles**: "Usa supabase_query para..."
3. **Especifica los parámetros** según la herramienta que necesites
4. **Ejecuta la consulta** y obtén los resultados

## 📝 Ejemplos de Uso

### Consultar usuarios estudiantes
```
Usa supabase_query para obtener todos los usuarios con rol "student" de la tabla users
```

### Crear un nuevo usuario
```
Usa supabase_auth para crear un nuevo usuario con email "test@ejemplo.com" y contraseña "test123"
```

### Verificar esquema de la base de datos
```
Usa supabase_schema para listar todas las tablas disponibles en la base de datos
```

### Ejecutar función RPC personalizada
```
Usa supabase_rpc para ejecutar la función login_user con email "test@ejemplo.com" y contraseña "test123"
```

## 🚨 Consideraciones de Seguridad

- **Claves de servicio**: Solo usa la clave de servicio en entornos seguros
- **Permisos RLS**: Asegúrate de que las políticas RLS estén configuradas correctamente
- **Validación de datos**: Siempre valida los datos antes de ejecutar consultas

## 🐛 Solución de Problemas

### Error de conexión
- Verifica que Supabase esté ejecutándose en `http://192.168.1.9:54321`
- Confirma que las claves de API sean correctas

### Error de compilación
- Ejecuta `npm run build` en el directorio `mcp-server`
- Verifica que todas las dependencias estén instaladas

### Herramientas no disponibles en Cursor
- Reinicia Cursor después de configurar `mcp-config.json`
- Verifica que la ruta al servidor MCP sea correcta

## 📚 Recursos Adicionales

- [Documentación de MCP](https://modelcontextprotocol.io/)
- [Documentación de Supabase](https://supabase.com/docs)
- [SDK de Supabase para JavaScript](https://supabase.com/docs/reference/javascript)
