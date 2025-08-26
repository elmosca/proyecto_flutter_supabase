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
    const action = url.searchParams.get('action')

    // Routes:
    // GET /tasks?project_id=:id - List tasks for a project
    // GET /tasks/:id - Get specific task
    // POST /tasks - Create new task
    // PUT /tasks/:id - Update task
    // PUT /tasks/:id/status - Update task status
    // POST /tasks/:id/assign - Assign task to user
    // POST /tasks/:id/comments - Add comment to task

    switch (method) {
      case 'GET':
        if (segments.length === 0) {
          const projectId = url.searchParams.get('project_id')
          if (projectId) {
            return await listTasksByProject(supabaseClient, parseInt(projectId))
          } else {
            return await listUserTasks(supabaseClient)
          }
        } else if (segments.length === 1) {
          return await getTask(supabaseClient, parseInt(segments[0]))
        }
        break
      
      case 'POST':
        if (segments.length === 0) {
          const body = await req.json()
          return await createTask(supabaseClient, body)
        } else if (segments.length === 2) {
          const taskId = parseInt(segments[0])
          const body = await req.json()
          
          switch (segments[1]) {
            case 'assign':
              return await assignTask(supabaseClient, taskId, body)
            case 'comments':
              return await addComment(supabaseClient, taskId, body)
            default:
              return errorResponse('Invalid action', 400)
          }
        }
        break
      
      case 'PUT':
        if (segments.length === 1) {
          const body = await req.json()
          return await updateTask(supabaseClient, parseInt(segments[0]), body)
        } else if (segments.length === 2 && segments[1] === 'status') {
          const body = await req.json()
          return await updateTaskStatus(supabaseClient, parseInt(segments[0]), body)
        }
        break
    }

    return errorResponse('Route not found', 404)

  } catch (error) {
    console.error('API Error:', error)
    return errorResponse(error.message, 500)
  }
})

