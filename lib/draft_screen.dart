import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_diary_app/providers/dream_provider.dart';
import 'package:dream_diary_app/edit_dream_screen.dart';
import 'package:dream_diary_app/models/dream_model.dart'; // Переконайтесь, що шлях вірний

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryColor = isLight ? Colors.black : Colors.white;
    
    // Використовуємо Consumer, щоб екран оновлювався при змінах
    return Consumer<DreamProvider>(
      builder: (context, dreamProvider, child) {
        final drafts = dreamProvider.drafts;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Drafts", 
              style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: secondaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: drafts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "No drafts yet",
                        style: TextStyle(
                          fontSize: 18, 
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: drafts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final dream = drafts[index];
                    return _buildDraftCard(context, dream, theme, isLight);
                  },
                ),
        );
      },
    );
  }

  Widget _buildDraftCard(BuildContext context, Dream dream, ThemeData theme, bool isLight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => EditDreamScreen(dream: dream))
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLight ? Colors.orange.shade200 : Colors.orange.shade900,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isLight ? Colors.orange.withOpacity(0.1) : Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхня частина: Лейбл "DRAFT" і кнопка видалення
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "DRAFT",
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, dream.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "Delete Draft",
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Заголовок
            Text(
              dream.title.isEmpty ? "Untitled Dream" : dream.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Опис (обрізаний)
            Text(
              dream.description.isEmpty ? "No description..." : dream.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight ? Colors.grey.shade600 : Colors.grey.shade400,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Нижня частина: Дата і кнопка "Edit"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dream.date.day}.${dream.date.month}.${dream.date.year}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                Row(
                  children: [
                    Text(
                      "Tap to edit",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: theme.primaryColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String dreamId) async {
    final dreamProvider = Provider.of<DreamProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Draft?'),
          content: const Text('Are you sure you want to permanently delete this draft?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                dreamProvider.deleteDream(dreamId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}