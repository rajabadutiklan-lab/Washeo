import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

// Layar Beranda. Datar: tanpa blur, tanpa gradient, tanpa bayangan.

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _outlet = 'Outlet Utama';

  // TODO: ganti dengan navigasi ke layar masing-masing.
  void _open(String name) {
    if (name == 'Laporan') return goTab(context, 0, 2);
    if (name == 'Pengaturan') return goTab(context, 0, 3);
    showInfo(context, 'Buka $name');
  }

  @override
  Widget build(BuildContext context) {
    return EwashoPage(
      current: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EwashoHeader(
            outlet: _outlet,
            onOutletChanged: (v) => setState(() => _outlet = v),
            actionIcon: Icons.notifications_rounded,
            onAction: () => _open('Notifikasi'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Omset Hari Ini',
                  value: rupiah(1250000),
                  percent: '+12%',
                  caption: 'dari kemarin',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'Omset Bulanan',
                  value: rupiah(28750000),
                  percent: '+8%',
                  caption: 'dari bulan lalu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BannerCarousel(onTap: _open),
          const SizedBox(height: 18),
          Text('Menu Utama', style: ts(15, w: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MenuCard(
                  icon: Icons.assignment_outlined,
                  title: 'Pesanan',
                  subtitle: 'Kelola transaksi',
                  onTap: () => _open('Pesanan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Laporan',
                  subtitle: 'Omset & statistik',
                  onTap: () => _open('Laporan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MenuCard(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Scan Pesanan',
                  subtitle: 'Cek status & ambil',
                  onTap: () => _open('Scan Pesanan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MenuCard(
                  icon: Icons.settings_outlined,
                  title: 'Pengaturan',
                  subtitle: 'Outlet, layanan, dll',
                  onTap: () => _open('Pengaturan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner geser (warna datar)
// ---------------------------------------------------------------------------

class _BannerData {
  const _BannerData(
      this.kicker, this.title, this.button, this.target, this.color);
  final String kicker;
  final String title;
  final String button;
  final String target;
  final Color color;
}

const _banners = [
  _BannerData('Kelola usaha laundry lebih mudah',
      'Laundry Rapi, Pelanggan Happy', 'Lihat Tutorial', 'Tutorial', kTealDark),
  _BannerData('Harian, mingguan dan bulanan otomatis',
      'Pantau Omset Setiap Saat', 'Lihat Laporan', 'Laporan', kOrange),
  _BannerData('Printer thermal 58 mm dan 80 mm', 'Cetak Struk Sekali Tekan',
      'Atur Printer', 'Pengaturan', kDark),
];

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 124,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _controller,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _BannerSlide(
                data: _banners[i],
                onTap: () => widget.onTap(_banners[i].target),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _banners.length; i++)
              Container(
                width: i == _page ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == _page ? kRed : const Color(0xFFD9D9D9),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.data, required this.onTap});
  final _BannerData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: data.color,
        padding: const EdgeInsets.fromLTRB(18, 0, 10, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.kicker,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(12, c: Colors.white, h: 1.25)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(data.title,
                        style: ts(16.5,
                            w: FontWeight.w700, c: Colors.white, h: 1.25)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data.button,
                          style:
                              ts(12.5, w: FontWeight.w600, c: Colors.white)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/banner_laundry.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 84,
                height: 84,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: wOp(.14)),
                child: const Icon(Icons.local_laundry_service_outlined,
                    size: 46, color: Colors.white),
              ),
            ),
          ],
        ),
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
      child: SizedBox(
        height: 112,
        child: EwashoCard(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: kTile,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 25, color: kRed),
                  ),
                  const Spacer(),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        size: 18, color: kRed),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(title, style: ts(14, w: FontWeight.w600, h: 1.25)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(subtitle, style: ts(11, c: kMuted, h: 1.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
