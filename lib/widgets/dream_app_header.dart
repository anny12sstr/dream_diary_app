import 'package:flutter/material.dart';
import 'package:dream_diary_app/constants/app_strings.dart';

// --- Єдиний Header для всіх сторінок ---
class DreamAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onNavigate;
  final VoidCallback onAccountOptions;

  const DreamAppHeader({
    super.key,
    required this.selectedIndex,
    required this.onNavigate,
    required this.onAccountOptions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = Colors.purple.shade700;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    TextStyle textStyleNormal(int index) => TextStyle(
          color: selectedIndex == index ? primaryColor : secondaryColor,
          fontWeight:
              selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow:
            isLight ? [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Логотип
          GestureDetector(
            onTap: () => onNavigate(0),
            child: Row(
              children: [
                Icon(Icons.nightlight_round, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  AppStrings.appTitle, 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Навігаційні посилання
          Row(
            children: [
              TextButton(
                onPressed: () => onNavigate(0),
                child: Text(AppStrings.navDashboard, style: textStyleNormal(0)), 
              ),
              TextButton(
                onPressed: () => onNavigate(1),
                child: Text(AppStrings.navAddDream, style: textStyleNormal(1)), 
              ),
              TextButton(
                onPressed: () => onNavigate(2),
                child: Text(AppStrings.navAnalytics, style: textStyleNormal(2)), 
              ),
            ],
          ),
          // Іконка облікового запису
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.person, color: Colors.white, size: 18),
              onPressed: onAccountOptions,
            ),
          ),
        ],
      ),
    );
  }
}