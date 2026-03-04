class ReklamModel {
  final String id;
  final String title;
  final String? image;
  final String? link;
  final String placement;
  final bool active;
  final DateTime createdAt;

  const ReklamModel({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
    required this.placement,
    required this.active,
    required this.createdAt,
  });

  factory ReklamModel.fromJson(Map<String, dynamic> json) {
    return ReklamModel(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'REKLAM',
      image: json['image'] as String?,
      link: json['link'] as String?,
      placement: (json['placement'] as String?)?.trim().isNotEmpty == true
          ? (json['placement'] as String).trim()
          : 'user_panel',
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

