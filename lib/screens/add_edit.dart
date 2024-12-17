import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/models/todo_model.dart';
import '../providers/todo_provider.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoScreen({Key? key, this.todo}) : super(key: key);

  @override
  _AddEditTodoScreenState createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isCompleted = false;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _isCompleted = widget.todo?.isCompleted ?? false;

    _dueDate = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);

      final newTodo = Todo(
        id: widget.todo?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isCompleted: _isCompleted,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
      );

      if (widget.todo == null) {
        todoProvider.addTodo(newTodo);
      } else {
        todoProvider.updateTodo(newTodo);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todo == null ? 'Create New Task' : 'Edit Task',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          widget.todo != null
              ? IconButton(
                  onPressed: () {
                    final todoProvider =
                        Provider.of<TodoProvider>(context, listen: false);
                    todoProvider.deleteTodo(widget.todo!.id!);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete),
                )
              : SizedBox()
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Task Details',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title is required'
                      : null,
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 12,
                  style: textTheme.bodyLarge,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due Date',
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      label: Text(
                        _dueDate == null
                            ? 'Select Date'
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () => _selectDate(context),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mark as Completed',
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.todo == null ? 'Create Task' : 'Update Task',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
