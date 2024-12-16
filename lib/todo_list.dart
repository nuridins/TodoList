import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<String> currentTodoList = [];
  final TextEditingController textField = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  Future<void> getTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTodoList = prefs.getString('todos');
    if (cachedTodoList != null) {
      setState(() {
        currentTodoList.addAll(List<String>.from(jsonDecode(cachedTodoList)));
      });
    }
  }

  Future<void> storeTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', jsonEncode(currentTodoList));
  }

  void _addTodo() {
    final text = textField.text;
    if (text.isNotEmpty) {
      setState(() {
        currentTodoList.add(text);
      });
      textField.clear();
      storeTodoList();
    }
  }

  void _removeTodoAt(int index) {
    setState(() {
      currentTodoList.removeAt(index);
    });
    storeTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textField,
                    decoration: const InputDecoration(
                      labelText: 'Add a todo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentTodoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(currentTodoList[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeTodoAt(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}