import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app_with_firebase/features/note/data/inote_facade.dart';
import 'package:expense_app_with_firebase/features/note/data/model/note_model.dart';
import 'package:flutter/material.dart';

class NoteProvider with ChangeNotifier {
  final InoteFacade inoteFacade;
  NoteProvider({required this.inoteFacade});
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final noteController = TextEditingController();
  final stockController = TextEditingController();

  Future<void> addNotes({
    required String expenseId,
  }) async {
    final stock = int.tryParse(stockController.text.trim());
    final result = await inoteFacade.addNotes(
        notemodel: NoteModel(
            expenseId: expenseId,
            note: noteController.text,
            createdAt: Timestamp.now(),
            stock: stock!),
        expenseId: expenseId);

        result.fold((failure) {
          log(failure.errorMessage);
        }, (success) {
          log(success.toString());
        },);
  }
}
