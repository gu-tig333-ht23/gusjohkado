import 'dart:convert';
import 'package:http/http.dart' as http;

class APIManager {
  static const baseUrl = 'https://todoapp-api.apps.k8s.gu.se/';
  String? apiKey = 'dfb66b49-e92d-4ba1-99f8-7e1f10455c45';

  Future<List<Map<String, dynamic>>> getTodos() async {
    final response = await http.get(Uri.parse('${baseUrl}todos?key=$apiKey'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  Future<void> addTodo(Map<String, dynamic> todo) async {
    final response = await http.post(
      Uri.parse('${baseUrl}todos?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add todo');
    }
  }
  Future<void> updateTodo(String id, Map<String, dynamic> updatedTodo) async {
  final response = await http.put(
    Uri.parse('${baseUrl}todos/$id?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(updatedTodo),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update todo');
  }
}
Future<void> deleteTodo(String id) async {
  final response = await http.delete(
    Uri.parse('${baseUrl}todos/$id?key=$apiKey'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete todo');
  }
}
}

final apiManager = APIManager();