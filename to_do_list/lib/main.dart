import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/tasks_provider.dart';
import 'Screens/add_screen.dart';
import 'screens/home_screen.dart';
import 'screens/resume_screen.dart';
import 'screens/tasks_screen.dart';

void main() {
  runApp(const TarefinhasApp());
}

class TarefinhasApp extends StatelessWidget {
  const TarefinhasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasksProvider()..loadTasks(),
      child: MaterialApp(
        title: 'Tarefinhas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF06051B),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/add': (_) => const AddScreen(),
          '/tasks': (_) => const TasksScreen(),
          '/resume': (_) => const ResumeScreen(),
        },
      ),
    );
  }
}