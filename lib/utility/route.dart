

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/', // ベース：認証状態を識別してホーム画面orログインへ遷移させる
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
      ),
      // GoRoute(
      //     path: '/chatList/detail',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return ChatDetailPage(roomId: roomId, readUsers: readUsers);
      //     }),
    ],
    // ignore: avoid_redundant_argument_values
    initialLocation: '/',
  );
