import 'package:chat_app_read/logic/chat_service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/auth_service_provider.dart';
import 'chat_datail_page.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // viewModel定義
    final authViewModel = ref.read(authPageViewModelProvider);
    final chatViewModel = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('サンプルSNS'),
        actions: [
          IconButton(
            onPressed: () {
              authViewModel.signOut(context);
            },
            icon: const Icon(Icons.signpost_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: chatViewModel.chatRoomListStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('データが見つかりません'));
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
                      stream: chatViewModel.notReadChatStream(data),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (snapshot.hasData) {
                          // Note: ここで扱う変数はListView単体向けの変数のため、こういう時にhooks使うと良さそう
                          final messageData = snapshot.data!.docs;
                          final notReadChatList = <String>[];
                          var readUserList = <String>[];
                          var dataCount = 0;
                          for (final message in messageData) {
                            notReadChatList.add(message.id);
                            readUserList = message['readUsers'] as List<String>;
                            if (!readUserList.contains(
                                FirebaseAuth.instance.currentUser!.uid)) {
                              dataCount++;
                            }
                          }
                          data['notReadChatList'] = notReadChatList;

                          return NotReadChatCountWidget(dataCount: dataCount);
                        }
                        return const SizedBox();
                      },
                    ),
                    onTap: () {
                      // Todo: GoRouterに組み込みたいが、配列の受け渡しができない
                      chatViewModel.pushToChatDetailPage(context, data);
                    },
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}

/// 未読のチャット数を表示する
class NotReadChatCountWidget extends StatelessWidget {
  const NotReadChatCountWidget({
    super.key,
    required this.dataCount,
  });

  final int dataCount;

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
