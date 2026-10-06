import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';

// Layar Pengaturan. Tanpa blur: kartu putih tembus pandang (kaca tipis).

const _red = Color(0xFFE8212B);
const _ink = Color(0xFF14142B);
const _muted = Color(0xFF7A7A8C);
const double _designWidth = 400;

Color _w(double opacity) => Color.fromRGBO(255, 255, 255, opacity);

TextStyle _t(double size,
        {FontWeight w = FontWeight.w400, Color c = _ink, double? h}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, height: h);

class _Menu {
  const _Menu(this.judul, this.sub, this.icon, this.bg, this.fg);
  final String judul;
  final String sub;
  final IconData icon;
  final Color bg;
  final Color fg;
}

const _menus = [
  _Menu('Printer', 'Struk & label', Icons.print_rounded, Color(0xFFFFE2C4),
      Color(0xFFF97316)),
  _Menu('Layanan', 'Jenis layanan', Icons.checkroom_rounded,
      Color(0xFFFFDADD), _red),
  _Menu('Parfum', 'Varian parfum', Icons.sanitizer_outlined,
      Color(0xFFEBDDFB), Color(0xFF7C3AED)),
  _Menu('Manajemen Cabang', 'Outlet & cabang', Icons.storefront_outlined,
      Color(0xFFD9E8FF), Color(0xFF2563EB)),
  _Menu('Otomasi', 'WA & notifikasi', Icons.chat_rounded, Color(0xFFD8F3DC),
      Color(0xFF16A34A)),
  _Menu('Audit Aktivitas', 'Riwayat pengguna', Icons.description_outlined,
      Color(0xFFFFEBC8), Color(0xFFF59E0B)),
  _Menu('Reminder Pekerjaan', 'Jadwal & notifikasi',
      Icons.notifications_none_rounded, Color(0xFFFFDADD), _red),
  _Menu('Database Pelanggan', 'Kelola pelanggan', Icons.people_outline_rounded,
      Color(0xFFD9E8FF), Color(0xFF2563EB)),
  _Menu('Upgrade Paket', 'Kelola langganan', Icons.workspace_premium_rounded,
      Color(0xFFFFDADD), _red),
  _Menu('Tentang Kami', 'Informasi aplikasi', Icons.info_outline_rounded,
      Color(0xFFEBDDFB), Color(0xFF7C3AED)),
  _Menu('Bantuan', 'Pusat bantuan', Icons.help_rounded, Color(0xFFD3EEF2),
      Color(0xFF0E9FB5)),
  _Menu('Profil', 'Akun pengguna', Icons.person_outline_rounded,
      Color(0xFFE4E4EA), Color(0xFF475467)),
];

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  String _outlet = 'Outlet Utama';

  // TODO: ganti dengan navigasi ke layar masing-masing.
  void _open(String name) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Buka $name'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: _red,
      bottomNavigationBar: const EwashoBottomNav(current: 3),
      body: Stack(
        children: [
          const Positioned.fill(child: RepaintBoundary(child: _Background())),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 124 + mq.padding.bottom),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: math.min(mq.size.width, 520),
                  child: MediaQuery(
                    data: mq.copyWith(textScaler: TextScaler.noScaling),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _designWidth,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: _content(),
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

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          outlet: _outlet,
          onOutletChanged: (v) => setState(() => _outlet = v),
          onBell: () => _open('Notifikasi'),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PENGATURAN',
                  style: _t(24, w: FontWeight.w800, c: Colors.white, h: 1.1)),
              const SizedBox(height: 4),
              Text('Kelola sistem sesuai kebutuhan usaha Anda',
                  style: _t(12, c: _w(.95))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < _menus.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MenuCard(
                  data: _menus[i],
                  onTap: () => _open(_menus[i].judul),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MenuCard(
                  data: _menus[i + 1],
                  onTap: () => _open(_menus[i + 1].judul),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  Widget _blob(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _w(opacity)),
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF5258), Color(0xFFE8212B), Color(0xFFD01520)],
          stops: [0, .5, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, right: -70, child: _blob(300, .10)),
          Positioned(top: 150, left: -130, child: _blob(280, .08)),
          Positioned(top: 420, right: -150, child: _blob(340, .08)),
          Positioned(bottom: 40, left: -90, child: _blob(260, .09)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.outlet,
    required this.onOutletChanged,
    required this.onBell,
  });

  final String outlet;
  final ValueChanged<String> onOutletChanged;
  final VoidCallback onBell;

  static const _outlets = ['Outlet Utama', 'Outlet Cabang 1', 'Outlet Cabang 2'];

  @override
  Widget build(BuildContext context) {
    final pill = BoxDecoration(
      color: _w(.16),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _w(.40)),
    );
    return Row(
      children: [
        const SizedBox(width: 6),
        Image.asset(
          'assets/images/logo_ewasho.png',
          width: 46,
          height: 46,
          errorBuilder: (_, __, ___) => Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: const Text(
              'e',
              style: TextStyle(
                color: _red,
                fontSize: 29,
                height: 1,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EWASHO',
                style: _t(20, w: FontWeight.w800, c: Colors.white, h: 1.05)
                    .copyWith(letterSpacing: .8)),
            Text('KASIR LAUNDRY',
                style: _t(6.8, w: FontWeight.w500, c: Colors.white)
                    .copyWith(letterSpacing: 2.9)),
          ],
        ),
        const Spacer(),
        PopupMenuButton<String>(
          onSelected: onOutletChanged,
          position: PopupMenuPosition.under,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          itemBuilder: (_) => [
            for (final o in _outlets) PopupMenuItem(value: o, child: Text(o)),
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
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Text(outlet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12, w: FontWeight.w500, c: Colors.white)),
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
          onTap: onBell,
          child: Container(
            width: 40,
            height: 40,
            decoration: pill,
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.data, required this.onTap});
  final _Menu data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66,
        padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xEEFFFFFF), Color(0xD4FFEDEE)],
          ),
          border: Border.all(color: const Color(0xCCFFFFFF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F8A0010),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: data.bg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(data.icon, color: data.fg, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(data.judul,
                        style: _t(11, w: FontWeight.w600, h: 1.3)),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(data.sub, style: _t(9.5, c: _muted, h: 1.3)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _red, size: 18),
          ],
        ),
      ),
    );
  }
}
