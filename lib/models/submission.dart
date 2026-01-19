import 'package:cloud_firestore/cloud_firestore.dart';

class Submission {
  final String id;
  final String jenis;
  final String nik;
  final String nama;
  final String alamat;
  String status; // Menunggu / Diproses / Selesai / Ditolak
  final DateTime createdAt;

  Submission({
    required this.id,
    required this.jenis,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.status,
    required this.createdAt,
  });

  // 🔹 fromMap factory
  factory Submission.fromMap(Map<String, dynamic> map, String docId) {
    return Submission(
      id: docId,
      jenis: map['jenis'] ?? '',
      nik: map['nik'] ?? '',
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      status: map['status'] ?? 'Menunggu',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🔹 Optional: toMap
  Map<String, dynamic> toMap() {
    return {
      'jenis': jenis,
      'nik': nik,
      'nama': nama,
      'alamat': alamat,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

class SubmissionRepository {
  SubmissionRepository._private();
  static final SubmissionRepository instance = SubmissionRepository._private();

  final List<Submission> _items = [];

  List<Submission> getAll() => List.unmodifiable(_items);

  void add(Submission s) {
    _items.insert(0, s);
  }

  void updateStatus(String id, String newStatus) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0) _items[i].status = newStatus;
  }

  void clearAll() => _items.clear();
}
