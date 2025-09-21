class Schedule {
  final int id;
  final int anteprojectId;
  final int tutorId;
  final DateTime startDate;
  final List<ReviewDate> reviewDates;
  final DateTime finalDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Schedule({
    required this.id,
    required this.anteprojectId,
    required this.tutorId,
    required this.startDate,
    required this.reviewDates,
    required this.finalDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      anteprojectId: json['anteproject_id'],
      tutorId: json['tutor_id'],
      startDate: DateTime.parse(json['start_date']),
      reviewDates: (json['review_dates'] as List)
          .map((date) => ReviewDate.fromJson(date))
          .toList(),
      finalDate: DateTime.parse(json['final_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anteproject_id': anteprojectId,
      'tutor_id': tutorId,
      'start_date': startDate.toIso8601String(),
      'review_dates': reviewDates.map((date) => date.toJson()).toList(),
      'final_date': finalDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Schedule copyWith({
    int? id,
    int? anteprojectId,
    int? tutorId,
    DateTime? startDate,
    List<ReviewDate>? reviewDates,
    DateTime? finalDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      anteprojectId: anteprojectId ?? this.anteprojectId,
      tutorId: tutorId ?? this.tutorId,
      startDate: startDate ?? this.startDate,
      reviewDates: reviewDates ?? this.reviewDates,
      finalDate: finalDate ?? this.finalDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Schedule(id: $id, anteprojectId: $anteprojectId, tutorId: $tutorId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ReviewDate {
  final int id;
  final int scheduleId;
  final DateTime date;
  final String description;
  final String? milestoneReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewDate({
    required this.id,
    required this.scheduleId,
    required this.date,
    required this.description,
    this.milestoneReference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewDate.fromJson(Map<String, dynamic> json) {
    return ReviewDate(
      id: json['id'],
      scheduleId: json['schedule_id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      milestoneReference: json['milestone_reference'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'date': date.toIso8601String(),
      'description': description,
      'milestone_reference': milestoneReference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReviewDate copyWith({
    int? id,
    int? scheduleId,
    DateTime? date,
    String? description,
    String? milestoneReference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewDate(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      date: date ?? this.date,
      description: description ?? this.description,
      milestoneReference: milestoneReference ?? this.milestoneReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewDate(id: $id, date: $date, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewDate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
