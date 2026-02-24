import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await SettingsService.load();
  runApp(const AgriApp());
}

class AgriApp extends StatelessWidget {
  const AgriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家庭菜園アプリ',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.data == null) {
            return const LoginScreen();
          }
          // 初回ログイン時にローカルデータをFirestoreへ移行
          StorageService.migrateFromLocalStorage(snap.data!.uid);
          return const HomeScreen();
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        primary: const Color(0xFF2E7D32),
        secondary: const Color(0xFFF57F17),
      ),
      useMaterial3: true,
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
