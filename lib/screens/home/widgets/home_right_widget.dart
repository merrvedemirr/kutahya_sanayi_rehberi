import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/screens/home/home_screen.dart';
import 'package:sanayi_websites/screens/home/widgets/filter_chips_widget.dart';
import 'package:sanayi_websites/screens/home/widgets/search_bar_widget.dart';
import 'package:sanayi_websites/viewmodel/dukkans_repository.dart';

class HomeRightWidget extends ConsumerStatefulWidget {
  const HomeRightWidget({
    super.key,
    required this.kategoriler,
    required this.selectedKategori,
  });

  final List<String> kategoriler;
  final String? selectedKategori;

  @override
  ConsumerState<HomeRightWidget> createState() => _HomeRightWidgetState();
}

class _HomeRightWidgetState extends ConsumerState<HomeRightWidget> {
  //todo: Burada kategoriler APiden gelecek
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SearchBarWidget(
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          ),
          const SizedBox(height: 12),
          FilterChipsWidget(
            kategoriler: HomeScreen.kategoriler,
            selected: widget.selectedKategori,
            onSelected: (k) =>
                ref.read(selectedKategoriProvider.notifier).state = k,
          ),
        ],
      ),
    );
  }
}
