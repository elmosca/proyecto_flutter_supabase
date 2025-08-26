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
    const segments = url.pathname.split('/').filter(Boolean)

    // Routes:
    // GET /anteprojects - List anteprojects for current user
    // GET /anteprojects/:id - Get specific anteproject
    // POST /anteprojects - Create new anteproject
    // PUT /anteprojects/:id - Update anteproject
    // POST /anteprojects/:id/submit - Submit anteproject for review

    switch (method) {
      case 'GET':
        if (segments.length === 0) {
          return await listAnteprojects(supabaseClient)
        } else if (segments.length === 1) {
          return await getAnteproject(supabaseClient, parseInt(segments[0]))
        }
        break
      
      case 'POST':
        if (segments.length === 0) {
          const body = await req.json()
          return await createAnteproject(supabaseClient, body)
        } else if (segments.length === 2 && segments[1] === 'submit') {
          return await submitAnteproject(supabaseClient, parseInt(segments[0]))
        }
        break
      
      case 'PUT':
        if (segments.length === 1) {
          const body = await req.json()
          return await updateAnteproject(supabaseClient, parseInt(segments[0]), body)
        }
        break
    }

    return new Response(JSON.stringify({ error: 'Route not found' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

async function listAnteprojects(supabase: any) {
  // Get current user
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'No autenticado' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // Get user role from the database
  const { data: userData } = await supabase
    .from('users')
    .select('role')
    .eq('id', user.id)
    .single()

  let query = supabase
    .from('anteprojects')
    .select(`
      *,
      anteproject_students!inner(student_id, is_lead_author),
      users!anteprojects_tutor_id_fkey(full_name, email)
    `)

  // Filter based on user role
  if (userData?.role === 'student') {
    query = query.eq('anteproject_students.student_id', user.id)
  } else if (userData?.role === 'tutor') {
    query = query.eq('tutor_id', user.id)
  }
  // Admins can see all anteprojects (no filter)

  const { data, error } = await query.order('created_at', { ascending: false })

  if (error) {
    return new Response(JSON.stringify({ error: 'Error al obtener anteproyectos' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function getAnteproject(supabase: any, id: number) {
  const { data, error } = await supabase
    .from('anteprojects')
    .select(`
      *,
      anteproject_students(
        student_id,
        is_lead_author,
        users!anteproject_students_student_id_fkey(full_name, email, nre)
      ),
      anteproject_objectives(
        objective_id,
        is_selected,
        custom_description,
        dam_objectives(title, description)
      ),
      users!anteprojects_tutor_id_fkey(full_name, email),
      anteproject_evaluations(
        score,
        comments,
        evaluated_at,
        anteproject_evaluation_criteria(name, description, max_score)
      )
    `)
    .eq('id', id)
    .single()

  if (error) {
    return new Response(JSON.stringify({ error: 'Anteproyecto no encontrado' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function createAnteproject(supabase: any, body: any) {
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'No autenticado' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const {
    title,
    project_type,
    description,
    academic_year,
    expected_results,
    timeline,
    tutor_id,
    objectives,
    student_ids
  } = body

  // Create anteproject
  const { data: anteproject, error: anteprojectError } = await supabase
    .from('anteprojects')
    .insert({
      title,
      project_type,
      description,
      academic_year,
      expected_results,
      timeline,
      tutor_id,
      status: 'draft'
    })
    .select()
    .single()

  if (anteprojectError) {
    return new Response(JSON.stringify({ error: 'Error al crear anteproyecto' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // Add students
  if (student_ids && student_ids.length > 0) {
    const students = student_ids.map((studentId: string, index: number) => ({
      anteproject_id: anteproject.id,
      student_id: studentId,
      is_lead_author: index === 0 // First student is lead author
    }))

    await supabase
      .from('anteproject_students')
      .insert(students)
  }

  // Add objectives
  if (objectives && objectives.length > 0) {
    const anteprojectObjectives = objectives.map((obj: any) => ({
      anteproject_id: anteproject.id,
      objective_id: obj.objective_id,
      is_selected: obj.is_selected,
      custom_description: obj.custom_description
    }))

    await supabase
      .from('anteproject_objectives')
      .insert(anteprojectObjectives)
  }

  return new Response(JSON.stringify(anteproject), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function updateAnteproject(supabase: any, id: number, body: any) {
  const { data, error } = await supabase
    .from('anteprojects')
    .update(body)
    .eq('id', id)
    .select()
    .single()

  if (error) {
    return new Response(JSON.stringify({ error: 'Error al actualizar anteproyecto' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function submitAnteproject(supabase: any, id: number) {
  // Verify anteproject exists and is in draft status
  const { data: anteproject, error: fetchError } = await supabase
    .from('anteprojects')
    .select('*')
    .eq('id', id)
    .single()

  if (fetchError || !anteproject) {
    return new Response(JSON.stringify({ error: 'Anteproyecto no encontrado' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  if (anteproject.status !== 'draft') {
    return new Response(JSON.stringify({ error: 'El anteproyecto no puede ser enviado en su estado actual' }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // Update status to submitted
  const { data, error } = await supabase
    .from('anteprojects')
    .update({
      status: 'submitted',
      submitted_at: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single()

  if (error) {
    return new Response(JSON.stringify({ error: 'Error al enviar anteproyecto' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // Create notification for tutor
  await supabase
    .from('notifications')
    .insert({
      user_id: anteproject.tutor_id,
      type: 'anteproject_submitted',
      title: 'Nuevo Anteproyecto Enviado',
      message: `Se ha enviado un anteproyecto para revisión: "${anteproject.title}"`,
      action_url: `/anteprojects/${id}`,
      metadata: {
        anteproject_id: id
      }
    })

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
