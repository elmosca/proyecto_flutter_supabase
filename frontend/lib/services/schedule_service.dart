import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule.dart';
import '../models/anteproject.dart';

class ScheduleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene el cronograma de un anteproyecto
  Future<Schedule?> getScheduleByAnteproject(int anteprojectId) async {
    try {
      final response = await _supabase
          .from('schedules')
          .select('''
            *,
            review_dates (
              *
            )
          ''')
          .eq('anteproject_id', anteprojectId)
          .single();

      // response ya es null si no se encuentra el registro

      // Convertir review_dates a objetos ReviewDate
      final reviewDates = (response['review_dates'] as List)
          .map((date) => ReviewDate.fromJson(date))
          .toList();

      return Schedule(
        id: response['id'],
        anteprojectId: response['anteproject_id'],
        tutorId: response['tutor_id'],
        startDate: DateTime.parse(response['start_date']),
        reviewDates: reviewDates,
        finalDate: DateTime.parse(response['final_date']),
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
      );
    } catch (e) {
      // Si no existe el cronograma, retornar null
      return null;
    }
  }

  /// Crea un nuevo cronograma para un anteproyecto
  Future<Schedule> createSchedule({
    required int anteprojectId,
    required int tutorId,
    required DateTime startDate,
    required DateTime finalDate,
    required List<ReviewDate> reviewDates,
  }) async {
    try {
      // Crear el cronograma principal
      final scheduleResponse = await _supabase
          .from('schedules')
          .insert({
            'anteproject_id': anteprojectId,
            'tutor_id': tutorId,
            'start_date': startDate.toIso8601String(),
            'final_date': finalDate.toIso8601String(),
          })
          .select()
          .single();

      final scheduleId = scheduleResponse['id'];

      // Crear las fechas de revisión
      final reviewDatesData = reviewDates.map((reviewDate) => {
        'schedule_id': scheduleId,
        'date': reviewDate.date.toIso8601String(),
        'description': reviewDate.description,
        'milestone_reference': reviewDate.milestoneReference,
      }).toList();

      await _supabase
          .from('review_dates')
          .insert(reviewDatesData);

      // Actualizar el campo timeline del anteproyecto
      await _updateAnteprojectTimeline(anteprojectId, reviewDates);

      // Obtener el cronograma completo
      final schedule = await getScheduleByAnteproject(anteprojectId);
      if (schedule == null) {
        throw Exception('Error al crear el cronograma');
      }
      return schedule;
    } catch (e) {
      throw Exception('Error al crear cronograma: $e');
    }
  }

  /// Actualiza un cronograma existente
  Future<Schedule> updateSchedule({
    required int scheduleId,
    required DateTime startDate,
    required DateTime finalDate,
    required List<ReviewDate> reviewDates,
  }) async {
    try {
      // Obtener el anteproject_id antes de actualizar
      final schedule = await _supabase
          .from('schedules')
          .select('anteproject_id')
          .eq('id', scheduleId)
          .single();

      final anteprojectId = schedule['anteproject_id'];

      // Actualizar el cronograma principal
      await _supabase
          .from('schedules')
          .update({
            'start_date': startDate.toIso8601String(),
            'final_date': finalDate.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', scheduleId);

      // Eliminar fechas de revisión existentes
      await _supabase
          .from('review_dates')
          .delete()
          .eq('schedule_id', scheduleId);

      // Crear las nuevas fechas de revisión
      final reviewDatesData = reviewDates.map((reviewDate) => {
        'schedule_id': scheduleId,
        'date': reviewDate.date.toIso8601String(),
        'description': reviewDate.description,
        'milestone_reference': reviewDate.milestoneReference,
      }).toList();

      await _supabase
          .from('review_dates')
          .insert(reviewDatesData);

      // Actualizar el campo timeline del anteproyecto
      await _updateAnteprojectTimeline(anteprojectId, reviewDates);

      // Obtener el cronograma actualizado
      final updatedSchedule = await getScheduleByAnteproject(anteprojectId);
      if (updatedSchedule == null) {
        throw Exception('Error al actualizar el cronograma');
      }
      return updatedSchedule;
    } catch (e) {
      throw Exception('Error al actualizar cronograma: $e');
    }
  }

  /// Elimina un cronograma
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      // Eliminar fechas de revisión primero
      await _supabase
          .from('review_dates')
          .delete()
          .eq('schedule_id', scheduleId);

      // Eliminar el cronograma
      await _supabase
          .from('schedules')
          .delete()
          .eq('id', scheduleId);
    } catch (e) {
      throw Exception('Error al eliminar cronograma: $e');
    }
  }

  /// Genera fechas de revisión basadas en los hitos del anteproyecto
  List<ReviewDate> generateReviewDatesFromMilestones({
    required Anteproject anteproject,
    required DateTime startDate,
    required DateTime finalDate,
  }) {
    final reviewDates = <ReviewDate>[];
    final timeline = anteproject.timeline;
    
    if (timeline.isEmpty) {
      // Si no hay hitos, crear fechas por defecto
      reviewDates.addAll(_createDefaultReviewDates(startDate, finalDate));
      return reviewDates;
    }

    // Calcular intervalos basados en el número de hitos
    final totalDays = finalDate.difference(startDate).inDays;
    final intervalDays = (totalDays / (timeline.length + 1)).round();

    // Fecha de inicio
    reviewDates.add(ReviewDate(
      id: 0, // Temporal, se asignará al guardar
      scheduleId: 0, // Temporal
      date: startDate,
      description: 'Inicio del proyecto',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Fechas de revisión basadas en hitos
    int index = 0;
    for (final entry in timeline.entries) {
      final milestoneDate = startDate.add(Duration(days: (index + 1) * intervalDays));
      
      // Crear descripción basada en el hito
      String description;
      if (index == 0) {
        description = 'Revisión del esquema de datos y primer prototipo';
      } else if (index == 1) {
        description = 'Revisión de los hitos 1 y 2';
      } else if (index == timeline.length - 1) {
        description = 'Revisión de los hitos ${index + 1} y ${index + 2} y de las correcciones sobre los hitos anteriores';
      } else {
        description = 'Revisión del hito ${index + 1}: ${entry.key}';
      }

      reviewDates.add(ReviewDate(
        id: 0, // Temporal
        scheduleId: 0, // Temporal
        date: milestoneDate,
        description: description,
        milestoneReference: entry.key,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      index++;
    }

    // Fecha final
    reviewDates.add(ReviewDate(
      id: 0, // Temporal
      scheduleId: 0, // Temporal
      date: finalDate,
      description: 'Revisión final e indicaciones para presentación y exposición',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    return reviewDates;
  }

  /// Crea fechas de revisión por defecto cuando no hay hitos
  List<ReviewDate> _createDefaultReviewDates(DateTime startDate, DateTime finalDate) {
    final totalDays = finalDate.difference(startDate).inDays;
    final intervalDays = (totalDays / 4).round(); // 4 revisiones por defecto

    return [
      ReviewDate(
        id: 0,
        scheduleId: 0,
        date: startDate,
        description: 'Inicio del proyecto',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ReviewDate(
        id: 0,
        scheduleId: 0,
        date: startDate.add(Duration(days: intervalDays)),
        description: 'Revisión del esquema de datos y primer prototipo',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ReviewDate(
        id: 0,
        scheduleId: 0,
        date: startDate.add(Duration(days: intervalDays * 2)),
        description: 'Revisión de los hitos 1 y 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ReviewDate(
        id: 0,
        scheduleId: 0,
        date: startDate.add(Duration(days: intervalDays * 3)),
        description: 'Revisión de los hitos 3 y 4 y de las correcciones sobre los hitos 1 y 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ReviewDate(
        id: 0,
        scheduleId: 0,
        date: finalDate,
        description: 'Revisión final e indicaciones para presentación y exposición',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Actualiza el campo timeline del anteproyecto con las fechas de revisión
  Future<void> _updateAnteprojectTimeline(int anteprojectId, List<ReviewDate> reviewDates) async {
    try {
      // Crear el objeto timeline en formato JSON
      final timeline = <String, String>{};
      
      for (int i = 0; i < reviewDates.length; i++) {
        final reviewDate = reviewDates[i];
        final dateStr = '${reviewDate.date.day.toString().padLeft(2, '0')}/${reviewDate.date.month.toString().padLeft(2, '0')}/${reviewDate.date.year}';
        
        // Crear clave única para cada fecha
        final key = 'revision_${i + 1}';
        timeline[key] = '$dateStr: ${reviewDate.description}';
      }

      // Actualizar el campo timeline del anteproyecto
      await _supabase
          .from('anteprojects')
          .update({
            'timeline': timeline,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', anteprojectId);
    } catch (e) {
      // No lanzar excepción para no interrumpir el flujo principal
      // Solo loggear el error
      debugPrint('Error al actualizar timeline del anteproyecto: $e');
    }
  }
}
