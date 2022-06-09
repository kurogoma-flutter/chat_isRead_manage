import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/pages/chat_datail_page.dart';

// ignore: lines_longer_than_80_chars
final chatViewModelProvider = ChangeNotifierProvider<ChatPageViewModel>(
  (ref) {
    return ChatPageViewModel();
  },
);

class ChatPageViewModel extends ChangeNotifier {
  ChatPageViewModel();

  Stream<QuerySnapshot> chatRoomListStream = FirebaseFirestore.instance
      .collection('chatRoom')
      .orderBy('createdAt')
      .snapshots();

  Stream<QuerySnapshot> notReadChatStream(Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collectionGroup('chatMessage')
        .where('roomId', isEqualTo: data['roomId'])
        .snapshots();
  }

  // Todo: GoRouterに組み込みたいが、配列の受け渡しができない
  void pushToChatDetailPage(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    Navigator.of(context).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (context) {
          return ChatDetailPage(
            roomId: data['roomId'] as String,
            notReadChatList: data['notReadChatList'] as List<String>,
            roomName: data['roomName'] as String,
          );
        },
      ),
    );
  }

  Future<void> readChatMessage(
    List<String> notReadChatList,
    String roomId,
  ) async {
    for (final chatDocumentId in notReadChatList) {
      // ignore: lines_longer_than_80_chars
      final readUsers = await fetchReadUserList(chatDocumentId, roomId);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      if (!readUsers.contains(uid)) {
        readUsers.add(uid);
        await FirebaseFirestore.instance
            .collection('chatRoom')
            .doc(roomId)
            .collection('chatMessage')
            .doc(chatDocumentId)
            .update({'readUsers': readUsers});
      }
    }
  }

  Future<List<dynamic>> fetchReadUserList(
    String chatDocumentId,
    String roomId,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .collection('chatMessage')
        .doc(chatDocumentId)
        .get();

    final data = snapshot.data();
    return data!['readUsers'] as List<dynamic>;
  }

  Stream<QuerySnapshot> chatMessageStream(String roomId) {
    return FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .collection('chatMessage')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 入力テキスト
  String chatInputText = '';

  // ignore: use_setters_to_change_properties
  void handleText(String value) {
    chatInputText = value;
  }

  // フォームリセット
  void clearInput(TextEditingController textEditingController) {
    textEditingController.clear();
    chatInputText = '';
    notifyListeners();
  }

  Future<void> postChatMessage(String roomId) async {
    // テキストが空白でなけでば送信可能
    if (chatInputText.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(roomId)
          .collection('chatMessage')
          .add(<String, dynamic>{
        'uid': uid,
        'createdAt': Timestamp.now(),
        'message': chatInputText,
        'roomId': roomId,
        'readUsers': [uid]
      });
      // 親のchatRoomコレクションを更新
      await updateChatRoomInfo(roomId);
    }
  }

  Future<void> updateChatRoomInfo(String roomId) async {
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .update(<String, dynamic>{
      'latestMessageAt': Timestamp.now(),
      'latestMessage': chatInputText,
    });
  }
}
