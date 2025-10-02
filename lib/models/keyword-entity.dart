class KeywordEntity {
  final int keywordId;
  final String keywordName;

  KeywordEntity({
    required this.keywordId,
    required this.keywordName,
  });

  factory KeywordEntity.fromJson(Map<String, dynamic> json) => KeywordEntity(
    keywordId: json['keyword_id'],
    keywordName: json['keyword_name'],
  );
}
