import 'package:dartz/dartz.dart';
import 'package:expense_app_with_firebase/features/note/data/model/note_model.dart';
import 'package:expense_app_with_firebase/general/failures/main_failures.dart';

abstract class InoteFacade {
  Future<Either<MainFailure,NoteModel>> addNotes({required NoteModel notemodel,required String expenseId})async{
    throw UnimplementedError('error');
  }
}