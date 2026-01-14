import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/reflection_service.dart';
import '../../../../shared/services/storage_service.dart';
import '../../data/models/reflection_model.dart';

class DraftReflectionScreen extends StatefulWidget {
  final String? photoPath; // Photo from home screen camera (optional)
  final ReflectionModel? existingReflection;

  const DraftReflectionScreen({
    super.key,
    this.photoPath,
    this.existingReflection,
  });

  @override
  State<DraftReflectionScreen> createState() => _DraftReflectionScreenState();
}

class _DraftReflectionScreenState extends State<DraftReflectionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ReflectionService _reflectionService = ReflectionService();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isEditMode = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viga foto tegemisel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveReflection() async {
    if (_selectedImage == null && widget.existingReflection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Palun tee foto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Palun kirjuta sõnum'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw 'Kasutaja ei ole sisse logitud';

      final currentYear = DateHelper.currentYear();

      String photoUrl;
      if (_selectedImage != null) {
        // New photo upload
        photoUrl = await _storageService.uploadReflectionPhoto(
          photoFile: _selectedImage!,
          userId: user.uid,
          year: currentYear,
        );
      } else if (widget.existingReflection != null) {
        // Editing - keep existing photo URL
        photoUrl = widget.existingReflection!.photoUrl;
      } else {
        throw 'No photo available';
      }

      // user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Unknown';

      final reflection = ReflectionModel(
        id: widget.existingReflection?.id ?? Uuid().v4(),
        userId: user.uid,
        userName: userName,
        year: currentYear,
        reflectionText: _messageController.text.trim(),
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _reflectionService.saveReflection(reflection);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Salvestatud!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(Duration(seconds: 1));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viga salvestamisel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.existingReflection != null) {
      _messageController.text = widget.existingReflection!.reflectionText;
      _isEditMode = true;
    }
    if (widget.photoPath != null) {
      _selectedImage = File(widget.photoPath!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => context.go('/home'),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${DateHelper.currentYear()}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
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
                  // Photo display area (NOT clickable)
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    )
                        : widget.existingReflection != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.existingReflection!.photoUrl,
                        width: double.infinity,
                        height: 400,
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
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Foto puudub',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  // Message label
                  Text(
                    'Sõnum',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Message text field
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Kirjelda oma aastat...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                  // Bottom row: Submit button + Camera FAB
                  Row(
                    children: [
                      // Submit button (takes most space)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveReflection,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Camera FAB (retake photo)
                      GestureDetector(
                        onTap: _isLoading ? null : _takePhoto,
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            'assets/images/icon_camera.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
