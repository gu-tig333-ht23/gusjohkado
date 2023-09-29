import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyState extends ChangeNotifier {
  String apiKey;
  List<Task> tasks;

  MyState(this.apiKey, this.tasks);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiKey = await register();
  final prefs = await SharedPreferences.getInstance();

  List<Task> savedTasks = [];

  final tasksJson = prefs.getString('tasks');
  if (tasksJson != null) {
    final List<dynamic> taskData = json.decode(tasksJson) as List<dynamic>;
    savedTasks = taskData.map((json) => Task.fromJson(json)).toList();
  }

  if (apiKey != null) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => MyState(apiKey, savedTasks),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('To-Do List', style: TextStyle(fontSize: 24)),
            ),
            body: TodoListScreen(),
          ),
        ),
      ),
    );
  } else {
  
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

enum TodoFilter { all, checked, unchecked }

class _TodoListScreenState extends State<TodoListScreen> {
  TodoFilter currentFilter = TodoFilter.all;
  List<Task> todos = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final myState = Provider.of<MyState>(context, listen: false);
    setState(() {
      this.todos = myState.tasks;
    });
    super.didChangeDependencies();
  }

  Future<void> _updateTasks() async {
    final myState = Provider.of<MyState>(context, listen: false);

    
    final updatedTasks = [...myState.tasks, ...todos];
    myState.tasks = updatedTasks;

    final prefs = await SharedPreferences.getInstance();
    try {
      final tasksJson = json.encode(updatedTasks.map((task) => task.toJson()).toList());
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          DropdownButton<TodoFilter>(
            value: currentFilter,
            onChanged: (TodoFilter? newValue) {
              setState(() {
                currentFilter = newValue ?? TodoFilter.all;
              });
            },
            items: TodoFilter.values.map((TodoFilter filter) {
              return DropdownMenuItem<TodoFilter>(
                value: filter,
                child: Text(
                  filter == TodoFilter.all
                      ? 'All'
                      : filter == TodoFilter.checked
                          ? 'Done'
                          : 'Not done',
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: todos.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final task = todos[index];
                if (currentFilter == TodoFilter.checked && !task.done) {
                  return const SizedBox.shrink();
                } else if (currentFilter == TodoFilter.unchecked && task.done) {
                  return const SizedBox.shrink();
                }
                return ChecklistItem(
                  title: task.title,
                  isChecked: task.done,
                  onRemove: () async {
                    await deleteTodo(
                        Provider.of<MyState>(context, listen: false).apiKey, task.id);
                    setState(() {
                      todos.removeAt(index);
                    });
                    await _updateTasks();
                  },
                  onCheckedChanged: (newValue) async {
                    await updateTodo(
                        Provider.of<MyState>(context, listen: false).apiKey, task.id, newValue ?? false);
                    setState(() {
                      task.done = newValue ?? false;
                    });
                    await _updateTasks();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () async {
                final newTask = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
                );
                if (newTask != null) {
                  final result = await addTodo(
                      Provider.of<MyState>(context, listen: false).apiKey,
                      Task(id: '', title: newTask, done: false));

                  
                  setState(() {
                    todos = result.tasks;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding:  EdgeInsets.symmetric(horizontal: 50.0, vertical: 25.0),
                child: Text(
                  'Add new task',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  FilterButton({
    required this.label,
    required this.onPressed,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.lightBlue : Colors.grey,
      ),
      child: Text(label),
    );
  }
}

class ChecklistItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onCheckedChanged;
  final VoidCallback onRemove;

  ChecklistItem({
    required this.title,
    required this.isChecked,
    required this.onCheckedChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      leading: Checkbox(
        value: isChecked,
        onChanged: onCheckedChanged,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onRemove,
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add new task',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _taskController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Write new task:',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final newTask = _taskController.text.trim();
                if (newTask.isNotEmpty) {
                  Navigator.pop(context, newTask);
                }
              },
              child: const Text(
                'Add to tasks',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}









