import 'package:flutter/material.dart';

enum UploadCVStatus { init, uploaded, uploading, success }

class UploadCVViewModel extends ChangeNotifier {
  UploadCVStatus _status = UploadCVStatus.init;
  UploadCVStatus get status => _status;
  String? fileName;

  void selectFile(String name) {
    fileName = name;
    _status = UploadCVStatus.uploaded;
    notifyListeners();
  }

  void removeFile() {
    fileName = null;
    _status = UploadCVStatus.init;
    notifyListeners();
  }

  Future<void> submit() async {
    _status = UploadCVStatus.uploading;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _status = UploadCVStatus.success;
    notifyListeners();
  }

  void reset() {
    fileName = null;
    _status = UploadCVStatus.init;
    notifyListeners();
  }
}
