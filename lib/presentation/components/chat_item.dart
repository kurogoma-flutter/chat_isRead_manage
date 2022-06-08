import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// チャット吹き出し（相手側）
class LeftBalloon extends StatelessWidget {
  const LeftBalloon({
    super.key,
    required this.content,
  });

  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const SizedBox(width: 16),
          DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              gradient: LinearGradient(
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                colors: [
                  Color.fromARGB(255, 31, 136, 99),
                  Color.fromARGB(255, 13, 171, 31),
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// チャット吹き出し（自分側）
class RightBalloon extends StatelessWidget {
  const RightBalloon({
    super.key,
    required this.content,
    required this.readUsers,
  });
  final String content;
  final List<dynamic> readUsers;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 10),
      child: Row(
        children: [
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final readUserCount = readUsers.length - 1;
              return Padding(
                padding: const EdgeInsets.only(top: 30, right: 8),
                child: Visibility(
                  visible: readUserCount > 0,
                  child: Text(
                    readUserCount.toString(),
                    style: const TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40),
                topLeft: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
              gradient: LinearGradient(
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                colors: [
                  Color.fromARGB(255, 47, 137, 233),
                  Color.fromARGB(255, 105, 79, 248),
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
