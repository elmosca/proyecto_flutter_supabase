import 'package:flutter/material.dart';
import '../../widgets/files/file_upload_widget.dart';

class FileUploadScreen extends StatelessWidget {
  final String attachableType;
  final int attachableId;

  const FileUploadScreen({
    super.key,
    required this.attachableType,
    required this.attachableId,
  });

  @override
  Widget build(BuildContext context) {
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
