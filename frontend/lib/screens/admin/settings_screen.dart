import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/system_setting.dart';
import '../../models/user.dart';
import '../../services/settings_service.dart';
import '../../widgets/navigation/persistent_scaffold.dart';
import '../../utils/app_exception.dart';
import '../../utils/error_translator.dart';
import '../../widgets/settings/setting_text_input_widget.dart';
import '../../widgets/settings/setting_number_input_widget.dart';
import '../../widgets/settings/setting_switch_widget.dart';
import '../../widgets/settings/setting_json_widget.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla de configuración del sistema para administradores
class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _service = SettingsService();
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  // Mapa para almacenar cambios pendientes
  final Map<String, dynamic> _pendingChanges = {};
  final Map<String, String> _validationErrors = {};

  Map<String, List<SystemSetting>> _settingsByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final categorized = await _service.getSettingsByCategory();
      if (mounted) {
        setState(() {
          _settingsByCategory = categorized;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final message = e is AppException
            ? ErrorTranslator.getFallbackMessage(e)
            : 'Error cargando configuraciones: $e';
        setState(() {
          _errorMessage = message;
          _loading = false;
        });

        // Mostrar error también en snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $message'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    // Validar antes de guardar
    final errors = _validateSettings();
    if (errors.isNotEmpty) {
      setState(() {
        _validationErrors.clear();
        _validationErrors.addAll(errors);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores antes de guardar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirmar antes de guardar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambios'),
        content: Text(
          '¿Está seguro de guardar ${_pendingChanges.length} configuración(es)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _saving = true;
      _validationErrors.clear();
    });

    try {
      await _service.updateSettings(_pendingChanges);

      if (mounted) {
        setState(() {
          _pendingChanges.clear();
          _saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuraciones guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar para obtener valores actualizados
        await _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        final message = e is AppException
            ? ErrorTranslator.getFallbackMessage(e)
            : 'Error guardando configuraciones: $e';
        setState(() {
          _errorMessage = message;
          _saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Map<String, String> _validateSettings() {
    final errors = <String, String>{};

    for (final entry in _pendingChanges.entries) {
      final key = entry.key;
      final value = entry.value;

      // Validaciones específicas por clave
      if (key == 'max_file_size_mb') {
        final intValue = value as int;
        if (intValue < 1 || intValue > 1000) {
          errors[key] = 'El tamaño debe estar entre 1 y 1000 MB';
        }
      } else if (key == 'max_project_duration_days') {
        final intValue = value as int;
        if (intValue < 30 || intValue > 1095) {
          errors[key] = 'La duración debe estar entre 30 y 1095 días';
        }
      } else if (key == 'institution_name') {
        final stringValue = value as String;
        if (stringValue.trim().isEmpty) {
          errors[key] = 'El nombre de la institución es obligatorio';
        }
        if (stringValue.length < 3 || stringValue.length > 255) {
          errors[key] = 'El nombre debe tener entre 3 y 255 caracteres';
        }
      } else if (key == 'allowed_file_types') {
        try {
          final jsonValue = value as String;
          jsonDecode(jsonValue); // Validar que es JSON válido
          // Validar que es un array
          final decoded = jsonDecode(jsonValue);
          if (decoded is! List) {
            errors[key] = 'Debe ser un array JSON';
          }
        } catch (e) {
          errors[key] = 'JSON inválido';
        }
      }
    }

    return errors;
  }

  void _handleSettingChange(String key, dynamic value) {
    setState(() {
      _pendingChanges[key] = value;
      // Limpiar error de validación si existe
      _validationErrors.remove(key);
    });
  }

  Widget _buildSettingsSection(String category, List<SystemSetting> settings) {
    if (settings.isEmpty) {
      return const SizedBox.shrink();
    }

    String title;
    IconData icon;

    switch (category) {
      case 'general':
        title = 'Configuración General';
        icon = Icons.info;
        break;
      case 'files':
        title = 'Configuración de Archivos';
        icon = Icons.folder;
        break;
      case 'projects':
        title = 'Configuración de Proyectos';
        icon = Icons.assignment;
        break;
      case 'features':
        title = 'Funcionalidades';
        icon = Icons.toggle_on;
        break;
      default:
        title = 'Otras Configuraciones';
        icon = Icons.settings;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text('${settings.length} configuración(es)'),
        initiallyExpanded: category == 'general',
        children: settings.map((setting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSettingWidget(setting),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingWidget(SystemSetting setting) {
    final errorText = _validationErrors[setting.key];
    final hasPendingChanges = _pendingChanges.containsKey(setting.key);

    switch (setting.type) {
      case SettingType.string:
        return SettingTextInputWidget(
          setting: setting.copyWith(
            value: hasPendingChanges
                ? _pendingChanges[setting.key].toString()
                : setting.value,
          ),
          onChanged: (value) => _handleSettingChange(setting.key, value),
          errorText: errorText,
        );

      case SettingType.integer:
        int? minValue;
        int? maxValue;
        String? unit;

        if (setting.key == 'max_file_size_mb') {
          minValue = 1;
          maxValue = 1000;
          unit = 'MB';
        } else if (setting.key == 'max_project_duration_days') {
          minValue = 30;
          maxValue = 1095;
          unit = 'días';
        }

        return SettingNumberInputWidget(
          setting: setting.copyWith(
            value: hasPendingChanges
                ? _pendingChanges[setting.key].toString()
                : setting.value,
          ),
          onChanged: (value) => _handleSettingChange(setting.key, value),
          minValue: minValue,
          maxValue: maxValue,
          unit: unit,
          errorText: errorText,
        );

      case SettingType.boolean:
        return SettingSwitchWidget(
          setting: setting.copyWith(
            value: hasPendingChanges
                ? (_pendingChanges[setting.key] as bool).toString()
                : setting.value,
          ),
          onChanged: (value) => _handleSettingChange(setting.key, value),
        );

      case SettingType.json:
        return SettingJsonWidget(
          setting: setting.copyWith(
            value: hasPendingChanges
                ? _pendingChanges[setting.key].toString()
                : setting.value,
          ),
          onChanged: (value) => _handleSettingChange(setting.key, value),
          errorText: errorText,
        );
    }
  }

  Widget _buildHistorySection() {
    final settingsWithHistory = _settingsByCategory.values
        .expand((settings) => settings)
        .where((s) => s.updatedBy != null)
        .toList();

    if (settingsWithHistory.isEmpty) {
      return const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: ExpansionTile(
          leading: Icon(Icons.history),
          title: Text('Historial de Cambios'),
          subtitle: Text('No hay modificaciones registradas'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aún no se han realizado modificaciones a las configuraciones.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.history),
        title: const Text('Historial de Cambios'),
        subtitle: Text(
          '${settingsWithHistory.length} configuración(es) modificada(s)',
        ),
        children: settingsWithHistory.map((setting) {
          return ListTile(
            leading: const Icon(Icons.edit, size: 20),
            title: Text(setting.key.replaceAll('_', ' ')),
            subtitle: Text(
              'Actualizado: ${setting.updatedAt.day}/${setting.updatedAt.month}/${setting.updatedAt.year} ${setting.updatedAt.hour}:${setting.updatedAt.minute.toString().padLeft(2, '0')}',
            ),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PersistentScaffold(
      title: l10n.systemSettings,
      titleKey: 'settings',
      user: widget.user,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _settingsByCategory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSettings,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Indicador de cambios pendientes
                if (_pendingChanges.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_pendingChanges.length} cambio(s) pendiente(s)',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _pendingChanges.clear();
                              _validationErrors.clear();
                            });
                          },
                          child: const Text('Descartar'),
                        ),
                      ],
                    ),
                  ),

                // Lista de configuraciones
                Expanded(
                  child: _settingsByCategory.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay configuraciones disponibles',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ..._settingsByCategory.entries.map(
                              (entry) =>
                                  _buildSettingsSection(entry.key, entry.value),
                            ),
                            _buildHistorySection(),
                          ],
                        ),
                ),

                // Botón de guardar
                if (_pendingChanges.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveSettings,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _saving ? 'Guardando...' : 'Guardar Cambios',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
