import 'package:chat_app_read/logic/auth_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // viewModelを呼び出し
    // ref.watch() => 再レンダリングしたい変数用
    final viewModelWatch = ref.watch(authPageViewModelProvider);
    // ref.read() => 再レンダリングが発生して欲しくないメソッドなど用
    final viewModelRead = ref.read(authPageViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        // 簡易戻るボタン
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'ログインページ',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('メールアドレスでログイン', style: TextStyle(fontSize: 20)),
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
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  border: OutlineInputBorder(),
                ),
                // 入力したテキストを変数に反映
                onChanged: viewModelRead.handleEmail,
                // 入力バリデーション
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '入力してください';
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
                // パスワードの表示非表示
                obscureText: viewModelWatch.isObscure,
                decoration: InputDecoration(
                  focusColor: Colors.red,
                  labelText: 'パスワード',
                  hintText: 'Enter Your Password',
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    // パスワードの表示非表示
                    icon: Icon(
                      viewModelWatch.isObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: viewModelRead.convertObscure,
                  ),
                ),
                onChanged: viewModelRead.handlePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '入力してください';
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
                  // ログイン処理
                  await viewModelRead.login(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text('ログイン', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
