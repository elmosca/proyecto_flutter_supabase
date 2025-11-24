import 'package:flutter/material.dart';
import '../../models/system_setting.dart';

/// Widget para editar configuraciones de tipo número entero
class SettingNumberInputWidget extends StatelessWidget {
  final SystemSetting setting;
  final ValueChanged<int> onChanged;
  final int? minValue;
  final int? maxValue;
  final String? errorText;
  final String? unit; // Ej: "MB", "días", etc.

  const SettingNumberInputWidget({
    super.key,
    required this.setting,
    required this.onChanged,
    this.minValue,
    this.maxValue,
    this.errorText,
    this.unit,
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
          initialValue: setting.intValue?.toString() ?? '',
          decoration: InputDecoration(
            labelText: setting.description ?? setting.key,
            hintText: 'Ingrese un número${unit != null ? ' en $unit' : ''}',
            errorText: errorText,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixText: unit,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null) {
              onChanged(intValue);
            }
          },
          enabled: setting.isEditable,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio';
            }
            final intValue = int.tryParse(value);
            if (intValue == null) {
              return 'Debe ser un número válido';
            }
            if (minValue != null && intValue < minValue!) {
              return 'El valor mínimo es $minValue';
            }
            if (maxValue != null && intValue > maxValue!) {
              return 'El valor máximo es $maxValue';
            }
            return null;
          },
        ),
        if (minValue != null || maxValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Rango permitido: ${minValue ?? '∞'} - ${maxValue ?? '∞'}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }
}
