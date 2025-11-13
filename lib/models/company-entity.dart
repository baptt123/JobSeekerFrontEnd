// lib/models/company_entity.dart
// (File này có thể bạn đã có, nếu chưa thì hãy tạo mới)

class CompanyEntity {
  final int companyId;
  final String name;
  final String? description;
  final String? website;
  final String? address;
  final String? logoUrl;

  CompanyEntity({
    required this.companyId,
    required this.name,
    this.description,
    this.website,
    this.address,
    this.logoUrl,
  });

  factory CompanyEntity.fromJson(Map<String, dynamic> json) {
    return CompanyEntity(
      companyId: json['company_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }
}