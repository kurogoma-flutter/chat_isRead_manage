import 'package:chat_app_read/logic/auth_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // viewModel定義
    final viewModelWatch = ref.watch(authPageViewModelProvider);
    final viewModelRead = ref.read(authPageViewModelProvider);

    return Scaffold(
      appBar: AppBar(
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
                      borderSide: BorderSide(color: Colors.blueAccent),),
                  border: OutlineInputBorder(),
                ),
                onChanged: viewModelRead.handleEmail,
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
                obscureText: viewModelWatch.isObscure,
                decoration: InputDecoration(
                  focusColor: Colors.red,
                  labelText: 'パスワード',
                  hintText: 'Enter Your Password',
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(viewModelWatch.isObscure
                        ? Icons.visibility_off
                        : Icons.visibility,),
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
                  await viewModelRead.login(context);
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
