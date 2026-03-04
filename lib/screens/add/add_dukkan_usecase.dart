import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/core/constants/supabase_constants.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';
import 'package:sanayi_websites/services/dukkan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dukkanServiceProvider = Provider<DukkanService>((ref) => DukkanService());

final addDukkanUseCaseProvider = Provider<AddDukkanUseCase>((ref) {
  return AddDukkanUseCase(ref.read(dukkanServiceProvider));
});

final updateDukkanUseCaseProvider = Provider<UpdateDukkanUseCase>((ref) {
  return UpdateDukkanUseCase(ref.read(dukkanServiceProvider));
});

class AddDukkanMedia {
  final PlatformFile? logo;
  final PlatformFile? cover;
  final List<PlatformFile> photos;

  const AddDukkanMedia({
    required this.logo,
    required this.cover,
    required this.photos,
  });
}

class AddDukkanPayload {
  final String isim;
  final String telefon;
  final String? telefon2;
  final String? whatsapp;
  final String? blok;
  final String? kapiNo;
  final String kategori;
  final bool acikMi;
  final String? calismaSaatleri;
  final String? tatilGunleri;
  final String? aciklama;
  final List<String> markalar;
  final String userId;
  final String? sahipAdi;

  const AddDukkanPayload({
    required this.isim,
    required this.telefon,
    required this.telefon2,
    required this.whatsapp,
    required this.blok,
    required this.kapiNo,
    required this.kategori,
    required this.acikMi,
    required this.calismaSaatleri,
    required this.tatilGunleri,
    required this.aciklama,
    required this.markalar,
    required this.userId,
    required this.sahipAdi,
  });

  DukkanModel toModel() {
    return DukkanModel(
      id: '',
      createdAt: DateTime.now(),
      isim: isim,
      sahipAdi: sahipAdi,
      telefon: telefon,
      telefon2: telefon2,
      whatsapp: whatsapp,
      blok: blok,
      kapiNo: kapiNo,
      kategori: kategori,
      acikMi: acikMi,
      calismaSaatleri: calismaSaatleri,
      tatilGunleri: tatilGunleri,
      aciklama: aciklama,
      markalar: markalar,
      userId: userId,
      onaylandiMi: false,
    );
  }

  /// Update map for `dukkanlar` table.
  /// Does not include immutable fields like `created_at`.
  Map<String, dynamic> toUpdateMap() {
    return {
      'isim': isim,
      'sahip_adi': sahipAdi,
      'telefon': telefon,
      'telefon2': telefon2,
      'whatsapp': whatsapp,
      'blok': blok,
      'kapi_no': kapiNo,
      'kategori': kategori,
      'acik_mi': acikMi,
      'calisma_saatleri': calismaSaatleri,
      'tatil_gunleri': tatilGunleri,
      'aciklama': aciklama,
      'markalar': markalar,
    };
  }
}

class AddDukkanUseCase {
  final DukkanService _service;

  AddDukkanUseCase(this._service);

  Future<DukkanModel> execute({
    required AddDukkanPayload payload,
    required AddDukkanMedia media,
  }) async {
    final created = await _service.addDukkan(payload.toModel());
    final update = await _uploadMediaAndBuildUpdate(
      userId: payload.userId,
      dukkanId: created.id,
      media: media,
    );

    if (update.isEmpty) return created;
    return await _service.updateDukkan(created.id, update);
  }

  Future<Map<String, dynamic>> _uploadMediaAndBuildUpdate({
    required String userId,
    required String dukkanId,
    required AddDukkanMedia media,
  }) async {
    final storage = Supabase.instance.client.storage.from(
      SupabaseConstants.storageBucket,
    );

    final Map<String, dynamic> update = {};

    if (media.logo != null) {
      final path = await _uploadSingle(
        storage: storage,
        userId: userId,
        dukkanId: dukkanId,
        folder: null,
        filenameBase: 'logo',
        file: media.logo!,
      );
      update['logo_url'] = path;
    }

    if (media.cover != null) {
      final path = await _uploadSingle(
        storage: storage,
        userId: userId,
        dukkanId: dukkanId,
        folder: null,
        filenameBase: 'cover',
        file: media.cover!,
      );
      update['kapak_foto'] = path;
    }

    if (media.photos.isNotEmpty) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final List<String> paths = [];

      for (var i = 0; i < media.photos.length; i++) {
        final f = media.photos[i];
        final ext = _safeExt(f);
        final path =
            'users/$userId/dukkanlar/$dukkanId/photos/${ts}_$i.$ext';
        await storage.uploadBinary(
          path,
          f.bytes!,
          fileOptions: FileOptions(
            contentType: _contentType(ext),
            upsert: true,
          ),
        );
        paths.add(path);
      }

      update['fotograflar'] = paths;
    }

