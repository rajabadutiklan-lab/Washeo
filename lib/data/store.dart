import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Penyimpanan data aplikasi. Untuk sekarang semua data disimpan di HP
// (shared_preferences, format JSON) sehingga jalan tanpa internet.
// Nanti bagian _save/load bisa diganti ke server tanpa mengubah layar.

const kStatuses = [
  'Penjemputan',
  'Antrian',
  'Proses',
  'Siap Ambil',
  'Diantar',
  'Diambil',
  'Batal',
  'Telat Ambil',
];

/// Status yang berarti pesanan masih dikerjakan.
const kStatusAktif = ['Penjemputan', 'Antrian', 'Proses'];

class Durasi {
  const Durasi(this.nama, this.jam, this.kali, this.keterangan);
  final String nama;

  /// Lama pengerjaan dalam jam.
  final int jam;

  /// Pengali harga dibanding Reguler.
  final double kali;
  final String keterangan;
}

// Angka contoh - sesuaikan dengan aturan usaha.
const kDurasi = [
  Durasi('Reguler', 72, 1.0, '3 hari'),
  Durasi('Express', 24, 1.5, '1 hari'),
  Durasi('Kilat', 6, 2.0, '6 jam'),
];

class Service {
  const Service(this.id, this.nama, this.satuan, this.harga, this.langkah);
  final String id;
  final String nama;

  /// kg, pcs, atau pasang.
  final String satuan;

  /// Harga Reguler per satuan.
  final int harga;

  /// Kenaikan jumlah tiap kali tombol + ditekan.
  final double langkah;
}

// Daftar contoh - nanti diatur lewat menu Layanan.
const kServices = [
  Service('cuci_setrika', 'Cuci Setrika', 'kg', 7000, 0.5),
  Service('cuci_kering', 'Cuci Kering', 'kg', 5000, 0.5),
  Service('setrika', 'Setrika Saja', 'kg', 4500, 0.5),
  Service('bed_cover', 'Bed Cover', 'pcs', 25000, 1),
  Service('selimut', 'Selimut', 'pcs', 15000, 1),
  Service('sepatu', 'Sepatu', 'pasang', 30000, 1),
];

class Customer {
  Customer({
    required this.id,
    required this.nama,
    required this.hp,
    required this.pria,
    this.alamat = '',
    this.lat,
    this.lng,
  });

  final String id;
  String nama;
  String hp;
  bool pria;
  String alamat;
  double? lat;
  double? lng;

  bool get adaLokasi => lat != null && lng != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'hp': hp,
        'pria': pria,
        'alamat': alamat,
        'lat': lat,
        'lng': lng,
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        nama: j['nama'] as String,
        hp: (j['hp'] ?? '') as String,
        pria: (j['pria'] ?? true) as bool,
        alamat: (j['alamat'] ?? '') as String,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
      );
}

class OrderItem {
  OrderItem({
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.qty,
  });

  final String nama;
  final String satuan;

  /// Harga per satuan setelah dikali durasi.
  final int harga;
  final double qty;

  int get subtotal => (harga * qty).round();

  Map<String, dynamic> toJson() =>
      {'nama': nama, 'satuan': satuan, 'harga': harga, 'qty': qty};

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        nama: j['nama'] as String,
        satuan: j['satuan'] as String,
        harga: (j['harga'] as num).toInt(),
        qty: (j['qty'] as num).toDouble(),
      );
}

class Order {
  Order({
    required this.kode,
    required this.customerId,
    required this.nama,
    required this.pria,
    required this.masuk,
    required this.estimasi,
    required this.durasi,
    required this.items,
    required this.status,
    required this.bayar,
    this.metode = '',
    this.dibayar = 0,
    this.catatan = '',
  });

  final String kode;
  final String customerId;
  final String nama;
  final bool pria;
  final DateTime masuk;
  final DateTime estimasi;
  final String durasi;
  final List<OrderItem> items;
  String status;

