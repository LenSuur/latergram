import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/reflection_service.dart';
import '../../../../shared/widgets/main_app_bar.dart';
import '../../../reflection/data/models/reflection_model.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ReflectionService _reflectionService = ReflectionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(currentRoute: '/gallery'),

      body: StreamBuilder<Map<int, List<ReflectionModel>>>(
        stream: _reflectionService.getAllReflectionsGroupedByYear(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading gallery',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final groupedReflections = snapshot.data ?? {};

          if (groupedReflections.isEmpty) {
            return Center(
              child: Text(
                'No reflections yet',
                style: TextStyle(color: Colors.grey[400], fontSize: 18),
              ),
            );
          }

          final years = groupedReflections.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final reflections = groupedReflections[year]!;
              return _buildYearSection(year, reflections);
            },
          );
        },
      ),
    );
  }

  Widget _buildYearSection(int year, List<ReflectionModel> reflections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year header
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '$year',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(${reflections.length})',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        // Grid of photos
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: reflections.length,
          itemBuilder: (context, index) {
            final reflection = reflections[index];
            return _buildPhotoTile(reflection);
          },
        ),

        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoTile(ReflectionModel reflection) {
    return GestureDetector(
      onTap: () {
        context.push('/reflection-detail', extra: reflection);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Hero(
          tag: 'photo_${reflection.id}',
          child: Image.network(
            reflection.photoUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[800],
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: Icon(Icons.error, color: Colors.grey[600]),
              );
            },
          ),
        ),
      ),
    );
  }
}