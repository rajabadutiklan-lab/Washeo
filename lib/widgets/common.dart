import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bottom_nav.dart';

// Bagian yang dipakai bersama semua layar: warna, header, motif, kartu.
// Tidak ada blur di sini supaya ringan di HP kelas bawah.

const kRed = Color(0xFFE8212B);
const kInk = Color(0xFF14142B);
const kMuted = Color(0xFF7A7A8C);
const kGreen = Color(0xFF16A34A);

/// Warna dasar layar: abu sangat muda yang netral, bukan merah muda.
const kBody = Color(0xFFF6F7F9);

/// Lebar acuan desain. Isi layar disusun pada lebar ini lalu diskalakan
/// seragam ke lebar HP.
const double kDesignWidth = 400;

Color wOp(double opacity) => Color.fromRGBO(255, 255, 255, opacity);

TextStyle ts(double size,
        {FontWeight w = FontWeight.w400, Color c = kInk, double? h}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, height: h);

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
// Kerangka layar: motif header merah di atas, badan terang, menu bawah
// ---------------------------------------------------------------------------

class EwashoPage extends StatelessWidget {
  const EwashoPage({
    super.key,
    required this.current,
    required this.child,
    this.redHeight = 150,
  });

  /// Indeks menu bawah yang aktif.
  final int current;

  /// Isi layar, disusun pada lebar [kDesignWidth].
  final Widget child;

  /// Tinggi area merah (satuan desain) sebelum memudar ke warna badan.
  final double redHeight;

  static const double _fade = 70;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = math.min(mq.size.width, 520.0);
    final scale = width / kDesignWidth;
    final motifHeight = mq.padding.top + (redHeight + _fade) * scale;
    return Scaffold(
      extendBody: true,
      backgroundColor: kBody,
      bottomNavigationBar: EwashoBottomNav(current: current),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: motifHeight,
            child: RepaintBoundary(
              child: HeaderMotif(solid: 1 - (_fade * scale) / motifHeight),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 88 + mq.padding.bottom),
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
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
    );
  }
}

/// Motif header yang sama di semua layar: gradient merah dengan dua
/// lengkung lembut, memudar ke warna badan di bagian bawah.
class HeaderMotif extends StatelessWidget {
  const HeaderMotif({super.key, required this.solid});

  /// Bagian (0..1) dari tinggi yang tetap merah penuh sebelum memudar.
  final double solid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF4A52), Color(0xFFE8212B), Color(0xFFD9141F)],
            ),
          ),
        ),
        Positioned(
          top: -110,
          right: -70,
          child: Container(
            width: 300,
            height: 300,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: wOp(.09)),
          ),
        ),
        Positioned(
          top: 40,
          left: -120,
          child: Container(
            width: 250,
            height: 250,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: wOp(.06)),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Color(0x00F6F7F9), Color(0x00F6F7F9), kBody],
              stops: [0, solid.clamp(0.0, 1.0).toDouble(), 1],
            ),
          ),
        ),
      ],
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
    final pill = BoxDecoration(
      color: wOp(.16),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: wOp(.40)),
    );
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 4),
          const EwashoLogo(),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: onOutletChanged,
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (_) => [
              for (final o in outlets) PopupMenuItem(value: o, child: Text(o)),
            ],
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: pill,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 19),
                  const SizedBox(width: 7),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 92),
                    child: Text(outlet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(12, w: FontWeight.w500, c: Colors.white)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 19),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: 40,
              height: 40,
              decoration: pill,
              child: Icon(actionIcon, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo + nama EWASHO. Ukurannya tetap, dipakai di semua header.
class EwashoLogo extends StatelessWidget {
  const EwashoLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo_ewasho.png',
          width: 46,
          height: 46,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EWASHO',
                style: ts(20, w: FontWeight.w800, c: Colors.white, h: 1.05)
                    .copyWith(letterSpacing: .8)),
            Text('KASIR LAUNDRY',
                style: ts(6.8, w: FontWeight.w500, c: Colors.white)
                    .copyWith(letterSpacing: 2.9)),
          ],
        ),
      ],
    );
  }
}

/// Judul layar besar di bawah header (mis. LAPORAN, PENGATURAN).
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: ts(24, w: FontWeight.w800, c: Colors.white, h: 1.1)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: ts(12, c: wOp(.95))),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu putih & kartu statistik
// ---------------------------------------------------------------------------

class EwashoCard extends StatelessWidget {
  const EwashoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFEDEEF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141D2433),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: kRed, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: ts(11.5, h: 1.2)),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child:
                          Text(value, style: ts(17, w: FontWeight.w700, h: 1.3)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.north_east_rounded,
                            color: kGreen, size: 13),
                        const SizedBox(width: 4),
                        Text(percent,
                            style: ts(11.5, w: FontWeight.w600, c: kGreen)),
                      ],
                    ),
                    Text(caption, style: ts(9.5, c: kMuted)),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(right: 0, bottom: 2, child: MiniBars()),
        ],
      ),
    );
  }
}

class MiniBars extends StatelessWidget {
  const MiniBars({super.key});

  @override
  Widget build(BuildContext context) {
    const heights = [8.0, 13.0, 18.0, 24.0];
    const colors = [
      Color(0xFFFFB3B6),
      Color(0xFFFF9499),
      Color(0xFFFF7078),
      Color(0xFFF2434B),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < heights.length; i++)
          Container(
            width: 5.5,
            height: heights[i],
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: colors[i],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
      ],
    );
  }
}
