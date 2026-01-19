import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class AjukanSuratPage extends StatefulWidget {
  const AjukanSuratPage({super.key});
  @override
  State<AjukanSuratPage> createState() => _AjukanSuratPageState();
}

class _AjukanSuratPageState extends State<AjukanSuratPage> {
  String selectedJenis = 'Pilih jenis surat';
  final TextEditingController nikCtrl = TextEditingController();
  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController alamatCtrl = TextEditingController();

  @override
  void dispose() {
    nikCtrl.dispose();
    namaCtrl.dispose();
    alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> openJenisDialog() async {
    final items = [
      'Surat Keterangan Domisili',
      'Surat Keterangan Usaha',
      'Surat Keterangan Tidak Mampu',
      'Surat Kelahiran',
      'Surat Kematian',
    ];

    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder:
          (ctx) => SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder:
                  (c, i) => ListTile(
                    title: Text(items[i]),
                    onTap: () => Navigator.pop(ctx, items[i]),
                  ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: items.length,
            ),
          ),
    );

    if (!mounted) return; // ✅ FIX LINTER

    if (choice != null) {
      setState(() => selectedJenis = choice);
    }
  }

  /// 🔥 SUBMIT KE FIRESTORE
  Future<void> submitPengajuan() async {
    if (selectedJenis == 'Pilih jenis surat') {
      _msg('Pilih jenis surat dulu');
      return;
    }
    if (nikCtrl.text.trim().isEmpty ||
        namaCtrl.text.trim().isEmpty ||
        alamatCtrl.text.trim().isEmpty) {
      _msg('Lengkapi semua field yang diperlukan');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _msg('User belum login');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('submissions').add({
        'userId': user.uid,
        'jenis': selectedJenis,
        'nik': nikCtrl.text.trim(),
        'nama': namaCtrl.text.trim(),
        'alamat': alamatCtrl.text.trim(),
        'status': 'Menunggu',
        'createdAt': FieldValue.serverTimestamp(),
      });

      nikCtrl.clear();
      namaCtrl.clear();
      alamatCtrl.clear();

      if (!mounted) return; // ✅ FIX LINTER

      setState(() {
        selectedJenis = 'Pilih jenis surat';
      });

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Pengajuan Terkirim'),
              content: const Text(
                'Permintaan surat telah dikirim. Silakan ambil fisik surat ke balai desa apabila disetujui.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/riwayat_surat');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      _msg('Gagal mengirim pengajuan');
    }
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Surat'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text('Jenis Surat', style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: openJenisDialog,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(selectedJenis)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('NIK', style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: nikCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan NIK',
                  prefixIcon: const Icon(
                    Icons.credit_card_outlined,
                    color: AppColors.textGray,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Nama Lengkap', style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama sesuai KTP',
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: AppColors.textGray,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Alamat', style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              TextField(
                controller: alamatCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat lengkap',
                  prefixIcon: const Icon(
                    Icons.home_outlined,
                    color: AppColors.textGray,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submitPengajuan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Kirim Pengajuan',
                    style: AppTextStyle.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
