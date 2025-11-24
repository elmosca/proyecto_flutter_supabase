import 'package:flutter/material.dart';
import '../../models/system_setting.dart';

/// Widget para editar configuraciones de tipo texto
class SettingTextInputWidget extends StatelessWidget {
  final SystemSetting setting;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const SettingTextInputWidget({
    super.key,
    required this.setting,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          setting.key.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: setting.stringValue ?? '',
          decoration: InputDecoration(
            labelText: setting.description ?? setting.key,
            hintText: 'Ingrese el valor',
            errorText: errorText,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: onChanged,
          enabled: setting.isEditable,
          maxLines: setting.key.contains('address') ? 2 : 1,
        ),
      ],
    );
  }
}
