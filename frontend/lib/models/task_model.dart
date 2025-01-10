import 'dart:convert';
import 'dart:ui';

import 'package:frontend/core/constants/utils.dart';

class TaskModel {
  String? mongoId;
  final String id;
  final String title;
  final String description;
  final Color color;
  final DateTime dueAt;
  final DateTime createdAt;
  final String userId;
  final DateTime updatedAt;
  final int isSynced;

  TaskModel({
    this.mongoId,
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.dueAt,
    required this.isSynced,
  });

  TaskModel copyWith({
    String? mongoId,
    String? id,
    String? uid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    Color? color,
    int? isSynced,
  }) {
    return TaskModel(
      mongoId: mongoId ?? this.mongoId,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      color: color ?? this.color,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mongoId': mongoId,
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueAt': dueAt.toIso8601String(),
      'hexColor': rgbToHex(color),
      'isSynced': isSynced,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      mongoId: map['mongoId'] ?? '',
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      dueAt: DateTime.parse(map['dueAt']),
      color: hexToRgb(map['hexColor']),
      isSynced: map['isSynced'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TaskModel(id: $id, uid: $userId, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, dueAt: $dueAt, color: $color)';
  }

  @override
  bool operator ==(covariant TaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dueAt == dueAt &&
        other.color == color &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        dueAt.hashCode ^
        color.hashCode ^
        isSynced.hashCode;
  }
}
