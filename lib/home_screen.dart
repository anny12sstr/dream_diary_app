// ignore_for_file: deprecated_member_use, sort_child_properties_last, use_build_context_synchronously
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:universal_html/html.dart' as html; 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'add_dream_screen.dart';
import 'analytics_screen.dart';
import 'services/auth_repository.dart';
import 'constants/app_strings.dart';
import 'providers/dream_provider.dart';
import 'widgets/dream_app_header.dart';
import 'dream_detail_screen.dart';
import 'edit_dream_screen.dart';
import 'package:dream_diary_app/models/dream_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen(this.toggleTheme, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthRepository _authRepository = AuthRepository();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  String? _selectedEmotion;

  int _currentPage = 1;
  final int _itemsPerPage = 2; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        analytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'Dashboard'},
        );
      } catch (e) {
        // Handle error
      }
    });
  }

  // ЕКСПОРТ  WEB версія
  Future<void> _exportDreams() async {
    try {
      final dreams = context.read<DreamProvider>().dreams;
      if (dreams.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No dreams to export")),
        );
        return;
      }

      final List<Map<String, dynamic>> dreamsMapList = dreams.map((d) => {
        'id': d.id,
        'title': d.title,
        'description': d.description,
        'date': d.date.toIso8601String(),
        'category': d.category,
        'emotion': d.emotion,
        'rating': d.rating,
        'tags': d.tags,
        'isDraft': d.isDraft,
      }).toList();
      
      final String jsonString = const JsonEncoder.withIndent('  ').convert(dreamsMapList);
      final String fileName = 'dreams_export_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
          
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded'), backgroundColor: Colors.green),
        );
      } 

    } catch (e) {
      debugPrint(" EXPORT ERROR: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _currentPage = 1; 
      });
      _applyFilters();
    }
  }

  void _clearDate(bool isStartDate) {
    setState(() {
      if (isStartDate) {
        _startDate = null;
      } else {
        _endDate = null;
      }
      _currentPage = 1;
    });
    _applyFilters();
  }

  void _applyFilters() {
    context.read<DreamProvider>().applyFilters(
          startDate: _startDate,
          endDate: _endDate,
          category: _selectedCategory,
          emotion: _selectedEmotion,
        );
  }

  List<Widget> get _pages => [
        _buildDashboard(context),
        AddDreamScreen(widget.toggleTheme),
        AnalyticsScreen(widget.toggleTheme),
      ];

  void _navigateToDetail(BuildContext context, Dream dream) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DreamDetailScreen(dream: dream),
      ),
    ).then((_) {
       _applyFilters();
    });
  }

  void _navigateToEdit(BuildContext context, Dream dream) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDreamScreen(dream: dream),
      ),
    ).then((_) {
      _applyFilters();
    });
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = Colors.purple.shade700;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    final dreamProvider = context.watch<DreamProvider>();
    final totalItems = dreamProvider.totalFilteredDreamsCount;
    final paginatedDreams = dreamProvider.getDreamsForPage(_currentPage, _itemsPerPage);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.dashboardTitle,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor)),
                  Text(AppStrings.dashboardSubtitle,
                      style: TextStyle(
                          color: isLight
                              ? Colors.grey.shade600
                              : Colors.grey.shade400)),
                ],
              ),
              Row(
                children: [
                
                  TextButton.icon(
                    onPressed: _exportDreams,
                    icon: Icon(Icons.download_outlined,
                        color: isLight ? Colors.grey.shade700 : Colors.white70),
                    label: Text(AppStrings.exportButton,
                        style: TextStyle(
                            color: isLight
                                ? Colors.grey.shade700
                                : Colors.white70)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            color: isLight
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _onItemTapped(1),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(AppStrings.newDreamButton,
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
      


          _FilterControls(
            startDate: _startDate,
            endDate: _endDate,
            onSelectDate: _selectDate,
            onClearDate: _clearDate,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
                _currentPage = 1;
              });
              _applyFilters();
            },
            selectedEmotion: _selectedEmotion,
            onEmotionChanged: (newValue) {
              setState(() {
                _selectedEmotion = newValue;
                _currentPage = 1;
              });
              _applyFilters();
            },
            onFilterPressed: _applyFilters,
          ),

          const SizedBox(height: 16),

          _buildDreamGrid(paginatedDreams, theme, isLight, secondaryColor),

          const SizedBox(height: 16),

          _buildPaginationControls(totalItems, theme),
        ],
      ),
    );
  }

  Widget _buildDreamGrid(List<Dream> dreams, ThemeData theme, bool isLight, Color secondaryColor) {
    final dreamProvider = context.watch<DreamProvider>();

    if (dreamProvider.isLoading) {
      return const Center(
        heightFactor: 10,
        child: CircularProgressIndicator(),
      );
    }

    if (dreamProvider.error != null) {
      return Center(
        heightFactor: 10,
        child: Text(
          'Error loading dreams: ${dreamProvider.error}',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (dreams.isEmpty) {
      return const Center(
        heightFactor: 10,
        child: Text('No dreams found for this period.'),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.65,
      ),
      itemCount: dreams.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final dream = dreams[index];
        return _buildDreamCard(dream, theme, isLight, secondaryColor);
      },
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        emotion,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDreamCard(Dream dream, ThemeData theme, bool isLight, Color secondaryColor) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, dream),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: isLight
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dream.title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      dream.category,
                      style: TextStyle(
                        color: Colors.purple.shade400,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildEmotionPill(dream.emotion, theme),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dream.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: isLight ? Colors.grey.shade700 : Colors.grey.shade400,
                      fontSize: 13,
                      height: 1.4),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${dream.date.day}.${dream.date.month}.${dream.date.year}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${dream.rating.toStringAsFixed(1)}/5',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: -12,
              right: -12,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz,
                    color: isLight ? Colors.grey.shade700 : Colors.grey.shade400),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(dream.id);
                  } else if (value == 'rate') {
                    _showRatingDialog(dream);
                  } else if (value == 'edit') {
                    _navigateToEdit(context, dream);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'rate',
                    child: ListTile(
                      leading: Icon(Icons.star_border),
                      title: Text('Rate Dream'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalItems, ThemeData theme) {
    if (totalItems == 0) return const SizedBox.shrink();

    final int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    final bool isLight = theme.brightness == Brightness.light;
    final Color primaryColor = theme.primaryColor;
    final Color secondaryColor = isLight ? Colors.black : Colors.white;

    List<Widget> pageWidgets = [];

    pageWidgets.add(_buildPageNumber(1, secondaryColor, primaryColor));

    if (_currentPage > 3) {
      pageWidgets.add(const Text('...'));
    }

    for (int i = max(2, _currentPage - 1); i <= min(totalPages - 1, _currentPage + 1); i++) {
      pageWidgets.add(_buildPageNumber(i, secondaryColor, primaryColor));
    }

    if (_currentPage < totalPages - 2) {
      pageWidgets.add(const Text('...'));
    }

    if (totalPages > 1) {
      pageWidgets.add(_buildPageNumber(totalPages, secondaryColor, primaryColor));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _currentPage == 1
                ? null
                : () {
                    setState(() {
                      _currentPage--;
                    });
                  },
            icon: Icon(Icons.chevron_left,
                color: _currentPage == 1 ? Colors.grey : secondaryColor)),
        const SizedBox(width: 8),
        ...pageWidgets.map((w) =>
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: w)),
        const SizedBox(width: 8),
        IconButton(
            onPressed: _currentPage == totalPages
                ? null
                : () {
                    setState(() {
                      _currentPage++;
                    });
                  },
            icon: Icon(Icons.chevron_right,
                color: _currentPage == totalPages ? Colors.grey : secondaryColor)),
      ],
    );
  }

  Widget _buildPageNumber(int page, Color textColor, Color primaryColor) {
    bool isCurrent = _currentPage == page;
    return TextButton(
      onPressed: () {
        setState(() {
          _currentPage = page;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isCurrent ? primaryColor : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(40, 40),
      ),
      child: Text(
        '$page',
        style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? Colors.white : textColor),
      ),
    );
  }

  Future<void> _showRatingDialog(Dream dream) async {
    double currentRating = dream.rating;
    final dreamProvider = context.read<DreamProvider>(); 

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rate this dream'),
          content: StatefulBuilder(builder: (context, setState) {
            return RatingBar.builder(
              initialRating: currentRating,
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
                  currentRating = rating;
                });
              },
            );
          }),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  await dreamProvider.updateDreamRating(dream.id, currentRating);
                  
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rating updated!"), backgroundColor: Colors.green));
                  
                  // ВИПРАВЛЕННЯ: Тут теж оновлюємо фільтри, щоб список на UI оновився
                  _applyFilters();
                  
                } catch (e) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update rating: $e"), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(String dreamId) async {
    final dreamProvider = context.read<DreamProvider>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Dream?'),
          content: const Text('Are you sure you want to permanently delete this dream?'),
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

  void _onItemTapped(int index) {
    try {
      String screenName;
      switch (index) {
        case 0:
          screenName = 'Dashboard';
          break;
        case 1:
          screenName = 'Add_Dream';
          break;
        case 2:
          screenName = 'Analytics';
          break;
        default:
          screenName = 'Unknown';
      }
      FirebaseAnalytics.instance.logEvent(
        name: 'navigation_tap',
        parameters: {'screen_name': screenName},
      );
    } catch (e) {
      //
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = Colors.purple.shade700;

    return Scaffold(
      appBar: DreamAppHeader(
        selectedIndex: _selectedIndex,
        onNavigate: _onItemTapped,
        onAccountOptions: _showAccountOptions,
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            top: 24,
            right: 32,
            child: GestureDetector(
              onTap: widget.toggleTheme,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFFCD34D) : primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isLight ? primaryColor : Colors.white, width: 2),
                ),
                child: Icon(
                  isLight ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                  color: isLight ? primaryColor : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountOptions() {
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.accountOptionsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUser != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text(
                  AppStrings.loggedInAs,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Text(
                  currentUser.email ?? AppStrings.noEmailAvailable,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(AppStrings.logOutButton,
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await _authRepository.signOut();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${AppStrings.errorGeneric}: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text(AppStrings.loginButton),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text(AppStrings.signUpButtonDialog),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/signup');
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ... Клас _FilterControls залишається без змін, як у попередньому повідомленні ...
class _FilterControls extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(BuildContext, bool) onSelectDate;
  final Function(bool) onClearDate; 
  
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  
  final String? selectedEmotion;
  final Function(String?) onEmotionChanged;

  final VoidCallback onFilterPressed;

  static const double _breakpoint = 1100.0;

  const _FilterControls({
    this.startDate,
    this.endDate,
    required this.onSelectDate,
    required this.onClearDate, 
    this.selectedCategory,
    required this.onCategoryChanged,
    this.selectedEmotion,
    required this.onEmotionChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _breakpoint) {
          return _buildNarrowLayout(context);
        } else {
          return _buildWideLayout(context);
        }
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.grey.withOpacity(0.1) : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
            color: isLight ? Colors.grey.shade200 : Colors.grey.shade800),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppStrings.filterDateRange,
              style: TextStyle(color: secondaryColor)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildDatePickerButton(context, true), 
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(AppStrings.filterDateTo,
                style: TextStyle(color: secondaryColor)),
          ),
          Expanded(
            flex: 2,
            child: _buildDatePickerButton(context, false), 
          ),
          const SizedBox(width: 24),
          Text(AppStrings.filterCategory,
              style: TextStyle(color: secondaryColor)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildDropdown(
              context,
              AppStrings.filterCategoryAll,
              ['All Categories', 'Lucid Dream', 'Nightmare', 'Abstract', 'Adventure'],
              selectedCategory, 
              onCategoryChanged, 
            ),
          ),
          const SizedBox(width: 24),
          Text(AppStrings.filterEmotion,
              style: TextStyle(color: secondaryColor)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildDropdown(
              context, 
              AppStrings.filterEmotionAll,
              ['All Emotions', 'Happy', 'Peaceful', 'Anxious', 'Fearful'], 
              selectedEmotion, 
              onEmotionChanged
            ), 
          ),
          const SizedBox(width: 24),
          _buildSearchButton(context),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryColor = isLight ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.grey.withOpacity(0.1) : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
            color: isLight ? Colors.grey.shade200 : Colors.grey.shade800),
      ),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 16.0,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          _buildFilterGroup(
            label: AppStrings.filterDateRange,
            labelColor: secondaryColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 140,
                  child: _buildDatePickerButton(context, true),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(AppStrings.filterDateTo,
                      style: TextStyle(color: secondaryColor)),
                ),
                SizedBox(
                  width: 140,
                  child: _buildDatePickerButton(context, false), 
                ),
              ],
            ),
          ),
          _buildFilterGroup(
            label: AppStrings.filterCategory,
            labelColor: secondaryColor,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200),
              child: _buildDropdown(
                context,
                AppStrings.filterCategoryAll,
                ['All Categories', 'Lucid Dream', 'Nightmare', 'Abstract', 'Adventure'],
                selectedCategory,
                onCategoryChanged,
              ),
            ),
          ),
          _buildFilterGroup(
            label: AppStrings.filterEmotion,
            labelColor: secondaryColor,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200),
              child: _buildDropdown(
                context, 
                AppStrings.filterEmotionAll,
                ['All Emotions', 'Happy', 'Peaceful', 'Anxious', 'Fearful'], 
                selectedEmotion, 
                onEmotionChanged
              ),
            ),
          ),
          _buildSearchButton(context),
        ],
      ),
    );
  }


  Widget _buildFilterGroup(
      {required String label,
      required Widget child,
      required Color labelColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: labelColor, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _filterInputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isLight ? Colors.grey.shade100 : Colors.grey.shade800,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  Widget _buildDatePickerButton(BuildContext context, bool isStartDate) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final secondaryColor = isLight ? Colors.black : Colors.white;
    final hintColor = isLight ? Colors.grey.shade600 : Colors.grey.shade400;
    final bgColor = isLight ? Colors.grey.shade100 : Colors.grey.shade800;

    final date = isStartDate ? startDate : endDate;
    final text = date == null
        ? (isStartDate
            ? AppStrings.filterHintStartDate
            : AppStrings.filterHintEndDate)
        : date.toIso8601String().split('T').first;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => onSelectDate(context, isStartDate),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(
                      color: date == null ? hintColor : secondaryColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 14),
                ),
              ),
            ),
          ),
          if (date != null)
            IconButton(
              icon: Icon(Icons.clear, size: 18, color: hintColor),
              onPressed: () => onClearDate(isStartDate),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String hint, List<String> items,
      String? value, Function(String?) onChanged) {
    final theme = Theme.of(context);
    final secondaryColor = theme.brightness == Brightness.light ? Colors.black : Colors.white;

    return DropdownButtonFormField(
      decoration: _filterInputDecoration(context, hint),
      dropdownColor: theme.scaffoldBackgroundColor,
      value: value, 
      items: items.map((String value) {
        return DropdownMenuItem(
            value: value,
            child: Text(value, style: TextStyle(color: secondaryColor)));
      }).toList(),
      onChanged: onChanged, 
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    final primaryColor = Colors.purple.shade700;
    return ElevatedButton(
      onPressed: onFilterPressed, 
      child: const Icon(Icons.search, color: Colors.white),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}