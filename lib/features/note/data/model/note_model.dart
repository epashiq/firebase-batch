// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String expenseId;
  String? id;
  String note;
  Timestamp createdAt;
  int stock;
  NoteModel({
    required this.expenseId,
    this.id,
    required this.note,
    required this.createdAt,
    required this.stock,
  });

  NoteModel copyWith({
    String? expenseId,
    String? id,
    String? note,
    Timestamp? createdAt,
    int? stock,
  }) {
    return NoteModel(
      expenseId: expenseId ?? this.expenseId,
      id: id ?? this.id,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expenseId': expenseId,
      'id': id,
      'note': note,
      'createdAt': createdAt,
      'stock': stock,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      expenseId: map['expenseId'] as String,
      id: map['id'] != null ? map['id'] as String : null,
      note: map['note'] as String,
      createdAt: map['createdAt'] as Timestamp,
      stock: map['stock'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
