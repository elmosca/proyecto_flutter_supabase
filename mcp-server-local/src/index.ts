#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

// Configuración para Supabase Local
const SUPABASE_URL = process.env.SUPABASE_URL || 'http://127.0.0.1:54321';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

// Crear cliente de Supabase
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Crear servidor MCP
const server = new Server(
  {
    name: 'supabase-local-mcp-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Listar herramientas disponibles
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'supabase_query',
        description: 'Ejecutar consulta SQL en Supabase Local',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'Consulta SQL a ejecutar',
            },
            table: {
              type: 'string',
              description: 'Nombre de la tabla (opcional, para consultas simples)',
            },
            operation: {
              type: 'string',
              enum: ['select', 'insert', 'update', 'delete', 'custom'],
              description: 'Tipo de operación',
            },
            data: {
              type: 'object',
              description: 'Datos para insertar/actualizar (opcional)',
            },
            filters: {
              type: 'object',
              description: 'Filtros para la consulta (opcional)',
            },
          },
          required: ['operation'],
        },
      },
      {
        name: 'supabase_auth',
        description: 'Operaciones de autenticación con Supabase Local',
        inputSchema: {
          type: 'object',
          properties: {
            action: {
              type: 'string',
              enum: ['signup', 'signin', 'signout', 'get_user', 'list_users'],
              description: 'Acción de autenticación a realizar',
            },
            email: {
              type: 'string',
              description: 'Email del usuario (para signup/signin)',
            },
            password: {
              type: 'string',
              description: 'Contraseña del usuario (para signup/signin)',
            },
            userData: {
              type: 'object',
              description: 'Datos adicionales del usuario (para signup)',
            },
          },
          required: ['action'],
        },
      },
      {
        name: 'supabase_storage',
        description: 'Operaciones con Supabase Storage Local',
        inputSchema: {
          type: 'object',
          properties: {
            action: {
              type: 'string',
              enum: ['upload', 'download', 'list', 'delete', 'get_public_url'],
              description: 'Acción de storage a realizar',
            },
            bucket: {
              type: 'string',
              description: 'Nombre del bucket',
            },
            path: {
              type: 'string',
              description: 'Ruta del archivo',
            },
            file: {
              type: 'string',
              description: 'Contenido del archivo (base64 para upload)',
            },
          },
          required: ['action'],
        },
      },
      {
        name: 'supabase_rpc',
        description: 'Ejecutar función RPC en Supabase Local',
        inputSchema: {
          type: 'object',
          properties: {
            function: {
              type: 'string',
              description: 'Nombre de la función RPC',
            },
            params: {
              type: 'object',
              description: 'Parámetros para la función RPC',
            },
          },
          required: ['function'],
        },
      },
      {
        name: 'supabase_schema',
        description: 'Obtener información del esquema de la base de datos local',
        inputSchema: {
          type: 'object',
          properties: {
            action: {
              type: 'string',
              enum: ['list_tables', 'describe_table', 'list_functions', 'describe_function'],
              description: 'Acción a realizar',
            },
            table: {
              type: 'string',
              description: 'Nombre de la tabla (para describe_table)',
            },
            function: {
              type: 'string',
              description: 'Nombre de la función (para describe_function)',
            },
          },
          required: ['action'],
        },
      },
    ],
  };
});

