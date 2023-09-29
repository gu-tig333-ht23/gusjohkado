import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'https://todoapp-api.apps.k8s.gu.se'; // Replace with your actual base URL
const apiKey = 'dbadcd2a-881c-4128-a964-bc3efad99155'; // Replace with your actual API key

class Task {
  final String id;
  final String title;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.done,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
    };
  }
}

class AddTodoResult {
  final String taskId;
  final List<Task> tasks;

  AddTodoResult(this.taskId, this.tasks);
}

Future<String?> register() async {
  final response = await http.get(Uri.parse('$baseUrl/register'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    return null;
  }
}

Future<List<Task>> listTodos(String apiKey) async {
  final response = await http.get(Uri.parse('$baseUrl/todos?key=$apiKey'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<Task> todos = data.map((json) => Task.fromJson(json)).toList();
    return todos;
  } else {
    return [];
  }
}

Future<AddTodoResult> addTodo(String apiKey, Task newTodo) async {
  final response = await http.post(
    Uri.parse('$baseUrl/todos?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(newTodo.toJson()),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<Task> todos = data.map((json) => Task.fromJson(json)).toList();

    // Extract the ID from the response
    final String taskId = data.isNotEmpty ? data.first['id'] : '';

    return AddTodoResult(taskId, todos);
  } else {
    return AddTodoResult('', []);
  }
}

Future<void> deleteTodo(String apiKey, String id) async {
  await http.delete(Uri.parse('$baseUrl/todos/$id?key=$apiKey'));
}

Future<void> updateTodo(String apiKey, String id, bool done) async {
  final response = await http.put(
    Uri.parse('$baseUrl/todos/$id?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'done': done}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update todo');
  }
}
















