import 'package:chat_app_read/logic/chat_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/auth_view_model.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // viewModel定義
    final authViewModel = ref.read(authPageViewModelProvider);
    final chatViewModel = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('チャットアプリの既読管理'),
        actions: [
          // サインアウト用ボタン
          IconButton(
            onPressed: () {
              authViewModel.signOut(context);
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 監視対象。ここのクエリで取得できるデータに変化があった場合再描画される
        stream: chatViewModel.chatRoomListStream,
        builder: (context, snapshot) {
          // .connectionStateで接続状況の取得ができるので、これで色々切り替えても良い
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // エラーが発生した時の処理（エラー画面遷移など）
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // Streamのクエリ条件でデータが0件だった場合
          if (!snapshot.hasData) {
            return const Center(child: Text('データが見つかりません'));
          }
          // データ表示
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // こうすることでdata['firestoreで設定したフィールドのキー']が使える
              final data = document.data()! as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(),
                  title: Text('${data['roomName']}'),
                  subtitle: Text('${data['latestMessage']}'),
                  // 通知管理用にStreamBuilderをネストする
                  trailing: StreamBuilder<QuerySnapshot>(
                    // 未読状態の数を取得する
                    stream: chatViewModel.notReadChatStream(data),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        // Note: ここで扱う変数はListView単体向けの変数のため、こういう時にhooks使うと良さそう
                        final messageData = snapshot.data!.docs;
                        final notReadChatList = <String>[]; // 次画面に引き渡す未読チャットリスト
                        var readUserList = <dynamic>[]; // 既読ユーザーリスト
                        var notReadCount = 0; // 未読数カウント
                        // チャット一覧から未読未読ユーザーの取得
                        for (final message in messageData) {
                          notReadChatList.add(message.id);
                          readUserList = message['readUsers'] as List;
                          if (!readUserList.contains(
                            FirebaseAuth.instance.currentUser!.uid,
                          )) {
                            notReadCount++;
                          }
                        }
                        data['notReadChatList'] = notReadChatList;
                        // 未読数を表示する数字のウィジェット
                        return NotReadChatCountWidget(dataCount: notReadCount);
                      }
                      // データが取得できなかった場合の仮置き
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
        },
      ),
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
