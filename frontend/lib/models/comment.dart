import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final int taskId;
  final int authorId;
  final String content;
  final bool isInternal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? author;

  const Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.content,
    required this.isInternal,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  Comment copyWith({
    int? id,
    int? taskId,
    int? authorId,
    String? content,
    bool? isInternal,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? author,
  }) {
    return Comment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      isInternal: isInternal ?? this.isInternal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, taskId: $taskId, authorId: $authorId, isInternal: $isInternal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
