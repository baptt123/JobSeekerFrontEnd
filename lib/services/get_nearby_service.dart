import 'package:dio/dio.dart';

import '../models/place-entity.dart';

class GetNearbyService {
  final Dio _dio = Dio();
  // 👉 Thay bằng API key của bạn
  final String _apiKey = '6977f01c1ff140ff9c6fde2f5d244e74';

  /// Bước 1: Lấy toạ độ từ text người dùng nhập
  Future<Map<String, double>> getCoordinates(String text) async {
    const String url = 'https://api.geoapify.com/v1/geocode/search';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'text': text,
          'limit': 1,
          'apiKey': _apiKey,
        },
      );

      final features = response.data['features'];
      if (features != null && features.isNotEmpty) {
        final coords = features[0]['geometry']['coordinates'];
        // Geoapify trả về [lon, lat]
        return {
          'lon': coords[0].toDouble(),
          'lat': coords[1].toDouble(),
        };
      } else {
        throw Exception('Không tìm thấy địa điểm.');
      }
    } catch (e) {
      print('❌ Lỗi Geocoding: $e');
      rethrow;
    }
  }

  /// Bước 2: Lấy danh sách công ty lân cận từ toạ độ
  Future<List<PlaceEntity>> getNearbyCompanies(double lat, double lon) async {
    const String url = 'https://api.geoapify.com/v2/places';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'categories': 'commercial.office',
          'filter': 'circle:$lon,$lat,5000', // 5km bán kính
          'bias': 'proximity:$lon,$lat',
          'limit': 20,
          'apiKey': _apiKey,
        },
      );

      final features = response.data['features'];
      if (features != null) {
        return features
            .map<PlaceEntity>((f) => PlaceEntity.fromGeoapifyJson(f))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi Places API: $e');
      rethrow;
    }
  }
}
