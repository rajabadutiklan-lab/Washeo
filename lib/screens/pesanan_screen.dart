import 'package:flutter/material.dart';

import '../widgets/common.dart';

// Layar Pesanan. Kartu tembus pandang (kaca tipis TANPA blur) di atas latar
// putih dengan variasi abu lembut, supaya efek transparannya terlihat.

const _statuses = [
  'Penjemputan',
  'Antrian',
  'Proses',
  'Siap Ambil',
  'Diantar',
  'Diambil',
  'Batal',
  'Telat Ambil',
];

class _Order {
  const _Order(this.nama, this.kode, this.masuk, this.layanan, this.berat,
      this.total, this.status);
  final String nama;
  final String kode;
  final String masuk;
  final int layanan;
  final double berat;
  final int total;
  final String status;
}

// Data contoh (ganti dengan data asli).
const _orders = [
  _Order('Agus Pratama', 'EW-261004-0134', '4 Okt 2026, 10:05', 2, 3.2, 27000,
      'Antrian'),
  _Order('Siti Nurhaliza', 'EW-261004-0133', '4 Okt 2026, 09:21', 3, 2.5,
      35000, 'Proses'),
  _Order('Budi Santoso', 'EW-261004-0132', '4 Okt 2026, 08:45', 2, 4.0, 24000,
      'Antrian'),
  _Order('Rina Aprilia', 'EW-261004-0131', '3 Okt 2026, 16:20', 4, 3.0, 48000,
      'Siap Ambil'),
  _Order('Andi Wijaya', 'EW-261004-0130', '3 Okt 2026, 14:10', 1, 1.0, 12000,
      'Diambil'),
  _Order('Dewi Lestari', 'EW-261004-0129', '3 Okt 2026, 11:35', 3, 2.8, 32000,
      'Proses'),
];

(Color, Color, IconData) _statusStyle(String s) => switch (s) {
      'Antrian' => (const Color(0xFFE9EDF2), kSlate, Icons.description_outlined),
      'Proses' => (const Color(0xFFFAEDDF), kOrange, Icons.schedule_rounded),
      'Siap Ambil' => (
          const Color(0xFFDFF3F2),
          kTealDark,
          Icons.check_circle_outline_rounded
        ),
      'Penjemputan' => (
          const Color(0xFFDFF3F2),
          kTealDark,
          Icons.local_shipping_outlined
        ),
      'Diantar' => (
          const Color(0xFFDFF3F2),
          kTealDark,
          Icons.local_shipping_outlined
        ),
      'Diambil' => (const Color(0xFFECEEF1), kMuted, Icons.inventory_2_outlined),
      _ => (const Color(0xFFFCE6E4), kRed, Icons.error_outline_rounded),
    };

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  String _outlet = 'Outlet Utama';
  String _tab = 'Antrian';

  int _count(String status) => _orders.where((o) => o.status == status).length;

  @override
  Widget build(BuildContext context) {
    final list = _orders.where((o) => o.status == _tab).toList();
    return EwashoPage(
      current: 1,
      background: const _Background(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EwashoHeader(
            outlet: _outlet,
            onOutletChanged: (v) => setState(() => _outlet = v),
            actionIcon: Icons.notifications_rounded,
            onAction: () => showInfo(context, 'Buka Notifikasi'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const PageTitle('Pesanan'),
              const Spacer(),
              _RoundButton(
                icon: Icons.search_rounded,
                filled: false,
                onTap: () => showInfo(context, 'Cari pesanan'),
              ),
              const SizedBox(width: 8),
              _RoundButton(
                icon: Icons.add_rounded,
                filled: true,
                onTap: () => showInfo(context, 'Tambah pesanan'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kLine)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final s in _statuses)
                    _Tab(
                      label: s,
                      count: _count(s),
                      active: s == _tab,
                      onTap: () => setState(() => _tab = s),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 56),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kTile,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: kMuted, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text('Belum ada pesanan $_tab', style: ts(13, c: kMuted)),
                ],
              ),
            )
          else
            for (final o in list) ...[
              _OrderCard(
                order: o,
                onTap: () => showInfo(context, 'Buka ${o.kode}'),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Latar putih dengan variasi abu lembut (digambar sekali, tanpa blur)
// ---------------------------------------------------------------------------

class _Background extends StatelessWidget {
  const _Background();

  static Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withAlpha(0)],
            stops: const [.35, 1],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF1F3F6)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              top: 120, left: -110, child: _blob(340, const Color(0xFFD3D9E2))),
          Positioned(
              top: 300, right: -140, child: _blob(380, const Color(0xFFDCE1E8))),
          Positioned(
              top: 560, left: -60, child: _blob(320, const Color(0xFFCFD6E0))),
          Positioned(
              top: 760, right: -90, child: _blob(300, const Color(0xFFD8DEE6))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tombol bulat, tab status, kartu pesanan
// ---------------------------------------------------------------------------

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? kRed : wOp(.7),
          border: filled ? null : Border.all(color: kOutline),
        ),
        child: Icon(icon, color: filled ? Colors.white : kSlate, size: 21),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hot = active && count > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? kRed : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: ts(13.5,
                  w: active ? FontWeight.w600 : FontWeight.w500,
                  c: active ? const Color(0xFF222222) : const Color(0xFF8A8FA3)),
            ),
            const SizedBox(width: 7),
            Container(
              constraints: const BoxConstraints(minWidth: 21),
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hot ? kRed : const Color(0xFFEEF0F5),
                borderRadius: BorderRadius.circular(10.5),
              ),
              child: Text(
                '$count',
                style: ts(10.5,
                    w: FontWeight.w500,
                    c: hot ? Colors.white : const Color(0xFF8A8FA3),
                    h: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});
  final _Order order;
  final VoidCallback onTap;

  String get _initials {
    final parts = order.nama.split(' ');
    final a = parts.first.isEmpty ? '' : parts.first[0];
    final b = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _statusStyle(order.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
        // Kaca tipis tanpa blur: putih tembus pandang + garis tepi putih.
        decoration: BoxDecoration(
          color: wOp(.62),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: wOp(.9),
                border: Border.all(color: const Color(0xFFDDE2EA)),
              ),
              child:
                  Text(_initials, style: ts(14, w: FontWeight.w600, c: kSlate)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(order.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ts(14, w: FontWeight.w600, h: 1.25)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: fg, size: 14),
                            const SizedBox(width: 5),
                            Text(order.status,
                                style: ts(11,
                                    w: FontWeight.w600, c: fg, h: 1.15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(order.kode, style: ts(11.5, c: kMuted, h: 1.3)),
                  Text('Masuk: ${order.masuk}',
                      style: ts(11.5, c: kMuted, h: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.checkroom_outlined,
                          color: kSlate, size: 17),
                      const SizedBox(width: 6),
                      Text('${order.layanan} layanan',
                          style: ts(11.5, c: kMuted)),
                      const SizedBox(width: 10),
                      Text('${order.berat.toStringAsFixed(1)} kg',
                          style: ts(11.5, w: FontWeight.w500)),
                      const Spacer(),
                      Text(rupiah(order.total),
                          style: ts(14.5, w: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(Icons.chevron_right_rounded, color: kRed, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
