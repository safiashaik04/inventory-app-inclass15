import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _login() async {
    setState(() { loading = true; error = null; });
    try {
      await _auth.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
      // AuthWrapper listens and will navigate automatically
    } on Exception catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            loading ? const CircularProgressIndicator() :
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: const Text('Create an account'),
            )
          ],
        ),
      ),
    );
  }
}
