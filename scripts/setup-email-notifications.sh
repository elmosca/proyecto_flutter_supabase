#!/bin/bash

# Script para configurar las notificaciones por email
# Ejecutar desde la raíz del proyecto

echo "📧 Configurando notificaciones por email..."

# Verificar que estamos en el directorio correcto
if [ ! -f "backend/supabase/functions/send-email/index.ts" ]; then
    echo "❌ Error: Ejecuta este script desde la raíz del proyecto"
    exit 1
fi

# Verificar que Supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    echo "❌ Error: Supabase CLI no está instalado"
    echo "Instálalo desde: https://supabase.com/docs/guides/cli"
    exit 1
fi

echo "✅ Supabase CLI encontrado"

# Verificar que estamos logueados en Supabase
if ! supabase status &> /dev/null; then
    echo "❌ Error: No estás logueado en Supabase"
    echo "Ejecuta: supabase login"
    exit 1
fi

echo "✅ Autenticado en Supabase"

# Desplegar la Edge Function
echo "🚀 Desplegando Edge Function send-email..."
supabase functions deploy send-email

if [ $? -eq 0 ]; then
    echo "✅ Edge Function desplegada exitosamente"
else
    echo "❌ Error desplegando Edge Function"
    exit 1
fi

# Aplicar migraciones
echo "📊 Aplicando migraciones de base de datos..."
supabase db push

if [ $? -eq 0 ]; then
    echo "✅ Migraciones aplicadas exitosamente"
else
    echo "❌ Error aplicando migraciones"
    exit 1
fi

echo ""
echo "🎉 ¡Configuración completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Ve a https://resend.com y crea una cuenta"
echo "2. Obtén tu API Key"
echo "3. En el dashboard de Supabase, ve a Settings > Edge Functions"
echo "4. Agrega la variable de entorno: RESEND_API_KEY=tu_api_key"
echo "5. Actualiza las URLs en las migraciones con tu dominio real"
echo ""
echo "🔧 Para probar:"
echo "- Crea un comentario en un anteproyecto"
echo "- Cambia el estado de un anteproyecto"
echo "- Revisa los logs en Supabase Dashboard > Edge Functions"
echo ""
echo "📚 Documentación completa en: backend/supabase/functions/send-email/README.md"
