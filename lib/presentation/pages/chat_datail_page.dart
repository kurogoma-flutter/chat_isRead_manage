import 'package:chat_app_read/logic/chat_service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  const ChatDetailPage({
    super.key,
    required this.notReadChatList,
    required this.roomId,
  });
  final List<String> notReadChatList;
  final String roomId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  @override
  Widget build(BuildContext context) {
    final chatViewModel = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('チャットメッセージ'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: chatViewModel.chatMessageStream(widget.roomId),
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
            // 既読処理
            chatViewModel.readChatMessage(
              widget.notReadChatList,
              widget.roomId,
            );
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
