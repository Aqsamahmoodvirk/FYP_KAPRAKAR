import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../repositories/chat_repository.dart';

class ChatService extends ChangeNotifier {
  final ChatRepository _chatRepository;
  IO.Socket? _socket;

  ChatService(this._chatRepository);

  final String serverUrl = "http://172.23.181.1:5000";

  bool _isLoading = false;
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _currentMessages = [];
  String? _activeChatId;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get chats => _chats;
  List<Map<String, dynamic>> get currentMessages => _currentMessages;

  void connectSocket(String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      if (kDebugMode) print("Socket.io Connected: ${_socket!.id}");
      _socket!.emit('setup', userId);
    });

    _socket!.on('receive message', (data) {
      final String incomingChatId = data['chatId'];

      // If the incoming message belongs to the currently active chat screen
      if (incomingChatId == _activeChatId) {
        _currentMessages.add(Map<String, dynamic>.from(data));
      } else {
        // Find chat and increment unread count
        final chatIndex = _chats.indexWhere((c) => c['_id'] == incomingChatId);
        if (chatIndex != -1) {
          int currentUnread = _chats[chatIndex]['unreadCount'] ?? 0;
          _chats[chatIndex]['unreadCount'] = currentUnread + 1;
        }
      }

      // Always update last message in chat list
      final chatIndex = _chats.indexWhere((c) => c['_id'] == incomingChatId);
      if (chatIndex != -1) {
        _chats[chatIndex]['lastMessage'] = data['text'];
      }

      notifyListeners();
    });

    _socket!.on('message deleted', (data) {
      final messageId = data is Map ? data['messageId'] : data.toString();
      final chatId = data is Map ? data['chatId'] : null;

      _currentMessages.removeWhere((msg) => msg['_id'] == messageId);

      // Update chat list lastMessage
      if (chatId != null) {
        final chatIndex = _chats.indexWhere((c) => c['_id'] == chatId);
        if (chatIndex != -1) {
          String newLastMessage = "";
          if (_currentMessages.isNotEmpty) {
            newLastMessage = _currentMessages.last['text'] ?? "";
          }
          _chats[chatIndex]['lastMessage'] = newLastMessage;
        }
      }

      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) print("Socket.io Disconnected");
    });
  }

  void joinChatRoom(String chatId) {
    _activeChatId = chatId;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join chat', chatId);
    }
  }

  void leaveChatRoom() {
    _activeChatId = null;
  }

  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      // Optimistically clear local badge
      final chatIndex = _chats.indexWhere((c) => c['_id'] == chatId);
      if (chatIndex != -1) {
        _chats[chatIndex]['unreadCount'] = 0;
        notifyListeners();
      }

      await _chatRepository.markChatAsRead(chatId, userId);
    } catch (e) {
      if (kDebugMode) print("Failed to mark chat as read: $e");
    }
  }

  Future<void> fetchUserChats(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _chats = await _chatRepository.getUserChats(userId);
    } catch (e) {
      if (kDebugMode) print("Error fetching chats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String chatId) async {
    try {
      _currentMessages = await _chatRepository.getMessages(chatId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error fetching messages: $e");
    }
  }

  Future<Map<String, dynamic>> accessChat(
    String currentUserId,
    String otherUserId,
  ) async {
    return await _chatRepository.accessChat(currentUserId, otherUserId);
  }

  Future<void> emitMessage(Map<String, dynamic> messageData) async {
    // Optimistically add to UI
    _currentMessages.add(messageData);
    notifyListeners();

    // Send to Socket Server
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send message', messageData);
    }

    // Send to REST API
    try {
      final savedMessage = await _chatRepository.sendMessage(messageData);
    } catch (e) {
      if (kDebugMode) print("Failed to save message: $e");
    }
  }

  Future<void> unsendMessage(String messageId, String chatId) async {
    try {
      // Remove optimistically
      _currentMessages.removeWhere(
        (msg) => msg['_id'] == messageId || msg['_id'] == null,
      );

      // Update chat list lastMessage for the sender
      final chatIndex = _chats.indexWhere((c) => c['_id'] == chatId);
      if (chatIndex != -1) {
        String newLastMessage = "";
        if (_currentMessages.isNotEmpty) {
          newLastMessage = _currentMessages.last['text'] ?? "";
        }
        _chats[chatIndex]['lastMessage'] = newLastMessage;
      }

      notifyListeners();

      // Emit socket event to delete on other client
      if (_socket != null && _socket!.connected) {
        _socket!.emit('unsend message', {
          'messageId': messageId,
          'chatId': chatId,
        });
      }

      // REST API
      await _chatRepository.deleteMessage(messageId);
    } catch (e) {
      if (kDebugMode) print("Failed to unsend message: $e");
      // Could re-fetch messages here on failure
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRepository.deleteChat(chatId);
      _chats.removeWhere((chat) => chat['_id'] == chatId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Failed to delete chat: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
