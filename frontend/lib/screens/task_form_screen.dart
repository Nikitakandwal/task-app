import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;

  String _status = 'To-Do';
  DateTime? _dueDate;
  int? _blockedBy;
  bool _saving = false;

  bool get _isEdit => widget.task != null;
  static const _fmt = 'yyyy-MM-dd';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _desc = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? 'To-Do';
    _dueDate = t != null ? DateTime.tryParse(t.dueDate) : null;
    _blockedBy = t?.blockedBy;

    if (!_isEdit) {
      _loadDraft();
      _title.addListener(_saveDraft);
      _desc.addListener(_saveDraft);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  // ── Draft helpers ──────────────────────────────────────────────────────────

  Future<void> _loadDraft() async {
    final p = await SharedPreferences.getInstance();
    final dTitle = p.getString('draft_title');
    final dDesc = p.getString('draft_desc');
    if (dTitle != null && mounted) _title.text = dTitle;
    if (dDesc != null && mounted) _desc.text = dDesc;
  }

  Future<void> _saveDraft() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('draft_title', _title.text);
    await p.setString('draft_desc', _desc.text);
  }

  Future<void> _clearDraft() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('draft_title');
    await p.remove('draft_desc');
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please pick a due date')));
      return;
    }

    setState(() => _saving = true);

    final data = {
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'due_date': DateFormat(_fmt).format(_dueDate!),
      'status': _status,
      'blocked_by': _blockedBy,
    };

    try {
      final p = context.read<TaskProvider>();
      if (_isEdit) {
        await p.update(widget.task!.id, data);
      } else {
        await p.create(data);
        await _clearDraft();
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final allTasks = context.watch<TaskProvider>().tasks;
    final otherTasks =
        allTasks.where((t) => t.id != widget.task?.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'New Task'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),

            // Description
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            // Due date
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                _dueDate == null
                    ? 'Pick due date *'
                    : 'Due: ${DateFormat('MMM d, yyyy').format(_dueDate!)}',
              ),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 14),

            // Status
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['To-Do', 'In Progress', 'Done']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 14),

            // Blocked by
            DropdownButtonFormField<int?>(
              value: _blockedBy,
              decoration: const InputDecoration(
                labelText: 'Blocked by (optional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('None')),
                ...otherTasks.map(
                  (t) => DropdownMenuItem<int?>(
                    value: t.id,
                    child: Text(t.title),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _blockedBy = v),
            ),
            const SizedBox(height: 24),

            // Save button
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEdit ? 'Update Task' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}