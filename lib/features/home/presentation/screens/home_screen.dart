import 'package:flutter/material.dart';
import 'package:latergram/shared/services/auth_service.dart';
import 'package:latergram/shared/services/reflection_service.dart';

import '../../../../core/utils/date_helper.dart';
import '../../../reflection/data/models/reflection_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ReflectionService _reflectionService = ReflectionService();

  ReflectionModel? _currentYearReflection;
  List<ReflectionModel> _pastReflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      // Get current year's reflection
      final currentYear = DateHelper.currentYear();
      final currentReflection = await _reflectionService
          .getUserReflectionForYear(user.uid, currentYear);

      setState(() {
        _currentYearReflection = currentReflection;
        _isLoading = false;
      });

      // Listen to past reflections (Stream - real-time updates)
      _reflectionService.getUserReflections(user.uid).listen((reflections) {
        setState(() {
          _pastReflections = reflections
              .where((r) => r.year < DateHelper.currentYear())
              .toList();
        });
      });
    } catch (e) {
      print('Error loading reflections: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCurrentYearCard() {
    final currentYear = DateHelper.currentYear();

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Aasta $currentYear',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Photo or placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.add_photo_alternate,
                  size: 64,
                  color: Colors.grey[600],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Placeholder text
            Text(
              'Lisa oma foto ja mõtted...',
              style: TextStyle(color: Colors.grey[600]),
            ),

            SizedBox(height: 16),

            // Open button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Open button pressed');
                  // TODO: Navigate to create screen
                },
                child: Text('Ava'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastYearsCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Varasemad aastad',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Siin kuvatakse sinu varasemad aastad',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        toolbarHeight: 56,
        flexibleSpace: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home - clickable image
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    print('Home tapped');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/icon_home.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            Text(
                              'Error loading image',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ],
                        );
                      },
                    )
                  ),
                ),
              ),

              // Gallery - clickable image
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    print('Gallery tapped');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/icon_gallery.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Profile - clickable image
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    print('Profile tapped');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/icon_profile.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card 1: Current Year
                  _buildCurrentYearCard(),

                  SizedBox(height: 16),

                  // Card 2: Past Years
                  _buildPastYearsCard(),
                ],
              ),
            ),
      floatingActionButton: DateHelper.isDecember()
          ? GestureDetector(
        onTap: () {
          print('Camera tapped');
          // TODO: Navigate to create reflection
        },
        child: Container(
          width: 80,
          height: 80,
          child: Image.asset(
            'assets/images/icon_camera.png',
            fit: BoxFit.contain,
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