    return update;
  }

  Future<String> _uploadSingle({
    required StorageFileApi storage,
    required String userId,
    required String dukkanId,
    required String? folder,
    required String filenameBase,
    required PlatformFile file,
  }) async {
    final ext = _safeExt(file);
    final folderPart = (folder == null || folder.isEmpty) ? '' : '/$folder';
    final path = 'users/$userId/dukkanlar/$dukkanId$folderPart/$filenameBase.$ext';

    await storage.uploadBinary(
      path,
      file.bytes!,
      fileOptions: FileOptions(
        contentType: _contentType(ext),
        upsert: true,
      ),
    );

    return path;
  }

  String _contentType(String? ext) {
    final e = (ext ?? '').toLowerCase();
    if (e == 'png') return 'image/png';
    if (e == 'webp') return 'image/webp';
    if (e == 'gif') return 'image/gif';
    return 'image/jpeg';
  }

  String _safeExt(PlatformFile f) {
    final ext = (f.extension ?? '').toLowerCase();
    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp') {
      return ext == 'jpg' ? 'jpeg' : ext;
    }
    return 'jpeg';
  }
}

class UpdateDukkanUseCase {
  final DukkanService _service;

  UpdateDukkanUseCase(this._service);

  Future<DukkanModel> execute({
    required String dukkanId,
    required AddDukkanPayload payload,
    required AddDukkanMedia media,
  }) async {
    final update = payload.toUpdateMap();
    final mediaUpdate = await _uploadMediaAndBuildUpdate(
      userId: payload.userId,
      dukkanId: dukkanId,
      media: media,
    );

    update.addAll(mediaUpdate);
    return await _service.updateDukkan(dukkanId, update);
  }

  Future<Map<String, dynamic>> _uploadMediaAndBuildUpdate({
    required String userId,
    required String dukkanId,
    required AddDukkanMedia media,
  }) async {
    final storage = Supabase.instance.client.storage.from(
      SupabaseConstants.storageBucket,
    );

    final Map<String, dynamic> update = {};

    if (media.logo != null) {
      final path = await _uploadSingle(
        storage: storage,
        userId: userId,
        dukkanId: dukkanId,
        folder: null,
        filenameBase: 'logo',
        file: media.logo!,
      );
      update['logo_url'] = path;
    }

    if (media.cover != null) {
      final path = await _uploadSingle(
        storage: storage,
        userId: userId,
        dukkanId: dukkanId,
        folder: null,
        filenameBase: 'cover',
        file: media.cover!,
      );
      update['kapak_foto'] = path;
    }

    if (media.photos.isNotEmpty) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final List<String> paths = [];

      for (var i = 0; i < media.photos.length; i++) {
        final f = media.photos[i];
        final ext = _safeExt(f);
        final path =
            'users/$userId/dukkanlar/$dukkanId/photos/${ts}_$i.$ext';
        await storage.uploadBinary(
          path,
          f.bytes!,
          fileOptions: FileOptions(
            contentType: _contentType(ext),
            upsert: true,
          ),
        );
        paths.add(path);
      }

      update['fotograflar'] = paths;
    }

    return update;
  }

  Future<String> _uploadSingle({
    required StorageFileApi storage,
    required String userId,
    required String dukkanId,
    required String? folder,
    required String filenameBase,
    required PlatformFile file,
  }) async {
    final ext = _safeExt(file);
    final folderPart = (folder == null || folder.isEmpty) ? '' : '/$folder';
    final path =
        'users/$userId/dukkanlar/$dukkanId$folderPart/$filenameBase.$ext';

    await storage.uploadBinary(
      path,
      file.bytes!,
      fileOptions: FileOptions(
        contentType: _contentType(ext),
        upsert: true,
      ),
    );

    return path;
  }

  String _contentType(String? ext) {
    final e = (ext ?? '').toLowerCase();
    if (e == 'png') return 'image/png';
    if (e == 'webp') return 'image/webp';
    if (e == 'gif') return 'image/gif';
    return 'image/jpeg';
  }

  String _safeExt(PlatformFile f) {
    final ext = (f.extension ?? '').toLowerCase();
    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'webp') {
      return ext == 'jpg' ? 'jpeg' : ext;
    }
    return 'jpeg';
  }
}

