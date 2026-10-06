import 'package:flutter/material.dart';

import '../screens/beranda_screen.dart';
import '../screens/laporan_screen.dart';
import '../screens/pengaturan_screen.dart';
import 'common.dart';

/// Warna ikon menu bawah yang tidak aktif. Tombol scan memakai warna yang sama.
const kNavGrey = Color(0xFF667085);

// Indeks tab: 0 Beranda, 1 Pesanan, 2 Laporan, 3 Pengaturan, 4 Profil.
// Nilai -1 = tombol Scan (bukan tab, sejajar dengan menu lain).
const _slots = [
  (0, Icons.home_outlined, 'Beranda'),
  (1, Icons.receipt_long_outlined, 'Pesanan'),
  (-1, Icons.qr_code_scanner_rounded, 'Scan'),
  (2, Icons.bar_chart_rounded, 'Laporan'),
  (3, Icons.settings_outlined, 'Pengaturan'),
  (4, Icons.person_outline_rounded, 'Profil'),
];

/// Pindah tab. Indeks: 0 Beranda, 1 Pesanan, 2 Laporan, 3 Pengaturan, 4 Profil.
void goTab(BuildContext context, int from, int to) {
  if (to == from) return;
  final Widget? page = switch (to) {
    0 => const BerandaScreen(),
    2 => const LaporanScreen(),
    3 => const PengaturanScreen(),
    _ => null,
  };
  if (page == null) {
    // TODO: layar Pesanan dan Profil belum dibuat.
    showInfo(context, to == 1 ? 'Buka Pesanan' : 'Buka Profil');
    return;
  }
  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
    (route) => false,
  );
}

/// Menu bawah yang dipakai semua layar utama.
class EwashoBottomNav extends StatelessWidget {
  const EwashoBottomNav({super.key, required this.current});

  final int current;

  Widget _item(BuildContext context, (int, IconData, String) slot) {
    final active = slot.$1 == current;
    final color = active ? kRed : kNavGrey;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (slot.$1 < 0) {
            // TODO: buka layar scan.
            showInfo(context, 'Buka Scan Pesanan');
          } else {
            goTab(context, current, slot.$1);
          }
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFE9EA) : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(slot.$2, color: color, size: 24),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    slot.$3,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      child: Container(
        height: 68 + inset,
        padding: EdgeInsets.only(left: 4, right: 4, bottom: inset),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A1D2433),
              blurRadius: 14,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [for (final s in _slots) _item(context, s)],
        ),
      ),
    );
  }
}
