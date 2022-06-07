import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
  }

  handleEmail(e) {
    setState(() {
      _email = e;
    });
  }

  handlePassword(e) {
    setState(() {
      _password = e;
    });
  }

  convertObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  clearText() {
    setState(() {
      _email = '';
      _password = '';
      _isObscure = true;
    });
  }

  /// メール認証：ユーザーログイン
  Future login(BuildContext context) async {
    try {
      // メール/パスワードでログイン
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential result = await auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      // ログインに成功した場合
      final User user = result.user!;

      return context.go('/');
    } on FirebaseAuthException catch (e) {
      // ログインに失敗した場合
      String message = '';
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

  /// サインアウト処理
  Future signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go('/');
    } on FirebaseAuthException catch (e) {
      print('サインアウトに失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('ログインページ',
            style: TextStyle(fontWeight: FontWeight.w400)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'メールアドレスでログイン',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: TextFormField(
                autovalidateMode:
                    AutovalidateMode.onUserInteraction, // 入力時バリデーション
                cursorColor: Colors.blueAccent,
                decoration: const InputDecoration(
                  focusColor: Colors.red,
                  labelText: 'メールアドレス',
                  hintText: 'sample@gmail.com',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
                maxLines: 1,
                onChanged: (value) {
                  handleEmail(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "入力してください";
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: TextFormField(
                autovalidateMode:
                    AutovalidateMode.onUserInteraction, // 入力時バリデーション
                cursorColor: Colors.blueAccent,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  focusColor: Colors.red,
                  labelText: 'パスワード',
                  hintText: 'Enter Your Password',
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent)),
                  border: const OutlineInputBorder(borderSide: BorderSide()),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      convertObscure();
                    },
                  ),
                ),
                maxLines: 1,
                onChanged: (value) {
                  handlePassword(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "入力してください";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  await login(context);
                  // clearText();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'ログイン',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
