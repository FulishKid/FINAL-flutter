import 'package:app/api/bb_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _message = '';

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final message = await Provider.of<MyAPIService>(context, listen: false)
          .resetPassword(email);
      setState(() {
        _message = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Send Reset Link'),
              ),
              const SizedBox(height: 16.0),
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color:
                        _message.contains('Error') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
