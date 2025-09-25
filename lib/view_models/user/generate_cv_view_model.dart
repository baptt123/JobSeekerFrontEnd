import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:job_seeker_frontend/services/generate_cv_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../dto/create_user_cv_dto.dart';
import '../../models/user-cv-entity.dart';

enum ViewState { idle, busy, error }

class GenerateCvViewModel extends ChangeNotifier {
  final GenerativeCVService apiService;

  GenerateCvViewModel({required this.apiService});

  ViewState _state = ViewState.idle;
  String? _errorMessage;
  Uint8List? _lastPdfBytes;
  UserCvEntity? _lastCreatedCv;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  Uint8List? get lastPdfBytes => _lastPdfBytes;
  UserCvEntity? get lastCreatedCv => _lastCreatedCv;

  void _setState(ViewState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> generatePdfFromPrompt(String prompt) async {
    try {
      _setState(ViewState.busy);
      _errorMessage = null;

      final bytes = await apiService.generateCV(prompt);
      _lastPdfBytes = bytes as Uint8List?;

      // Save to temporary file and open
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/generated_cv_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes as List<int>);
      await OpenFile.open(file.path);

      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> createCv(CreateUserCvDto dto) async {
    try {
      _setState(ViewState.busy);
      _errorMessage = null;

      final cv = await apiService.createCvWithKeywords(dto);
      _lastCreatedCv = cv;

      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
