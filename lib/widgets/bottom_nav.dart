import 'package:flutter/material.dart';

import '../screens/beranda_screen.dart';
import '../screens/laporan_screen.dart';
import '../screens/pengaturan_screen.dart';

/// Warna ikon menu bawah yang tidak aktif. Tombol scan memakai warna yang sama.
const kNavGrey = Color(0xFF667085);
const _navRed = Color(0xFFE8212B);

const _navItems = [
  (Icons.home_outlined, 'Beranda'),
  (Icons.receipt_long_outlined, 'Pesanan'),
  (Icons.bar_chart_rounded, 'Laporan'),
  (Icons.settings_outlined, 'Pengaturan'),
  (Icons.person_outline_rounded, 'Profil'),
];

void _toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 900),
    ));
}

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
    _toast(context, 'Buka ${_navItems[to].$2}');
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

  Widget _item(BuildContext context, int i) {
    final active = i == current;
    final color = active ? _navRed : kNavGrey;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => goTab(context, current, i),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFE4E6) : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_navItems[i].$1, color: color, size: 24),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _navItems[i].$2,
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
      child: SizedBox(
        height: 106 + inset,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 76 + inset,
              padding: EdgeInsets.only(left: 4, right: 4, bottom: inset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A800010),
                    blurRadius: 14,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [_item(context, 0), _item(context, 1)],
                    ),
                  ),
                  const SizedBox(width: 78),
                  Expanded(
                    child: Row(
                      children: [
                        _item(context, 2),
                        _item(context, 3),
                        _item(context, 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => _toast(context, 'Buka Scan Pesanan'),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kNavGrey,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33344054),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
