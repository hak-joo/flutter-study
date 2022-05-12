import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hybrix_task/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        User? user = authService.currentUser();
        return Scaffold(
            appBar: AppBar(
              title: Text("Hybrix_Task"),
            ),
            body: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "회원가입",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "이메일"),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "패스워드"),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      authService.register(
                        email: emailController.text,
                        password: passwordController.text,
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("회원가입이 완료되었습니다")));
                          Navigator.pop(context);
                        },
                        onError: (err) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        },
                      );
                    },
                    child: Text("회원가입"),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
