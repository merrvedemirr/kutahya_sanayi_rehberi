class DukkanModel {
  final String id;
  final DateTime createdAt;
  final String isim;
  final String? sahipAdi;
  final String telefon;
  final String? telefon2;
  final String? whatsapp;
  final String? blok;
  final String? kapiNo;
  final String? acikAdres;
  final double? enlem;
  final double? boylam;
  final String kategori;
  final bool acikMi;
  final String? calismaSaatleri;
  final String? tatilGunleri;
  final String? aciklama;
  final List<String> hizmetler;
  final List<String> markalar;
  final String? kapakFoto;
  final List<String> fotograflar;
  final String? logoUrl;
  final String? userId;
  final bool onaylandiMi;

  DukkanModel({
    required this.id,
    required this.createdAt,
    required this.isim,
    this.sahipAdi,
    required this.telefon,
    this.telefon2,
    this.whatsapp,
    this.blok,
    this.kapiNo,
    this.acikAdres,
    this.enlem,
    this.boylam,
    required this.kategori,
    required this.acikMi,
    this.calismaSaatleri,
    this.tatilGunleri,
    this.aciklama,
    this.hizmetler = const [],
    this.markalar = const [],
    this.kapakFoto,
    this.fotograflar = const [],
    this.logoUrl,
    this.userId,
    this.onaylandiMi = false,
  });

  factory DukkanModel.fromJson(Map<String, dynamic> json) {
    return DukkanModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isim: json['isim'] as String,
      sahipAdi: json['sahip_adi'] as String?,
      telefon: json['telefon'] as String,
      telefon2: json['telefon2'] as String?,
      whatsapp: json['whatsapp'] as String?,
      blok: json['blok'] as String?,
      kapiNo: json['kapi_no'] as String?,
      acikAdres: json['acik_adres'] as String?,
      enlem: (json['enlem'] as num?)?.toDouble(),
      boylam: (json['boylam'] as num?)?.toDouble(),
      kategori: json['kategori'] as String,
      acikMi: json['acik_mi'] as bool? ?? false,
      calismaSaatleri: json['calisma_saatleri'] as String?,
      tatilGunleri: json['tatil_gunleri'] as String?,
      aciklama: json['aciklama'] as String?,
      hizmetler: List<String>.from(json['hizmetler'] ?? []),
      markalar: List<String>.from(json['markalar'] ?? []),
      kapakFoto: json['kapak_foto'] as String?,
      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      logoUrl: json['logo_url'] as String?,
      userId: json['user_id'] as String?,
      onaylandiMi: json['onaylandi_mi'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isim': isim,
      'sahip_adi': sahipAdi,
      'telefon': telefon,
      'telefon2': telefon2,
      'whatsapp': whatsapp,
      'blok': blok,
      'kapi_no': kapiNo,
      'acik_adres': acikAdres,
      'enlem': enlem,
      'boylam': boylam,
      'kategori': kategori,
      'acik_mi': acikMi,
      'calisma_saatleri': calismaSaatleri,
      'tatil_gunleri': tatilGunleri,
      'aciklama': aciklama,
      'hizmetler': hizmetler,
      'markalar': markalar,
      'kapak_foto': kapakFoto,
      'fotograflar': fotograflar,
      'logo_url': logoUrl,
      'user_id': userId,
      'onaylandi_mi': onaylandiMi,
    };
  }

  DukkanModel copyWith({
    String? isim,
    String? sahipAdi,
    String? telefon,
    String? telefon2,
    String? whatsapp,
    String? blok,
    String? kapiNo,
    String? acikAdres,
    double? enlem,
    double? boylam,
    String? kategori,
    bool? acikMi,
    String? calismaSaatleri,
    String? tatilGunleri,
    String? aciklama,
    List<String>? hizmetler,
    List<String>? markalar,
    String? kapakFoto,
    List<String>? fotograflar,
    String? logoUrl,
    String? userId,
    bool? onaylandiMi,
  }) {
    return DukkanModel(
      id: id,
      createdAt: createdAt,
      isim: isim ?? this.isim,
      sahipAdi: sahipAdi ?? this.sahipAdi,
      telefon: telefon ?? this.telefon,
      telefon2: telefon2 ?? this.telefon2,
      whatsapp: whatsapp ?? this.whatsapp,
      blok: blok ?? this.blok,
      kapiNo: kapiNo ?? this.kapiNo,
      acikAdres: acikAdres ?? this.acikAdres,
      enlem: enlem ?? this.enlem,
      boylam: boylam ?? this.boylam,
      kategori: kategori ?? this.kategori,
      acikMi: acikMi ?? this.acikMi,
      calismaSaatleri: calismaSaatleri ?? this.calismaSaatleri,
      tatilGunleri: tatilGunleri ?? this.tatilGunleri,
      aciklama: aciklama ?? this.aciklama,
      hizmetler: hizmetler ?? this.hizmetler,
      markalar: markalar ?? this.markalar,
      kapakFoto: kapakFoto ?? this.kapakFoto,
      fotograflar: fotograflar ?? this.fotograflar,
      logoUrl: logoUrl ?? this.logoUrl,
      userId: userId ?? this.userId,
      onaylandiMi: onaylandiMi ?? this.onaylandiMi,
    );
  }

  String get adres {
    final parts = [
      blok,
      kapiNo,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', No: ') : (acikAdres ?? '');
  }

  String get idFormatted => '#${id.substring(0, 6).toUpperCase()}';
}
