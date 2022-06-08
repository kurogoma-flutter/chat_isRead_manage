import 'package:chat_app_read/logic/chat_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextInputWidget extends ConsumerStatefulWidget {
  const TextInputWidget({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends ConsumerState<TextInputWidget> {
  // テキスト文字列の操作
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatViewModel = ref.watch(chatViewModelProvider);
    final chatPageViewModelRead = ref.read(chatViewModelProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 68,
      child: Row(
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextField(
                controller: textEditingController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                maxLength: 400,
                onChanged: (e) => chatPageViewModelRead.handleText(e),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await chatViewModel.postChatMessage(widget.roomId);
              chatViewModel.clearInput(textEditingController);
            },
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
