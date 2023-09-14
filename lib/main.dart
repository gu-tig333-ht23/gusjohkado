import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('To-Do List',
          style: TextStyle(fontSize: 24)
          ),
        ),
        body: TodoListScreen(),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen();

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

enum TodoFilter { all, checked, unchecked } // filteralternativ

class _TodoListScreenState extends State<TodoListScreen> {
  TodoFilter currentFilter = TodoFilter.all; // default filtret visar alla todos
  List<Task> Todos = []; // sparar mina todos tillfälligt i lista

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[    //Dropdownfilter för att sortera todos
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
            itemCount: Todos.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final task = Todos[index];
              if (currentFilter == TodoFilter.checked &&
                  !Todos[index].isChecked) {
                return SizedBox.shrink();
              } else if (currentFilter == TodoFilter.unchecked &&
                  Todos[index].isChecked) {
                return SizedBox.shrink();
              }
              return ChecklistItem(
                title: Todos[index].title,
                isChecked: Todos[index].isChecked,
                onRemove: () {
                  setState(() {
                    Todos.removeAt(index);
                  });
                },
                onCheckedChanged: (newValue) {
                  setState(() {
                    Todos[index].isChecked = newValue ?? false;
                  });
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
                setState(() {
                  Todos.add(Task(title: newTask, isChecked: false));
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 25.0),
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
        icon: Icon(Icons.close),
        onPressed: onRemove,
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  AddTaskScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new task',
        style: TextStyle(fontSize: 24)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _taskController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: 'Write new task:',
                
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final newTask = _taskController.text.trim();
                if (newTask.isNotEmpty) {
                  Navigator.pop(context, newTask);
                }
              },
              child: Text('Add to tasks',
              style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String title;
  bool isChecked;

  Task({
    required this.title,
    required this.isChecked,
  });
}
