import 'package:flutter/material.dart';
import '../models/complaint.dart';
import 'package:intl/intl.dart';

class ConversationThread extends StatelessWidget {
  final List<ComplaintReply> replies;
  final ScrollController? scrollController;

  const ConversationThread({
    Key? key,
    required this.replies,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No replies yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: replies.length,
      itemBuilder: (context, index) {
        final reply = replies[index];
        return _buildMessageBubble(reply, context);
      },
    );
  }

  Widget _buildMessageBubble(ComplaintReply reply, BuildContext context) {
    final isFromTailor = reply.isFromTailor;
    final alignment = isFromTailor ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isFromTailor
        ? Colors.grey.shade100
        : Theme.of(context).primaryColor.withOpacity(0.1);
    final textColor = isFromTailor ? Colors.black87 : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isFromTailor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // Sender name
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFromTailor ? Icons.support_agent : Icons.person,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reply.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromTailor ? 4 : 16),
                  bottomRight: Radius.circular(isFromTailor ? 16 : 4),
                ),
                border: Border.all(
                  color: isFromTailor
                      ? Colors.grey.shade300
                      : Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(reply.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
