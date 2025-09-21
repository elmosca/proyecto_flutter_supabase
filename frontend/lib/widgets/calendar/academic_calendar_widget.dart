import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/user.dart';

class AcademicCalendarWidget extends StatefulWidget {
  final List<User> students;
  final Function(String) onYearSelected;
  final String? selectedYear;
  
  const AcademicCalendarWidget({
    super.key,
    required this.students,
    required this.onYearSelected,
    this.selectedYear,
  });

  @override
  State<AcademicCalendarWidget> createState() => _AcademicCalendarWidgetState();
}

class _AcademicCalendarWidgetState extends State<AcademicCalendarWidget> {
  late final ValueNotifier<List<User>> _selectedStudents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedAcademicYear;

  @override
  void initState() {
    super.initState();
    _selectedStudents = ValueNotifier(_getStudentsForDay(DateTime.now()));
    _selectedAcademicYear = widget.selectedYear ?? _getCurrentAcademicYear();
  }

  @override
  void dispose() {
    _selectedStudents.dispose();
    super.dispose();
  }

  String _getCurrentAcademicYear() {
    final now = DateTime.now();
    final year = now.year;
    if (now.month >= 9) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }

  List<String> _getAvailableAcademicYears() {
    final years = widget.students
        .map((s) => s.academicYear)
        .where((year) => year != null)
        .cast<String>()
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a)); // Ordenar de más reciente a más antiguo
    return years;
  }

  List<User> _getStudentsForDay(DateTime day) {
    if (_selectedAcademicYear == null) return [];
    
    return widget.students.where((student) {
      return student.academicYear == _selectedAcademicYear;
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedStudents.value = _getStudentsForDay(selectedDay);
    }
  }

  void _onYearChanged(String year) {
    setState(() {
      _selectedAcademicYear = year;
    });
    widget.onYearSelected(year);
    _selectedStudents.value = _getStudentsForDay(_selectedDay ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final availableYears = _getAvailableAcademicYears();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con selector de año
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Calendario Académico',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (availableYears.isNotEmpty) ...[
                  Text(
                    'Año:',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedAcademicYear,
                      underline: const SizedBox(),
                      items: availableYears.map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(
                            year,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _onYearChanged(newValue);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Calendario
            TableCalendar<User>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getStudentsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Información de estudiantes del año seleccionado
            if (_selectedAcademicYear != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Estudiantes del año $_selectedAcademicYear: ',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_getStudentsForDay(DateTime.now()).length}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Lista de estudiantes del día seleccionado
            ValueListenableBuilder<List<User>>(
              valueListenable: _selectedStudents,
              builder: (context, students, _) {
                if (students.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No hay estudiantes en este año académico',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estudiantes del año $_selectedAcademicYear:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getSpecialtyColor(student.specialty),
                              child: Text(
                                student.fullName.split(' ').map((n) => n[0]).take(2).join(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              student.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.email),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      student.specialty ?? 'Sin especialidad',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: student.status == UserStatus.active 
                                    ? Colors.green.shade100 
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                student.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: student.status == UserStatus.active 
                                      ? Colors.green.shade700 
                                      : Colors.red.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpecialtyColor(String? specialty) {
    switch (specialty?.toUpperCase()) {
      case 'DAM':
        return Colors.blue.shade600;
      case 'ASIR':
        return Colors.green.shade600;
      case 'DAW':
        return Colors.purple.shade600;
      case 'SMR':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
