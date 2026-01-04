import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
    print('========================================');
    print('YOUR USER ID: ${_authService.currentUser?.uid}');
    print('========================================');
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

            // Open button - NOW NAVIGATES
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go('/draft-reflection');
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
    // If no past reflections, show empty state
    if (_pastReflections.isEmpty) {
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

    // Show list of past years with accordion
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

            // List of past years
            ..._pastReflections
                .map((reflection) => _PastYearItem(reflection: reflection))
                .toList(),
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
                    // Already on home
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/icon_home.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Gallery - clickable image WITH NAVIGATION
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.go('/gallery');
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

              // Profile - clickable image WITH NAVIGATION
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.go('/profile');
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
              onTap: () async {
                final ImagePicker imagePicker = ImagePicker();
                final XFile? photo = await imagePicker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1920,
                  maxHeight: 1920,
                  imageQuality: 85,
                );

                if (photo != null) {
                  context.push('/draft-reflection', extra: photo.path);
                }
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

// Accordion item for past years
class _PastYearItem extends StatefulWidget {
  final ReflectionModel reflection;

  const _PastYearItem({required this.reflection});

  @override
  State<_PastYearItem> createState() => _PastYearItemState();
}

class _PastYearItemState extends State<_PastYearItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Aasta ${widget.reflection.year}',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey[400],
          ),
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
          },
        ),

        if (_isExpanded)
          GestureDetector(
            onTap: () {
              // TODO: Navigate to detail view
              print('View reflection: ${widget.reflection.id}');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.reflection.photoUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(Icons.error, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ),

        Divider(color: Colors.grey[800]),
      ],
    );
  }
}
