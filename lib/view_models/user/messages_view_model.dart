import 'package:flutter/material.dart';

class MessagesViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> messages = [
    // example: {'name': 'Andy Robertson', 'snippet': 'Please send your CV...', 'time': '5m ago'}
  ];
}
