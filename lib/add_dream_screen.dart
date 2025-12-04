// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'constants/app_strings.dart';
import 'providers/dream_provider.dart';

class AddDreamScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const AddDreamScreen(this.toggleTheme, {super.key});

  @override
  _AddDreamScreenState createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedCategory;
  String? _selectedEmotion;
  double _selectedRating = 3.0;

  final List<String> _predefinedTags = [
    'flying', 'falling', 'family', 'friends', 'work', 'school', 'test',
    'chased', 'running', 'water', 'ocean', 'forest', 'house', 'stranger',
    'death', 'lost', 'teeth', 'car', 'baby', 'monster', 'celebrity'
  ];
  final List<String> _selectedTags = [];

  bool _isLoading = false;

  // Оновлений метод збереження з параметром isDraft
  Future<void> _saveDream({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      await context.read<DreamProvider>().addDream(
            title: _titleController.text,
            description: _descriptionController.text,
            category: _selectedCategory!,
            emotion: _selectedEmotion!,
            tags: _selectedTags,
            rating: _selectedRating,
            isDraft: isDraft, // Передаємо параметр у провайдер
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isDraft ? "Dream saved to drafts!" : AppStrings.dreamSavedSuccess),
            backgroundColor: Colors.green),
      );

      // Очищення форми після успішного збереження
      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedEmotion = null;
        _selectedTags.clear();
        _selectedRating = 3.0;
      });

    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error saving dream: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _showTagsDialog() async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(AppStrings.tagsLabel),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _predefinedTags.map((tag) {
                    final bool isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setDialogState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: theme.primaryColor.withOpacity(0.3),
                      checkmarkColor: theme.primaryColor,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _tagsController.text = _selectedTags.join(', ');
                  },
                  child: const Text(AppStrings.okButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = Colors.purple.shade700;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    TextStyle fieldTitleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    );

    TextStyle hintTextStyle = TextStyle(
      color: isLight ? Colors.grey.shade600 : Colors.grey.shade400,
    );

    List<BoxShadow> containerShadow = [
      BoxShadow(
        color: isLight ? Colors.grey.withOpacity(0.1) : Colors.black12,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
    Widget dreamRecordingTips = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.blue.shade50 : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                AppStrings.tipsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(AppStrings.tip1, style: hintTextStyle),
          Text(AppStrings.tip2, style: hintTextStyle),
          Text(AppStrings.tip3, style: hintTextStyle),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.addDreamTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
          Text(
            AppStrings.addDreamSubtitle,
            style: hintTextStyle,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: containerShadow,
              border: Border.all(
                  color: isLight ? Colors.grey.shade200 : Colors.grey.shade800),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Row(
                    children: [
                      Icon(Icons.drive_file_rename_outline, color: primaryColor, size: 20),
                      const SizedBox(width: 4),
                      Text(AppStrings.titleLabel, style: fieldTitleStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "e.g., 'Flying over the city'",
                      hintStyle: hintTextStyle,
                      filled: true,
                      fillColor:
                          isLight ? Colors.grey.shade100 : Colors.grey.shade800,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a dream title";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // DESCRIPTION
                  Row(
                    children: [
                      Icon(Icons.text_fields, color: primaryColor, size: 20),
                      const SizedBox(width: 4),
                      Text(AppStrings.descLabel, style: fieldTitleStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: AppStrings.descHint,
                      hintStyle: hintTextStyle,
                      filled: true,
                      fillColor:
                          isLight ? Colors.grey.shade100 : Colors.grey.shade800,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorDreamDescEmpty;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // CATEGORY & EMOTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.category,
                                    color: primaryColor, size: 20),
                                const SizedBox(width: 4),
                                Text(AppStrings.categoryLabel, style: fieldTitleStyle),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                hintText: AppStrings.categoryHint,
                                hintStyle: hintTextStyle,
                                filled: true,
                                fillColor: isLight
                                    ? Colors.grey.shade100
                                    : Colors.grey.shade800,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none),
                              ),
                              dropdownColor: theme.scaffoldBackgroundColor,
                              items: ['Lucid Dream', 'Nightmare', 'Abstract', 'Adventure']
                                  .map((String value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(color: secondaryColor)));
                              }).toList(),
                              onChanged: (value) {
                                setState(() { _selectedCategory = value; });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return AppStrings.errorCategoryEmpty;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.favorite_border,
                                    color: primaryColor, size: 20),
                                const SizedBox(width: 4),
                                Text(AppStrings.emotionLabel, style: fieldTitleStyle),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedEmotion,
                              decoration: InputDecoration(
                                hintText: AppStrings.emotionHint,
                                hintStyle: hintTextStyle,
                                filled: true,
                                fillColor: isLight
                                    ? Colors.grey.shade100
                                    : Colors.grey.shade800,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none),
                              ),
                              dropdownColor: theme.scaffoldBackgroundColor,
                              items: ['Happy', 'Peaceful', 'Anxious', 'Fearful']
                                  .map((String value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(color: secondaryColor)));
                              }).toList(),
                              onChanged: (value) {
                                setState(() { _selectedEmotion = value; });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return AppStrings.errorEmotionEmpty;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TAGS
                  Row(
                    children: [
                      Icon(Icons.tag, color: primaryColor, size: 20),
                      const SizedBox(width: 4),
                      Text(AppStrings.tagsLabel, style: fieldTitleStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tagsController,
                    readOnly: true,
                    onTap: _showTagsDialog,
                    decoration: InputDecoration(
                      hintText: AppStrings.tagsHint,
                      hintStyle: hintTextStyle,
                      filled: true,
                      fillColor:
                          isLight ? Colors.grey.shade100 : Colors.grey.shade800,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  Text(
                      AppStrings.tagsHelpText,
                      style: hintTextStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 20),

                  // RATING
                  Row(
                    children: [
                      Icon(Icons.star_border, color: primaryColor, size: 20),
                      const SizedBox(width: 4),
                      Text("Rating", style: fieldTitleStyle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _selectedRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _selectedRating = rating;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                           // Очистити форму або повернутися назад?
                           // Зазвичай тут Navigator.pop(context), але якщо це таб, то просто очистити
                           _formKey.currentState?.reset();
                           _titleController.clear();
                           _descriptionController.clear();
                           _tagsController.clear();
                           setState(() {
                              _selectedCategory = null;
                              _selectedEmotion = null;
                              _selectedTags.clear();
                              _selectedRating = 3.0;
                           });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.close, // Змінив іконку для логіки "Clear"
                                color: isLight
                                    ? Colors.grey.shade700
                                    : Colors.white),
                            const SizedBox(width: 4),
                            Text("Clear", // Змінив текст на Clear, бо Cancel для таба не дуже пасує
                                style: TextStyle(
                                    color: isLight
                                        ? Colors.grey.shade700
                                        : Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // SAVE AS DRAFT BUTTON
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _saveDream(isDraft: true),
                        icon: const Icon(Icons.archive, color: Colors.black),
                        label: const Text(AppStrings.saveDraftButton,
                            style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLight
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // SAVE DREAM BUTTON (PUBLISH)
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _saveDream(isDraft: false),
                        icon: _isLoading
                          ? Container()
                          : const Icon(Icons.check, color: Colors.white),
                        label: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(AppStrings.saveDreamButton,
                              style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          dreamRecordingTips,
        ],
      ),
    );
  }
}