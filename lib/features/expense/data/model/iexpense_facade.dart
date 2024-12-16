import 'package:dartz/dartz.dart';
import 'package:expense_app_with_firebase/features/expense/data/expense_model.dart';
import 'package:expense_app_with_firebase/general/failures/main_failures.dart';


abstract class IexpenseFacade {

  Future<Either<MainFailure,ExpenseModel>> addExpenses({required ExpenseModel expenseModel})async{
    throw UnimplementedError('error');
  }

  Future<Either<MainFailure,List<ExpenseModel>>> fetchExpenses()async{
    throw UnimplementedError('error');
  }
}