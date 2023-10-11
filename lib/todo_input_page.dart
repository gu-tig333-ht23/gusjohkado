import 'package:flutter/material.dart';
import 'api_manager.dart';

class TodoInputPage extends StatefulWidget {
  const TodoInputPage({super.key});

  @override
  _TodoInputPageState createState() => _TodoInputPageState();
}

class _TodoInputPageState extends State<TodoInputPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Todo",
          style: TextStyle(
            fontSize: 24.0,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Write new task:",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _saveTodo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20.0),
                    textStyle: const TextStyle(fontSize: 20, fontFamily: 'Roboto'),
                  ),
                  child: Text(
                    "Add",
                    style: TextStyle(fontSize: 25.0, fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _saveTodo() async {
    if (_controller.text.isNotEmpty) {
      final todo = {
        "title": _controller.text,
        "done": false,
      };
      try {
        await apiManager.addTodo(todo);
        Navigator.of(context).pop(); 
      } catch (e) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding todo: $e")),
        );
      }
    }
  }
}