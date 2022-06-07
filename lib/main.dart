import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

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
    initialLocation: '/',
  );

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return const MyHomePage();
          } else {
            return const LoginPage();
          }
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サンプルSNS'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chatRoom')
              .orderBy('createdAt')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("データが見つかりません"));
            }
            // データ表示
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                final data = document.data()! as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(),
                    title: Text('${data['roomId']}'),
                    subtitle: Text('${data['latestMessage']}'),
                    trailing: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collectionGroup('chatMessage')
                          .where('roomId', isEqualTo: data['roomId'])
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final messageData = snapshot.data!.docs;
                          List<String> notReadChatList = [];
                          List readUserList = [];
                          int dataCount = 0;
                          for (final message in messageData) {
                            notReadChatList.add(message.id.toString());

                            readUserList = message['readUsers'];

                            if (!readUserList.contains(
                                FirebaseAuth.instance.currentUser!.uid)) {
                              dataCount++;
                            }
                          }
                          data['notReadChatList'] = notReadChatList;

                          return Visibility(
                              visible: dataCount > 0,
                              child: CircleAvatar(
                                maxRadius: 8,
                                backgroundColor: Colors.pink,
                                child: Text(
                                  dataCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ));
                        }
                        return const SizedBox();
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatDetailPage(
                              roomId: data['roomId'],
                              notReadChatList: data['notReadChatList'],
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final List<String> notReadChatList;
  final String roomId;

  const ChatDetailPage({
    Key? key,
    required this.notReadChatList,
    required this.roomId,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  @override
  initState() {
    super.initState();
  }

  Future<void> _readChatMessage() async {
    for (final chatDocumentId in widget.notReadChatList) {
      // FirebaseFirestore.instance
      //     .collection('chatRoom')
      //     .doc(widget.roomId)
      //     .collection('chatMessage')
      //     .doc(chatDocumentId)
      //     .update({'readUsers': readUsers});
      _getReadUserList(chatDocumentId);
    }
  }

  Future _getReadUserList(String chatDocumentId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(widget.roomId)
        .collection('chatMessage')
        .doc(chatDocumentId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャットメッセージ'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chatRoom')
              .doc(widget.roomId)
              .collection('chatMessage')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("データが見つかりません"));
            }
            // 既読処理
            _readChatMessage();
            // データ表示
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                final data = document.data()! as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(),
                    title: Text('${data['message']}'),
                    subtitle: Text('${data['uid']}'),
                    onTap: () {},
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
