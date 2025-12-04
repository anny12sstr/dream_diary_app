import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:dream_diary_app/constants/app_strings.dart'; 
import 'package:dream_diary_app/models/dream_model.dart'; 

class DreamDetailScreen extends StatelessWidget {
  final Dream dream;

  const DreamDetailScreen({super.key, required this.dream});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navViewDream), // "View Dream"
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Назва
            Text(
              dream.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Дата, час та рейтинг
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dream.date.day}.${dream.date.month}.${dream.date.year} – ${dream.date.hour}:${dream.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                RatingBarIndicator(
                  rating: dream.rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Категорія та Емоція
            Row(
              children: [
                _buildTagChip(dream.category, Colors.purple.shade400, theme),
                const SizedBox(width: 8),
                _buildEmotionPill(dream.emotion, theme),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            //  Опис
            Text(
              AppStrings.descLabel, // "Dream Description"
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dream.description,
              style: TextStyle(
                color: isLight ? Colors.grey.shade800 : Colors.grey.shade300,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Теги
            if (dream.tags.isNotEmpty) ...[
              Text(
                AppStrings.tagsLabel, // "Tags"
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: dream.tags
                    .map((tag) => _buildTagChip(tag, Colors.blue.shade400, theme))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Віджет для емоції
  Widget _buildEmotionPill(String emotion, ThemeData theme) {
    Color pillColor;
    Color textColor;
    final bool isLight = theme.brightness == Brightness.light;

    switch (emotion) {
      case 'Happy':
        pillColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Peaceful':
        pillColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;
      case 'Anxious':
        pillColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Fearful':
        pillColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        pillColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }
    
    if (!isLight) {
      pillColor = pillColor.withOpacity(0.2);
      textColor = pillColor.withOpacity(1.0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        emotion,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  // Віджет для тегів
  Widget _buildTagChip(String label, Color color, ThemeData theme) {
    final bool isLight = theme.brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLight ? color.withOpacity(0.1) : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}