import 'package:tooGoodToWaste/dto/User.dart';

class Message {
  final String message;
  final User user;

  const Message({
    required this.message,
    required this.user
  });
}