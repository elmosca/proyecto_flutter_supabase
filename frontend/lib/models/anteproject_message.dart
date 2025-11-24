import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'anteproject_message.g.dart';

@JsonSerializable()
class AnteprojectMessage {
  final int id;
  @JsonKey(name: 'anteproject_id')
  final int anteprojectId;
  @JsonKey(name: 'sender_id')
  final int senderId;
  final String content;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // Relación con el remitente
  final User? sender;

  const AnteprojectMessage({
    required this.id,
    required this.anteprojectId,
    required this.senderId,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory AnteprojectMessage.fromJson(Map<String, dynamic> json) {
    // Crear una copia del JSON para no modificar el original
    final jsonCopy = Map<String, dynamic>.from(json);
    
    // Parsear el objeto sender si viene anidado
    User? senderUser;
    if (jsonCopy['sender'] != null) {
      final senderRaw = jsonCopy['sender'];
      
      if (senderRaw is User) {
        // Ya es un objeto User, guardarlo y removerlo del JSON
        senderUser = senderRaw;
        jsonCopy['sender'] = null;
      } else if (senderRaw is Map) {
        // Convertir a Map<String, dynamic> de forma segura
        Map<String, dynamic> senderData;
        
        if (senderRaw is Map<String, dynamic>) {
          senderData = senderRaw;
        } else {
          senderData = <String, dynamic>{};
          for (final key in senderRaw.keys) {
            final value = senderRaw[key];
            senderData[key.toString()] = value;
          }
        }
        
        try {
          senderUser = User.fromJson(senderData);
          jsonCopy['sender'] = null; // Remover para que el código generado no lo procese
        } catch (e) {
          debugPrint('⚠️ Error parseando sender: $e');
          jsonCopy['sender'] = null;
        }
      } else {
        // Si no es ni User ni Map, limpiarlo
        debugPrint('⚠️ sender tiene tipo inesperado: ${senderRaw.runtimeType}');
        jsonCopy['sender'] = null;
      }
    }
    
    // Llamar al código generado sin el sender
    final message = _$AnteprojectMessageFromJson(jsonCopy);
    
    // Si tenemos un sender parseado, crear un nuevo mensaje con él
    if (senderUser != null) {
      return AnteprojectMessage(
        id: message.id,
        anteprojectId: message.anteprojectId,
        senderId: message.senderId,
        content: message.content,
        isRead: message.isRead,
        readAt: message.readAt,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        sender: senderUser,
      );
    }
    
    return message;
  }

  Map<String, dynamic> toJson() => _$AnteprojectMessageToJson(this);

  AnteprojectMessage copyWith({
    int? id,
    int? anteprojectId,
    int? senderId,
    String? content,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? sender,
  }) {
    return AnteprojectMessage(
      id: id ?? this.id,
      anteprojectId: anteprojectId ?? this.anteprojectId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
    );
  }
}

