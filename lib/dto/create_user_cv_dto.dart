class CreateUserCvDto {
  final int userId;
  final String title;
  final String? fileUrl;
  final String? content;
  final bool? isDefault;
  final List<String>? keywords;

  CreateUserCvDto({
    required this.userId,
    required this.title,
    this.fileUrl,
    this.content,
    this.isDefault,
    this.keywords,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'file_url': fileUrl,
      'content': content,
      'is_default': isDefault,
      'keywords': keywords,
    }..removeWhere((key, value) => value == null);
  }
}
