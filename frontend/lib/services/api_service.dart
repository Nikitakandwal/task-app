import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const _base = 'http://10.0.2.2:8000';

  Future<List<Task>> getTasks() async {
    final res = await http.get(Uri.parse('$_base/tasks'));
    _check(res);
    return (jsonDecode(res.body) as List).map((j) => Task.fromJson(j)).toList();
  }

  Future<Task> createTask(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_base/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _check(res);
    return Task.fromJson(jsonDecode(res.body));
  }

  Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_base/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _check(res);
    return Task.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteTask(int id) async {
    final res = await http.delete(Uri.parse('$_base/tasks/$id'));
    _check(res);
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) throw Exception('API error ${res.statusCode}');
  }
}