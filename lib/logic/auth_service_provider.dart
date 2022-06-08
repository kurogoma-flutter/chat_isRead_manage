import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authPageViewModelProvider = ChangeNotifierProvider<AuthPageViewModel>(
  (ref) {
    return AuthPageViewModel();
  },
);

class AuthPageViewModel extends ChangeNotifier {
  AuthPageViewModel();

  String email = '';
  String password = '';
  bool isObscure = true;

  void handleEmail(String e) {
    email = e;
    notifyListeners();
  }

  void handlePassword(String e) {
    password = e;
    notifyListeners();
  }

  void convertObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void clearText() {
    email = '';
    password = '';
    isObscure = true;
    notifyListeners();
  }

  /// サインアウト処理
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      context.go('/');
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('サインアウトに失敗しました');
      // ignore: avoid_print
      print(e);
    }
  }

  /// メール認証：ユーザーログイン
  Future<void> login(BuildContext context) async {
    try {
      // メール/パスワードでログイン
      final auth = FirebaseAuth.instance;
      // ignore: unused_local_variable
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ignore: use_build_context_synchronously
      return context.go('/');
    } on FirebaseAuthException catch (e) {
      // ログインに失敗した場合
      var message = '';
      // エラーコード別処理
      switch (e.code) {
        case 'invalid-email':
          message = 'メールアドレスが不正です。';
          break;
        case 'wrong-password':
          message = 'パスワードが違います。';
          break;
        case 'user-disabled':
          message = '指定されたユーザーは無効です。';
          break;
        case 'user-not-found':
          message = '指定されたユーザーは存在しません。';
          break;
        case 'operation-not-allowed':
          message = '指定されたユーザーはこの操作を許可していません。';
          break;
        case 'too-many-requests':
          message = '複数回リクエストが発生しました。';
          break;
        case 'email-already-exists':
          message = '指定されたメールアドレスは既に使用されています。';
          break;
        case 'internal-error':
          message = '内部処理エラーが発生しました。';
          break;
        default:
          message = '予期せぬエラーが発生しました。';
      }

      // ignore: avoid_print
      print(message);
    }
  }

  /// ログインステータスを監視し、ページ切り替えをする
  Stream<User?> authStateStream = FirebaseAuth.instance.authStateChanges();
}
