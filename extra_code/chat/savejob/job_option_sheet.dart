import 'package:flutter/material.dart';

class JobOptionsSheet extends StatelessWidget {
  final VoidCallback onSendMessage;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onApply;

  const JobOptionsSheet({
    super.key,
    required this.onSendMessage,
    required this.onShare,
    required this.onDelete,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(height: 4, width: 38, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3))),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.send, color: Colors.deepPurple),
            title: Text('Send message'),
            onTap: onSendMessage,
          ),
          ListTile(
            leading: Icon(Icons.share_outlined, color: Colors.deepPurple),
            title: Text('Shared'),
            onTap: onShare,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.deepPurple),
            title: Text('Delete'),
            onTap: onDelete,
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white), SizedBox(width: 8),
                  Text('Apply', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
              onPressed: onApply,
            ),
          ),
        ],
      ),
    );
  }
}
