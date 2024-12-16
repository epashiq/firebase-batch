import 'package:expense_app_with_firebase/features/expense/data/model/iexpense_facade.dart';
import 'package:expense_app_with_firebase/features/expense/presentation/provider/expense_provider.dart';
import 'package:expense_app_with_firebase/features/expense/presentation/view/add_expense_page.dart';
import 'package:expense_app_with_firebase/features/note/data/inote_facade.dart';
import 'package:expense_app_with_firebase/features/note/presentation/provider/note_provider.dart';
import 'package:expense_app_with_firebase/general/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependency();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider(iexpenseFacade: sl<IexpenseFacade>())),
        ChangeNotifierProvider(create: (_) => NoteProvider(inoteFacade: sl<InoteFacade>()))
        ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AddExpensePage(),
      ),
    );
  }
}
