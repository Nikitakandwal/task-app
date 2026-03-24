import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TaskProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _SearchFilterBar(),
          Expanded(child: _TaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, [Task? task]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    ).then((_) => context.read<TaskProvider>().load());
  }
}

// ── Search + Filter bar ───────────────────────────────────────────────────────

class _SearchFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.read<TaskProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title…',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: p.setSearch,
            ),
          ),
          const SizedBox(width: 8),
          Consumer<TaskProvider>(
            builder: (_, p, __) => DropdownButton<String>(
              value: p.statusFilter,
              underline: const SizedBox(),
              items: ['All', 'To-Do', 'In Progress', 'Done']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => p.setFilter(v!),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task list ─────────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, p, _) {
        if (p.loading) return const Center(child: CircularProgressIndicator());
        final tasks = p.filtered;
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (_, i) => _TaskCard(task: tasks[i]),
        );
      },
    );
  }
}

// ── Task card ─────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final p = context.read<TaskProvider>();
    final blocked = p.isBlocked(task);

    return Card(
      color: blocked ? Theme.of(context).colorScheme.surfaceVariant : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            color: blocked ? Theme.of(context).disabledColor : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${task.status}  ·  Due ${task.dueDate}',
          style: TextStyle(fontSize: 12, color: blocked ? Theme.of(context).disabledColor : null),
        ),
        leading: _statusIcon(task.status, blocked),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (blocked)
              const Tooltip(
                message: 'Blocked',
                child: Icon(Icons.lock_outline, size: 16),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(task: task),
                ),
              ).then((_) => p.load()),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, p),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(String status, bool blocked) {
    if (blocked) return const Icon(Icons.pause_circle_outline);
    return switch (status) {
      'Done' => const Icon(Icons.check_circle, color: Colors.green),
      'In Progress' => const Icon(Icons.timelapse, color: Colors.orange),
      _ => const Icon(Icons.radio_button_unchecked),
    };
  }

  Future<void> _confirmDelete(BuildContext context, TaskProvider p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) p.delete(task.id);
  }
}