import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  // 1. Thêm biến nhận tên/email
  final String userName;

  // 2. Cập nhật constructor
  const HomeHeader({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 20.0,
        bottom: 60.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF008080),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              // 3. Hiển thị text động: "Let's find job, <email/Guest>"
              "Let's find job, $userName",
              style: const TextStyle(
                fontSize: 24, // Giảm nhẹ font size để đỡ tràn nếu email dài
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}