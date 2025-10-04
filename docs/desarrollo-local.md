# ⚠️ DOCUMENTO OBSOLETO - Desarrollo Local con Supabase

> **IMPORTANTE**: Este documento está obsoleto desde el 4 de octubre de 2025.  
> El proyecto ahora utiliza **Supabase Cloud** exclusivamente.  
> Para recuperar la configuración local, usar la rama: `backup-supabase-local`

---

## 📋 Estado del Documento

- **Estado**: ⚠️ OBSOLETO
- **Fecha de obsolescencia**: 4 de octubre de 2025
- **Razón**: Migración a Supabase Cloud
- **Alternativa**: Usar Supabase Cloud (https://app.supabase.com)
- **Backup disponible**: Rama `backup-supabase-local`

---

## 🔄 Recuperación de Configuración Local (Si Necesario)

Si necesitas recuperar la configuración local de Supabase:

```bash
# Cambiar a la rama de backup
git checkout backup-supabase-local

# Ver archivos preservados
ls backend/supabase/

# Copiar archivos específicos si los necesitas
git checkout backup-supabase-local -- backend/supabase/
```

---

## 📚 Documentación Actual

Para la configuración actual del proyecto, consulta:
- [README Principal](../README.md)
- [Migraciones de Base de Datos](base_datos/migraciones/README.md)
- [Configuración de Supabase Cloud](desarrollo/03-guias-tecnicas/supabase-cloud.md)

---

# ⚠️ Contenido Original (Obsoleto)

## Configuración para Desarrollo Local (OBSOLETO)

### 1. Servidor MCP

El servidor MCP ha sido configurado para trabajar tanto en local como en producción.

#### Archivos de configuración:

- **`mcp-server/src/index.ts`**: Código fuente del servidor MCP
- **`mcp-server/.env`**: Variables de entorno para el servidor MCP
- **`mcp-config.json`**: Configuración de Cursor para conectar con el servidor MCP

#### Cambios realizados:

1. **URL de Supabase**: Cambiada de `http://192.168.1.9:54321` (producción) a `http://127.0.0.1:54321` (local)
2. **Archivo .env**: Creado con configuración local
3. **mcp-config.json**: Actualizado para apuntar a local

### 2. Frontend Flutter

#### Archivo de configuración:

- **`frontend/lib/config/app_config.dart`**: Configuración de entornos

#### Cambios realizados:

1. **Entorno local**: Configurado para usar `http://127.0.0.1:54321`
2. **Claves de Supabase**: Configuradas para el entorno local

### 3. Scripts de utilidad

- **`scripts/create_users_local.js`**: Script para crear usuarios de prueba en Supabase local

## Cambio entre Local y Producción

### Para cambiar a LOCAL:

1. **Servidor MCP**:
   ```bash
   # En mcp-server/.env
   SUPABASE_URL=http://127.0.0.1:54321
   ```

2. **Frontend**:
   ```bash
   # Ejecutar con variable de entorno
   flutter run -d edge --dart-define=ENVIRONMENT=local
   ```

3. **Configuración de Cursor**:
   ```json
   // En mcp-config.json
   "SUPABASE_URL": "http://127.0.0.1:54321"
   ```

### Para cambiar a PRODUCCIÓN:

1. **Servidor MCP**:
   ```bash
   # En mcp-server/.env
   SUPABASE_URL=http://192.168.1.9:54321
   ```

2. **Frontend**:
   ```bash
   # Ejecutar sin variable de entorno (usa producción por defecto)
   flutter run -d edge
   ```

3. **Configuración de Cursor**:
   ```json
   // En mcp-config.json
   "SUPABASE_URL": "http://192.168.1.9:54321"
   ```

## Comandos útiles

### Iniciar servidor MCP:
```bash
cd mcp-server
npm run build
npm start
```

### Crear usuarios de prueba:
```bash
cd mcp-server
node create_users_local.js
```

### Verificar estado de Supabase local:
```bash
curl http://127.0.0.1:54321/rest/v1/
```

## Problemas conocidos

1. **Base de datos local vacía**: Las migraciones no se han aplicado automáticamente
2. **Servidor MCP**: Requiere reiniciar Cursor después de cambios de configuración
3. **Dependencias**: Los scripts de Node.js requieren estar en el directorio `mcp-server`

## Solución de problemas

### Error "Database error checking email":
- **Causa**: Base de datos local sin tablas de autenticación
- **Solución**: Ejecutar migraciones con `supabase db reset`

### Error "Not connected" en MCP:
- **Causa**: Servidor MCP no iniciado o configuración incorrecta
- **Solución**: Verificar `mcp-config.json` y reiniciar Cursor

### Error "Cannot find module":
- **Causa**: Script ejecutado desde directorio incorrecto
- **Solución**: Ejecutar desde `mcp-server/` donde están las dependencias
