// import '../models/job-entity.dart';
//
// class PaginatedJobsResponse {
//   final List<JobEntity> data;
//   final int total;
//   final int page;
//   final int totalPages;
//
//   PaginatedJobsResponse({
//     required this.data,
//     required this.total,
//     required this.page,
//     required this.totalPages,
//   });
//
//   factory PaginatedJobsResponse.fromJson(Map<String, dynamic> json) {
//     var list = json['data'] as List;
//     List<JobEntity> jobList = list.map((i) => JobEntity.fromJson(i)).toList();
//     return PaginatedJobsResponse(
//       data: jobList,
//       total: json['total'],
//       page: json['page'],
//       totalPages: json['totalPages'],
//     );
//   }
// }


import '../models/job-entity.dart';

class PaginatedJobsResponse {
  final List<JobEntity> data;
  final int total;
  final int page;
  final int totalPages;

  PaginatedJobsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory PaginatedJobsResponse.fromJson(Map<String, dynamic> json) {
    // Ép kiểu 'as List' an toàn hơn
    final list = json['data'] as List<dynamic>? ?? [];

    // ✅ ĐÃ SỬA: Gọi đúng factory 'fromFlatJson'
    List<JobEntity> jobList = list
        .map((i) => JobEntity.fromFlatJson(i as Map<String, dynamic>))
        .toList();

    return PaginatedJobsResponse(
      data: jobList,
      // Thêm ép kiểu an toàn
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}