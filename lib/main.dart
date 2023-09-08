import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Todo App',
          style: TextStyle(fontSize: 24)
          ),
        ),
        body: TodoListScreen(),
      ),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                TodoTask(title: 'Clean', isChecked: true),
                TodoTask(title: 'Buy milk', isChecked: false),
                TodoTask(title: 'Pick up package', isChecked: true),
                TodoTask(title: 'Do homework', isChecked: false),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskScreen()),
    ); // från Navigator.push och hit är för att kunna trycka på + och se screen 2
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 25.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Add new task',
               style: TextStyle(fontSize: 25),
              ),
            ),
          );
        }
      }

class TodoTask extends StatelessWidget {
  final String title;
  final bool isChecked;

  TodoTask({required this.title, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          decoration:
              isChecked ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      leading: Checkbox(
        value: isChecked,
        onChanged: (bool? newValue) {
          // checkbox state senare
        },
      ),
      trailing: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
        // lägg till funktion att ta bort tasks här
        },
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add task',
        style: TextStyle(fontSize: 24)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Write new task:',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                //lägg till funktion för knappen lägg till task
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
