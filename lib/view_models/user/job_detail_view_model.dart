import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart'; // Import Dio để bắt lỗi

import '../../models/comments-entity.dart';
import '../../models/job-entity.dart';
import '../../models/user-cv-entity.dart';
import '../../services/job_service.dart';
import '../../services/job_application_service.dart';
import '../../services/cv_service.dart';
import '../../services/comment_service.dart';
import 'home_view_model.dart';
import 'save_job_view_model.dart';

class JobDetailViewModel extends ChangeNotifier {
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobService _jobService = JobService();
  final CvGenerationService _cvService = CvGenerationService();
  final CommentService _commentService = CommentService();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Job State ---
  JobEntity? _job;
  JobEntity? get job => _job;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Apply State ---
  bool _isLoadingCvs = false;
  bool get isLoadingCvs => _isLoadingCvs;
  List<UserCVEntity> _myCvs = [];
  List<UserCVEntity> get myCvs => _myCvs;
  bool _isApplying = false;
  bool get isApplying => _isApplying;
  bool _isApplied = false;
  bool get isApplied => _isApplied;

  // --- Save State ---
  bool _isSaved = false;
  bool get isSaved => _isSaved;
  bool _isSaving = false;

  // --- COMMENT STATE ---
  List<CommentEntity> _comments = [];
  List<CommentEntity> get comments => _comments;
  bool _isLoadingComments = false;
  bool get isLoadingComments => _isLoadingComments;

  // --- AUTH STATE ---
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;

  // 1. Fetch Job Detail & Comments
  Future<void> fetchJobDetail(String jobTitle) async {
    _isLoading = true;
    notifyListeners();
    try {
      _job = await _jobService.getJobDetail(jobTitle);

      if (_job != null) {
        _isApplied = _job!.isApplied;
        _isSaved = _job!.isSaved;

        // Gọi loadComments và checkLogin song song
        await Future.wait([
          loadComments(_job!.jobId),
          checkLoginStatus(),
        ]);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Logic Comment ---

  Future<void> loadComments(int jobId) async {
    _isLoadingComments = true;
    notifyListeners();
    try {
      _comments = await _commentService.getComments(jobId);
    } catch (e) {
      debugPrint("Lỗi lấy comment: $e");
      // Có thể set _comments = [] nếu muốn an toàn
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      _isLoggedIn = (token != null && token.isNotEmpty);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi check login status: $e");
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // ✅ Thay đổi: Trả về bool để UI biết có thành công hay không
  Future<bool> sendComment(BuildContext context, String content) async {
    if (_job == null || content.trim().isEmpty) return false;

    try {
      await _commentService.postComment(_job!.jobId, content);

      // Gửi thành công -> Reload list
      await loadComments(_job!.jobId);
      return true;

    } on DioException catch (e) {
      String msg = "Gửi bình luận thất bại";
      if (e.response?.statusCode == 401) {
        msg = "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.";
        _isLoggedIn = false; // Cập nhật lại trạng thái UI ngay
        notifyListeners();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi không xác định: $e"), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  // ... (Các hàm fetchMyCvs, submitApplication, toggleSaveJob GIỮ NGUYÊN) ...
  // Để tiết kiệm không gian, tôi giả định các hàm bên dưới không đổi
  // Nếu bạn cần tôi paste lại toàn bộ file, hãy báo nhé.

  // 2. Lấy danh sách CV
  Future<void> fetchMyCvs() async {
    _isLoadingCvs = true;
    _myCvs = [];
    notifyListeners();
    try {
      _myCvs = await _cvService.getMyCvs();
    } catch (e) {
      debugPrint("Lỗi lấy CV: $e");
    } finally {
      _isLoadingCvs = false;
      notifyListeners();
    }
  }

  // 3. Gửi Ứng Tuyển
  Future<bool> submitApplication(BuildContext context, int? selectedCvId, String coverLetter) async {
    if (_isApplying || _job == null) return false;
    if (selectedCvId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng chọn 1 CV để ứng tuyển"), backgroundColor: Colors.orange)
        );
      }
      return false;
    }
    _isApplying = true;
    notifyListeners();
    try {
      await _jobApplicationService.applyForJob(
        jobId: _job!.jobId,
        cvId: selectedCvId,
        coverLetter: coverLetter,
      );
      _isApplied = true;
      _isApplying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isApplying = false;
      notifyListeners();
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red)
        );
      }
      return false;
    }
  }

  // 4. Toggle Save
  Future<void> toggleSaveJob(BuildContext context) async {
    if (_isSaving || _job == null) return;
    _isSaving = true;
    final originalState = _isSaved;
    _isSaved = !_isSaved;
    notifyListeners();
    try {
      if (_isSaved) {
        await _jobService.saveJob(_job!.jobId);
      } else {
        await _jobService.unsaveJob(_job!.jobId);
      }
      if (context.mounted) {
        context.read<HomeViewModel>().fetchInitialData();
        context.read<SavedJobsViewModel>().fetchSavedJobs();
      }
    } catch (e) {
      _isSaved = originalState;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi thao tác"), backgroundColor: Colors.red)
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}