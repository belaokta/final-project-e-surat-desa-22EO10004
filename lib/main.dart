import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/choose_role.dart';
import 'screens/login_user.dart';
import 'screens/admin_login.dart';
import 'screens/dashboard_user.dart';
import 'screens/dashboard_admin.dart';
import 'screens/ajukan_surat.dart';
import 'screens/status_surat.dart';
import 'screens/riwayat_surat.dart';
import 'screens/verifikasi_akun.dart';
import 'screens/kelola_surat_masuk.dart';
import 'screens/profile_user.dart';
import 'screens/register_user.dart';
import 'screens/profile_admin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'e-Surat Desa',
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/choose_role': (_) => const ChooseRolePage(),
        '/login_user': (_) => const LoginUserPage(),
        '/register_user': (_) => const RegisterUserPage(),
        '/admin_login': (_) => const AdminLoginPage(),
        '/dashboard_user': (_) => const DashboardUserPage(),
        '/dashboard_admin': (_) => const DashboardAdminPage(),
        '/ajukan_surat': (_) => const AjukanSuratPage(),
        '/status_surat': (_) => const StatusSuratPage(),
        '/riwayat_surat': (_) => const RiwayatSuratPage(),
        '/verifikasi_akun': (_) => const VerifikasiAkunPage(),
        '/kelola_surat_masuk': (_) => const KelolaSuratMasukPage(),
        '/profile_user': (_) => const ProfileUserPage(),
        '/profile_admin': (_) => const ProfileAdminPage(),
      },
    );
  }
}
