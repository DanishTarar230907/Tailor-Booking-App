import 'package:flutter/material.dart';
import '../models/measurement.dart';

class CommunicationSection extends StatefulWidget {
  final Measurement measurement;
  final Function(Measurement) onUpdate;
  final bool isTailor;

  const CommunicationSection({
    super.key,
    required this.measurement,
    required this.onUpdate,
    this.isTailor = true,
  });

  @override
  State<CommunicationSection> createState() => _CommunicationSectionState();
}

class _CommunicationSectionState extends State<CommunicationSection> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.measurement;
    
    // Auto-scroll to bottom on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Column(
      children: [
        // Message List Area
        Container(
          constraints: const BoxConstraints(maxHeight: 250), // Taller
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: m.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 32, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: m.messages.length,
                  itemBuilder: (context, index) {
                    final msg = m.messages[index];
                    final sender = msg['sender'];
                    // "Me" depends on who is viewing passing in isTailor
                    final isMe = widget.isTailor ? sender == 'tailor' : sender == 'customer';
                    
                    final date = DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now();
                    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[600] : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                          border: isMe ? null : Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        // Input Area
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a reply...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, size: 20),
                color: Colors.white,
                tooltip: 'Send Reply',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    final newMsg = {
      'sender': widget.isTailor ? 'tailor' : 'customer',
      'text': _controller.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Create new list to ensure immutability triggers updates if needed
    final updatedMsgs = List<Map<String, dynamic>>.from(widget.measurement.messages)..add(newMsg);
    final updated = widget.measurement.copyWith(messages: updatedMsgs);
    
    widget.onUpdate(updated);
    _controller.clear();
    
    // Scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
}
