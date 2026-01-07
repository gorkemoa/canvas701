import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../widgets/widgets.dart';
import '../../../core/widgets/app_mode_switcher.dart';

class SpecialPage extends StatelessWidget {
  const SpecialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Canvas701Colors.primary,
            elevation: 0,
            toolbarHeight: 45,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            pinned: true,
            title: const AppModeSwitcher(),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: Canvas701SearchBar(),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Canvas701Colors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: Canvas701Spacing.lg),
                  Text(
                    'Sana Özel Fırsatlar',
                    style: Canvas701Typography.headlineSmall,
                  ),
                  const SizedBox(height: Canvas701Spacing.sm),
                  Text(
                    'Çok yakında burada!',
                    style: Canvas701Typography.bodyMedium.copyWith(
                      color: Canvas701Colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
