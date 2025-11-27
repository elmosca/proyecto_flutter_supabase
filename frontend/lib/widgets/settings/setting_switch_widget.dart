import 'package:flutter/material.dart';
import '../../models/system_setting.dart';

/// Widget para editar configuraciones de tipo booleano (Switch)
class SettingSwitchWidget extends StatelessWidget {
  final SystemSetting setting;
  final ValueChanged<bool> onChanged;

  const SettingSwitchWidget({
    super.key,
    required this.setting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: SwitchListTile(
        title: Text(
          setting.key.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: setting.description != null
            ? Text(setting.description!)
            : null,
        value: setting.boolValue ?? false,
        onChanged: setting.isEditable ? onChanged : null,
        secondary: Icon(
          setting.boolValue == true ? Icons.check_circle : Icons.cancel,
          color: setting.boolValue == true ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
