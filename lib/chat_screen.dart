import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_store.dart';

class ChatScreen extends StatefulWidget {
  final String recipientEmail;
  final String recipientName;
  final String recipientImage;

  const ChatScreen({
    super.key,
    required this.recipientEmail,
    required this.recipientName,
    required this.recipientImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Box? _messagesBox;
  String _currentUserEmail = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _sendLike() async {
  if (_messagesBox == null || _currentUserEmail.isEmpty) return;

  final messages = _messages;
  messages.add({
    "senderEmail": _currentUserEmail,
    "text": "👍",
    "timestamp": DateTime.now().toIso8601String(),
    "read": false,
  });

  await _messagesBox!.put(_conversationKey, messages);
  setState(() {});
  _scrollToBottom();
}


  Future<void> _initChat() async {
    final box = await Hive.openBox('messagesBox');
    final currentUser = await UserStore.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _messagesBox = box;
      _currentUserEmail = currentUser?["email"] ?? "";
      _isLoading = false;
    });
    // Mark all incoming messages as read the moment the chat opens
    await _markAllAsRead();
    _scrollToBottom();
  }

  /// Order-independent conversation key so both sides share one thread
  String get _conversationKey {
    final sorted = [_currentUserEmail, widget.recipientEmail]..sort();
    return sorted.join("__");
  }

  List<Map<String, dynamic>> get _messages {
    final raw = _messagesBox?.get(_conversationKey, defaultValue: []);
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  /// Sets read = true on every message sent by the other person
  Future<void> _markAllAsRead() async {
    if (_messagesBox == null || _currentUserEmail.isEmpty) return;
    final messages = _messages;
    bool changed = false;
    final updated = messages.map((msg) {
      if (msg["senderEmail"] != _currentUserEmail && msg["read"] != true) {
        changed = true;
        return {...msg, "read": true};
      }
      return msg;
    }).toList();
    if (changed) {
      await _messagesBox!.put(_conversationKey, updated);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _messagesBox == null) return;

    final messages = _messages;
    messages.add({
      "senderEmail": _currentUserEmail,
      "text": text,
      "timestamp": DateTime.now().toIso8601String(),
      "read": false, // recipient hasn't opened it yet
    });

    await _messagesBox!.put(_conversationKey, messages);
    _messageController.clear();
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return "";
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  bool _isSameDay(String a, String b) {
    final da = DateTime.tryParse(a);
    final db = DateTime.tryParse(b);
    if (da == null || db == null) return false;
    return da.year == db.year && da.month == db.month && da.day == db.day;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 24, 105, 172)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color.fromARGB(255, 24, 105, 172),
              backgroundImage: widget.recipientImage.isNotEmpty
                  ? FileImage(File(widget.recipientImage))
                  : null,
              child: widget.recipientImage.isEmpty
                  ? Text(
                      widget.recipientName.isNotEmpty
                          ? widget.recipientName[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 24, 105, 172),
                  ),
                ),
                const Text(
                  "Active now",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call,
                color: Color.fromARGB(255, 24, 105, 172)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam,
                color: Color.fromARGB(255, 24, 105, 172)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages list ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder(
                    valueListenable: _messagesBox!.listenable(),
                    builder: (context, Box box, _) {
                      // Auto-mark as read whenever new messages arrive while open
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _markAllAsRead());

                      final messages = _messages;

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 60,
                                color: Color.fromARGB(180, 24, 105, 172),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Say hello to ${widget.recipientName}!",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 94, 92, 92),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent);
                        }
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe =
                              msg["senderEmail"] == _currentUserEmail;
                          final text = msg["text"] ?? "";
                          final timestamp = msg["timestamp"] ?? "";
                          final isRead = msg["read"] == true;
                          final isLast = index == messages.length - 1;

                          final showDateLabel = index == 0
                              ? true
                              : !_isSameDay(
                                  messages[index - 1]["timestamp"] ?? "",
                                  timestamp);

                          return Column(
                            children: [
                              if (showDateLabel)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  child: Text(
                                    _formatTime(timestamp),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              _buildMessageBubble(
                                text: text,
                                isMe: isMe,
                                isRead: isRead,
                                isLast: isLast,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),

          // ── Input bar ─────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color.fromARGB(255, 24, 105, 172), size: 28),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Color.fromARGB(255, 24, 105, 172), size: 26),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none,
                        color: Color.fromARGB(255, 24, 105, 172), size: 26),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: "Text Message",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: hasText ? _sendMessage : _sendLike,
                        child: Icon(
                          hasText ? Icons.send : Icons.thumb_up,
                          color: const Color.fromARGB(255, 24, 105, 172),
                          size: 28,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required bool isRead,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color.fromARGB(255, 24, 105, 172),
                  backgroundImage: widget.recipientImage.isNotEmpty
                      ? FileImage(File(widget.recipientImage))
                      : null,
                  child: widget.recipientImage.isEmpty
                      ? Text(
                          widget.recipientName.isNotEmpty
                              ? widget.recipientName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color.fromARGB(255, 24, 105, 172)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),

          // ── Read receipt (only on the last sent message) ───────────────
          if (isMe && isLast)
            Padding(
              padding: const EdgeInsets.only(top: 3, right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead
                        ? const Color.fromARGB(255, 24, 105, 172)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    isRead ? "Seen" : "Sent",
                    style: TextStyle(
                      fontSize: 11,
                      color: isRead
                          ? const Color.fromARGB(255, 24, 105, 172)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}