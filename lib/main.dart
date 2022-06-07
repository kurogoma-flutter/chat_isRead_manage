import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
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
                          Map<String, List<String>> notReadChatData = {};
                          int dataCount = 0;
                          for (final message in messageData) {
                            if (notReadChatData.containsKey(data['roomId'])) {
                              notReadChatData[data['roomId']] = [
                                ...notReadChatData[data['roomId']]!,
                                message.id.toString()
                              ];
                            } else {
                              notReadChatData[data['roomId']] = [
                                message.id.toString()
                              ];
                            }

                            List messageList = message['readUsers'];
                            if (!messageList
                                .contains('L12aTxOq1haZum5elgs7sbnZLhI3')) {
                              dataCount++;
                            }
                          }

                          data['notReadChatData'] = notReadChatData;

                          return Visibility(
                              visible: dataCount > 0,
                              child: CircleAvatar(
                                maxRadius: 8,
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  dataCount.toString(),
                                  style: const TextStyle(
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
                      if (data.containsKey('notReadChatData')) {
                        print(data['notReadChatData']);
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
