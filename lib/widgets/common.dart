import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bottom_nav.dart';

// Bagian yang dipakai bersama semua layar. Gaya: datar dan bersih -
// latar terang, kartu putih tanpa bayangan, tanpa gradient, tanpa blur.

const kRed = Color(0xFFE1251A);
const kInk = Color(0xFF4C4C4C);
const kMuted = Color(0xFF747474);
const kSlate = Color(0xFF465363);
const kTeal = Color(0xFF00A29B);
const kTealDark = Color(0xFF016B67);
const kOrange = Color(0xFFD57624);
const kDark = Color(0xFF4E4E4E);
const kBody = Color(0xFFF4F8FB);
const kLine = Color(0xFFE6E6E6);
const kTile = Color(0xFFF3F4F8);
const kOutline = Color(0xFFADB3BF);

/// Lebar acuan desain. Isi layar disusun pada lebar ini lalu diskalakan
/// seragam ke lebar HP.
const double kDesignWidth = 400;

Color wOp(double opacity) => Color.fromRGBO(255, 255, 255, opacity);

TextStyle ts(double size,
        {FontWeight w = FontWeight.w400, Color c = kInk, double? h}) =>
    TextStyle(fontSize: size * 1.08, fontWeight: w, color: c, height: h);

String rupiah(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

void showInfo(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 900),
    ));
}

// ---------------------------------------------------------------------------
// Kerangka layar: latar terang polos + menu bawah
// ---------------------------------------------------------------------------

class EwashoPage extends StatelessWidget {
  const EwashoPage({
    super.key,
    required this.current,
    required this.child,
    this.background,
  });

  /// Latar khusus (diam, tidak ikut scroll). Kosong = warna polos.
  final Widget? background;

  /// Indeks menu bawah yang aktif.
  final int current;

  /// Isi layar, disusun pada lebar [kDesignWidth].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = math.min(mq.size.width, 520.0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBody,
        bottomNavigationBar: EwashoBottomNav(current: current),
        body: Stack(
          children: [
            if (background != null)
              Positioned.fill(child: RepaintBoundary(child: background!)),
            SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: MediaQuery(
                  data: mq.copyWith(textScaler: TextScaler.noScaling),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: kDesignWidth,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: child,
                      ),
                    ),
                  ),
                ),
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

// ---------------------------------------------------------------------------
// Header: satu logo dan nama yang sama di semua layar
// ---------------------------------------------------------------------------

class EwashoHeader extends StatelessWidget {
  const EwashoHeader({
    super.key,
    required this.outlet,
    required this.onOutletChanged,
    required this.actionIcon,
    required this.onAction,
  });

  final String outlet;
  final ValueChanged<String> onOutletChanged;
  final IconData actionIcon;
  final VoidCallback onAction;

  static const outlets = ['Outlet Utama', 'Outlet Cabang 1', 'Outlet Cabang 2'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          const EwashoLogo(),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: onOutletChanged,
            position: PopupMenuPosition.under,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (_) => [
              for (final o in outlets) PopupMenuItem(value: o, child: Text(o)),
            ],
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: kSlate, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront_outlined,
                      color: kSlate, size: 17),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: Text(outlet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(12, w: FontWeight.w500, c: kSlate)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: kSlate, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(actionIcon, color: kSlate, size: 25),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo Ewasho (gambar mesin cuci + tulisan). Satu gambar, ukurannya tetap,
/// dipakai di semua header.
class EwashoLogo extends StatelessWidget {
  const EwashoLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_ewasho.png',
      height: 36,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Judul layar (mis. Laporan, Pengaturan) dengan teks merah.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ts(21, w: FontWeight.w600, c: kRed, h: 1.15)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: ts(12.5, c: kMuted)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu putih datar & kartu statistik
// ---------------------------------------------------------------------------

class EwashoCard extends StatelessWidget {
  const EwashoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String percent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return EwashoCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kTile,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kRed, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ts(11.5, c: kMuted, h: 1.2)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: ts(17, w: FontWeight.w700, h: 1.25)),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.north_east_rounded,
                        color: kTeal, size: 13),
                    const SizedBox(width: 3),
                    Text(percent,
                        style: ts(11.5, w: FontWeight.w600, c: kTeal)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(10, c: kMuted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar pelanggan
// ---------------------------------------------------------------------------

/// Foto avatar pelanggan. Wajah dipilih "acak" dari 10 gambar per jenis
/// kelamin, tetapi selalu sama untuk [seed] yang sama (mis. nama atau nomor
/// HP pelanggan), jadi tidak berganti-ganti tiap layar dibuka.
///
/// Gambarnya kecil (112 px, sekitar 2 KB per file) dan di-decode pada ukuran
/// kecil, jadi aman dipakai di daftar panjang.
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({
    super.key,
    required this.seed,
    required this.pria,
    this.size = 46,
  });

  final String seed;
  final bool pria;
  final double size;

  static const int jumlahPerJenis = 10;

  static String assetFor(String seed, {required bool pria}) {
    var h = 7;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    final n = (h % jumlahPerJenis) + 1;
    final nama = pria ? 'pria' : 'wanita';
    return 'assets/images/avatars/${nama}_${n.toString().padLeft(2, '0')}.webp';
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        assetFor(seed, pria: pria),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: 112,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: kTile,
          child: Icon(Icons.person_rounded, color: kOutline, size: size * .6),
        ),
      ),
    );
  }
}

/// Latar putih dengan variasi abu lembut (digambar sekali, tanpa blur).
/// Dipakai di layar yang punya kartu tembus pandang.
class SoftGreyBackground extends StatelessWidget {
  const SoftGreyBackground({super.key});

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
