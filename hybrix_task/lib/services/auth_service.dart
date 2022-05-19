import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  User? currentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  void register({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String err) onError,
  }) async {
    if (email.isEmpty) {
      onError("이메일을 입력해 주세요.");
      return;
    } else if (password.isEmpty) {
      onError("비밀번호를 입력해 주세요.");
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      // 검증 후 결과 전달
      if (e.code == 'weak-password') {
        onError('비밀번호를 6자리 이상 입력해 주세요.');
      } else if (e.code == 'email-already-in-use') {
        onError('이미 가입된 이메일 입니다.');
      } else if (e.code == 'invalid-email') {
        onError('이메일 형식을 확인해주세요.');
      } else if (e.code == 'user-not-found') {
        onError('일치하는 이메일이 없습니다.');
      } else if (e.code == 'wrong-password') {
        onError('비밀번호가 일치하지 않습니다.');
      } else {
        onError(e.message!);
      }
    }
  }

  void login({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String err) onError,
  }) async {
    if (email.isEmpty) {
      onError("이메일을 입력해주세요");
      return;
    } else if (password.isEmpty) {
      onError("비밀번호를 입력해주세요");
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      onSuccess();
      notifyListeners(); // 로그인 상태 변경 알림
    } on FirebaseAuthException catch (e) {
      onError(e.message!);
    } catch (e) {
      onError(e.toString());
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners(); // 로그인 상태 변경 알림
  }
}
