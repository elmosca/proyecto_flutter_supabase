import 'package:flutter/material.dart';
import '../../widgets/files/file_upload_widget.dart';

class FileUploadScreen extends StatelessWidget {
  const FileUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos de navegación
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final attachableType = args['attachableType'] as String;
    final attachableId = args['attachableId'] as int;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: FileUploadWidget(
          attachableType: attachableType,
          attachableId: attachableId,
        ),
      ),
    );
  }
}
