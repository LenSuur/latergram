import 'package:flutter/material.dart';
import '../../../../shared/services/reflection_service.dart';
import '../../data/models/reflection_model.dart';

class TimelineScreen extends StatefulWidget {
  final String userId;
  final int initialYear;

  const TimelineScreen({
    super.key,
    required this.userId,
    required this.initialYear,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final ReflectionService _reflectionService = ReflectionService();

  late PageController _pageController;
  int _currentPage = 0;
  List<ReflectionModel> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    final reflections = await _reflectionService.getAllUserReflections(widget.userId);

    if (mounted) {
      // Find index of initial year
      final initialIndex = reflections.indexWhere(
        (r) => r.year == widget.initialYear,
      );

      setState(() {
        _reflections = reflections;
        _currentPage = initialIndex >= 0 ? initialIndex : 0;
        _isLoading = false;
      });

      // Jump to initial page after build
      if (reflections.isNotEmpty && initialIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(initialIndex);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_reflections.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No reflections found',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // PageView for swiping
          PageView.builder(
            controller: _pageController,
            itemCount: _reflections.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final reflection = _reflections[index];
              return _buildTimelinePage(reflection);
            },
          ),

          // Top bar with close button and year
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    // Year badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_reflections[_currentPage].year}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // Spacer for symmetry
                    SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Bottom indicators (dots)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _reflections.length,
                        (index) => _buildDotIndicator(index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelinePage(ReflectionModel reflection) {
    return Column(
      children: [
        // Photo
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            child: Image.network(
              reflection.photoUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ),

        // Info section
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                Text(
                  reflection.userName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                // Reflection text
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      reflection.reflectionText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[600],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
