import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/providers/theme_provider.dart';
import 'package:todo_list_app/providers/todo_provider.dart';
import 'package:todo_list_app/screens/home.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Offline Notes',
            debugShowCheckedModeBanner: false,
            
            themeMode: ThemeMode.system,
            theme:
                themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}