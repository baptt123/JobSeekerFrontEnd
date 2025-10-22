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
    var list = json['data'] as List;
    List<JobEntity> jobList = list.map((i) => JobEntity.fromJson(i)).toList();
    return PaginatedJobsResponse(
      data: jobList,
      total: json['total'],
      page: json['page'],
      totalPages: json['totalPages'],
    );
  }
}