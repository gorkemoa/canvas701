import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:canvas701/core/view/services_page.dart';
import 'package:canvas701/core/app_mode.dart';
import 'package:flutter/material.dart';

class AppModeSwitcher extends StatelessWidget {
  final Color backgroundColor;
  final bool isBack;
  final List<Widget>? trailing;
  final VoidCallback? onMenuIconTap;

  const AppModeSwitcher({
    super.key,
    this.backgroundColor = Canvas701Colors.primary,
    this.isBack = false,
    this.trailing,
    this.onMenuIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Menu Icon (Turkcell Style)
          _buildAppBarIcon(
            isBack ? Icons.arrow_back_ios_new_rounded : Icons.grid_view_rounded,
            onTap: onMenuIconTap ??
                () {
                  if (isBack) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServicesPage(),
                      ),
                    );
                  }
                },
          ),
          // Vertical Divider
          Container(
            width: 1.5,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white.withOpacity(0.4),
          ),
          // Mode Switcher
          Expanded(
            child: ValueListenableBuilder<AppMode>(
              valueListenable: AppModeManager.instance.modeNotifier,
              builder: (context, currentMode, _) {
                const double canvasWidth = 115;
                const double creatorsWidth = 125;
                const double gap = 8;
                const double switcherHeight = 36;

                return SizedBox(
                  height: switcherHeight,
                  child: Stack(
                    children: [
                      // Inactive Backgrounds (The track shapes)
                      Row(
                        children: [
                          _buildInactivePill(
                            width: canvasWidth,
                            height: switcherHeight,
                          ),
                          const SizedBox(width: gap),
                          _buildInactivePill(
                            width: creatorsWidth,
                            height: switcherHeight,
                          ),
                        ],
                      ),
                      // Liquid Trail (The "Illusion" part)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuint,
                        left: currentMode == AppMode.canvas
                            ? 0
                            : canvasWidth + gap,
                        width: currentMode == AppMode.canvas
                            ? canvasWidth
                            : creatorsWidth,
                        height: switcherHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                      // Sliding White Indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        left: currentMode == AppMode.canvas
                            ? 0
                            : canvasWidth + gap,
                        width: currentMode == AppMode.canvas
                            ? canvasWidth
                            : creatorsWidth,
                        height: switcherHeight,
                        child: Padding(
                          padding: const EdgeInsets.all(0.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Interactive Logos
                      Row(
                        children: [
                          _buildLogoItem(
                            isActive: currentMode == AppMode.canvas,
                            assetPath:
                                'https://office701.b-cdn.net/canvas701/logo/canvas701-new-logo-black.png',
                            onTap: () {
                              final manager = AppModeManager.instance;
                              if (manager.currentMode != AppMode.canvas) {
                                manager.setMode(AppMode.canvas);
                              }
                              // Her durumda stack'i temizle ve ana sayfaya dön
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            width: canvasWidth,
                            height: switcherHeight,
                          ),
                          const SizedBox(width: gap),
                          _buildLogoItem(
                            isActive: currentMode == AppMode.creators,
                            assetPath:
                                'https://office701.b-cdn.net/canvas701/logo/canvas701-creators-ogo-black.png',
                            onTap: () {
                              final manager = AppModeManager.instance;
                              if (manager.currentMode != AppMode.creators) {
                                manager.setMode(AppMode.creators);
                              }
                              // Her durumda stack'i temizle ve ana sayfaya dön
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            width: creatorsWidth,
                            height: switcherHeight,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), ...trailing!],
        ],
      ),
    );
  }

  Widget _buildInactivePill({required double width, required double height}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
    );
  }

  Widget _buildLogoItem({
    required bool isActive,
    required String assetPath,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle glow behind active logo
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isActive ? 1.0 : 0.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Canvas701Colors.primary.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 500),
              scale: isActive ? 1.5 : 1.3,
              curve: Curves.easeInOutQuart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, 0, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 2,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isActive ? 1.0 : 0.5,
                  child: assetPath.startsWith('http')
                      ? Image.network(
                          assetPath,
                          height: 13,
                          fit: BoxFit.contain,
                          color: isActive ? null : Colors.white.withOpacity(0.9),
                          colorBlendMode: isActive ? null : BlendMode.srcIn,
                        )
                      : Image.asset(
                          assetPath,
                          height: 13,
                          fit: BoxFit.contain,
                          color: isActive ? null : Colors.white.withOpacity(0.9),
                          colorBlendMode: isActive ? null : BlendMode.srcIn,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
