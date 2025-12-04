// lib/analytics_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_diary_app/providers/dream_provider.dart';
import 'package:dream_diary_app/models/dream_model.dart';
import 'constants/app_strings.dart';
import 'draft_screen.dart'; 

enum TimePeriod { week, month, year }

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const AnalyticsScreen(this.toggleTheme, {super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  TimePeriod _selectedPeriod = TimePeriod.week;

  List<Dream> _filterDreamsByPeriod(List<Dream> allDreams) {
    final now = DateTime.now();
    final DateTime startDate;

    switch (_selectedPeriod) {
      case TimePeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }

    return allDreams.where((dream) => dream.date.isAfter(startDate)).toList();
  }

  Map<String, double> _calculateCategoryStats(List<Dream> dreams) {
    if (dreams.isEmpty) return {};
    
    final total = dreams.length;
    final Map<String, int> counts = {};
    
    for (var dream in dreams) {
      counts[dream.category] = (counts[dream.category] ?? 0) + 1;
    }

    final Map<String, double> percentages = {};
    counts.forEach((key, value) {
      percentages[key] = (value / total) * 100;
    });

    return percentages;
  }

  Map<String, double> _calculateEmotionStats(List<Dream> dreams) {
    if (dreams.isEmpty) return {'Positive': 0, 'Neutral': 0, 'Negative': 0};

    int positive = 0;
    int neutral = 0;
    int negative = 0;

    for (var dream in dreams) {
      switch (dream.emotion) {
        case 'Happy':
        case 'Peaceful':
          positive++;
          break;
        case 'Abstract': 
          neutral++;
          break;
        case 'Anxious':
        case 'Fearful':
        case 'Nightmare':
          negative++;
          break;
        default:
          neutral++;
      }
    }

    final total = dreams.length;
    return {
      'Positive': positive / total,
      'Neutral': neutral / total,
      'Negative': negative / total,
    };
  }

  Widget _buildPeriodButton(TimePeriod period, String label, Color primaryColor, Color secondaryColor, bool isLight) {
    final isSelected = _selectedPeriod == period;
   
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = primaryColor;
    } else if (isLight) {
      backgroundColor = Colors.grey.shade100;
    } else {
      backgroundColor = Colors.grey.shade800;
    }

    final textColor = isSelected ? Colors.white : secondaryColor;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.horizontal(
              left: period == TimePeriod.week ? const Radius.circular(8) : Radius.zero,
              right: period == TimePeriod.year ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = Colors.purple.shade700;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    final dreamProvider = context.watch<DreamProvider>();
    final publishedDreams = dreamProvider.dreams.where((d) => !d.isDraft).toList();
    final draftsCount = dreamProvider.drafts.length;

    final periodDreams = _filterDreamsByPeriod(publishedDreams);
    
    final categoryStats = _calculateCategoryStats(periodDreams);
    final emotionStats = _calculateEmotionStats(periodDreams);

    final totalDreams = periodDreams.length;
    
    final avgRating = totalDreams > 0
        ? periodDreams.map((e) => e.rating).reduce((a, b) => a + b) / totalDreams
        : 0.0;

    final lucidCount = periodDreams.where((d) => d.category == 'Lucid Dream').length;
    final nightmareCount = periodDreams.where((d) => d.category == 'Nightmare' || d.emotion == 'Fearful').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.analyticsTitle, style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // ВИДАЛЕНО actions: [...] щоб не перекривало заголовок
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- НОВЕ РОЗТАШУВАННЯ КНОПКИ DRAFTS (Вгорі контенту) ---
                  if (draftsCount > 0) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DraftsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note, color: Colors.orange.shade800),
                                const SizedBox(width: 12),
                                Text(
                                  "You have $draftsCount unfinished dreams",
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange.shade800),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // -------------------------------------------------------

                  Text(AppStrings.analyticsSubtitle, style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey.shade400)), 
                  const SizedBox(height: 16),

                  // --- ВИБІР ПЕРІОДУ ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: isLight ? Colors.grey.withOpacity(0.1) : Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.timePeriodLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: secondaryColor)), 
                        
                        Container(
                          height: 40,
                          width: 200, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.grey.shade700),
                          ),
                          child: Row(
                            children: [
                              _buildPeriodButton(TimePeriod.week, AppStrings.timePeriodWeek, primaryColor, secondaryColor, isLight),
                              _buildPeriodButton(TimePeriod.month, AppStrings.timePeriodMonth, primaryColor, secondaryColor, isLight), 
                              _buildPeriodButton(TimePeriod.year, AppStrings.timePeriodYear, primaryColor, secondaryColor, isLight), 
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // --- ГРАФІК ТА ЗАГАЛЬНА СТАТИСТИКА ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 280,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: theme.brightness == Brightness.light ? Colors.grey.withOpacity(0.2) : Colors.black12, blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.chartCategoryTitle, style: TextStyle(fontSize: 16, color: secondaryColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (periodDreams.isEmpty) 
                                const Expanded(child: Center(child: Text("No data")))
                              else
                                Expanded(
                                  child: ListView(
                                    children: categoryStats.entries.map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(entry.key, style: TextStyle(color: secondaryColor)),
                                                Text("${entry.value.toStringAsFixed(1)}%", style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: entry.value / 100,
                                              backgroundColor: isLight ? Colors.grey.shade200 : Colors.grey.shade700,
                                              color: primaryColor,
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildStatCard(theme, isLight, secondaryColor, AppStrings.metricTotalDreams, totalDreams.toString(), null),
                            const SizedBox(height: 16),
                            _buildStatCard(theme, isLight, secondaryColor, "Avg Rating", "${avgRating.toStringAsFixed(1)} / 5.0", null),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(theme, isLight, secondaryColor, AppStrings.metricLucidDreams, "$lucidCount", Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(theme, isLight, secondaryColor, AppStrings.metricNightmares, "$nightmareCount", Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: theme.brightness == Brightness.light ? Colors.grey.withOpacity(0.2) : Colors.black12, blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(AppStrings.chartQualityTitle, style: TextStyle(fontSize: 16, color: secondaryColor, fontWeight: FontWeight.bold)), 
                        const SizedBox(height: 16),
                        _buildQualityRow(AppStrings.qualityPositive, emotionStats['Positive']!, Colors.green, secondaryColor, isLight),
                        const SizedBox(height: 8),
                        _buildQualityRow(AppStrings.qualityNeutral, emotionStats['Neutral']!, Colors.grey, secondaryColor, isLight),
                        const SizedBox(height: 8),
                        _buildQualityRow(AppStrings.qualityNegative, emotionStats['Negative']!, Colors.red, secondaryColor, isLight),
                      ],
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

  Widget _buildStatCard(ThemeData theme, bool isLight, Color textColor, String title, String value, Color? valueColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: theme.brightness == Brightness.light ? Colors.grey.withOpacity(0.2) : Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7))), 
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor ?? textColor)),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String label, double percentage, Color color, Color textColor, bool isLight) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))), 
        const SizedBox(width: 8),
        Expanded(child: LinearProgressIndicator(
          value: percentage, 
          color: color, 
          backgroundColor: isLight ? Colors.grey.shade200 : Colors.grey.shade700,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        )),
        const SizedBox(width: 8),
        SizedBox(width: 40, child: Text("${(percentage * 100).toInt()}%", style: TextStyle(color: textColor))),
      ],
    );
  }
}