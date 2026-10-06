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
          _OmsetCard(
            omset: 1250000,
            onPesananBaru: () => _open('Pesanan Baru'),
            aksi: [
              _Aksi(Icons.receipt_long_outlined, 'Pesanan', kTeal,
                  () => _open('Pesanan')),
              _Aksi(Icons.qr_code_scanner_rounded, 'Scan', kOrange,
                  () => _open('Scan Pesanan')),
              _Aksi(Icons.bar_chart_rounded, 'Laporan', kTeal,
                  () => _open('Laporan')),
              _Aksi(Icons.settings_outlined, 'Pengaturan', kOrange,
                  () => _open('Pengaturan')),
            ],
          ),
          const SizedBox(height: 12),
          _BannerCarousel(onTap: _open),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu omset gelap + baris aksi cepat
// ---------------------------------------------------------------------------

class _Aksi {
  const _Aksi(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _OmsetCard extends StatefulWidget {
  const _OmsetCard({
    required this.omset,
    required this.onPesananBaru,
    required this.aksi,
  });

  final int omset;
  final VoidCallback onPesananBaru;
  final List<_Aksi> aksi;

  @override
  State<_OmsetCard> createState() => _OmsetCardState();
}

class _OmsetCardState extends State<_OmsetCard> {
  bool _tampil = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: kDark,
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Omset Hari Ini',
                          style: ts(13, c: Colors.white, h: 1.2)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _tampil ? rupiah(widget.omset) : 'Rp ••••••',
                                style: ts(25,
                                    w: FontWeight.w600,
                                    c: Colors.white,
                                    h: 1.15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _tampil = !_tampil),
                            child: Icon(
                              _tampil
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.onPesananBaru,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Color(0xFF363636), size: 17),
                        const SizedBox(width: 6),
                        Text('Pesanan Baru',
                            style: ts(12,
                                w: FontWeight.w600,
                                c: const Color(0xFF363636))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                for (final a in widget.aksi)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: a.onTap,
                      child: Column(
                        children: [
                          Icon(a.icon, color: a.color, size: 30),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(a.label,
                                style: ts(12.5, c: kSlate, h: 1.2)),
                          ),
                        ],
                      ),
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