  /// Belum Bayar, DP, atau Lunas.
  String bayar;
  String metode;
  int dibayar;
  String catatan;

  int get total => items.fold(0, (a, b) => a + b.subtotal);
  int get sisa => (total - dibayar).clamp(0, total).toInt();
  double get beratKg =>
      items.where((i) => i.satuan == 'kg').fold(0.0, (a, b) => a + b.qty);

  Map<String, dynamic> toJson() => {
        'kode': kode,
        'customerId': customerId,
        'nama': nama,
        'pria': pria,
        'masuk': masuk.toIso8601String(),
        'estimasi': estimasi.toIso8601String(),
        'durasi': durasi,
        'items': [for (final i in items) i.toJson()],
        'status': status,
        'bayar': bayar,
        'metode': metode,
        'dibayar': dibayar,
        'catatan': catatan,
      };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        kode: j['kode'] as String,
        customerId: (j['customerId'] ?? '') as String,
        nama: j['nama'] as String,
        pria: (j['pria'] ?? true) as bool,
        masuk: DateTime.parse(j['masuk'] as String),
        estimasi: DateTime.parse(j['estimasi'] as String),
        durasi: (j['durasi'] ?? 'Reguler') as String,
        items: [
          for (final i in (j['items'] as List))
            OrderItem.fromJson(Map<String, dynamic>.from(i as Map)),
        ],
        status: j['status'] as String,
        bayar: (j['bayar'] ?? 'Belum Bayar') as String,
        metode: (j['metode'] ?? '') as String,
        dibayar: ((j['dibayar'] ?? 0) as num).toInt(),
        catatan: (j['catatan'] ?? '') as String,
      );
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore I = AppStore._();

  static const _key = 'ewasho_data_v1';

  final List<Customer> customers = [];
  final List<Order> orders = [];
  int _seq = 0;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) {
        _seed();
        await _save();
      } else {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        customers
          ..clear()
          ..addAll([
            for (final c in (j['customers'] as List))
              Customer.fromJson(Map<String, dynamic>.from(c as Map)),
          ]);
        orders
          ..clear()
          ..addAll([
            for (final o in (j['orders'] as List))
              Order.fromJson(Map<String, dynamic>.from(o as Map)),
          ]);
        _seq = ((j['seq'] ?? orders.length) as num).toInt();
      }
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: mulai dari contoh.
      if (customers.isEmpty && orders.isEmpty) _seed();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'seq': _seq,
          'customers': [for (final c in customers) c.toJson()],
          'orders': [for (final o in orders) o.toJson()],
        }),
      );
    } catch (_) {
      // Gagal menyimpan tidak boleh menghentikan kasir bekerja.
    }
  }

  // ---- Pelanggan ----------------------------------------------------------

  Customer addCustomer({
    required String nama,
    required String hp,
    required bool pria,
    String alamat = '',
    double? lat,
    double? lng,
  }) {
    final c = Customer(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      nama: nama,
      hp: hp,
      pria: pria,
      alamat: alamat,
      lat: lat,
      lng: lng,
    );
    customers.insert(0, c);
    _save();
    notifyListeners();
    return c;
  }

  int jumlahPesanan(Customer c) =>
      orders.where((o) => o.customerId == c.id).length;

  // ---- Pesanan ------------------------------------------------------------

  String _kodeBaru(DateTime t) {
    _seq++;
    String two(int v) => v.toString().padLeft(2, '0');
    return 'EW-${two(t.year % 100)}${two(t.month)}${two(t.day)}-'
        '${_seq.toString().padLeft(4, '0')}';
  }

  Order addOrder({
    required Customer customer,
    required Durasi durasi,
    required List<OrderItem> items,
    required String bayar,
    String metode = '',
    int dibayar = 0,
    String catatan = '',
  }) {
    final now = DateTime.now();
    final o = Order(
      kode: _kodeBaru(now),
      customerId: customer.id,
      nama: customer.nama,
      pria: customer.pria,
      masuk: now,
      estimasi: now.add(Duration(hours: durasi.jam)),
      durasi: durasi.nama,
      items: items,
      status: 'Antrian',
      bayar: bayar,
      metode: metode,
      dibayar: dibayar,
      catatan: catatan,
    );
    orders.insert(0, o);
    _save();
    notifyListeners();
    return o;
  }

  void setStatus(Order o, String status) {
    o.status = status;
    _save();
    notifyListeners();
  }

  void setLunas(Order o, String metode) {
    o.bayar = 'Lunas';
    o.metode = metode;
    o.dibayar = o.total;
    _save();
    notifyListeners();
  }

  // ---- Ringkasan Beranda --------------------------------------------------

  Iterable<Order> get _hariIni {
    final now = DateTime.now();
    return orders.where((o) => _sameDay(o.masuk, now) && o.status != 'Batal');
  }

  int get omsetHariIni => _hariIni.fold(0, (a, b) => a + b.total);
  int get masukHariIni => _hariIni.length;

  int get harusSelesai {
    final now = DateTime.now();
    return orders
        .where((o) =>
            kStatusAktif.contains(o.status) &&
            _sameDay(o.estimasi, now) &&
            o.estimasi.isAfter(now))
        .length;
  }

  int get terlambat {
    final now = DateTime.now();
    return orders
        .where((o) => kStatusAktif.contains(o.status) && o.estimasi.isBefore(now))
        .length;
  }

  // ---- Data contoh awal ---------------------------------------------------

  void _seed() {
    final now = DateTime.now();
    Customer c(String nama, String hp, bool pria, String alamat) {
      final v = Customer(
        id: 'c${customers.length + 1}',
        nama: nama,
        hp: hp,
        pria: pria,
        alamat: alamat,
      );
      customers.add(v);
      return v;
    }

    final agus = c('Agus Pratama', '081234500001', true, 'Jl. Melati No. 12');
    final siti = c('Siti Nurhaliza', '081234500002', false, 'Jl. Mawar No. 5');
    final budi = c('Budi Santoso', '081234500003', true, 'Jl. Kenanga No. 8');
    final rina = c('Rina Aprilia', '081234500004', false, 'Jl. Anggrek No. 21');
    final andi = c('Andi Wijaya', '081234500005', true, '');
    final dewi = c('Dewi Lestari', '081234500006', false, 'Jl. Dahlia No. 3');

    void o(Customer cu, int jamLalu, Durasi d, String status, String bayar,
        List<(int, double)> isi) {
      final masuk = now.subtract(Duration(hours: jamLalu));
      final items = [
        for (final (idx, qty) in isi)
          OrderItem(
            nama: kServices[idx].nama,
            satuan: kServices[idx].satuan,
            harga: (kServices[idx].harga * d.kali).round(),
            qty: qty,
          ),
      ];
      final order = Order(
        kode: _kodeBaru(masuk),
        customerId: cu.id,
        nama: cu.nama,
        pria: cu.pria,
        masuk: masuk,
        estimasi: masuk.add(Duration(hours: d.jam)),
        durasi: d.nama,
        items: items,
        status: status,
        bayar: bayar,
      );
      if (bayar == 'Lunas') {
        order
          ..dibayar = order.total
          ..metode = 'Tunai';
      }
      orders.insert(0, order);
    }

    o(dewi, 30, kDurasi[0], 'Proses', 'Belum Bayar', [(0, 2.5), (3, 1)]);
    o(andi, 27, kDurasi[1], 'Diambil', 'Lunas', [(1, 2.0)]);
    o(rina, 25, kDurasi[1], 'Siap Ambil', 'Lunas', [(0, 3.0), (4, 1)]);
    o(budi, 3, kDurasi[0], 'Antrian', 'Belum Bayar', [(0, 4.0)]);
    o(siti, 2, kDurasi[1], 'Proses', 'Lunas', [(0, 2.5), (2, 1.0)]);
    o(agus, 1, kDurasi[0], 'Antrian', 'Belum Bayar', [(1, 3.0), (5, 1)]);
  }
}
