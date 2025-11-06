import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _adminCodeCtrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _signup() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await _auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        adminSecret: _adminCodeCtrl.text.trim().isEmpty
            ? null
            : _adminCodeCtrl.text.trim(),
      );

      // ✅ Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Redirecting...')),
      );

      // ✅ Return to login (AuthWrapper will reroute automatically)
      Navigator.pop(context);

    } on Exception catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            // Optional: Admin secret input - demo only
            TextField(controller: _adminCodeCtrl, decoration: const InputDecoration(labelText: 'Admin secret (optional)')),
            const SizedBox(height: 20),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            loading ? const CircularProgressIndicator() :
            ElevatedButton(onPressed: _signup, child: const Text('Create account')),
          ],
        ),
      ),
    );
  }
}
