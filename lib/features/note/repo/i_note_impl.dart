import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_app_with_firebase/features/note/data/inote_facade.dart';
import 'package:expense_app_with_firebase/features/note/data/model/note_model.dart';
import 'package:expense_app_with_firebase/general/failures/main_failures.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: InoteFacade)
class InoteImpl implements InoteFacade {
  final FirebaseFirestore firebaseFirestore;
  InoteImpl(this.firebaseFirestore);
  @override
  Future<Either<MainFailure, NoteModel>> addNotes(
      {required NoteModel notemodel, required String expenseId}) async {
    try {
      final expenseRef = firebaseFirestore.collection('expense').doc(expenseId);

      final noteId = const Uuid().v4();

      await expenseRef.update({
        'notes.$noteId': notemodel.copyWith(id: noteId).toMap(),
      });

      return right(notemodel.copyWith(id: noteId));
    } catch (e) {
      return left(MainFailure.serverFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, List<NoteModel>>> fetchNotes(
      {required String expenseId}) async {
    try {
      final expenseDoc =
          await firebaseFirestore.collection('expense').doc(expenseId).get();

      if (expenseDoc.exists) {
        final expensData = expenseDoc.data();
        log('expenseData : ${expensData.toString()}');

        final Map<String, dynamic> noteMap =
            Map<String, dynamic>.from(expensData?['notes'] ?? {});
        log('NoteMap : ${noteMap.toString()}');

        final List<NoteModel> noteList = [];

        noteMap.forEach((key, value) {
          log('Note Data (key: $key): $value');
          final note = NoteModel.fromMap(value);
          noteList.add(note);
          log('length : ${noteList.length}');
        });
        log('right');
        return right(noteList);
      } else {
        return right([]);
      }
    } catch (e) {
      return left(MainFailure.serverFailure(errorMessage: e.toString()));
    }
  }

  @override
  void clearData() {}

  @override
  Future<Either<MainFailure, void>> updateStock(
      {required String expenseId,
      required String noteId,
      required int stock}) async {
    try {
      final expenseRef = firebaseFirestore.collection('expense').doc(expenseId);

      await expenseRef.update({
        'notes.$noteId.stock': FieldValue.increment(stock),
      });

      return right(null);
    } catch (e) {
      return left(MainFailure.serverFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, void>> deleteNote(
      {required String expenseId, required String noteId}) async {
    try {
      final expenseRef = firebaseFirestore.collection('expense').doc(expenseId);
      await expenseRef.update({
        'notes.$noteId': FieldValue.delete(),
      });

      return right(null);
    } catch (e) {
      return left(MainFailure.serverFailure(errorMessage: e.toString()));
    }
  }
}
