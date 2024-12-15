//main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/task_list_view.dart';
import 'views/login_view.dart';
import 'controllers/login_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ybbiyaxcyqnmpiswdcsc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliYml5YXhjeXFubXBpc3dkY3NjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1NDQxODgsImV4cCI6MjA0OTEyMDE4OH0.3AJo66nCxDhCop_gvzBQvkK1AcvUP9TvH2z2d_st6Ao',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: _determineInitialRoute(),
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const StudentPlannerPage(),
      },
      onGenerateRoute: _generateRoute,
      onUnknownRoute: _unknownRoute,
    );
  }

  String _determineInitialRoute() {
    final controller = LoginController();
    return controller.isLoggedIn() ? '/home' : '/login';
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case '/home':
        final loginController = LoginController();
        if (loginController.isLoggedIn()) {
          return MaterialPageRoute(builder: (_) => const StudentPlannerPage());
        } else {
          return MaterialPageRoute(builder: (_) => const LoginView());
        }
      default:
        return null;
    }
  }

  Route<dynamic>? _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
