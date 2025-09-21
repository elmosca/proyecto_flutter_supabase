import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  
  // Helper para crear estilos de texto con soporte Unicode
  static pw.TextStyle _textStyle({
    double fontSize = 12,
    pw.FontWeight? fontWeight,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
  
  /// Genera un PDF de ejemplo del anteproyecto para guía del estudiante
  static Future<Uint8List> generateAnteprojectExamplePdf() async {
    final pdf = pw.Document();
    
    // Configurar página
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildStudentInfo(),
            pw.SizedBox(height: 20),
            _buildTitle(),
            pw.SizedBox(height: 15),
            _buildProjectType(),
            pw.SizedBox(height: 15),
            _buildDescription(),
            pw.SizedBox(height: 15),
            _buildObjectives(),
            pw.SizedBox(height: 15),
            _buildExpectedResults(),
            pw.SizedBox(height: 15),
            _buildTimeline(),
            pw.SizedBox(height: 30),
            _buildSignatures(),
          ];
        },
      ),
    );
    
    return pdf.save();
  }
  
  /// Genera un PDF del anteproyecto del estudiante
  static Future<Uint8List> generateAnteprojectPdf({
    required String studentName,
    required String title,
    required String projectType,
    required String description,
    required String objectives,
    required Map<String, dynamic> expectedResults,
    required Map<String, dynamic> timeline,
    required String academicYear,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildStudentInfo(studentName: studentName, academicYear: academicYear),
            pw.SizedBox(height: 20),
            _buildTitle(title: title),
            pw.SizedBox(height: 15),
            _buildProjectType(projectType: projectType),
            pw.SizedBox(height: 15),
            _buildDescription(description: description),
            pw.SizedBox(height: 15),
            _buildObjectives(objectives: objectives),
            pw.SizedBox(height: 15),
            _buildExpectedResults(expectedResults: expectedResults),
            pw.SizedBox(height: 15),
            _buildTimeline(timeline: timeline),
            pw.SizedBox(height: 30),
            _buildSignatures(),
          ];
        },
      ),
    );
    
    return pdf.save();
  }
  
  /// Imprime o guarda el PDF
  static Future<void> printOrSavePdf(Uint8List pdfBytes, {String? fileName}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: fileName ?? 'anteproyecto_ejemplo.pdf',
    );
  }
  
  /// Guarda el PDF en el dispositivo
  static Future<String> savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }
  
  // Métodos privados para construir las secciones del PDF
  
  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
        pw.Text(
          'ANTEPROYECTO',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Trabajo de Fin de Ciclo Superior',
            style: const pw.TextStyle(
              fontSize: 16,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            'Desarrollo de Aplicaciones Multiplataforma',
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildStudentInfo({String? studentName, String? academicYear}) {
    final name = studentName ?? 'Juan Antonio Francés Pérez';
    final year = academicYear ?? '2025/2026';
    
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'El alumno $name, del CIFP Carlos III de Cartagena, matriculado durante el curso académico $year en el módulo de Proyecto del ciclo formativo de grado superior Desarrollo de Aplicaciones Multiplataforma (modalidad distancia), propone al tribunal para su aceptación la realización del siguiente proyecto:',
        style: const pw.TextStyle(fontSize: 12),
        textAlign: pw.TextAlign.justify,
      ),
    );
  }
  
  static pw.Widget _buildTitle({String? title}) {
    final projectTitle = title ?? 'Sistema de Seguimiento de Proyectos TFCGS - Ciclo DAM';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Título:',
          style: _textStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          projectTitle,
          style: _textStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  static pw.Widget _buildProjectType({String? projectType}) {
    final type = projectType ?? 'Proyecto de ejecución o realización de un producto.';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Tipo de proyecto:',
          style: _textStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          type,
          style: _textStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  static pw.Widget _buildDescription({String? description}) {
    final desc = description ?? 'El proyecto consiste en el desarrollo de una plataforma digital colaborativa para la planificación, seguimiento y evaluación de los Trabajos de Fin de Grado Ciclo Superior (TFGCS) en ciclos formativos de DAM. Utiliza un enfoque Kanban para la gestión de tareas, permitiendo la interacción entre administradores, tutores y alumnos.';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Descripción:',
          style: _textStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          desc,
          style: _textStyle(fontSize: 12),
          textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }
  
  static pw.Widget _buildObjectives({String? objectives}) {
    final obj = objectives ?? '''• Consolidar los conocimientos adquiridos durante el ciclo sobre herramientas de desarrollo y técnicas de análisis y diseño de aplicaciones.
• Llevar a cabo el análisis de requisitos previo al desarrollo, atendiendo a necesidades reales de planificación y seguimiento de proyectos académicos.
• Elegir herramientas modernas para una solución fullstack (Spring Boot, Flutter, PostgreSQL, Docker).
• Implementar el esquema relacional del proyecto y su persistencia con PostgreSQL.''';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Objetivos:',
          style: _textStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          obj,
          style: _textStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  static pw.Widget _buildExpectedResults({Map<String, dynamic>? expectedResults}) {
    final results = expectedResults ?? {
      'hito1': 'Análisis y Diseño + Infraestructura Base',
      'hito2': 'Sistema de Autenticación y Gestión de Usuarios',
      'hito3': 'Gestión de Proyectos y Tareas',
      'hito4': 'Funcionalidades Colaborativas y Finalización',
    };
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resultados esperados (Hitos):',
          style: _textStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        ...results.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Text(
            '${entry.key}: ${entry.value}',
            style: _textStyle(fontSize: 12),
          ),
        )),
      ],
    );
  }
  
  static pw.Widget _buildTimeline({Map<String, dynamic>? timeline}) {
    final time = timeline ?? {
      '17/03/2025': 'Inicio',
      '15/04/2025': 'Revisión del esquema de datos y primer prototipo',
      '15/05/2025': 'Revisión de los hitos 1 y 2',
      '01/06/2025': 'Revisión de los hitos 3 y 4 y de las correcciones sobre los hitos 1 y 2',
      '08/06/2025': 'Revisión final e indicaciones para presentación y exposición',
    };
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Temporalización inicial:',
          style: _textStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        ...time.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Text(
            '${entry.key}: ${entry.value}',
            style: _textStyle(fontSize: 12),
          ),
        )),
      ],
    );
  }
  
  static pw.Widget _buildSignatures() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 20),
        pw.Text(
          'En Cartagena, a ${_getCurrentDate()}.',
          style: _textStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Text(
                  'Firma de los alumnos',
                  style: _textStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 150,
                  height: 1,
                  color: PdfColors.black,
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Text(
                  'Firma del tutor colectivo',
                  style: _textStyle(fontSize: 12),
                ),
                pw.Text(
                  'en representación del equipo docente',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: 150,
                  height: 1,
                  color: PdfColors.black,
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.Text(
            'Sello de la secretaría del centro (con fecha)',
            style: _textStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
  
  static String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${now.day} de ${months[now.month - 1]} de ${now.year}';
  }
}
