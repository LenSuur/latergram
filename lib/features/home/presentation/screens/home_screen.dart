import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latergram/shared/services/auth_service.dart';
import 'package:latergram/shared/services/reflection_service.dart';

import '../../../../core/utils/date_helper.dart';
import '../../../../shared/widgets/main_app_bar.dart';
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

    setState(() => _isLoading = false);

    try {
      _reflectionService.getUserReflections(user.uid).listen((reflections) {
        final currentYear = DateHelper.currentYear();

        ReflectionModel? currentYearReflection;
        try {
          currentYearReflection = reflections.firstWhere(
            (r) => r.year == currentYear,
          );
        } catch (e) {
          currentYearReflection = null;
        }

        // Filter past year reflections
        final pastReflections = reflections
            .where((r) => r.year < currentYear)
            .toList();

        setState(() {
          _currentYearReflection = currentYearReflection;
          _pastReflections = pastReflections;
        });
      });
    } catch (e) {
      print('Error loading reflections: $e');
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

            _currentYearReflection == null
                ? Container(
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
                  )
                : GestureDetector(
                    onTap: () {
                      context.push(
                        '/reflection-detail',
                        extra: _currentYearReflection,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Hero(
                        tag: 'photo_${_currentYearReflection!.id}',
                        child: Image.network(
                          _currentYearReflection!.photoUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

            SizedBox(height: 16),

            _currentYearReflection == null
                ? Text(
                    'Lisa oma foto ja mõtted...',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                : Text(
                    _currentYearReflection!.reflectionText,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentYearReflection != null) {
                    context.push(
                      '/draft-reflection',
                      extra: _currentYearReflection,
                    );
                  } else {
                    context.go('/draft-reflection');
                  }
                },
                child: Text(_currentYearReflection == null ? 'Ava' : 'Muuda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastYearsCard() {
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
      appBar: MainAppBar(currentRoute: '/home'),
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
              context.push('/reflection-detail', extra: widget.reflection);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: 'photo_${widget.reflection.id}',
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
          ),

        Divider(color: Colors.grey[800]),
      ],
    );
  }
}
