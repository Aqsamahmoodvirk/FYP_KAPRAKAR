import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../services/chat_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../services/journey_service.dart';
import 'dart:ui';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _chatId;
  String _otherUserName = "Chat";
  String _myUserId = "";

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _chatId = args['chatId'];
      _otherUserName = args['otherUserName'] ?? "Unknown";
      
      final journeyService = context.read<JourneyService>();
      final chatService = context.read<ChatService>();

      _myUserId = journeyService.currentUserId ?? "";

      if (_chatId != null) {
        chatService.joinChatRoom(_chatId!);
        chatService.markChatAsRead(_chatId!, _myUserId);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await chatService.fetchMessages(_chatId!);
          _scrollToBottom();
        });
      }
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    
    if (mounted) {
      context.read<ChatService>().leaveChatRoom();
    }
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatId == null) return;

    final chatService = context.read<ChatService>();
    final msgData = {
      'chatId': _chatId,
      'senderId': _myUserId,
      'text': text,
    };

    chatService.emitMessage(msgData);
    _messageController.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteChat() async {
    final chatService = context.read<ChatService>();
    if (_chatId == null) return;
    
    try {
      await chatService.deleteChat(_chatId!);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete chat: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("Are you sure you want to delete this entire conversation? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteChat();
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmUnsendMessage(String messageId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Unsend Message", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                if (_chatId != null) {
                  context.read<ChatService>().unsendMessage(messageId, _chatId!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null) {
      return Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.errorLoadingChat)));
    }

    final chatService = context.watch<ChatService>();
    final messages = chatService.currentMessages;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.6),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                    Theme.of(context).colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  _otherUserName.isNotEmpty ? _otherUserName.substring(0, 1).toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _otherUserName, 
                  style: TextStyle(
                    fontSize: 17, 
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )
                ),
                Text(
                  "Active now", 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  )
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: _confirmDeleteChat,
            tooltip: "Delete Chat",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Elegant subtle background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(
              left: AppSpacing.md, 
              right: AppSpacing.md, 
              top: 110, // Space for glass AppBar
              bottom: 120, // Space for glass input area
            ),
            itemCount: messages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildChatHeader();
              }
              final msg = messages[index - 1];
              return _buildMessageBubble(msg);
            },
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "Messages are end-to-end encrypted.",
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    // msg['senderId'] can be a string or an object depending on populate
    final senderObj = msg['senderId'];
    final String senderIdStr = senderObj is Map ? senderObj['_id'] : senderObj.toString();
    final bool isMe = senderIdStr == _myUserId;
    final String messageId = msg['_id'] ?? '';
    
    final String text = msg['text'] ?? '';
    String time = 'Just now';
    if (msg['createdAt'] != null) {
      try {
        final DateTime parsed = DateTime.parse(msg['createdAt'].toString()).toLocal();
        time = DateFormat('h:mm a').format(parsed);
      } catch (e) {
        time = '';
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe && messageId.isNotEmpty ? () => _confirmUnsendMessage(messageId) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? null : Colors.white,
            gradient: isMe 
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    Theme.of(context).colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
            boxShadow: [
              if (isMe)
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(6),
              bottomRight: isMe ? const Radius.circular(6) : const Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, 
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      )
                    ),
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeAMessage,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        Theme.of(context).colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
