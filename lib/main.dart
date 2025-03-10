import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:comet/config/firebase_options.dart';
import 'package:comet/config/theme.dart';
import 'package:comet/core/services/auth_service.dart';
import 'package:comet/core/services/notification_service.dart';
import 'package:comet/core/services/encryption_service.dart';
import 'package:comet/features/auth/controller/auth_controller.dart';
import 'package:comet/features/auth/presentation/screens/login_screen.dart';
import 'package:comet/features/community/controller/community_controller.dart';
import 'package:comet/features/items/controller/item_controller.dart';
import 'package:comet/features/profile/controller/profile_controller.dart';
import 'package:comet/features/chat/controller/chat_controller.dart';
import 'package:comet/shared/layouts/main_layout.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

final GetIt locator = GetIt.instance;
final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup service locator
  setupLocator();
  
  // Initialize services
  await locator<AuthService>().init();
  await locator<NotificationService>().init();
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => ProfileController()),
      ChangeNotifierProvider(create: (_) => ItemController()),
      ChangeNotifierProvider(create: (_) => CommunityController()),
      ChangeNotifierProvider(create: (_) => ChatController()),
    ],
    child: const CometApp(),
  ));
}

void setupLocator() {
  // Core services
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => EncryptionService());
  locator.registerLazySingleton(() => FlutterSecureStorage());
}

class CometApp extends StatefulWidget {
  const CometApp({Key? key}) : super(key: key);

  @override
  State<CometApp> createState() => _CometAppState();
}

class _CometAppState extends State<CometApp> {
  @override
  void initState() {
    super.initState();
    // Check user authentication state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().checkAuthState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          if (authController.isInitializing) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (authController.currentUser != null) {
            return const MainLayout();
          }
          
          return const LoginScreen();
        },
      ),
    );
  }
}