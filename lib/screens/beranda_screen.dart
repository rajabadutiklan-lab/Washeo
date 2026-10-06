import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';

// ---------------------------------------------------------------------------
// Warna & helper
// ---------------------------------------------------------------------------

class EColors {
  static const red = Color(0xFFE8212B);
  static const redDark = Color(0xFFC40F1B);
  static const redLight = Color(0xFFFF5A60);
  static const ink = Color(0xFF14142B);
  static const muted = Color(0xFF6E6E82);
  static const green = Color(0xFF16A34A);
}

Color _w(double opacity) => Color.fromRGBO(255, 255, 255, opacity);

String rupiah(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

// ---------------------------------------------------------------------------
// Layar Beranda
// ---------------------------------------------------------------------------

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _outlet = 'Outlet Utama';
  final _outlets = const ['Outlet Utama', 'Outlet Cabang 1', 'Outlet Cabang 2'];

  // TODO: ganti dengan navigasi ke layar masing-masing.
  void _open(String name) {
    if (name == 'Laporan') return goTab(context, 0, 2);
    if (name == 'Pengaturan') return goTab(context, 0, 3);
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
    return Scaffold(
      extendBody: true,
      backgroundColor: EColors.red,
      bottomNavigationBar: const EwashoBottomNav(current: 0),
      body: Stack(
        children: [
          const Positioned.fill(child: _Background()),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    outlet: _outlet,
                    outlets: _outlets,
                    onOutletChanged: (v) => setState(() => _outlet = v),
                    onBell: () => _open('Notifikasi'),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Omset Hari Ini',
                          value: 1250000,
                          percent: '+12%',
                          caption: 'dari kemarin',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.bar_chart_rounded,
                          label: 'Omset Bulanan',
                          value: 28750000,
                          percent: '+8%',
                          caption: 'dari bulan lalu',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _BannerCarousel(onTutorial: () => _open('Tutorial')),
                  const SizedBox(height: 14),
                  GridView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 172,
                    ),
                    children: [
                      _MenuCard(
                        icon: Icons.assignment_rounded,
                        title: 'PESANAN',
                        subtitle: 'Kelola transaksi',
                        onTap: () => _open('Pesanan'),
                      ),
                      _MenuCard(
                        icon: Icons.bar_chart_rounded,
                        title: 'LAPORAN',
                        subtitle: 'Omset & statistik',
                        onTap: () => _open('Laporan'),
                      ),
                      _MenuCard(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'SCAN PESANAN',
                        subtitle: 'Cek status & ambil',
                        onTap: () => _open('Scan Pesanan'),
                      ),
                      _MenuCard(
                        icon: Icons.settings_rounded,
                        title: 'PENGATURAN',
                        subtitle: 'Outlet, layanan, dll',
                        onTap: () => _open('Pengaturan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Latar: gradient merah + gelembung lembut
// ---------------------------------------------------------------------------

class _Background extends StatelessWidget {
  const _Background();

  Widget _bubble(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [_w(opacity), _w(opacity * .25)],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EColors.redLight, EColors.red, EColors.redDark],
          stops: [0, .45, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, right: -60, child: _bubble(280, .16)),
          Positioned(top: 180, left: -120, child: _bubble(260, .12)),
          Positioned(top: 430, right: -140, child: _bubble(320, .10)),
          Positioned(bottom: 60, left: -80, child: _bubble(240, .12)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu kaca (glassmorphism)
// ---------------------------------------------------------------------------

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 24,
    this.opacity = .8,
    this.blur = 18,
    this.padding = EdgeInsets.zero,
    this.borderOpacity = .65,
  });

  final Widget child;
  final double radius;
  final double opacity;
  final double blur;
  final EdgeInsetsGeometry padding;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33A00012),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(color: _w(borderOpacity), width: 1.2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _w(opacity),
                  _w((opacity - .14).clamp(0.0, 1.0)),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: logo + pilih outlet + lonceng
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.outlet,
    required this.outlets,
    required this.onOutletChanged,
    required this.onBell,
  });

  final String outlet;
  final List<String> outlets;
  final ValueChanged<String> onOutletChanged;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo_ewasho.png',
          width: 52,
          height: 52,
          errorBuilder: (_, __, ___) => Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _w(.95)),
            child: const Text(
              'e',
              style: TextStyle(
                color: EColors.red,
                fontSize: 32,
                height: 1,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EWASHO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                height: 1.05,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'KASIR LAUNDRY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7.5,
                letterSpacing: 3.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<String>(
              onSelected: onOutletChanged,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (_) => [
                for (final o in outlets) PopupMenuItem(value: o, child: Text(o)),
              ],
              child: Glass(
                radius: 22,
                opacity: .22,
                borderOpacity: .45,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        outlet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onBell,
          child: const Glass(
            radius: 22,
            opacity: .22,
            borderOpacity: .45,
            padding: EdgeInsets.all(10),
            child: Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu statistik omset
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final int value;
  final String percent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22C40F1B),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: EColors.red, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        rupiah(value),
                        style: const TextStyle(
                          color: EColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.north_east_rounded,
                            color: EColors.green, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          percent,
                          style: const TextStyle(
                            color: EColors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      caption,
                      style: const TextStyle(
                        color: EColors.muted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(right: 0, bottom: 0, child: _MiniBars()),
        ],
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars();

  @override
  Widget build(BuildContext context) {
    const heights = [10.0, 16.0, 22.0, 30.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < heights.length; i++)
          Container(
            width: 6,
            height: heights[i],
            margin: const EdgeInsets.only(left: 2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  EColors.redLight.withAlpha(120 + i * 40),
                  EColors.red.withAlpha(120 + i * 40),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Banner geser
// ---------------------------------------------------------------------------

class _BannerData {
  const _BannerData(this.title, this.subtitle, this.button);
  final String title;
  final String subtitle;
  final String button;
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.onTutorial});
  final VoidCallback onTutorial;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _page = 0;

  static const _items = [
    _BannerData('Laundry Rapi\nPelanggan Happy',
        'Kelola usaha laundry\nlebih mudah bersama EWASHO', 'Lihat Tutorial'),
    _BannerData('Pantau Omset\nSetiap Saat',
        'Laporan harian, mingguan\ndan bulanan otomatis', 'Lihat Laporan'),
    _BannerData('Cetak Struk\nSekali Tekan',
        'Dukung printer thermal\n58 mm dan 80 mm', 'Atur Printer'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188,
      child: Glass(
        radius: 28,
        opacity: .20,
        borderOpacity: .40,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _items.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) =>
                  _BannerSlide(data: _items[i], onTap: widget.onTutorial),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _w(i == _page ? 1 : .35),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.data, required this.onTap});
  final _BannerData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 26),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _w(.95),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _w(.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _w(.7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.button,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Image.asset(
              'assets/images/banner_laundry.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.local_laundry_service_rounded,
                size: 110,
                color: _w(.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu menu 2x2
// ---------------------------------------------------------------------------

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 26,
        opacity: .84,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFFFE3E5)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30C40F1B),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [EColors.redLight, EColors.redDark],
                        ).createShader(rect),
                        child: Icon(icon, size: 40, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: EColors.ink,
                          fontSize: 15,
                          letterSpacing: .3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: EColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _w(.9),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 6),
                  ],
                ),
                child: const Icon(Icons.chevron_right_rounded,
                    size: 20, color: EColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
