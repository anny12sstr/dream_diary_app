// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
import 'constants/app_strings.dart'; 
import 'providers/dream_provider.dart'; 
import 'package:dream_diary_app/models/dream_model.dart';

class EditDreamScreen extends StatefulWidget {
  final Dream dream; 

  const EditDreamScreen({super.key, required this.dream});

  @override
  _EditDreamScreenState createState() => _EditDreamScreenState();
}

class _EditDreamScreenState extends State<EditDreamScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  String? _selectedCategory;
  String? _selectedEmotion;
  late double _selectedRating; 

  final List<String> _predefinedTags = [
    'flying', 'falling', 'family', 'friends', 'work', 'school', 'test',
    'chased', 'running', 'water', 'ocean', 'forest', 'house', 'stranger',
    'death', 'lost', 'teeth', 'car', 'baby', 'monster', 'celebrity'
  ];
  final List<String> _selectedTags = [];

  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.dream.title);
    _descriptionController = TextEditingController(text: widget.dream.description);
    _selectedCategory = widget.dream.category;
    _selectedEmotion = widget.dream.emotion;
    _selectedRating = widget.dream.rating; 
    _selectedTags.addAll(widget.dream.tags);
    _tagsController = TextEditingController(text: _selectedTags.join(', '));
  }

  // ОНОВЛЕНИЙ МЕТОД ЗБЕРЕЖЕННЯ
  // Тепер приймає параметр publish. 
  // Якщо true - сон стає публічним (isDraft = false).
  // Якщо false - сон залишається чернеткою (якщо був нею).
  // Якщо null - залишаємо старий статус.
  Future<void> _saveDream({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    setState(() { _isLoading = true; });

    try {
      final provider = Provider.of<DreamProvider>(context, listen: false);

      // Визначаємо новий статус isDraft
      // Якщо publish == true, то isDraft стає false.
      // Інакше залишаємо те, що було (widget.dream.isDraft).
      final bool newIsDraftStatus = publish ? false : widget.dream.isDraft;

      await provider.updateDream(
            id: widget.dream.id, 
            title: _titleController.text, 
            description: _descriptionController.text,
            category: _selectedCategory!,
            emotion: _selectedEmotion!,
            tags: _selectedTags, 
            rating: _selectedRating, 
            isDraft: newIsDraftStatus, 
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(publish ? "Dream published successfully!" : "Dream updated successfully!"), 
              backgroundColor: Colors.green),
        );
        
        Navigator.pop(context);
      }

    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating dream: $e'),
              backgroundColor: Colors.red),
        );
       }
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
                    setState(() {
                         _tagsController.text = _selectedTags.join(', '); 
                    });
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

    return Scaffold( 
      appBar: AppBar(
        title: const Text(AppStrings.navEditDream), 
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

                    // BUTTONS (ЛОГІКА ПУБЛІКАЦІЇ)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel Button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); 
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back,
                                  color: isLight
                                      ? Colors.grey.shade700
                                      : Colors.white),
                              const SizedBox(width: 4),
                              Text(AppStrings.cancelButton, 
                                  style: TextStyle(
                                      color: isLight
                                          ? Colors.grey.shade700
                                          : Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ЯКЩО ЦЕ ЧЕРНЕТКА - ПОКАЗУЄМО ДОДАТКОВУ КНОПКУ "SAVE DRAFT"
                        if (widget.dream.isDraft) ...[
                          OutlinedButton(
                             onPressed: _isLoading ? null : () => _saveDream(publish: false),
                             style: OutlinedButton.styleFrom(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                               side: BorderSide(color: primaryColor),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             ),
                             child: Text("Save Draft", style: TextStyle(color: primaryColor)),
                          ),
                          const SizedBox(width: 16),
                        ],

                        // SAVE / PUBLISH BUTTON
                        ElevatedButton.icon(
                          // Якщо це чернетка, при натисканні публікуємо (publish: true).
                          // Якщо звичайний сон, просто зберігаємо (publish: false).
                          onPressed: _isLoading 
                             ? null 
                             : () => _saveDream(publish: widget.dream.isDraft),
                          
                          icon: _isLoading 
                            ? Container() 
                            : Icon(
                                widget.dream.isDraft ? Icons.publish : Icons.check, 
                                color: Colors.white
                              ),
                          label: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                // Змінюємо текст кнопки: Publish або Save
                                widget.dream.isDraft ? "Publish" : AppStrings.saveDreamButton, 
                                style: const TextStyle(color: Colors.white)
                              ),
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
          ],
        ),
      ),
    );
  }
}