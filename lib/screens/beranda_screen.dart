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
      background: const SoftGreyBackground(),
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
          _BannerCarousel(onTap: _open),
          const SizedBox(height: 12),
          _OmsetCard(
            omset: 1250000,
            aksi: [
              _Aksi('\u{1F9FE}', 'Tambah\nTransaksi',
                  () => _open('Tambah Transaksi'),
                  plus: true),
              _Aksi('\u{1F6F5}', 'Antar\nJemput', () => _open('Antar Jemput')),
              _Aksi('\u{1F69A}', 'Kurir', () => _open('Kurir')),
              _Aksi('\u{1F465}', 'Pelanggan', () => _open('Pelanggan')),
              _Aksi('\u{1F4C5}', 'Hari Ini', () => _open('Hari Ini'), badge: 0),
              _Aksi('\u{1F916}', 'Chatbot', () => _open('Chatbot')),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _open('Manage Outlet'),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: kRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apps_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text('MANAGE OUTLET',
                      style: ts(14, w: FontWeight.w600, c: Colors.white)
                          .copyWith(letterSpacing: .6)),
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
// Kartu omset gelap + baris aksi cepat
// ---------------------------------------------------------------------------

class _Aksi {
  const _Aksi(this.emoji, this.label, this.onTap, {this.badge, this.plus = false});
  final String emoji;
  final String label;
  final VoidCallback onTap;

  /// Angka di pojok kanan atas (null = tidak ditampilkan).
  final int? badge;

  /// Tanda plus merah kecil di pojok ikon.
  final bool plus;
}

class _OmsetCard extends StatelessWidget {
  const _OmsetCard({required this.omset, required this.aksi});

  final int omset;
  final List<_Aksi> aksi;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GlassOmset(omset: omset, masuk: 6, harusSelesai: 3, terlambat: 1),
        const SizedBox(height: 10),
        for (var r = 0; r < aksi.length; r += 3) ...[
          if (r > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var c = r; c < r + 3 && c < aksi.length; c++) ...[
                if (c > r) const SizedBox(width: 8),
                Expanded(child: _GlassTile(aksi[c])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Ubin menu tembus pandang (kaca tipis tanpa blur).
class _GlassTile extends StatelessWidget {
  const _GlassTile(this.data);
  final _Aksi data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: wOp(.62),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.4),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: 46,
                      height: 42,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Text(data.emoji,
                              style: const TextStyle(fontSize: 32, height: 1.2)),
                          if (data.plus)
                            Positioned(
                              right: -2,
                              bottom: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kRed,
                                  border:
                                      Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(Icons.add_rounded,
                                    color: Colors.white, size: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: Center(
                        child: Text(data.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: ts(12.5, c: kInk, h: 1.2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (data.badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${data.badge}',
                      style: ts(10.5,
                          w: FontWeight.w600, c: Colors.white, h: 1.1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Kartu omset tembus pandang, sama gayanya dengan kartu di layar Pesanan:
/// putih transparan + garis tepi putih, tanpa blur dan tanpa warna-warni.
class _GlassOmset extends StatelessWidget {
  const _GlassOmset({
    required this.omset,
    required this.masuk,
    required this.harusSelesai,
    required this.terlambat,
  });

  final int omset;
  final int masuk;
  final int harusSelesai;
  final int terlambat;

  Widget _stat(int value, String label) => Expanded(
        child: Column(
          children: [
            Text('$value', style: ts(26, w: FontWeight.w700, h: 1.1)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: ts(13, c: kMuted, h: 1.2)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: wOp(.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Omset Hari Ini', style: ts(14.5, c: kSlate, h: 1.2)),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(rupiah(omset),
                      style: ts(17, w: FontWeight.w700, h: 1.2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFDDE2EA)),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat(masuk, 'Masuk'),
              _stat(harusSelesai, 'Harus Selesai'),
              _stat(terlambat, 'Terlambat'),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slider: satu judul pendek + ilustrasi, warna datar
// ---------------------------------------------------------------------------

class _BannerData {
  const _BannerData(this.title, this.asset, this.target, this.color);
  final String title;
  final String asset;
  final String target;
  final Color color;
}

const _banners = [
  _BannerData('Laundry Rapi,\nPelanggan Happy', 'slider_pesanan', 'Tutorial',
      kTealDark),
  _BannerData('Bayar Pakai\nQRIS', 'slider_qris', 'QRIS', kDark),
  _BannerData('Pantau Omset\nSetiap Saat', 'slider_laporan', 'Laporan',
      kTealDark),
  _BannerData('Kelola Banyak\nCabang', 'slider_cabang', 'Manajemen Cabang',
      kDark),
  _BannerData('Notifikasi\nWhatsApp', 'slider_whatsapp', 'Otomasi', kTealDark),
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
          height: 150,
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
        padding: const EdgeInsets.fromLTRB(20, 10, 14, 10),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(data.title,
                    style: ts(19, w: FontWeight.w700, c: Colors.white, h: 1.25)),
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/${data.asset}.webp',
              width: 150,
              height: 130,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ],
        ),
      ),
    );
  }
}
