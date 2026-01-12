import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:latergram/core/router/app_router.dart';
import 'package:latergram/core/theme/app_theme.dart';
import 'package:latergram/firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

late final String appVersion;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final packageInfo = await PackageInfo.fromPlatform();
  appVersion = packageInfo.version;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
