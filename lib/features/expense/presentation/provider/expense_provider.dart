import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app_with_firebase/features/expense/data/expense_model.dart';
import 'package:expense_app_with_firebase/features/expense/data/model/iexpense_facade.dart';
import 'package:flutter/material.dart';

class ExpenseProvider with ChangeNotifier {
  final IexpenseFacade iexpenseFacade;
  ExpenseProvider({required this.iexpenseFacade});
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  bool isAmountType = false;
  bool isLoading = false;
  bool noMoreData = false;

  List<ExpenseModel> expenseList = [];
  DocumentSnapshot? lastDocument;
  int expenseCount = 0;
  num totalAmount = 0;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? countListner;

  Future<void> addExpense() async {
    final title = titleController.text.trim();
    final amount = int.tryParse(amountController.text.trim());

    final result = await iexpenseFacade.addExpenses(
        expenseModel: ExpenseModel(
            title: title, amount: amount!, amountType: isAmountType));

    result.fold(
      (failure) {
        log(failure.errorMessage);
      },
      (success) {
        log('add expens succesfully');
        addLocally(success);
      },
    );
    // try {
    //   final amount = int.tryParse(amountController.text.trim());
    //   if (amount == null) {
    //     throw Exception("Invalid amount");
    //   }

    //   final expenseModel = ExpenseModel(
    //     title: titleController.text.trim(),
    //     amount: amount,
    //     amountType: isAmountType,
    //   );

    //   final expenseDoc = firebaseFirestore.collection('expense').doc();
    //   final id = expenseDoc.id;
    //   final expense = expenseModel.copyWith(id: id);

    //   final generalDoc = firebaseFirestore.collection('general').doc('count');

    //   final batch = firebaseFirestore.batch();

    //   batch.set(expenseDoc, expense.toMap());
    //   addLocally(expense);

    //   batch.update(generalDoc, {'count': FieldValue.increment(1)});

    //   await batch.commit();

    //   log('Expense added successfully');
    // } catch (e) {
    //   log('Error adding expense: $e');
    // }
  }

  void toggle(bool value) {
    isAmountType = value;
    notifyListeners();
  }

  Future<void> getExpenses() async {
    if(isLoading||noMoreData)return;
    isLoading = true;
    notifyListeners();
    final result = await iexpenseFacade.fetchExpenses();

    result.fold(
      (failure) {
        log(failure.errorMessage);
      },
      (success) {
        expenseList.addAll(success);
        for (var element in success) {
          if (element.amountType) {
            totalAmount += element.amount;
          } else {
            totalAmount -= element.amount;
          }
        }
      },
    );

    isLoading = false;
    notifyListeners();

    // try {
    //   Query query = firebaseFirestore
    //       .collection('expense')
    //       .orderBy('title', descending: false);

    //   if (lastDocument != null) {
    //     query = query.startAfterDocument(lastDocument!);
    //   }
    //   QuerySnapshot querySnapshot = await query.limit(10).get();

    //   if (querySnapshot.docs.length < 10) {
    //     noMoreData = true;
    //   } else {
    //     lastDocument = querySnapshot.docs.last;
    //   }

    //   final newList = querySnapshot.docs
    //       .map(
    //           (exp) => ExpenseModel.fromMap(exp.data() as Map<String, dynamic>))
    //       .toList();

    //   expenseList.addAll(newList);
    //   calculateExpenses();
    // } catch (e) {
    //   log(e.toString());
    // } finally {
    //   isLoading = false;
    //   notifyListeners();
    // }
  }

  Future<void> initializeCount() async {
    countListner = firebaseFirestore
        .collection('general')
        .doc('count')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        expenseCount = snapshot.data()?['count'] ?? 0;
        notifyListeners();
      }
    });
  }

  void addLocally(ExpenseModel expense) {
    expenseList.insert(0, expense);
    notifyListeners();
  }

  void clearController() {
    titleController.clear();
    amountController.clear();
  }

  void calculateExpenses() {
    for (var amount in expenseList) {
      if (amount.amountType) {
        totalAmount += amount.amount;
      } else {
        totalAmount -= amount.amount;
      }
    }
    notifyListeners();
  }
}
