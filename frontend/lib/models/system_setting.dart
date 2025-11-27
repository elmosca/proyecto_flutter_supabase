import 'dart:convert';

/// Modelo que representa una configuración del sistema
class SystemSetting {
  final int id;
  final String key;
  final String value;
  final SettingType type;
  final String? description;
  final bool isEditable;
  final int? updatedBy;
  final DateTime updatedAt;

  const SystemSetting({
    required this.id,
    required this.key,
    required this.value,
    required this.type,
    this.description,
    required this.isEditable,
    this.updatedBy,
    required this.updatedAt,
  });

  /// Crea un SystemSetting desde un JSON
  factory SystemSetting.fromJson(Map<String, dynamic> json) {
    return SystemSetting(
      id: json['id'] as int,
      key: json['setting_key'] as String,
      value: json['setting_value'] as String,
      type: SettingType.fromString(json['setting_type'] as String),
      description: json['description'] as String?,
      isEditable: json['is_editable'] as bool? ?? true,
      updatedBy: json['updated_by'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte un SystemSetting a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setting_key': key,
      'setting_value': value,
      'setting_type': type.name,
      'description': description,
      'is_editable': isEditable,
      'updated_by': updatedBy,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Obtiene el valor como String
  String? get stringValue {
    if (type == SettingType.string || type == SettingType.json) {
      return value;
    }
    return null;
  }

  /// Obtiene el valor como int
  int? get intValue {
    if (type == SettingType.integer) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Obtiene el valor como bool
  bool? get boolValue {
    if (type == SettingType.boolean) {
      return value.toLowerCase() == 'true' ||
          value == '1' ||
          value.toLowerCase() == 'yes';
    }
    return null;
  }

  /// Obtiene el valor como JSON (Map)
  Map<String, dynamic>? get jsonValue {
    if (type == SettingType.json) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Obtiene el valor como JSON (List)
  List<dynamic>? get jsonListValue {
    if (type == SettingType.json) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded;
        }
        return null;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Crea una copia del SystemSetting con valores modificados
  SystemSetting copyWith({
    int? id,
    String? key,
    String? value,
    SettingType? type,
    String? description,
    bool? isEditable,
    int? updatedBy,
    DateTime? updatedAt,
  }) {
    return SystemSetting(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      isEditable: isEditable ?? this.isEditable,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Enum para los tipos de configuración
enum SettingType {
  string('string'),
  integer('integer'),
  boolean('boolean'),
  json('json');

  final String name;
  const SettingType(this.name);

  static SettingType fromString(String value) {
    return SettingType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => SettingType.string,
    );
  }
}

/// Extension para obtener etiquetas en español
extension SettingTypeExtension on SettingType {
  String get displayName {
    switch (this) {
      case SettingType.string:
        return 'Texto';
      case SettingType.integer:
        return 'Número';
      case SettingType.boolean:
        return 'Booleano';
      case SettingType.json:
        return 'JSON';
    }
  }
}
