import 'package:dartz/dartz.dart';
import 'package:expense_app_with_firebase/features/note/data/model/note_model.dart';
import 'package:expense_app_with_firebase/general/failures/main_failures.dart';

abstract class InoteFacade {
  Future<Either<MainFailure,NoteModel>> addNotes({required NoteModel notemodel,required String expenseId})async{
    throw UnimplementedError('not adding notes');
  }

  Future<Either<MainFailure,List<NoteModel>>> fetchNotes({required String expenseId})async{
    throw UnimplementedError('not fetching notes');
  }
  void clearData();

  Future<Either<MainFailure,void>> updateStock({required String expenseId,required String noteId,required int stock})async{
    throw UnimplementedError('not Updating stock');
  }
}