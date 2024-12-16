
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
}
