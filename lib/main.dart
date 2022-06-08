import 'package:chat_app_read/logic/auth_service_provider.dart';
import 'package:chat_app_read/presentation/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/pages/login_page.dart';
import 'utility/route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      title: 'チャット既読アプリ',
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
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
          // 取得後、データの有無でログインページorホームページ
          if (snapshot.hasData) {
            return const MyHomePage();
          } else {
            return const LoginPage();
          }
        });
  }
}
