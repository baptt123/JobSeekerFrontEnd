import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Lấy chiều rộng màn hình
    final screenWidth = MediaQuery.of(context).size.width;

    // 2. Tính padding ngang dựa trên chiều rộng (ví dụ: 5% chiều rộng)
    final horizontalPadding = screenWidth * 0.05;

    return Container(
      width: double.infinity, // Đảm bảo container chiếm hết chiều rộng
      // 3. Áp dụng padding động cho trái/phải, giữ cố định trên/dưới
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 20.0, // Giữ cố định để không phá vỡ layout
        bottom: 60.0, // Giữ cố định cho SearchCard
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
          // 4. Dùng FittedBox để text tự động co giãn
          FittedBox(
            fit: BoxFit.scaleDown, // Tự động co nhỏ text nếu cần
            child: const Text(
              "Let's find job",
              style: TextStyle(
                fontSize: 28, // Giữ cỡ chữ lớn làm cơ sở
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1, // Đảm bảo text luôn trên 1 dòng
            ),
          ),
          // Giữ cố định chiều cao này
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}