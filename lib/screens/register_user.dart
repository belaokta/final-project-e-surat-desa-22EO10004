import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nikCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _alamatCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// 🔥 REGISTER FIREBASE (AUTO UID)
  void _submitRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // 1️⃣ Buat akun Firebase Auth
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

        final uid = cred.user!.uid; // ✅ AUTO USER ID

        // 2️⃣ Simpan ke Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'nama': _namaCtrl.text.trim(),
          'nik': _nikCtrl.text.trim(),
          'alamat': _alamatCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': 'user',
          'isVerified': true,
          'createdAt': Timestamp.now(),
        });

        // 3️⃣ WAJIB logout (karena belum diverifikasi)
        await FirebaseAuth.instance.signOut();

        // 4️⃣ Dialog sukses (TAMPILAN ASLI)
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Pendaftaran Berhasil'),
                content: const Text(
                  'Akun Anda terdaftar dan menunggu verifikasi oleh admin.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // balik ke login
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } on FirebaseAuthException catch (e) {
        String msg = 'Pendaftaran gagal';
        if (e.code == 'email-already-in-use') {
          msg = 'Email sudah terdaftar';
        } else if (e.code == 'weak-password') {
          msg = 'Password terlalu lemah';
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  String? _validateNotEmpty(String? v) {
    if (v == null || v.trim().isEmpty) return 'Field tidak boleh kosong';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F58CD),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Lengkapi Data Berikut',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _namaCtrl,
                  decoration: _inputDecoration('Nama Lengkap'),
                  validator: _validateNotEmpty,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nikCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('NIK'),
                  validator: _validateNotEmpty,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _alamatCtrl,
                  decoration: _inputDecoration('Alamat'),
                  validator: _validateNotEmpty,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email'),
                  validator: _validateNotEmpty,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _inputDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _submitRegister,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AE0), Color(0xFFB39DDB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Catatan : Akun menunggu verifikasi admin',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6A5AE0)),
      ),
    );
  }
}
