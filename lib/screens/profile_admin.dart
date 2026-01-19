// lib/screens/profile_admin.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class ProfileAdminPage extends StatefulWidget {
  const ProfileAdminPage({super.key});

  @override
  State<ProfileAdminPage> createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  Future<Map<String, String>> _getAdminData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {'nama': '-', 'email': '-'};
    }

    final doc =
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

    return {'nama': doc.data()?['nama'] ?? 'Admin', 'email': user.email ?? '-'};
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return; // ✅ FIX warning
    Navigator.pushReplacementNamed(context, '/choose_role');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<Map<String, String>>(
            future: _getAdminData(),
            builder: (context, snapshot) {
              final nama = snapshot.data?['nama'] ?? 'Admin';
              final email = snapshot.data?['email'] ?? 'admin@desa.id';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoBox(label: 'Nama Lengkap', value: nama),
                  const SizedBox(height: 12),
                  _infoBox(label: 'Email', value: email),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),

      // Bottom Navigation Bar (TIDAK DIUBAH)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard_admin');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/kelola_surat_masuk');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Surat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _infoBox({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
