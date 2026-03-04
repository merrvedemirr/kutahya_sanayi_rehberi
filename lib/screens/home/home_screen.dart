import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/screens/home/widgets/card_skeleton.dart';
import 'package:sanayi_websites/screens/home/widgets/empty_state.dart';
import 'package:sanayi_websites/screens/home/widgets/home_card.dart';
import 'package:sanayi_websites/screens/home/widgets/home_right_widget.dart';
import 'package:sanayi_websites/screens/home/widgets/section_divider.dart';
import 'package:sanayi_websites/screens/home/widgets/stats_bar.dart';
import 'package:sanayi_websites/screens/user/widgets/reklam_panel.dart';
import 'package:sanayi_websites/viewmodel/dukkans_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'widgets/dukkan_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  //API
  static const List<String> kategoriler = [
    'Metal İşleme',
    "Yedek Parça",
    'Elektrik',
    'Boya',
    'Otomotiv',
    'İnşaat',
    'Ahşap',
    'Hidrolik',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dukkanlarAsync = ref.watch(filteredDukkanlarStreamProvider);
    final selectedKategori = ref.watch(selectedKategoriProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // APP BAR
          sliverAppBar(context),

          // SliverAppBar'dan hemen sonra:
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final isWide = c.maxWidth >= 900;

                      final left = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeCard(),
                          const SizedBox(height: 18),
                          // Mevcut _StatsBar'ı kullanmak istersen:
                          dukkanlarAsync.when(
                            data: (d) => StatsBar(dukkanlar: d),
                            loading: () => const StatsBarSkeleton(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      );

                      final right = HomeRightWidget(
                        kategoriler: kategoriler,
                        selectedKategori: selectedKategori,
                      );

                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: left),
                                const SizedBox(width: 28),
                                Expanded(flex: 6, child: right),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                left,
                                const SizedBox(height: 18),
                                right,
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
          ),

          // REKLAM (Dükkanlar divider üstü)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const ReklamPanel(
                    title: 'REKLAM',
                    height: 200,
                    placement: 'home_list_top',
                  ),
                ),
              ),
            ),
          ),

          // DIVIDER
          //Burası daha temiz olmalı
          SliverToBoxAdapter(
            child: dukkanlarAsync.when(
              data: (d) => SectionDivider(count: d.length),
              loading: () => const SectionDivider(count: null),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // DÜKKAN LİSTESİ
          dukkanlarAsync.when(
            data: (dukkanlar) {
              if (dukkanlar.isEmpty) {
                return const SliverFillRemaining(child: EmptyState());
              }
              final isMobile = MediaQuery.sizeOf(context).width < 600;

              if (isMobile) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DukkanCard(
                          dukkan: dukkanlar[i],
                          onTap: () =>
                              context.push('/dukkan/${dukkanlar[i].id}'),
                        ),
                      ),
                      childCount: dukkanlar.length,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    childAspectRatio: 0.70,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => DukkanCard(
                      dukkan: dukkanlar[i],
                      onTap: () => context.push('/dukkan/${dukkanlar[i].id}'),
                    ),
                    childCount: dukkanlar.length,
                  ),
                ),
              );
            },
            loading: () {
              final isMobile = MediaQuery.sizeOf(context).width < 600;

              if (isMobile) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: CardSkeleton(),
                      ),
                      childCount: 6,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 460,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    childAspectRatio: 0.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const CardSkeleton(),
                    childCount: 6,
                  ),
                ),
              );
            },
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Hata: $e',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar sliverAppBar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Column(
            children: [
              Text(
                'KÜTAHYA',
                style: AppTextStyles.cardNum.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'SANAYİ',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            'REHBERİ',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            color: AppColors.accentDark,
            child: Text(
              'BETA',
              style: AppTextStyles.labelUppercase.copyWith(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(height: 2, color: AppColors.accent),
      ),
      actions: [
        StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, _) {
            final loggedIn =
                Supabase.instance.client.auth.currentSession != null;

            if (!loggedIn) {
              if (isMobile) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onSelected: (v) {
                      if (v == 'login') context.push('/login');
                      if (v == 'register') context.push('/register');
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'login',
                        child: Text(
                          'GİRİŞ YAP',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'register',
                        child: Text(
                          'KAYIT OL',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Desktop/Tablet: iki buton
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.push('/login'),
                      child: Text('GİRİŞ YAP', style: AppTextStyles.chipLabel),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'KAYIT OL',
                        style: AppTextStyles.chipLabel.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                    child: Text('ÇIKIŞ', style: AppTextStyles.chipLabel),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/ekle'),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'DÜKKAN EKLE',
                      style: AppTextStyles.chipLabel.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
