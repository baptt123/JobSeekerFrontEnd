import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../models/comments-entity.dart';
import '../../models/job-entity.dart';
import '../../models/user-cv-entity.dart';
import '../../services/job_service.dart';
import '../../services/job_application_service.dart';
import '../../services/cv_service.dart';
import '../../services/comment_service.dart';

class JobDetailViewModel extends ChangeNotifier {
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobService _jobService = JobService();
  final CVService _cvService = CVService(); // Đổi tên cho khớp với file service đã tạo trước đó
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
  List<UserCvEntity> _myCvs = [];
  List<UserCvEntity> get myCvs => _myCvs;
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
  String? get errorMessage => _errorMessage;

  // 1. Fetch Job Detail & Init Data
  Future<void> fetchJobDetail(String jobTitleOrId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Giả sử API getDetail nhận ID hoặc Title. Ở đây truyền param vào.
      // Nếu API cần ID int, bạn cần parse ở UI trước khi truyền hoặc sửa logic service.
      _job = await _jobService.getJobDetail(jobTitleOrId);

      if (_job != null) {
        _isApplied = _job!.isApplied ?? false;
        _isSaved = _job!.isSaved ?? false;

        // Gọi song song để tiết kiệm thời gian
        await Future.wait([
          loadComments(_job!.jobId),
          checkLoginStatus(),
        ]);
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error fetching job detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Logic Comment
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      }
      return false;
    }
  }

  // 3. Lấy danh sách CV
  Future<void> fetchMyCvs() async {
    _isLoadingCvs = true;
    _myCvs = [];
    notifyListeners();
    try {
      final data = await _cvService.getMyCVs(); // Hàm này trả về List<dynamic> từ Service
      // Map data dynamic sang Entity
      // Lưu ý: Đảm bảo UserCvEntity có factory fromJson xử lý đúng các trường từ API
      _myCvs = (data).map((e) => UserCvEntity.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Lỗi lấy CV: $e");
    } finally {
      _isLoadingCvs = false;
      notifyListeners();
    }
  }

  // 4. Gửi Ứng Tuyển
  Future<bool> submitApplication(BuildContext context, int? selectedCvId, String coverLetter) async {
    if (_isApplying || _job == null) return false;
    if (selectedCvId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn 1 CV")));
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
      return true;
    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
      return false;
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }

  // 5. Toggle Save
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
    } catch (e) {
      _isSaved = originalState; // Revert nếu lỗi
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi thao tác"), backgroundColor: Colors.red));
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}