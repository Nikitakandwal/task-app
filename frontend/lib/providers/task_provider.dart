import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final _api = ApiService();

  List<Task> _tasks = [];
  bool loading = false;
  String searchQuery = '';
  String statusFilter = 'All';

  List<Task> get tasks => _tasks;

  List<Task> get filtered => _tasks.where((t) {
        final matchSearch =
            t.title.toLowerCase().contains(searchQuery.toLowerCase());
        final matchStatus =
            statusFilter == 'All' || t.status == statusFilter;
        return matchSearch && matchStatus;
      }).toList();

  bool isBlocked(Task task) {
    if (task.blockedBy == null) return false;
    try {
      final blocker = _tasks.firstWhere((t) => t.id == task.blockedBy);
      return blocker.status != 'Done';
    } catch (_) {
      return false;
    }
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setFilter(String f) {
    statusFilter = f;
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      _tasks = await _api.getTasks();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _api.createTask(data);
    await load();
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _api.updateTask(id, data);
    await load();
  }

  Future<void> delete(int id) async {
    await _api.deleteTask(id);
    await load();
  }
}