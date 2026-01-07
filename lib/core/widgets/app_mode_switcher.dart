import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:canvas701/core/view/services_page.dart';
import 'package:canvas701/core/app_mode.dart';
import 'package:flutter/material.dart';

class AppModeSwitcher extends StatelessWidget {
  final Color backgroundColor;
  final bool isBack;
  final List<Widget>? trailing;

  const AppModeSwitcher({
    super.key,
    this.backgroundColor = Canvas701Colors.primary,
    this.isBack = false,
    this.trailing,
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
            onTap: () {
              if (isBack) {
                Navigator.pop(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServicesPage()),
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
                const double canvasWidth = 100;
                const double creatorsWidth = 110;
                const double gap = 10;

                return SizedBox(
                  height: 28,
                  child: Stack(
                    children: [
                      // Inactive Backgrounds (The track shapes)
                      Row(
                        children: [
                          _buildInactivePill(width: canvasWidth),
                          const SizedBox(width: gap),
                          _buildInactivePill(width: creatorsWidth),
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
                        height: 28,
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
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Interactive Logos
                      Row(
                        children: [
                          _buildLogoItem(
                            isActive: currentMode == AppMode.canvas,
                            assetPath: 'assets/Canvas701-Logo.png',
                            onTap: () =>
                                AppModeManager.instance.setMode(AppMode.canvas),
                            width: canvasWidth,
                          ),
                          const SizedBox(width: gap),
                          _buildLogoItem(
                            isActive: currentMode == AppMode.creators,
                            assetPath: 'assets/Creators.png',
                            onTap: () => AppModeManager.instance.setMode(
                              AppMode.creators,
                            ),
                            width: creatorsWidth,
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

  Widget _buildInactivePill({required double width}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: width,
      height: 28,
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
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 28,
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
                  horizontal: 30,
                  vertical: 2,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isActive ? 1.0 : 0.5,
                  child: Image.asset(
                    assetPath,
                    height: 14,
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
