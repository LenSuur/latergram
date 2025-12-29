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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Legendid', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Center(
              child: Text(
                'Data loaded!',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}
