// lib/screens/verifikasi_akun.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class VerifikasiAkunPage extends StatefulWidget {
  const VerifikasiAkunPage({super.key});

  @override
  State<VerifikasiAkunPage> createState() => _VerifikasiAkunPageState();
}

class _VerifikasiAkunPageState extends State<VerifikasiAkunPage> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> items = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// 🔥 Ambil akun user yang belum diverifikasi
  Future<void> _loadUsers() async {
    final snap =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .get();

    if (!mounted) return;

    setState(() {
      items = snap.docs;
    });
  }

  /// 🔥 Setujui / Tolak akun
  Future<void> _setStatus(String userId, String nama, bool isVerified) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isVerified': isVerified,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status $nama diubah: ${isVerified ? 'Disetujui' : 'Ditolak'}',
        ),
      ),
    );

    _loadUsers(); // refresh list
  }

  int _bottomIndex = 1;

  void _onTapBottom(int idx) {
    if (idx == _bottomIndex) return;

    setState(() {
      _bottomIndex = idx;
    });

    if (idx == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard_admin');
    }
    if (idx == 1) {
      Navigator.pushReplacementNamed(context, '/verifikasi_akun');
    }
    if (idx == 2) {
      Navigator.pushReplacementNamed(context, '/profile_admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER (TETAP)
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(top: 28),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Verifikasi Akun Warga',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.gradientTop, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENT
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final d = items[i].data();
                    final verified = d['verified'] == true;

                    return _buildCard(
                      items[i].id,
                      d['nama'] ?? '-',
                      d['nik'] ?? '-',
                      d['email'] ?? '-',
                      verified ? 'Disetujui' : 'Pending',
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: _onTapBottom,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Surat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String userId,
    String nama,
    String nik,
    String email,
    String status,
  ) {
    Color statusColor;
    if (status == 'Disetujui') {
      statusColor = Colors.green;
    } else if (status == 'Ditolak') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'NIK : $nik',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Text(
            'Email : $email',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Status : ',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _setStatus(userId, nama, true),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Terima',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _setStatus(userId, nama, false),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Tolak', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
