import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/pages/chat_datail_page.dart';

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
  void pushToChatDetailPage(BuildContext context, Map<String, dynamic> data) {
    Navigator.of(context).push<dynamic>(
      MaterialPageRoute<dynamic>(
        builder: (context) {
          return ChatDetailPage(
            roomId: data['roomId'] as String,
            notReadChatList: data['notReadChatList'] as List<String>,
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

  Future<List<String>> fetchReadUserList(
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
    return data!['readUsers'] as List<String>;
  }

  Stream<QuerySnapshot> chatMessageStream(String roomId) {
    return FirebaseFirestore.instance
              .collection('chatRoom')
              .doc(roomId)
              .collection('chatMessage')
              .snapshots();
  } 
}
