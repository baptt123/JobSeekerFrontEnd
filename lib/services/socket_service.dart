import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message-entity.dart';
import '../utils/constant_api.dart';

class SocketService {
  late IO.Socket socket;

  void connect(int userId) {
    socket = IO.io(ConstantAPI.baseUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('connected to socket');
      socket.emit('join', {'userId': userId});
    });

    socket.on('joined', (data) => print("Joined room ${data['room']}"));
  }

  void sendMessage(int senderId, int receiverId, String content) {
    socket.emit('send_message',
        {'sender_id': senderId, 'receiver_id': receiverId, 'content': content});
  }

  void onNewMessage(void Function(MessageEntity) callback) {
    socket.on('new_message', (data) {
      callback(MessageEntity.fromJson(data));
    });
  }

  void disconnect() => socket.disconnect();
}
