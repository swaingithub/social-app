import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/providers/chat_provider.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider()..loadMessages(conversationId),
      child: _ChatView(conversationId: conversationId),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String conversationId;
  const _ChatView({required this.conversationId});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                if (chat.loading) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final m = chat.messages[chat.messages.length - 1 - index];
                    return ListTile(
                      title: Text(m.sender['username'] ?? ''),
                      subtitle: Text(m.text.isNotEmpty ? m.text : '[media]'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Message...'
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    await Provider.of<ChatProvider>(context, listen: false)
                        .sendMessage(widget.conversationId, text: text);
                    _controller.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


