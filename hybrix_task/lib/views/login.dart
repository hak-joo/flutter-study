import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrix_task/services/auth_service.dart';
import 'package:hybrix_task/views/home.dart';
import 'package:hybrix_task/views/register.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                        "로그인 후 이용해주세요",
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
                      authService.login(
                        email: emailController.text,
                        password: passwordController.text,
                        onSuccess: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("로그인 성공!")));

                          /* 로그인 성공 후 MainPage로 이동하게 함.
                          pushReplacement를 사용하여 현재 페이지를 pop함으로써 login page로 돌아가지 못하게 한다. */
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPage()));
                        },
                        onError: (err) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        },
                      );
                    },
                    child: Text("로그인"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text("회원가입"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }
}
