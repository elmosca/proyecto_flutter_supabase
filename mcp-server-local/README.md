# 🏠 Supabase Local MCP Server

Servidor MCP (Model Context Protocol) para comunicación con Supabase Local.

## 🎯 Propósito

Este servidor MCP está configurado específicamente para trabajar con Supabase local (`http://127.0.0.1:54321`), permitiendo desarrollo independiente sin depender del servidor de producción.

## 🚀 Instalación

```bash
# Instalar dependencias
npm install

# Copiar archivo de configuración
copy env.example .env

# Compilar TypeScript
npm run build
```

## 🔧 Configuración

### Variables de Entorno

El archivo `.env` debe contener:

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

## 🛠️ Uso

### Desarrollo

```bash
# Modo desarrollo con hot reload
npm run dev

# Modo watch
npm run watch
```

### Producción

```bash
# Compilar
npm run build

# Ejecutar
npm start
```

## 🔌 Herramientas Disponibles

### 1. `supabase_query`
Ejecutar consultas SQL en Supabase Local.

**Parámetros:**
- `operation`: `select`, `insert`, `update`, `delete`, `custom`
- `query`: Consulta SQL (opcional)
- `table`: Nombre de tabla (opcional)
- `data`: Datos para insertar/actualizar (opcional)
- `filters`: Filtros para la consulta (opcional)

### 2. `supabase_auth`
Operaciones de autenticación.

**Parámetros:**
- `action`: `signup`, `signin`, `signout`, `get_user`, `list_users`
- `email`: Email del usuario (opcional)
- `password`: Contraseña (opcional)
- `userData`: Datos adicionales (opcional)

### 3. `supabase_storage`
Operaciones con Supabase Storage.

**Parámetros:**
- `action`: `upload`, `download`, `list`, `delete`, `get_public_url`
- `bucket`: Nombre del bucket
- `path`: Ruta del archivo
- `file`: Contenido del archivo (base64)

### 4. `supabase_rpc`
Ejecutar funciones RPC.

**Parámetros:**
- `function`: Nombre de la función RPC
- `params`: Parámetros para la función

### 5. `supabase_schema`
Obtener información del esquema.

**Parámetros:**
- `action`: `list_tables`, `describe_table`, `list_functions`, `describe_function`
- `table`: Nombre de tabla (opcional)
- `function`: Nombre de función (opcional)

## 📋 Ejemplos de Uso

### Crear Usuario de Prueba

```json
{
  "name": "supabase_auth",
  "arguments": {
    "action": "signup",
    "email": "test@example.com",
    "password": "password123",
    "userData": {
      "full_name": "Usuario de Prueba",
      "role": "student"
    }
  }
}
```

### Consultar Usuarios

```json
{
  "name": "supabase_query",
  "arguments": {
    "operation": "select",
    "table": "users"
  }
}
```

### Listar Tablas

```json
{
  "name": "supabase_schema",
  "arguments": {
    "action": "list_tables"
  }
}
```

## 🔄 Diferencias con el Servidor de Producción

| Característica | Local | Producción |
|----------------|-------|------------|
| URL | `http://127.0.0.1:54321` | `http://192.168.1.9:54321` |
| Claves | Demo keys | Claves reales |
| Datos | Datos de prueba | Datos reales |
| Uso | Desarrollo | Producción |

## 🚨 Notas Importantes

1. **Solo para desarrollo**: Este servidor está configurado para Supabase local
2. **Datos de prueba**: Usa las claves demo de Supabase
3. **Independiente**: No afecta el servidor de producción
4. **Configuración local**: Asegúrate de que Supabase local esté ejecutándose

## 🐛 Solución de Problemas

### Error de Conexión
- Verificar que Supabase local esté ejecutándose: `supabase status`
- Verificar la URL en el archivo `.env`

### Error de Autenticación
- Verificar las claves en el archivo `.env`
- Asegurarse de usar las claves demo correctas

### Error de Compilación
- Ejecutar `npm install` para instalar dependencias
- Verificar que TypeScript esté instalado globalmente

## 📞 Soporte

Para problemas específicos de este servidor local, revisar:
1. Logs del servidor MCP
2. Estado de Supabase local
3. Configuración de variables de entorno
