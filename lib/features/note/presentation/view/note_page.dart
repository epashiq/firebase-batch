// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:expense_app_with_firebase/features/note/presentation/view/widgets/pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:expense_app_with_firebase/features/note/presentation/provider/note_provider.dart';

class NotePage extends StatefulWidget {
  final String expenseId;

  const NotePage({
    super.key,
    required this.expenseId,
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  void initState() {
    super.initState();
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      noteProvider.fetchNoted(expenseId: widget.expenseId);
      noteProvider.clearNoteList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isFetching) {
            return const LinearProgressIndicator();
          } else if (noteProvider.noteList.isEmpty) {
            return const Text('No notes found');
          } else {
            return ListView.builder(
              itemCount: noteProvider.noteList.length,
              itemBuilder: (context, index) {
                final note = noteProvider.noteList[index];
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                              noteProvider.isIncrease ? 'increse' : 'decrease'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: noteProvider.stockUpdateController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                    hintText: 'update your stock',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.remove),
                                  Expanded(
                                    child: Consumer<NoteProvider>(
                                        builder: (context, provider, c) {
                                      return SwitchListTile(
                                          value: provider.isIncrease,
                                          onChanged: (value) {
                                            log("$value");
                                            log("OOOO : ${noteProvider.isIncrease}");
                                            provider.toggle(value);
                                            log("OOOO : ${noteProvider.isIncrease}");
                                          });
                                    }),
                                  ),
                                  const Icon(Icons.add)
                                ],
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
                                int stockChange = int.tryParse(noteProvider
                                        .stockUpdateController.text) ??
                                    0;
                                if (!noteProvider.isIncrease) {
                                  stockChange = -stockChange;
                                }
                                PopScopeLoad.addShowDialog(
                                    context, 'stock Updated');
                                await noteProvider.updateStock(
                                    expenseId: widget.expenseId,
                                    noteId: note.id ?? '',
                                    stock: stockChange);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                noteProvider.clearController();
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.note,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Stock : ${note.stock.toString()}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                              onPressed: () {
                                noteProvider.deleteNote(
                                    expenseId: widget.expenseId,
                                    noteId: note.id!);
                              },
                              child: const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text('delete')))
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
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
                      controller: noteProvider.noteController,
                      decoration: InputDecoration(
                        labelText: "note",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteProvider.stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "stock",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                      noteProvider.addNotes(expenseId: widget.expenseId);
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
