import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hybrix_task/services/auth_service.dart';
import 'package:hybrix_task/services/user_location_service.dart';
import 'package:hybrix_task/views/login.dart';
import 'package:hybrix_task/views/home.dart';
import 'package:provider/provider.dart';

void main() async {
  // 네이티브 코드의 비동기 작업을 보장하기 위한 위젯 바인딩 보장
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // 최상위 디렉토리에서 multiprovider로 감싸서 해당 서비스에서 값 변경을 알리면 위젯에 반영을 하기 위함.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserLocationService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //로그인된 현재 유저를 받아옴
    User? user = context.read<AuthService>().currentUser();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      //로그인 되어있지 않을 때 LoginPage로, 로그인 되어 있다면 MainPage로
      home: user == null ? LoginPage() : MainPage(),
    );
  }
}
