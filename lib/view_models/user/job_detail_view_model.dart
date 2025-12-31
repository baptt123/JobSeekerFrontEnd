import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../models/comments-entity.dart';
import '../../models/job-entity.dart';
import '../../models/user-cv-entity.dart';
import '../../services/job_service.dart';
import '../../services/job_application_service.dart';
import '../../services/cv_service.dart'; // Sử dụng CvService chuẩn
import '../../services/comment_service.dart';
import 'home_view_model.dart';
import 'save_job_view_model.dart';

class JobDetailViewModel extends ChangeNotifier {
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobService _jobService = JobService();
  final CvGenerationService _cvService = CvGenerationService(); // Sửa lại thành CvService cho khớp file gốc
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
  List<UserCvEntity> _myCvs = []; // Chuẩn hóa tên Entity
  List<UserCvEntity> get myCvs => _myCvs;
  bool _isApplying = false;
  bool get isApplying => _isApplying;
  bool _isApplied = false;
  bool get isApplied => _isApplied;

  // --- Save State ---
  bool _isSaved = false;
  bool get isSaved => _isSaved;
  bool _isSaving = false;

  // --- COMMENT STATE (Mới) ---
  List<CommentEntity> _comments = [];
  List<CommentEntity> get comments => _comments;
  bool _isLoadingComments = false;
  bool get isLoadingComments => _isLoadingComments;

  // --- AUTH STATE (Mới) ---
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 1. Fetch Job Detail & Comments
  Future<void> fetchJobDetail(String jobTitle) async {
    _isLoading = true;
    notifyListeners();
    try {
      _job = await _jobService.getJobDetail(jobTitle); // Giả sử service nhận title hoặc id tuỳ logic cũ

      if (_job != null) {
        _isApplied = _job!.isApplied ?? false;
        _isSaved = _job!.isSaved ?? false;

        // Gọi loadComments và checkLogin song song để tối ưu
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

  // --- Logic Comment (Mới) ---

  Future<void> loadComments(int jobId) async {
    _isLoadingComments = true;
    notifyListeners();
    try {
      _comments = await _commentService.getComments(jobId);
    } catch (e) {
      debugPrint("Lỗi lấy comment: $e");
      _comments = [];
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

  Future<bool> sendComment(BuildContext context, String content) async {
    if (_job == null || content.trim().isEmpty) return false;

    try {
      await _commentService.postComment(_job!.jobId, content);

      // Gửi thành công -> Reload list comment
      await loadComments(_job!.jobId);
      return true;

    } on DioException catch (e) {
      String msg = "Gửi bình luận thất bại";
      if (e.response?.statusCode == 401) {
        msg = "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.";
        _isLoggedIn = false;
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

  // 2. Lấy danh sách CV (Logic Cũ & Mới kết hợp)
  Future<void> fetchMyCvs() async {
    _isLoadingCvs = true;
    _myCvs = [];
    notifyListeners();
    try {
      final data = await _cvService.getMyCvs();
      // Map data dynamic sang Entity
      _myCvs = (data).map((e) => UserCvEntity.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Lỗi lấy CV: $e");
    } finally {
      _isLoadingCvs = false;
      notifyListeners();
    }
  }

  // 3. Gửi Ứng Tuyển (Logic Cũ)
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

  // 4. Toggle Save (Logic Cũ)
  Future<void> toggleSaveJob(BuildContext context) async {
    if (_isSaving || _job == null) return;
    _isSaving = true;
    final originalState = _isSaved;
    _isSaved = !_isSaved; // Optimistic update
    notifyListeners();
    try {
      if (_isSaved) {
        await _jobService.saveJob(_job!.jobId);
      } else {
        await _jobService.unsaveJob(_job!.jobId);
      }
      // Cập nhật state ở màn Home/Saved nếu cần
      if (context.mounted) {
        // Kiểm tra provider tồn tại trước khi gọi để tránh lỗi
        try {
          context.read<HomeViewModel>().fetchInitialData();
          context.read<SavedJobsViewModel>().fetchSavedJobs();
        } catch (_) {}
      }
    } catch (e) {
      _isSaved = originalState; // Revert nếu lỗi
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi thao tác"), backgroundColor: Colors.red)
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}