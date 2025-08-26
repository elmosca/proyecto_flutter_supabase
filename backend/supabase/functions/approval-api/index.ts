import { serve } from "https://deno.land/std@0.192.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const { method } = req
    const url = new URL(req.url)
    const action = url.searchParams.get('action')

    if (method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const requestBody = await req.json()

    switch (action) {
      case 'approve':
        return await approveAnteproject(supabaseClient, requestBody)
      case 'reject':
        return await rejectAnteproject(supabaseClient, requestBody)
      case 'request-changes':
        return await requestChanges(supabaseClient, requestBody)
      default:
        return new Response(JSON.stringify({ error: 'Invalid action' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
    }
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

async function approveAnteproject(supabase: any, { anteproject_id, comments }: { anteproject_id: number, comments?: string }) {
  // 1. Verificar que el anteproyecto existe y está en estado válido
  const { data: anteproject, error: fetchError } = await supabase
    .from('anteprojects')
    .select('*')
    .eq('id', anteproject_id)
    .single()

  if (fetchError || !anteproject) {
    return new Response(JSON.stringify({ error: 'Anteproyecto no encontrado' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  if (anteproject.status !== 'submitted' && anteproject.status !== 'under_review') {
    return new Response(JSON.stringify({ error: 'El anteproyecto no puede ser aprobado en su estado actual' }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 2. Actualizar el estado del anteproyecto
  const { error: updateError } = await supabase
    .from('anteprojects')
    .update({
      status: 'approved',
      reviewed_at: new Date().toISOString(),
      tutor_comments: comments || null
    })
    .eq('id', anteproject_id)

  if (updateError) {
    return new Response(JSON.stringify({ error: 'Error al actualizar anteproyecto' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 3. Crear el proyecto asociado
  const { data: newProject, error: projectError } = await supabase
    .from('projects')
    .insert({
      title: anteproject.title,
      description: anteproject.description,
      status: 'planning',
      tutor_id: anteproject.tutor_id,
      anteproject_id: anteproject_id,
      start_date: new Date().toISOString().split('T')[0]
    })
    .select()
    .single()

  if (projectError) {
    return new Response(JSON.stringify({ error: 'Error al crear proyecto' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 4. Copiar estudiantes del anteproyecto al proyecto
  const { data: students } = await supabase
    .from('anteproject_students')
    .select('student_id, is_lead_author')
    .eq('anteproject_id', anteproject_id)

  if (students && students.length > 0) {
    const projectStudents = students.map((student: any) => ({
      project_id: newProject.id,
      student_id: student.student_id,
      is_lead: student.is_lead_author
    }))

    await supabase
      .from('project_students')
      .insert(projectStudents)
  }

  // 5. Crear notificación para los estudiantes
  if (students && students.length > 0) {
    const notifications = students.map((student: any) => ({
      user_id: student.student_id,
      type: 'anteproject_approved',
      title: 'Anteproyecto Aprobado',
      message: `Tu anteproyecto "${anteproject.title}" ha sido aprobado. Se ha creado el proyecto correspondiente.`,
      action_url: `/projects/${newProject.id}`,
      metadata: {
        anteproject_id: anteproject_id,
        project_id: newProject.id
      }
    }))

    await supabase
      .from('notifications')
      .insert(notifications)
  }

  return new Response(JSON.stringify({
    success: true,
    anteproject_id,
    project_id: newProject.id,
    message: 'Anteproyecto aprobado y proyecto creado exitosamente'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function rejectAnteproject(supabase: any, { anteproject_id, comments }: { anteproject_id: number, comments: string }) {
  // 1. Verificar que el anteproyecto existe
  const { data: anteproject, error: fetchError } = await supabase
    .from('anteprojects')
    .select('*')
    .eq('id', anteproject_id)
    .single()

  if (fetchError || !anteproject) {
    return new Response(JSON.stringify({ error: 'Anteproyecto no encontrado' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 2. Actualizar el estado del anteproyecto
  const { error: updateError } = await supabase
    .from('anteprojects')
    .update({
      status: 'rejected',
      reviewed_at: new Date().toISOString(),
      tutor_comments: comments
    })
    .eq('id', anteproject_id)

  if (updateError) {
    return new Response(JSON.stringify({ error: 'Error al rechazar anteproyecto' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 3. Crear notificación para los estudiantes
  const { data: students } = await supabase
    .from('anteproject_students')
    .select('student_id')
    .eq('anteproject_id', anteproject_id)

  if (students && students.length > 0) {
    const notifications = students.map((student: any) => ({
      user_id: student.student_id,
      type: 'anteproject_rejected',
      title: 'Anteproyecto Rechazado',
      message: `Tu anteproyecto "${anteproject.title}" ha sido rechazado. Revisa los comentarios del tutor.`,
      action_url: `/anteprojects/${anteproject_id}`,
      metadata: {
        anteproject_id: anteproject_id
      }
    }))

    await supabase
      .from('notifications')
      .insert(notifications)
  }

  return new Response(JSON.stringify({
    success: true,
    anteproject_id,
    message: 'Anteproyecto rechazado'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function requestChanges(supabase: any, { anteproject_id, comments }: { anteproject_id: number, comments: string }) {
  // 1. Verificar que el anteproyecto existe
  const { data: anteproject, error: fetchError } = await supabase
    .from('anteprojects')
    .select('*')
    .eq('id', anteproject_id)
    .single()

  if (fetchError || !anteproject) {
    return new Response(JSON.stringify({ error: 'Anteproyecto no encontrado' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 2. Cambiar estado a draft para permitir modificaciones
  const { error: updateError } = await supabase
    .from('anteprojects')
    .update({
      status: 'draft',
      reviewed_at: new Date().toISOString(),
      tutor_comments: comments
    })
    .eq('id', anteproject_id)

  if (updateError) {
    return new Response(JSON.stringify({ error: 'Error al solicitar cambios' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // 3. Crear notificación para los estudiantes
  const { data: students } = await supabase
    .from('anteproject_students')
    .select('student_id')
    .eq('anteproject_id', anteproject_id)

  if (students && students.length > 0) {
    const notifications = students.map((student: any) => ({
      user_id: student.student_id,
      type: 'anteproject_changes_requested',
      title: 'Cambios Solicitados',
      message: `Se han solicitado cambios en tu anteproyecto "${anteproject.title}". Revisa los comentarios del tutor.`,
      action_url: `/anteprojects/${anteproject_id}/edit`,
      metadata: {
        anteproject_id: anteproject_id
      }
    }))

    await supabase
      .from('notifications')
      .insert(notifications)
  }

  return new Response(JSON.stringify({
    success: true,
    anteproject_id,
    message: 'Cambios solicitados en el anteproyecto'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