function errorResponse(message: string, status: number) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function listTasksByProject(supabase: any, projectId: number) {
  const { data, error } = await supabase
    .from('tasks')
    .select(`
      *,
      milestone:milestones(id, title, milestone_number),
      assignees:task_assignees(
        user_id,
        assigned_at,
        user:users(full_name, email)
      ),
      comments:comments(count)
    `)
    .eq('project_id', projectId)
    .order('kanban_position', { ascending: true })

  if (error) {
    return errorResponse('Error al obtener tareas del proyecto', 500)
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function listUserTasks(supabase: any) {
  // Get current user
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) {
    return errorResponse('No autenticado', 401)
  }

  // Get tasks assigned to the current user
  const { data, error } = await supabase
    .from('task_assignees')
    .select(`
      task_id,
      assigned_at,
      task:tasks(
        *,
        project:projects(id, title, status),
        milestone:milestones(id, title, milestone_number),
        comments:comments(count)
      )
    `)
    .eq('user_id', user.id)
    .order('assigned_at', { ascending: false })

  if (error) {
    return errorResponse('Error al obtener tareas del usuario', 500)
  }

  // Flatten the response to return tasks directly
  const tasks = data.map((item: any) => ({
    ...item.task,
    assigned_at: item.assigned_at
  }))

  return new Response(JSON.stringify(tasks), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function getTask(supabase: any, id: number) {
  const { data, error } = await supabase
    .from('tasks')
    .select(`
      *,
      project:projects(id, title, status, tutor_id),
      milestone:milestones(id, title, milestone_number, status),
      assignees:task_assignees(
        user_id,
        assigned_at,
        assigned_by,
        user:users(full_name, email),
        assigner:users!task_assignees_assigned_by_fkey(full_name, email)
      ),
      comments:comments(
        id,
        content,
        is_internal,
        created_at,
        author:users(full_name, email),
        files(id, filename, file_path, file_size, mime_type)
      ),
      files(id, filename, file_path, file_size, mime_type, uploaded_at, uploader:users(full_name, email))
    `)
    .eq('id', id)
    .single()

  if (error) {
    return errorResponse('Tarea no encontrada', 404)
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function createTask(supabase: any, body: any) {
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) {
    return errorResponse('No autenticado', 401)
  }

  const {
    project_id,
    milestone_id,
    title,
    description,
    due_date,
    estimated_hours,
    complexity,
    tags,
    assignees
  } = body

  // Verify user has permission to create tasks in this project
  const { data: project, error: projectError } = await supabase
    .from('projects')
    .select('id, tutor_id, project_students(student_id)')
    .eq('id', project_id)
    .single()

  if (projectError || !project) {
    return errorResponse('Proyecto no encontrado', 404)
  }

  // Check if user is tutor or student of the project
  const { data: userData } = await supabase
    .from('users')
    .select('role')
    .eq('id', user.id)
    .single()

  const isAuthorized = userData?.role === 'admin' || 
                      project.tutor_id === user.id ||
                      project.project_students.some((ps: any) => ps.student_id === user.id)

  if (!isAuthorized) {
    return errorResponse('Sin permisos para crear tareas en este proyecto', 403)
  }

  // Get the next kanban position
  const { data: lastTask } = await supabase
    .from('tasks')
    .select('kanban_position')
    .eq('project_id', project_id)
    .order('kanban_position', { ascending: false })
    .limit(1)
    .single()

  const nextPosition = (lastTask?.kanban_position || 0) + 1

  // Create the task
  const { data: newTask, error: taskError } = await supabase
    .from('tasks')
    .insert({
      project_id,
      milestone_id: milestone_id || null,
      title,
      description,
      due_date: due_date || null,
      estimated_hours: estimated_hours || null,
      complexity: complexity || 'medium',
      tags: tags || null,
      kanban_position: nextPosition,
      generation_source: 'manual'
    })
    .select()
    .single()

  if (taskError) {
    return errorResponse('Error al crear tarea', 500)
  }

  // Assign users to the task
  if (assignees && assignees.length > 0) {
    const taskAssignments = assignees.map((userId: string) => ({
      task_id: newTask.id,
      user_id: userId,
      assigned_by: user.id
    }))

    await supabase
      .from('task_assignees')
      .insert(taskAssignments)
  }

  return new Response(JSON.stringify(newTask), {
    status: 201,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function updateTask(supabase: any, id: number, body: any) {
  const { data, error } = await supabase
    .from('tasks')
    .update(body)
    .eq('id', id)
    .select()
    .single()

  if (error) {
    return errorResponse('Error al actualizar tarea', 500)
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function updateTaskStatus(supabase: any, id: number, body: any) {
  const { status } = body
  
  const updateData: any = { status }
  
  // If completing the task, set completed_at
  if (status === 'completed') {
    updateData.completed_at = new Date().toISOString()
  }

  const { data, error } = await supabase
    .from('tasks')
    .update(updateData)
    .eq('id', id)
    .select()
    .single()

  if (error) {
    return errorResponse('Error al actualizar estado de tarea', 500)
  }

  // Create notification for task assignees
  const { data: assignees } = await supabase
    .from('task_assignees')
    .select('user_id')
    .eq('task_id', id)

  if (assignees && assignees.length > 0) {
    const notifications = assignees.map((assignee: any) => ({
      user_id: assignee.user_id,
      type: 'task_status_changed',
      title: 'Estado de Tarea Actualizado',
      message: `La tarea "${data.title}" cambió a estado: ${status}`,
      action_url: `/tasks/${id}`,
      metadata: {
        task_id: id,
        new_status: status
      }
    }))

    await supabase
      .from('notifications')
      .insert(notifications)
  }

  return new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function assignTask(supabase: any, taskId: number, body: any) {
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) {
    return errorResponse('No autenticado', 401)
  }

  const { user_id } = body

  // Check if assignment already exists
  const { data: existing } = await supabase
    .from('task_assignees')
    .select('id')
    .eq('task_id', taskId)
    .eq('user_id', user_id)
    .single()

  if (existing) {
    return errorResponse('Usuario ya asignado a esta tarea', 400)
  }

  // Create assignment
  const { data, error } = await supabase
    .from('task_assignees')
    .insert({
      task_id: taskId,
      user_id,
      assigned_by: user.id
    })
    .select(`
      *,
      user:users(full_name, email),
      task:tasks(title)
    `)
    .single()

  if (error) {
    return errorResponse('Error al asignar tarea', 500)
  }

  // Create notification for assigned user
  await supabase
    .from('notifications')
    .insert({
      user_id,
      type: 'task_assigned',
      title: 'Nueva Tarea Asignada',
      message: `Se te ha asignado la tarea: "${data.task.title}"`,
      action_url: `/tasks/${taskId}`,
      metadata: {
        task_id: taskId
      }
    })

  return new Response(JSON.stringify(data), {
    status: 201,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

async function addComment(supabase: any, taskId: number, body: any) {
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (userError || !user) {
    return errorResponse('No autenticado', 401)
  }

  const { content, is_internal } = body

  const { data, error } = await supabase
    .from('comments')
    .insert({
      task_id: taskId,
      author_id: user.id,
      content,
      is_internal: is_internal || false
    })
    .select(`
      *,
      author:users(full_name, email)
    `)
    .single()

  if (error) {
    return errorResponse('Error al añadir comentario', 500)
  }

  // Get task assignees for notifications (excluding the comment author)
  const { data: assignees } = await supabase
    .from('task_assignees')
    .select('user_id')
    .eq('task_id', taskId)
    .neq('user_id', user.id)

  const { data: task } = await supabase
    .from('tasks')
    .select('title')
    .eq('id', taskId)
    .single()

  if (assignees && assignees.length > 0 && task) {
    const notifications = assignees.map((assignee: any) => ({
      user_id: assignee.user_id,
      type: 'comment_added',
      title: 'Nuevo Comentario',
      message: `Nuevo comentario en la tarea: "${task.title}"`,
      action_url: `/tasks/${taskId}`,
      metadata: {
        task_id: taskId,
        comment_id: data.id
      }
    }))

    await supabase
      .from('notifications')
      .insert(notifications)
  }

  return new Response(JSON.stringify(data), {
    status: 201,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
