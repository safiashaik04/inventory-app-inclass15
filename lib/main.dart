import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'inventory_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  String? role;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    _authService.authStateChanges().listen((user) async {
      if (user == null) {
        setState(() {
          role = null;
          loading = false;
        });
      } else {
        // fetch role from Firestore
        final r = await _authService.getRoleForUid(user.uid);
        setState(() {
          role = r;
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_authService.currentUser == null) {
      return const LoginScreen();
    } else {
      final isAdmin = role == 'admin';
      return InventoryHomePage(isAdmin: isAdmin);
    }
  }
}
