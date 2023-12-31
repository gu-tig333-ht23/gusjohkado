import 'package:flutter/material.dart';
import 'api_manager.dart';
import 'todo_input_page.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

enum TodoFilter { all, done, notDone }

class _TodoListPageState extends State<TodoListPage> {
  TodoFilter currentFilter = TodoFilter.all;
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      _todos = await apiManager.getTodos();
      setState(() {});
    } catch (e) {
      // Errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _todos.where((todo) {
      switch (currentFilter) {
        case TodoFilter.done:
          return todo['done'] == true;
        case TodoFilter.notDone:
          return todo['done'] == false;
        case TodoFilter.all:
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo",
          style: TextStyle(fontSize: 28.0),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<TodoFilter>(
              value: currentFilter,
              onChanged: (TodoFilter? newValue) {
                setState(() {
                  currentFilter = newValue!;
                });
              },
              items: const <DropdownMenuItem<TodoFilter>>[
                DropdownMenuItem<TodoFilter>(
                  value: TodoFilter.all,
                  child: Text('All', style: TextStyle(fontSize: 18.0)),
                ),
                DropdownMenuItem<TodoFilter>(
                  value: TodoFilter.done,
                  child: Text('Done', style: TextStyle(fontSize: 18.0)),
                ),
                DropdownMenuItem<TodoFilter>(
                  value: TodoFilter.notDone,
                  child: Text('Not Done', style: TextStyle(fontSize: 18.0)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = filteredTodos[index];
          return ListTile(
            leading: Checkbox(
              value: todo['done'],
              onChanged: (bool? value) async {
                try {
                  await apiManager.updateTodo(todo['id'], {
                    "title": todo['title'],
                    "done": value,
                  });
                  setState(() {
                    todo['done'] = value;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error updating todo: $e")),
                  );
                }
              },
            ),
            title: Text(
              todo['title'],
              style: TextStyle(
                fontSize: 19.0,
                decoration: todo['done'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                try {
                  await apiManager.deleteTodo(todo['id']);
                  setState(() {
                    _todos.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Todo removed")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting todo: $e")),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                builder: (context) => const TodoInputPage(),
              ))
              .then((_) {
            _fetchTodos();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}











