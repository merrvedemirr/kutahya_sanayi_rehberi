import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/screens/user/pages/user_add_shop_page.dart';
import 'package:sanayi_websites/screens/user/pages/user_my_shops_page.dart';
import 'package:sanayi_websites/screens/user/pages/user_settings_page.dart';
import 'package:sanayi_websites/screens/user/pages/user_stats_page.dart';
import 'package:sanayi_websites/screens/user/widgets/panel_card.dart';
import 'package:sanayi_websites/screens/user/widgets/reklam_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserHome extends ConsumerStatefulWidget {
  const UserHome({super.key});

  @override
  ConsumerState<UserHome> createState() => _UserHomeState();
}

enum _UserPage { addShop, stats, myShops, settings }

class _UserHomeState extends ConsumerState<UserHome> {
  _UserPage _page = _UserPage.addShop;

  static const _desktopMinWidth = 1100.0;
  static const _tabletMinWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isDesktop = w >= _desktopMinWidth;
        final isTablet = w >= _tabletMinWidth && w < _desktopMinWidth;

        if (!isTablet && !isDesktop) {
          return _mobileLayout(context);
        }
        if (isTablet) {
          return _tabletLayout(context);
        }
        return _desktopLayout(context);
      },
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('PANEL', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accent),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    const Icon(Icons.dashboard, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Text('Kullanıcı Paneli', style: AppTextStyles.headlineMedium),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: ListView(
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.add_business,
                      label: 'Dükkan Ekle',
                      selected: _page == _UserPage.addShop,
                      onTap: () => setState(() => _page = _UserPage.addShop),
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.query_stats,
                      label: 'İstatistik',
                      selected: _page == _UserPage.stats,
                      onTap: () => setState(() => _page = _UserPage.stats),
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.store,
                      label: 'Dükkanlarım',
                      selected: _page == _UserPage.myShops,
                      onTap: () => setState(() => _page = _UserPage.myShops),
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.settings,
                      label: 'Ayarlar',
                      selected: _page == _UserPage.settings,
                      onTap: () => setState(() => _page = _UserPage.settings),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.textMuted),
                      title: Text('Çıkış', style: AppTextStyles.bodyMedium),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await Supabase.instance.client.auth.signOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCenter(context),
          const SizedBox(height: 16),
          const ReklamPanel(
            title: 'REKLAM',
            height: 520,
            placement: 'user_panel',
          ),
        ],
      ),
    );
  }

  Widget _tabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('PANEL', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accent),
        ),
        actions: [
          IconButton(
            tooltip: 'Çıkış',
            onPressed: () => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.surface,
            selectedIndex: _UserPage.values.indexOf(_page),
            onDestinationSelected: (i) =>
                setState(() => _page = _UserPage.values[i]),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.add_business),
                label: Text('Ekle'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.query_stats),
                label: Text('İstatistik'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store),
                label: Text('Dükkanlarım'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Ayarlar'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildCenter(context),
                const SizedBox(height: 16),
                const ReklamPanel(
                  title: 'REKLAM',
                  height: 700,
                  placement: 'user_panel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          Container(
            width: 280,
            color: AppColors.surface,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Text('KULLANICI PANELİ', style: AppTextStyles.labelAccent),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Menü', style: AppTextStyles.headlineMedium),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: AppColors.border, height: 1),
                  Expanded(
                    child: NavigationRail(
                      extended: true,
                      backgroundColor: AppColors.surface,
                      selectedIndex: _UserPage.values.indexOf(_page),
                      onDestinationSelected: (i) =>
                          setState(() => _page = _UserPage.values[i]),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.add_business),
                          label: Text('Dükkan Ekle'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.query_stats),
                          label: Text('Dükkan İstatistik'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.store),
                          label: Text('Dükkanlarım'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings),
                          label: Text('Ayarlar'),
                        ),
                      ],
                      trailing: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            Divider(color: AppColors.border, height: 1),
                            SizedBox(height: 12),
                            _RailButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildCenter(context),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 340,
                        child: SingleChildScrollView(
                          child: const ReklamPanel(
                            title: 'REKLAM',
                            height: 1000,
                            placement: 'user_panel',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter(BuildContext context) {
    Widget content;
    switch (_page) {
      case _UserPage.addShop:
        content = const UserAddShopPage();
        break;
      case _UserPage.stats:
        content = const UserStatsPage();
        break;
      case _UserPage.myShops:
        content = const UserMyShopsPage();
        break;
      case _UserPage.settings:
        content = const UserSettingsPage();
        break;
    }

    return PanelCard(child: content);
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.accent : AppColors.textMuted,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: selected ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

}

class _RailButtons extends StatelessWidget {
  const _RailButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Supabase.instance.client.auth.signOut(),
            child: Text('Çıkış', style: AppTextStyles.chipLabel),
          ),
        ),
      ],
    );
  }
}
