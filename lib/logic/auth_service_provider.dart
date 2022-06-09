import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: lines_longer_than_80_chars
final authPageViewModelProvider = ChangeNotifierProvider<AuthPageViewModel>(
  (ref) {
    return AuthPageViewModel();
  },
);

class AuthPageViewModel extends ChangeNotifier {
  AuthPageViewModel();

  // watch対象の変数
  String email = '';
  String password = '';
  bool isObscure = true;

  // 内部的に変数が変わるだけで良いので、notifyListeners()による再描画は不要
  // ignore: use_setters_to_change_properties
  void handleEmail(String e) {
    email = e;
  }

  // 内部的に変数が変わるだけで良いので、notifyListeners()による再描画は不要
  // ignore: use_setters_to_change_properties
  void handlePassword(String e) {
    password = e;
  }

  // UIの切り替えがあるのでnotifyListeners()が必要
  void convertObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  // Note: autoDisposeがある場合不要になるが、disposeされない時手動削除が必要
  void clearText() {
    email = '';
    password = '';
    isObscure = true;
    notifyListeners();
  }

  /// 認証状態を取得するStream => StreamBuilderに渡す
  Stream<User?> authStateStream = FirebaseAuth.instance.authStateChanges();

  /// サインアウト処理
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ログインページに遷移すると、もしかしたら認証状態があるのにログインしてしまう場合がある。
      // トップページに遷移すれば認証情報を取得してからログインページに遷移するので安心。
      // ignore: use_build_context_synchronously
      context.go('/');
    } on FirebaseAuthException catch (e) {
      debugPrint('サインアウトに失敗しました');
      debugPrint(e.toString());
    }
  }

  /// メール認証：ユーザーログイン
  Future<void> login(BuildContext context) async {
    try {
      // メール/パスワードでログイン
      final auth = FirebaseAuth.instance;
      print(email);
      print(password);
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

      print(message);
    }
  }
}
