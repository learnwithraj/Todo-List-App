import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/models/todo_model.dart';
import 'package:todo_list_app/providers/theme_provider.dart';
import 'package:todo_list_app/screens/add_edit.dart';
import 'package:todo_list_app/screens/widgets/home_drawer.dart';
import '../providers/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showCompleted = false;
  String _sortBy = 'Date';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      await todoProvider.init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Todo> _searchTasks(TodoProvider todoProvider, String query) {
    if (query.isEmpty) {
      return todoProvider.todos;
    }
    return todoProvider.todos
        .where((todo) =>
            todo.title.toLowerCase().contains(query.toLowerCase()) ||
            todo.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Todo> _getSortedAndFilteredTodos(TodoProvider todoProvider) {
    var filteredTodos = _searchTasks(todoProvider, _searchQuery);

    filteredTodos = _showCompleted
        ? filteredTodos
        : filteredTodos.where((todo) => !todo.isCompleted).toList();

    switch (_sortBy) {
      case 'Title':
        filteredTodos.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Completion':
        filteredTodos.sort(
            (a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
        break;
      default: // 'Date'
        filteredTodos.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt)); // Descending order
        break;
    }
    return filteredTodos;
  }

  Color _getTaskColorByDueDate(Todo todo) {
    if (todo.isCompleted) return Colors.green.shade100;

    if (todo.dueDate == null) return Colors.grey.shade100;

    final now = DateTime.now();
    final difference = todo.dueDate!.difference(now).inDays;

    if (difference < 0) return Colors.red.shade100; // Overdue
    if (difference == 0) return Colors.orange.shade100; // Due today
    if (difference <= 3) return Colors.yellow.shade100; // Due soon

    return Colors.white; // Normal
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    final sortedTodos = _getSortedAndFilteredTodos(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Sort dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Date',
                child: Text('Sort by Date'),
              ),
              PopupMenuItem<String>(
                value: 'Title',
                child: Text('Sort by Title'),
              ),
              PopupMenuItem<String>(
                value: 'Completion',
                child: Text('Sort by Completion'),
              ),
            ],
          ),
          IconButton(
            icon:
                Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
          ),
          // Theme toggle
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      drawer: HomeDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    )),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // List of todos
          Expanded(
            child: todoProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : sortedTodos.isEmpty
                    ? _buildEmptyState(context)
                    : _buildTodoList(sortedTodos, Colors.blue, textTheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditTodoScreen(),
            ),
          );
        },
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.checklist_rounded,
            size: 100,
            color: Colors.blue.shade600,
          ),
          SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? 'No tasks match your search'
                : 'No tasks yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          SizedBox(height: 10),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Tap the "Add Task" button to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue.shade700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos, Color color, TextTheme textTheme) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Dismissible(
          key: Key(todo.id.toString()),
          background: _buildDismissBackground(Icons.delete, Colors.red),
          secondaryBackground:
              _buildDismissBackground(Icons.delete, Colors.red),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            final todoProvider =
                Provider.of<TodoProvider>(context, listen: false);
            todoProvider.deleteTodo(todo.id!);
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _getTaskColorByDueDate(todo),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.black,
                  color: Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.description.isNotEmpty)
                    Text(
                      todo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  if (todo.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(todo.dueDate!),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: Checkbox(
                activeColor: Colors.blue,
                value: todo.isCompleted,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: (value) {
                  final todoProvider =
                      Provider.of<TodoProvider>(context, listen: false);
                  todoProvider.updateTodo(
                    Todo(
                      id: todo.id,
                      title: todo.title,
                      description: todo.description,
                      isCompleted: value ?? false,
                      dueDate: todo.dueDate,
                      createdAt: todo.createdAt,
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditTodoScreen(todo: todo),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground(IconData icon, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
