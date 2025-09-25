class CompanyEntity {
  final int companyId;
  final String name;
  final String? description;
  final String? website;
  final String? address;
  final String? logoUrl;
  final DateTime createdAt;

  CompanyEntity({
    required this.companyId,
    required this.name,
    this.description,
    this.website,
    this.address,
    this.logoUrl,
    required this.createdAt,
  });

  factory CompanyEntity.fromJson(Map<String, dynamic> json) => CompanyEntity(
    companyId: json['company_id'],
    name: json['name'],
    description: json['description'],
    website: json['website'],
    address: json['address'],
    logoUrl: json['logo_url'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'company_id': companyId,
    'name': name,
    'description': description,
    'website': website,
    'address': address,
    'logo_url': logoUrl,
    'created_at': createdAt.toIso8601String(),
  };
}
