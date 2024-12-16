
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_app_with_firebase/features/expense/data/expense_model.dart';
import 'package:expense_app_with_firebase/features/expense/data/model/iexpense_facade.dart';
import 'package:expense_app_with_firebase/general/failures/main_failures.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IexpenseFacade)
class IexpenseImpl implements IexpenseFacade {
  final FirebaseFirestore firebaseFirestore;
  IexpenseImpl(this.firebaseFirestore);

  DocumentSnapshot? lastDocument;
  bool noMoreDAta = false;

  @override
  Future<Either<MainFailure, ExpenseModel>> addExpenses(
      {required ExpenseModel expenseModel}) async {
    try {
      final expenseDoc = firebaseFirestore.collection('expense').doc();
      final id = expenseDoc.id;
      final expense = expenseModel.copyWith(id: id);

      final generalDoc = firebaseFirestore.collection('general').doc('count');

      final batch = firebaseFirestore.batch();

      batch.set(expenseDoc, expense.toMap());
     

      batch.update(generalDoc, {'count': FieldValue.increment(1)});

      batch.commit();
      return right(expense);
    } catch (e) {
      return left(MainFailure.serverFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<MainFailure, List<ExpenseModel>>> fetchExpenses() async {
    if (noMoreDAta) return right([]);
    try {
      Query query = firebaseFirestore
          .collection('expense')
          .orderBy('title', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      QuerySnapshot querySnapshot = await query.limit(10).get();

      if (querySnapshot.docs.length < 10) {
        noMoreDAta = true;
      } else {
        lastDocument = querySnapshot.docs.last;
      }

      final newList = querySnapshot.docs
          .map(
              (exp) => ExpenseModel.fromMap(exp.data() as Map<String, dynamic>))
          .toList();

      return right(newList);
    } catch (e) {
      return left(MainFailure.serverFailure(errorMessage: e.toString()));
    }
  }
}
