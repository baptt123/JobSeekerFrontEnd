class CVKeywordEntity{
  final int id;
  final int cvId;
  final int keywordId;

  CVKeywordEntity({
    required this.id,
    required this.cvId,
    required this.keywordId,
  });

  factory CVKeywordEntity.fromJson(Map<String, dynamic> json) => CVKeywordEntity(
    id: json['id'],
    cvId: json['cv_id'],
    keywordId: json['keyword_id'],
  );
}
