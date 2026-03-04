class SupabaseConstants {
  SupabaseConstants._();

  // Supabase projen kurulduktan sonra bu değerleri güncelle
  // supabase.com → Project Settings → API
  static const String supabaseUrl = 'https://nqkrppgypcspjqawuesr.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_qJ9TBm4QNtQXsNvwjJhD_g_wMeP2YST';

  // Tablo adları
  static const String dukkanlarTable = 'dukkanlar';
  static const String kategorilerTable = 'kategoriler';
  static const String markalarTable = 'markalar';
  static const String profilesTable = 'profiles';
  static const String reklamlarTable = 'reklamlar';

  // Storage bucket
  static const String storageBucket = 'dukkan-fotolari';
}
