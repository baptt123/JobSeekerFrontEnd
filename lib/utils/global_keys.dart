import 'package:flutter/material.dart';
class ManagingGlobalKey{
  // Key này sẽ giúp chúng ta truy cập vào Navigator từ bất kỳ đâu (kể cả trong DioClient)
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
