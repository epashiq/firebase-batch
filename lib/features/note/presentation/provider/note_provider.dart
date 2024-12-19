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
  final stockUpdateController = TextEditingController();

  List<NoteModel> noteList = [];

  bool isFetching = false;
  bool isIncrease = true;

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

    result.fold(
      (failure) {
        log(failure.errorMessage);
      },
      (success) {
        log(success.toString());
      },
    );
  }

  Future<void> fetchNoted({required String expenseId}) async {
    isFetching = true;
    notifyListeners();
    final result = await inoteFacade.fetchNotes(expenseId: expenseId);

    result.fold(
      (failure) {
        log(failure.errorMessage);
      },
      (success) {
        for (var element in success) {
          log('noteId : ${element.id},\nnote : ${element.note},\nstock : ${element.stock},\ncreatedAt: ${element.createdAt}');
        }
        noteList.clear();
        noteList.addAll(success);
      },
    );

    isFetching = false;
    notifyListeners();
  }

  void clearNoteList() {
    inoteFacade.clearData();
    noteList = [];
    notifyListeners();
  }

  Future<void> updateStock(
      {required String expenseId,
      required String noteId,
      required int stock}) async {
    final result = await inoteFacade.updateStock(
        expenseId: expenseId, noteId: noteId, stock: stock);

    result.fold(
      (failure) {
        log(failure.errorMessage);
      },
      (success) async {
        log('stock updated succesfully');
        await fetchNoted(expenseId: expenseId);
      },
    );

    notifyListeners();
  }

  Future<void> deleteNote(
      {required String expenseId, required String noteId}) async {
    final results =
        await inoteFacade.deleteNote(expenseId: expenseId, noteId: noteId);

    results.fold(
      (failure) {
        log(failure.errorMessage);
      },
      (success) {
        noteList.removeWhere((note) => note.id == noteId);
        log('delete note');
      },
    );

    notifyListeners();
  }

  void toggle(bool value) {
    isIncrease = !isIncrease;
    log("isIncrease: $isIncrease");
    notifyListeners();
  }

  void clearController() {
    noteController.clear();
    stockController.clear();
    stockUpdateController.clear();
    notifyListeners();
  }
}
