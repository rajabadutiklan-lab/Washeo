import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

// Layar Beranda. Tanpa blur sama sekali supaya ringan.

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
      redHeight: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EwashoHeader(
            outlet: _outlet,
            onOutletChanged: (v) => setState(() => _outlet = v),
            actionIcon: Icons.notifications_none_rounded,
            onAction: () => _open('Notifikasi'),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MenuCard(
                  icon: Icons.assignment_rounded,
                  title: 'PESANAN',
                  subtitle: 'Kelola transaksi',
                  onTap: () => _open('Pesanan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'LAPORAN',
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
                  title: 'SCAN PESANAN',
                  subtitle: 'Cek status & ambil',
                  onTap: () => _open('Scan Pesanan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MenuCard(
                  icon: Icons.settings_rounded,
                  title: 'PENGATURAN',
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
// Banner geser
// ---------------------------------------------------------------------------

class _BannerData {
  const _BannerData(this.title, this.subtitle, this.button, this.target);
  final String title;
  final String subtitle;
  final String button;
  final String target;
}

const _banners = [
  _BannerData('Laundry Rapi\nPelanggan Happy',
      'Kelola usaha laundry\nlebih mudah bersama EWASHO', 'Lihat Tutorial',
      'Tutorial'),
  _BannerData('Pantau Omset\nSetiap Saat',
      'Laporan harian, mingguan\ndan bulanan otomatis', 'Lihat Laporan',
      'Laporan'),
  _BannerData('Cetak Struk\nSekali Tekan',
      'Dukung printer thermal\n58 mm dan 80 mm', 'Atur Printer', 'Pengaturan'),
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
    return Container(
      height: 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF5A60), Color(0xFFE8212B), Color(0xFFD3121E)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33C40F1B),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: wOp(.10)),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _BannerSlide(
              data: _banners[i],
              onTap: () => widget.onTap(_banners[i].target),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _banners.length; i++)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: wOp(i == _page ? 1 : .38),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 22),
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
                  child: Text(data.title,
                      style:
                          ts(19, w: FontWeight.w700, c: Colors.white, h: 1.15)),
                ),
                const SizedBox(height: 5),
                Text(data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ts(11, c: wOp(.95), h: 1.35)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: wOp(.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: wOp(.7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(data.button,
                            style:
                                ts(11, w: FontWeight.w500, c: Colors.white)),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Image.asset(
              'assets/images/banner_laundry.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.local_laundry_service_rounded,
                size: 92,
                color: wOp(.88),
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
      child: SizedBox(
        height: 138,
        child: EwashoCard(
          radius: 22,
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECED),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(icon, size: 32, color: kRed),
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(title,
                          style: ts(13.5, w: FontWeight.w800, h: 1.25)
                              .copyWith(letterSpacing: .3)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(subtitle,
                            style: ts(10.5, c: kMuted, h: 1.3)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3F4F6),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 17, color: kInk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
