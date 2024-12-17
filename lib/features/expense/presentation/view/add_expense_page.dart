import 'package:expense_app_with_firebase/features/expense/presentation/provider/expense_provider.dart';
import 'package:expense_app_with_firebase/features/note/presentation/view/note_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      expenseProvider.getExpenses();
      expenseProvider.initializeCount();
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!expenseProvider.isLoading && !expenseProvider.noMoreData) {
          expenseProvider.getExpenses();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses : ${expenseProvider.expenseCount.toString()}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, wordSpacing: 2),
            ),
            RichText(
                text: TextSpan(
                    text: 'Total Amount :',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                  TextSpan(
                      text: expenseProvider.totalAmount.toString(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: expenseProvider.totalAmount >= 0
                              ? Colors.green
                              : Colors.red))
                ])),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Consumer<ExpenseProvider>(
                builder: (context, expProvider, child) {
                  if (expProvider.isLoading &&
                      expProvider.expenseList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (expProvider.expenseList.isEmpty) {
                    return const Center(child: Text('No expenses available'));
                  } else {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: expProvider.expenseList.length,
                      itemBuilder: (context, index) {
                        final exp = expenseProvider.expenseList[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  NotePage(expenseId: exp.id!,)
                                ));
                          },
                          child: Card.outlined(
                            elevation: 5,
                            child: ListTile(
                                title: Text(exp.title),
                                subtitle: Text(exp.amount.toString()),
                                trailing: Text(
                                  exp.amountType ? 'Credit' : 'Debit',
                                  style: TextStyle(
                                      color: exp.amountType
                                          ? Colors.green
                                          : Colors.red),
                                )),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add Expense"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: expenseProvider.titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: expenseProvider.amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: Text(
                        expenseProvider.isAmountType ? "Credit" : "Debit",
                      ),
                      value: expenseProvider.isAmountType,
                      onChanged: (value) {
                        expenseProvider.toggle(value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await expenseProvider.addExpense();
                      expenseProvider.clearController();

                      Navigator.pop(context);
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
