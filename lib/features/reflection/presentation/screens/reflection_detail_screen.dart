import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latergram/features/reflection/presentation/screens/timeline_screen.dart';
import '../../../../shared/services/reflection_service.dart';
import '../../data/models/reflection_model.dart';
import 'fullscreen_photo.dart';

class ReflectionDetailScreen extends StatefulWidget {
  final ReflectionModel reflection;

  const ReflectionDetailScreen({super.key, required this.reflection});

  @override
  State<ReflectionDetailScreen> createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen> {
  final ReflectionService _reflectionService = ReflectionService();

  @override
  Widget build(BuildContext context) {
    final reflection = widget.reflection;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${reflection.year}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullscreenPhoto(
                      photoUrl: reflection.photoUrl,
                      heroTag: 'photo_${reflection.id}',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'photo_${reflection.id}',
                child: Image.network(
                  reflection.photoUrl,
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 400,
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
                      height: 400,
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(Icons.error, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
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

                  SizedBox(height: 16),

                  Text(
                    reflection.reflectionText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 24),

                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Capture context BEFORE any async operations
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final theme = Theme.of(context);

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );

                        // Fetch all reflections for this user
                        final allReflections = await _reflectionService
                            .getAllUserReflections(widget.reflection.userId);

                        // Close loading - use captured navigator
                        navigator.pop();

                        if (allReflections.isEmpty) {
                          // No reflections found
                          messenger.showSnackBar(
                            SnackBar(content: Text('No reflections found')),
                          );
                          return;
                        }

                        // Find index of current reflection
                        final currentIndex = allReflections.indexWhere(
                              (r) => r.year == widget.reflection.year,
                        );

                        // Open timeline - use captured navigator
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) => TimelineScreen(
                              reflections: allReflections,
                              initialIndex: currentIndex >= 0 ? currentIndex : 0,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.timeline),
                      label: Text('View Timeline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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
}
