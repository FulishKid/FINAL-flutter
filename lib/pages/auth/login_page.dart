import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/bb_api.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Створення контролерів для полів вводу
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  String? _loginResult;
  bool isLoggined = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: screenHeight * 0.25,
              ),
              const Text(
                'Welcome to Beat Believers',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller:
                    emailController, // Використання контролера для Email
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller:
                    passwordController, // Використання контролера для Password
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Consumer<MyAPIService>(
                builder: (context, value, child) => Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    child: const Text('Log In'),
                    onPressed: () async {
                      String result = await loginUser(value, context);
                      if (result == 'User logged in successfully') {
                        context.go('home');
                      }
                    },
                  ),
                ),
              ),
              if (_loginResult != null)
                Column(
                  children: [
                    Text(
                      _loginResult!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                        onPressed: () => context.go('/login/password-reset'),
                        child: const Text('Forgot your password?'))
                  ],
                ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () => context.go('/login/register'),
                  child: const Text('Don\'t have an account? Sign up')),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> loginUser(MyAPIService apiService, context) async {
    final result = await apiService.loginUser(
      emailController.text,
      passwordController.text,
      context,
    );

    setState(() {
      _loginResult = result;
    });

    return result;
  }
}
