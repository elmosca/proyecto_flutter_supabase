import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/system_setting.dart';

/// Widget para editar configuraciones de tipo JSON (especialmente para tipos de archivo)
class SettingJsonWidget extends StatefulWidget {
  final SystemSetting setting;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const SettingJsonWidget({
    super.key,
    required this.setting,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<SettingJsonWidget> createState() => _SettingJsonWidgetState();
}

class _SettingJsonWidgetState extends State<SettingJsonWidget> {
  late TextEditingController _controller;
  bool _isValidJson = true;

  @override
  void initState() {
    super.initState();
    // Formatear el JSON para mostrarlo de forma legible
    try {
      final decoded = jsonDecode(widget.setting.value);
      _controller = TextEditingController(
        text: const JsonEncoder.withIndent('  ').convert(decoded),
      );
    } catch (e) {
      _controller = TextEditingController(text: widget.setting.value);
    }
    _controller.addListener(_validateJson);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateJson() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _isValidJson = false);
      return;
    }

    try {
      jsonDecode(text);
      setState(() => _isValidJson = true);
      widget.onChanged(text);
    } catch (e) {
      setState(() => _isValidJson = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.setting.key.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.setting.description ?? widget.setting.key,
            hintText: 'Ingrese un JSON válido',
            errorText:
                widget.errorText ?? (_isValidJson ? null : 'JSON inválido'),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade50,
            helperText: 'Formato JSON (array o objeto)',
          ),
          maxLines: 6,
          enabled: widget.setting.isEditable,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        // Mostrar vista previa del JSON parseado
        if (_isValidJson && _controller.text.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'JSON válido',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
