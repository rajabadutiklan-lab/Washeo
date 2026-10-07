import 'package:flutter/material.dart';

import '../screens/beranda_screen.dart';
import '../screens/laporan_screen.dart';
import '../screens/pengaturan_screen.dart';
import '../screens/pesanan_screen.dart';
import 'common.dart';

// Indeks tab: 0 Beranda, 1 Pesanan, 2 Laporan, 3 Pengaturan.
const _slots = [
  (0, Icons.home_outlined, 'Beranda'),
  (1, Icons.receipt_long_outlined, 'Pesanan'),
  (2, Icons.bar_chart_rounded, 'Laporan'),
  (3, Icons.settings_outlined, 'Pengaturan'),
];

/// Pindah tab. Indeks: 0 Beranda, 1 Pesanan, 2 Laporan, 3 Pengaturan.
void goTab(BuildContext context, int from, int to) {
  if (to == from) return;
  final Widget? page = switch (to) {
    0 => const BerandaScreen(),
    1 => const PesananScreen(),
    2 => const LaporanScreen(),
    3 => const PengaturanScreen(),
    _ => null,
  };
  if (page == null) return;
  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
    (route) => false,
  );
}

/// Menu bawah: 4 menu + tombol scan bulat merah di tengah.
class EwashoBottomNav extends StatelessWidget {
  const EwashoBottomNav({super.key, required this.current});

  final int current;

  static const double _bar = 62;
  static const double _circle = 58;
  static const double _rise = 14;

  Widget _item(BuildContext context, (int, IconData, String) slot) {
    final active = slot.$1 == current;
    final color = active ? kRed : kSlate;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => goTab(context, current, slot.$1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(slot.$2, color: color, size: 27),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.$3,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final inset = mq.padding.bottom;
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(
        height: _bar + _rise + inset,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _bar + inset,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(bottom: inset),
                child: Row(
                  children: [
                    _item(context, _slots[0]),
                    _item(context, _slots[1]),
                    const SizedBox(width: _circle + 14),
                    _item(context, _slots[2]),
                    _item(context, _slots[3]),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                // TODO: buka layar scan.
                onTap: () => showInfo(context, 'Buka Scan Pesanan'),
                child: Container(
                  width: _circle,
                  height: _circle,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kRed,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 25),
                      Text(
                        'Scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
