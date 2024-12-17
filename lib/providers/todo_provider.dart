import 'package:flutter/material.dart';
import 'package:todo_list_app/models/todo_model.dart';
import 'package:todo_list_app/services/database_services.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.initDB();
    await fetchTodos(); 
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTodos() async {
    _todos = await DatabaseHelper.instance.readAllTodos();
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await DatabaseHelper.instance.create(todo);
    await fetchTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await DatabaseHelper.instance.update(todo);
    await fetchTodos();
  }

  Future<void> deleteTodo(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchTodos();
  }
}
