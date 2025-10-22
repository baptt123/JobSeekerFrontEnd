import 'package:flutter/material.dart';

import '../../models/place-entity.dart';
import '../../services/get_nearby_service.dart';

enum ViewState { initial, loading, loaded, error }

class PlacesViewModel extends ChangeNotifier {
  final GetNearbyService _api = GetNearbyService();

  List<PlaceEntity> _places = [];
  List<PlaceEntity> get places => _places;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> findNearbyCompanies(String locationText) async {
    if (locationText.isEmpty) {
      _errorMessage = "Vui lòng nhập địa điểm";
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    _errorMessage = '';
    _places = [];
    notifyListeners();

    try {
      // 1️⃣ Lấy toạ độ
      final coords = await _api.getCoordinates(locationText);
      final lat = coords['lat']!;
      final lon = coords['lon']!;

      // 2️⃣ Lấy danh sách công ty lân cận
      _places = await _api.getNearbyCompanies(lat, lon);

      if (_places.isEmpty) {
        _errorMessage = "Không tìm thấy công ty lân cận nào.";
        _state = ViewState.error;
      } else {
        _state = ViewState.loaded;
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi: ${e.toString()}';
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
