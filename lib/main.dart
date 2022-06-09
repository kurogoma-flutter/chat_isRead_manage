import 'package:chat_app_read/logic/auth_view_model.dart';
import 'package:chat_app_read/presentation/pages/chat_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/login_page.dart';
import 'utility/route.dart';

Future<void> main() async {
  // GoRouter用の初期設定
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  // Firebase用の初期設定
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    // RiverPod用の初期設定
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GorRouterのための設定
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      title: 'チャット既読アプリ',
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}

// RiverPodで定義するProviderを呼び出す用のウィジェット
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModelをそのまま呼び出すことで変数やロジックを使える
    // メソッドを呼び出すのにはref.readが適切なので以下を定義してもよい
    // final viewModelRead = ref.read(authPageViewModelProvider);
    final viewModel = ref.watch(authPageViewModelProvider);

    return StreamBuilder<User?>(
      stream: viewModel.authStateStream,
      builder: (context, snapshot) {
        // 取得中はローディング
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // 認証情報の有無によりページを切り替える
        if (snapshot.hasData) {
          return const ChatListPage();
        }

        return const LoginPage();
      },
    );
  }
}
