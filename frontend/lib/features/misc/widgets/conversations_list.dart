import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/providers/chat_provider.dart';
import 'package:go_router/go_router.dart';

class ConversationsList extends StatelessWidget {
  const ConversationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        if (chat.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (chat.conversations.isEmpty) {
          return const Center(child: Text('No conversations yet'));
        }
        return ListView.separated(
          itemCount: chat.conversations.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, index) {
            final c = chat.conversations[index];
            final other = c.participants.firstWhere(
              (p) => true,
              orElse: () => {'username': 'User', 'profileImageUrl': ''},
            );
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (other['profileImageUrl'] ?? '').isNotEmpty
                    ? NetworkImage(other['profileImageUrl'])
                    : null,
                child: (other['profileImageUrl'] ?? '').isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(other['username'] ?? 'User'),
              subtitle: Text(c.lastMessage),
              onTap: () => context.go('/chat', extra: c.id),
            );
          },
        );
      },
    );
  }
}


