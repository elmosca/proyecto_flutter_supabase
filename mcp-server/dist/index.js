#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema, } from '@modelcontextprotocol/sdk/types.js';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
// Cargar variables de entorno
dotenv.config();
// Configuración de Supabase
const supabaseUrl = process.env.SUPABASE_URL || 'http://192.168.1.9:54321';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';
// Crear cliente de Supabase
const supabase = createClient(supabaseUrl, supabaseAnonKey);
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
// Definir herramientas disponibles
const tools = [
    {
        name: 'supabase_query',
        description: 'Ejecutar consulta SQL en Supabase',
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
        description: 'Operaciones de autenticación con Supabase',
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
        description: 'Operaciones con Supabase Storage',
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
        description: 'Ejecutar función RPC en Supabase',
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
        description: 'Obtener información del esquema de la base de datos',
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
];
// Crear servidor MCP
const server = new Server({
    name: 'supabase-mcp-server',
    version: '1.0.0',
}, {
    capabilities: {
        tools: {},
    },
});
// Manejar listado de herramientas
server.setRequestHandler(ListToolsRequestSchema, async () => {
    return { tools };
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
                return await handleRPC(args);
            case 'supabase_schema':
                return await handleSchema(args);
            default:
                throw new Error(`Herramienta desconocida: ${name}`);
        }
    }
    catch (error) {
        return {
            content: [
                {
                    type: 'text',
                    text: `Error: ${error instanceof Error ? error.message : String(error)}`,
                },
            ],
            isError: true,
        };
    }
});
// Implementar manejadores de herramientas
async function handleQuery(args) {
    const { query, table, operation, data, filters } = args;
    let result;
    let queryText = '';
    switch (operation) {
        case 'select':
            if (table) {
                let selectQuery = supabase.from(table).select('*');
                if (filters) {
                    Object.entries(filters).forEach(([key, value]) => {
                        selectQuery = selectQuery.eq(key, value);
                    });
                }
                result = await selectQuery;
                queryText = `SELECT * FROM ${table}${filters ? ` WHERE ${Object.entries(filters).map(([k, v]) => `${k} = '${v}'`).join(' AND ')}` : ''}`;
            }
            else if (query) {
                result = await supabaseAdmin.rpc('exec_sql', { sql: query });
                queryText = query;
            }
            else {
                throw new Error('Se requiere tabla o consulta SQL');
            }
            break;
        case 'insert':
            if (!table || !data) {
                throw new Error('Se requiere tabla y datos para insertar');
            }
            result = await supabaseAdmin.from(table).insert(data);
            queryText = `INSERT INTO ${table} VALUES (${JSON.stringify(data)})`;
            break;
        case 'update':
            if (!table || !data || !filters) {
                throw new Error('Se requiere tabla, datos y filtros para actualizar');
            }
            let updateQuery = supabaseAdmin.from(table).update(data);
            Object.entries(filters).forEach(([key, value]) => {
                updateQuery = updateQuery.eq(key, value);
            });
            result = await updateQuery;
            queryText = `UPDATE ${table} SET ${Object.entries(data).map(([k, v]) => `${k} = '${v}'`).join(', ')} WHERE ${Object.entries(filters).map(([k, v]) => `${k} = '${v}'`).join(' AND ')}`;
            break;
        case 'delete':
            if (!table || !filters) {
                throw new Error('Se requiere tabla y filtros para eliminar');
            }
            let deleteQuery = supabaseAdmin.from(table).delete();
            Object.entries(filters).forEach(([key, value]) => {
                deleteQuery = deleteQuery.eq(key, value);
            });
            result = await deleteQuery;
            queryText = `DELETE FROM ${table} WHERE ${Object.entries(filters).map(([k, v]) => `${k} = '${v}'`).join(' AND ')}`;
            break;
        case 'custom':
            if (!query) {
                throw new Error('Se requiere consulta SQL para operación personalizada');
            }
            result = await supabaseAdmin.rpc('exec_sql', { sql: query });
            queryText = query;
            break;
        default:
            throw new Error(`Operación no soportada: ${operation}`);
    }
    return {
        content: [
            {
                type: 'text',
                text: `**Consulta ejecutada:**\n\`\`\`sql\n${queryText}\n\`\`\`\n\n**Resultado:**\n\`\`\`json\n${JSON.stringify(result, null, 2)}\n\`\`\``,
            },
        ],
    };
}
async function handleAuth(args) {
    const { action, email, password, userData } = args;
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
            result = await supabaseAdmin.auth.admin.listUsers();
            break;
        default:
            throw new Error(`Acción de autenticación no soportada: ${action}`);
    }
    return {
        content: [
            {
                type: 'text',
                text: `**Acción:** ${action}\n\n**Resultado:**\n\`\`\`json\n${JSON.stringify(result, null, 2)}\n\`\`\``,
            },
        ],
    };
}
async function handleStorage(args) {
    const { action, bucket, path, file } = args;
    let result;
    switch (action) {
        case 'upload':
            if (!bucket || !path || !file) {
                throw new Error('Se requiere bucket, ruta y archivo para subir');
            }
            const fileBuffer = Buffer.from(file, 'base64');
            result = await supabaseAdmin.storage.from(bucket).upload(path, fileBuffer);
            break;
        case 'download':
            if (!bucket || !path) {
                throw new Error('Se requiere bucket y ruta para descargar');
            }
            result = await supabaseAdmin.storage.from(bucket).download(path);
            break;
        case 'list':
            if (!bucket) {
                throw new Error('Se requiere bucket para listar archivos');
            }
            result = await supabaseAdmin.storage.from(bucket).list();
            break;
        case 'delete':
            if (!bucket || !path) {
                throw new Error('Se requiere bucket y ruta para eliminar');
            }
            result = await supabaseAdmin.storage.from(bucket).remove([path]);
            break;
        case 'get_public_url':
            if (!bucket || !path) {
                throw new Error('Se requiere bucket y ruta para obtener URL pública');
            }
            result = supabaseAdmin.storage.from(bucket).getPublicUrl(path);
            break;
        default:
            throw new Error(`Acción de storage no soportada: ${action}`);
    }
    return {
        content: [
            {
                type: 'text',
                text: `**Acción:** ${action}\n\n**Resultado:**\n\`\`\`json\n${JSON.stringify(result, null, 2)}\n\`\`\``,
            },
        ],
    };
}
async function handleRPC(args) {
    const { function: functionName, params } = args;
    if (!functionName) {
        throw new Error('Se requiere nombre de función RPC');
    }
    const result = await supabaseAdmin.rpc(functionName, params || {});
    return {
        content: [
            {
                type: 'text',
                text: `**Función RPC:** ${functionName}\n**Parámetros:** ${JSON.stringify(params || {}, null, 2)}\n\n**Resultado:**\n\`\`\`json\n${JSON.stringify(result, null, 2)}\n\`\`\``,
            },
        ],
    };
}
async function handleSchema(args) {
    const { action, table, function: functionName } = args;
    let result;
    switch (action) {
        case 'list_tables':
            result = await supabaseAdmin.rpc('get_tables');
            break;
        case 'describe_table':
            if (!table) {
                throw new Error('Se requiere nombre de tabla');
            }
            result = await supabaseAdmin.rpc('get_table_info', { table_name: table });
            break;
        case 'list_functions':
            result = await supabaseAdmin.rpc('get_functions');
            break;
        case 'describe_function':
            if (!functionName) {
                throw new Error('Se requiere nombre de función');
            }
            result = await supabaseAdmin.rpc('get_function_info', { function_name: functionName });
            break;
        default:
            throw new Error(`Acción de esquema no soportada: ${action}`);
    }
    return {
        content: [
            {
                type: 'text',
                text: `**Acción:** ${action}\n\n**Resultado:**\n\`\`\`json\n${JSON.stringify(result, null, 2)}\n\`\`\``,
            },
        ],
    };
}
// Iniciar servidor
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error('Servidor MCP de Supabase iniciado');
}
main().catch((error) => {
    console.error('Error al iniciar servidor MCP:', error);
    process.exit(1);
});
//# sourceMappingURL=index.js.map