// Manejar llamadas a herramientas
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'supabase_query':
        return await handleQuery(args);
      case 'supabase_auth':
        return await handleAuth(args);
      case 'supabase_storage':
        return await handleStorage(args);
      case 'supabase_rpc':
        return await handleRpc(args);
      case 'supabase_schema':
        return await handleSchema(args);
      default:
        throw new Error(`Herramienta desconocida: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
    };
  }
});

// Función para manejar consultas SQL
async function handleQuery(args: any) {
  const { query, table, operation, data, filters } = args;

  try {
    let result;

    switch (operation) {
      case 'select':
        if (table) {
          let queryBuilder = supabase.from(table).select('*');
          if (filters) {
            Object.entries(filters).forEach(([key, value]) => {
              queryBuilder = queryBuilder.eq(key, value);
            });
          }
          result = await queryBuilder;
        } else if (query) {
          result = await supabase.rpc('execute_sql', { sql_query: query });
        } else {
          throw new Error('Se requiere tabla o consulta SQL');
        }
        break;

      case 'insert':
        if (!table || !data) {
          throw new Error('Se requiere tabla y datos para insertar');
        }
        result = await supabase.from(table).insert(data);
        break;

      case 'update':
        if (!table || !data) {
          throw new Error('Se requiere tabla y datos para actualizar');
        }
        let updateBuilder = supabase.from(table).update(data);
        if (filters) {
          Object.entries(filters).forEach(([key, value]) => {
            updateBuilder = updateBuilder.eq(key, value);
          });
        }
        result = await updateBuilder;
        break;

      case 'delete':
        if (!table) {
          throw new Error('Se requiere tabla para eliminar');
        }
        let deleteBuilder = supabase.from(table).delete();
        if (filters) {
          Object.entries(filters).forEach(([key, value]) => {
            deleteBuilder = deleteBuilder.eq(key, value);
          });
        }
        result = await deleteBuilder;
        break;

      case 'custom':
        if (!query) {
          throw new Error('Se requiere consulta SQL para operación personalizada');
        }
        result = await supabase.rpc('execute_sql', { sql_query: query });
        break;

      default:
        throw new Error(`Operación no soportada: ${operation}`);
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    throw new Error(`Error en consulta: ${error instanceof Error ? error.message : String(error)}`);
  }
}

// Función para manejar autenticación
async function handleAuth(args: any) {
  const { action, email, password, userData } = args;

  try {
    let result;

    switch (action) {
      case 'signup':
        if (!email || !password) {
          throw new Error('Se requiere email y contraseña para registro');
        }
        result = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: userData || {},
          },
        });
        break;

      case 'signin':
        if (!email || !password) {
          throw new Error('Se requiere email y contraseña para login');
        }
        result = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        break;

      case 'signout':
        result = await supabase.auth.signOut();
        break;

      case 'get_user':
        result = await supabase.auth.getUser();
        break;

      case 'list_users':
        result = await supabase.auth.admin.listUsers();
        break;

      default:
        throw new Error(`Acción de autenticación no soportada: ${action}`);
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    throw new Error(`Error en autenticación: ${error instanceof Error ? error.message : String(error)}`);
  }
}

// Función para manejar storage
async function handleStorage(args: any) {
  const { action, bucket, path, file } = args;

  try {
    let result;

    switch (action) {
      case 'upload':
        if (!bucket || !path || !file) {
          throw new Error('Se requiere bucket, ruta y archivo para subir');
        }
        const fileBuffer = Buffer.from(file, 'base64');
        result = await supabase.storage.from(bucket).upload(path, fileBuffer);
        break;

      case 'download':
        if (!bucket || !path) {
          throw new Error('Se requiere bucket y ruta para descargar');
        }
        result = await supabase.storage.from(bucket).download(path);
        break;

      case 'list':
        if (!bucket) {
          throw new Error('Se requiere bucket para listar archivos');
        }
        result = await supabase.storage.from(bucket).list(path);
        break;

      case 'delete':
        if (!bucket || !path) {
          throw new Error('Se requiere bucket y ruta para eliminar');
        }
        result = await supabase.storage.from(bucket).remove([path]);
        break;

      case 'get_public_url':
        if (!bucket || !path) {
          throw new Error('Se requiere bucket y ruta para obtener URL pública');
        }
        result = await supabase.storage.from(bucket).getPublicUrl(path);
        break;

      default:
        throw new Error(`Acción de storage no soportada: ${action}`);
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    throw new Error(`Error en storage: ${error instanceof Error ? error.message : String(error)}`);
  }
}

// Función para manejar RPC
async function handleRpc(args: any) {
  const { function: functionName, params } = args;

  try {
    if (!functionName) {
      throw new Error('Se requiere nombre de función RPC');
    }

    const result = await supabase.rpc(functionName, params || {});

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    throw new Error(`Error en RPC: ${error instanceof Error ? error.message : String(error)}`);
  }
}

// Función para manejar esquema
async function handleSchema(args: any) {
  const { action, table, function: functionName } = args;

  try {
    let result;

    switch (action) {
      case 'list_tables':
        result = await supabase.rpc('get_tables');
        break;

      case 'describe_table':
        if (!table) {
          throw new Error('Se requiere nombre de tabla para describir');
        }
        result = await supabase.rpc('describe_table', { table_name: table });
        break;

      case 'list_functions':
        result = await supabase.rpc('get_functions');
        break;

      case 'describe_function':
        if (!functionName) {
          throw new Error('Se requiere nombre de función para describir');
        }
        result = await supabase.rpc('describe_function', { function_name: functionName });
        break;

      default:
        throw new Error(`Acción de esquema no soportada: ${action}`);
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    throw new Error(`Error en esquema: ${error instanceof Error ? error.message : String(error)}`);
  }
}

// Iniciar servidor
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Servidor MCP Supabase Local iniciado');
}

main().catch((error) => {
  console.error('Error al iniciar servidor:', error);
  process.exit(1);
});
