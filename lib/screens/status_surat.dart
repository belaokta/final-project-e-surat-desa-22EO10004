// lib/screens/status_surat.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../models/submission.dart';

class StatusSuratPage extends StatefulWidget {
  const StatusSuratPage({super.key});

  @override
  State<StatusSuratPage> createState() => _StatusSuratPageState();
}

class _StatusSuratPageState extends State<StatusSuratPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Surat'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child:
                    user == null
                        ? const Center(child: Text("Silakan Login Kembali"))
                        : StreamBuilder<QuerySnapshot>(
                          // 🔥 Filter userId agar hanya surat dia yang muncul
                          stream:
                              FirebaseFirestore.instance
                                  .collection('submissions')
                                  .where('userId', isEqualTo: user.uid)
                                  .snapshots(), // Pakai snapshots() agar real-time
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  "Koneksi Error. Coba Refresh Halaman.",
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data?.docs ?? [];

                            if (docs.isEmpty) {
                              return _buildEmptyState();
                            }

                            return ListView.separated(
                              itemCount: docs.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) {
                                final data =
                                    docs[idx].data() as Map<String, dynamic>;
                                final s = Submission.fromMap(
                                  data,
                                  docs[idx].id,
                                );
                                return _cardSummary(s);
                              },
                            );
                          },
                        ),
              ),
              const SizedBox(height: 12),
              _buildRiwayatButton(), // Tombol biru di bawah
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET TAMPILAN ---
  Widget _cardSummary(Submission s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.jenis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Diajukan pada: ${s.createdAt.day.toString().padLeft(2, '0')} ${_monthName(s.createdAt.month)} ${s.createdAt.year}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          smallBadge(s.status), // Badge warna-warni
        ],
      ),
    );
  }

  Widget smallBadge(String status) {
    Color bg;
    Color text;
    if (status == 'Menunggu') {
      bg = const Color(0xFFFFF3E0);
      text = const Color(0xFFF57C00);
    } else if (status == 'Selesai') {
      bg = const Color(0xFFE8F5E9);
      text = const Color(0xFF2E7D32);
    } else if (status == 'Ditolak') {
      bg = const Color(0xFFFFEBEE);
      text = const Color(0xFFC62828);
    } else {
      bg = Colors.grey.shade200;
      text = Colors.black87;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Belum ada pengajuan', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/ajukan_surat'),
            child: const Text('Ajukan Surat'),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/riwayat_surat'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Riwayat Surat',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[m - 1];
  }
}
