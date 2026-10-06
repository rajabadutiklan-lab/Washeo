import 'dart:math' as math;

import 'package:flutter/material.dart';

// Layar Laporan. Sengaja TANPA BackdropFilter / blur supaya ringan:
// semua kartu berwarna solid, grafik digambar langsung dengan CustomPainter.

const _red = Color(0xFFE8212B);
const _ink = Color(0xFF14142B);
const _muted = Color(0xFF7A7A8C);
const _green = Color(0xFF16A34A);

/// Lebar acuan desain. Isi layar disusun pada lebar ini lalu diskalakan
/// seragam ke lebar HP, sehingga proporsinya sama di semua ukuran layar.
const double _designWidth = 400;

Color _w(double opacity) => Color.fromRGBO(255, 255, 255, opacity);

TextStyle _t(double size,
        {FontWeight w = FontWeight.w400, Color c = _ink, double? h}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, height: h);

String _rp(int value) {
  final s = value.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

const _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', //
  'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

// ---------------------------------------------------------------------------
// Data contoh (ganti dengan data asli)
// ---------------------------------------------------------------------------

const _hari = [8, 9, 10, 11, 12, 13, 14];
const _omsetHarian = [450000, 740000, 900000, 980000, 1250000, 1080000, 740000];
const _pesananHarian = [20, 31, 38, 42, 48, 44, 30];

class _Layanan {
  const _Layanan(this.nama, this.persen, this.jumlah, this.icon, this.bg, this.fg);
  final String nama;
  final int persen;
  final int jumlah;
  final IconData icon;
  final Color bg;
  final Color fg;
}

const _layanan = [
  _Layanan('Cuci Setrika', 42, 120, Icons.layers_rounded, Color(0xFFFFE9D6),
      Color(0xFFF97316)),
  _Layanan('Cuci', 28, 80, Icons.checkroom_rounded, Color(0xFFDFEBFF),
      Color(0xFF2563EB)),
  _Layanan('Setrika', 18, 52, Icons.iron_rounded, Color(0xFFECE3FF),
      Color(0xFF7C3AED)),
  _Layanan('Express', 12, 35, Icons.bolt_rounded, Color(0xFFFFE1E3), _red),
];

class _Bayar {
  const _Bayar(this.nama, this.persen, this.nominal, this.warna);
  final String nama;
  final int persen;
  final int nominal;
  final Color warna;
}

const _bayar = [
  _Bayar('QRIS', 52, 650000, _red),
  _Bayar('Tunai', 28, 350000, Color(0xFFFF9EA2)),
  _Bayar('Transfer', 15, 190000, Color(0xFF7FA6F8)),
  _Bayar('Lainnya', 5, 60000, Color(0xFFA9A9B6)),
];

class _Rekap {
  const _Rekap(this.tanggal, this.pesanan, this.omset, this.persen);
  final String tanggal;
  final int pesanan;
  final int omset;
  final List<int> persen; // QRIS, Tunai, Transfer, Lainnya
}

const _rekap = [
  _Rekap('12 Okt 2026', 48, 1250000, [52, 28, 15, 5]),
  _Rekap('11 Okt 2026', 42, 980000, [50, 30, 15, 5]),
];

// ---------------------------------------------------------------------------
// Layar
// ---------------------------------------------------------------------------

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  int _tab = 0;
  int _mode = 0; // 0 = omset, 1 = pesanan
  int _selected = 4;
  String _outlet = 'Outlet Utama';
  DateTime _tanggal = DateTime(2026, 10, 12);

  void _info(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ));
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFDEEEF),
      bottomNavigationBar: _LaporanNav(
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).maybePop();
          } else if (i != 2) {
            _info('Buka ${_LaporanNav.items[i].$2}');
          }
        },
        onScan: () => _info('Buka Scan Pesanan'),
      ),
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
                          child: _content(context),
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

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          outlet: _outlet,
          onOutletChanged: (v) => setState(() => _outlet = v),
          onCalendar: _pilihTanggal,
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('LAPORAN',
              style: _t(24, w: FontWeight.w800, c: Colors.white, h: 1.1)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Tabs(
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(width: 10),
            _DatePill(
              text: '${_tanggal.day} ${_bulan[_tanggal.month - 1]} '
                  '${_tanggal.year}',
              onTap: _pilihTanggal,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.monetization_on_rounded,
                label: 'Omset Hari Ini',
                value: _rp(1250000),
                percent: '+12%',
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: _StatCard(
                icon: Icons.bar_chart_rounded,
                label: 'Total Pesanan',
                value: '48',
                percent: '+18%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _chartCard(context),
        const SizedBox(height: 8),
        const SizedBox(
          height: 246,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 58, child: _LayananCard()),
              SizedBox(width: 8),
              Expanded(flex: 42, child: _BayarCard()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _RekapCard(onDetail: () => _info('Buka detail rekap')),
      ],
    );
  }

  Widget _chartCard(BuildContext context) {
    final omset = _mode == 0;
    final values = [
      for (final v in (omset ? _omsetHarian : _pesananHarian)) v.toDouble(),
    ];
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(omset ? 'Grafik Omset' : 'Grafik Pesanan',
                  style: _t(15, w: FontWeight.w700)),
              const Spacer(),
              _Toggle(
                index: _mode,
                onChanged: (i) => setState(() => _mode = i),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 178,
            child: LayoutBuilder(
              builder: (context, c) {
                final slot =
                    (c.maxWidth - _BarChartPainter.left) / values.length;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    final i =
                        ((d.localPosition.dx - _BarChartPainter.left) / slot)
                            .floor();
                    if (i >= 0 && i < values.length && i != _selected) {
                      setState(() => _selected = i);
                    }
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(c.maxWidth, 178),
                      painter: _BarChartPainter(
                        values: values,
                        xLabels: [for (final d in _hari) '$d Okt'],
                        yLabels: omset
                            ? const ['0', '500 rb', '1,0 jt', '1,5 jt', '2,0 jt']
                            : const ['0', '15', '30', '45', '60'],
                        maxY: omset ? 2000000 : 60,
                        selected: _selected,
                        tipTitle: '${_hari[_selected]} Okt 2026',
                        tipValue: omset
                            ? _rp(_omsetHarian[_selected])
                            : '${_pesananHarian[_selected]} pesanan',
                        fontFamily: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.fontFamily,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Latar & kartu (solid, tanpa blur)
// ---------------------------------------------------------------------------

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE5202A),
            Color(0xFFF03E46),
            Color(0xFFFBD0D3),
            Color(0xFFFDEEEF),
          ],
          stops: [0, .17, .31, .55],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: _w(.08)),
            ),
          ),
          for (final b in const [
            // (top, left, right, ukuran, warna) - bercak lembut di balik kartu
            (330.0, -110.0, null, 300.0, Color(0x33FF7A82)),
            (520.0, null, -120.0, 320.0, Color(0x2EFF8A90)),
            (760.0, -60.0, null, 260.0, Color(0x30FF6F78)),
          ])
            Positioned(
              top: b.$1,
              left: b.$2,
              right: b.$3,
              child: Container(
                width: b.$4,
                height: b.$4,
                decoration: BoxDecoration(shape: BoxShape.circle, color: b.$5),
              ),
            ),
          Positioned(
            top: 70,
            left: -90,
            child: Container(
              width: 220,
              height: 220,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: _w(.06)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      // Kaca tipis tanpa blur: isi putih tembus pandang + kilau gradient +
      // garis tepi terang. Latar di belakangnya samar-samar terlihat.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEBFFFFFF), Color(0xC4FFF6F6)],
        ),
        border: Border.all(color: const Color(0xE6FFFFFF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12B00014),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.outlet,
    required this.onOutletChanged,
    required this.onCalendar,
  });

  final String outlet;
  final ValueChanged<String> onOutletChanged;
  final VoidCallback onCalendar;

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
          onTap: onCalendar,
          child: Container(
            width: 40,
            height: 40,
            decoration: pill,
            child: const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 19),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab periode, pilih tanggal, toggle grafik
// ---------------------------------------------------------------------------

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['Harian', 'Mingguan', 'Bulanan', 'Kustom'];
  static const _flex = [6, 8, 7, 6];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _w(.22),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++)
            Expanded(
              flex: _flex[i],
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: i == index
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _labels[i],
                      style: i == index
                          ? _t(12, w: FontWeight.w600, c: _red)
                          : _t(12, w: FontWeight.w500, c: Colors.white),
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

class _DatePill extends StatelessWidget {
  const _DatePill({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded, color: _red, size: 16),
            const SizedBox(width: 7),
            Text(text, style: _t(11, c: const Color(0xFF55556A))),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _red, size: 17),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Omset', 'Pesanan'];
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E9EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 2; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: i == index
                    ? BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Text(
                  labels[i],
                  style: i == index
                      ? _t(10.5, w: FontWeight.w500, c: Colors.white)
                      : _t(10.5, c: _muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu statistik
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFFBE4E5)),
                ),
                child: Icon(icon, color: _red, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: _t(11.5, h: 1.2)),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child:
                          Text(value, style: _t(17, w: FontWeight.w700, h: 1.3)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.north_east_rounded,
                            color: _green, size: 13),
                        const SizedBox(width: 4),
                        Text(percent,
                            style: _t(11.5, w: FontWeight.w600, c: _green)),
                      ],
                    ),
                    Text('dari kemarin', style: _t(9.5, c: _muted)),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(right: 0, bottom: 2, child: _MiniBars()),
        ],
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars();

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

// ---------------------------------------------------------------------------
// Grafik batang
// ---------------------------------------------------------------------------

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.xLabels,
    required this.yLabels,
    required this.maxY,
    required this.selected,
    required this.tipTitle,
    required this.tipValue,
    required this.fontFamily,
  });

  final List<double> values;
  final List<String> xLabels;
  final List<String> yLabels;
  final double maxY;
  final int selected;
  final String tipTitle;
  final String tipValue;
  final String? fontFamily;

  static const double left = 42;
  static const double bottom = 24;
  static const double top = 46;

  TextPainter _tp(String s, double size, Color c,
      [FontWeight w = FontWeight.w400]) {
    return TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          color: c,
          fontWeight: w,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  double _ratio(int i) => (values[i] / maxY).clamp(0.0, 1.0).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(left, top, size.width, size.height - bottom);
    final grid = Paint()
      ..color = const Color(0xFFF3DFE0)
      ..strokeWidth = 1;

    final steps = yLabels.length - 1;
    for (var i = 0; i <= steps; i++) {
      final y = chart.bottom - chart.height * i / steps;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      final t = _tp(yLabels[i], 9.5, _muted);
      t.paint(canvas, Offset(chart.left - 8 - t.width, y - t.height / 2));
    }

    final slot = chart.width / values.length;
    final barW = slot * .54;
    for (var i = 0; i < values.length; i++) {
      final cx = chart.left + slot * (i + .5);
      final h = chart.height * _ratio(i);
      final sel = i == selected;
      if (h > 0) {
        final r = Rect.fromLTWH(cx - barW / 2, chart.bottom - h, barW, h);
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: sel
                ? const [Color(0xFFFF4A52), _red]
                : const [Color(0xFFFFB9BC), Color(0xFFFF9398)],
          ).createShader(r);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            r,
            topLeft: const Radius.circular(5),
            topRight: const Radius.circular(5),
          ),
          paint,
        );
      }
      final t = _tp(xLabels[i], 9.5, sel ? _ink : _muted,
          sel ? FontWeight.w700 : FontWeight.w400);
      t.paint(canvas, Offset(cx - t.width / 2, chart.bottom + 7));
    }

    if (selected < 0 || selected >= values.length) return;

    // Tooltip di atas batang terpilih.
    final cx = chart.left + slot * (selected + .5);
    final barTop = chart.bottom - chart.height * _ratio(selected);
    final t1 = _tp(tipTitle, 9, _muted);
    final t2 = _tp(tipValue, 11, _ink, FontWeight.w700);
    final w = math.max(t1.width, t2.width) + 18;
    final hh = t1.height + t2.height + 9;
    final l = (cx - w / 2).clamp(0.0, size.width - w).toDouble();
    final tp = math.max(0.0, barTop - 11 - hh);
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(l, tp, w, hh),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      box.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x24000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(box, Paint()..color = Colors.white);
    t1.paint(canvas, Offset(l + 9, tp + 4));
    t2.paint(canvas, Offset(l + 9, tp + 4 + t1.height));
    canvas.drawCircle(Offset(cx, barTop - 5), 2.5, Paint()..color = _red);
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.selected != selected ||
      old.maxY != maxY ||
      old.tipValue != tipValue ||
      old.fontFamily != fontFamily;
}

// ---------------------------------------------------------------------------
// Layanan terlaris
// ---------------------------------------------------------------------------

class _LayananCard extends StatelessWidget {
  const _LayananCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('Layanan Terlaris',
                      style: _t(14, w: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 6),
              Text('Lihat semua', style: _t(9.5, w: FontWeight.w500, c: _red)),
            ],
          ),
          for (final l in _layanan) _LayananRow(l),
        ],
      ),
    );
  }
}

class _LayananRow extends StatelessWidget {
  const _LayananRow(this.data);
  final _Layanan data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: data.bg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(data.icon, color: data.fg, size: 21),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(data.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(11.5, w: FontWeight.w500, h: 1.3)),
                  ),
                  Text('${data.persen}%',
                      style: _t(11.5, w: FontWeight.w700, h: 1.3)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E6E7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor:
                            (data.persen / 60).clamp(0.0, 1.0).toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2434B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 58,
                    child: Text('${data.jumlah} pesanan',
                        textAlign: TextAlign.right,
                        style: _t(8.5, c: _muted, h: 1.2)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metode pembayaran (donut)
// ---------------------------------------------------------------------------

class _BayarCard extends StatelessWidget {
  const _BayarCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(11, 12, 11, 10),
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Metode Pembayaran',
                  style: _t(14, w: FontWeight.w700)),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const RepaintBoundary(
                  child: CustomPaint(
                    size: Size(110, 110),
                    painter: _DonutPainter(),
                  ),
                ),
                SizedBox(
                  width: 68,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_rp(1250000),
                            style: _t(11, w: FontWeight.w700, h: 1.2)),
                      ),
                      Text('Total Omset', style: _t(8, c: _muted, h: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          for (final b in _bayar)
            SizedBox(
              height: 16,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: b.warna),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(b.nama, style: _t(9)),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Text('${b.persen}%',
                        textAlign: TextAlign.right,
                        style: _t(9, w: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 52,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(_rp(b.nominal), style: _t(8.5, c: _muted)),
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

class _DonutPainter extends CustomPainter {
  const _DonutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .15;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    var start = -math.pi / 2;
    for (final b in _bayar) {
      final sweep = 2 * math.pi * b.persen / 100;
      paint.color = b.warna;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}

// ---------------------------------------------------------------------------
// Rekap harian
// ---------------------------------------------------------------------------

class _RekapCard extends StatelessWidget {
  const _RekapCard({required this.onDetail});
  final VoidCallback onDetail;

  static const double _c1 = 74;
  static const double _c2 = 52;
  static const double _c3 = 80;

  @override
  Widget build(BuildContext context) {
    final head = _t(10, c: _muted);
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Rekap Harian', style: _t(14, w: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: onDetail,
                child: Row(
                  children: [
                    Text('Lihat detail',
                        style: _t(10, w: FontWeight.w500, c: _red)),
                    const Icon(Icons.chevron_right_rounded,
                        color: _red, size: 15),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECEC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(width: _c1, child: Text('Tanggal', style: head)),
                SizedBox(width: _c2, child: Text('Pesanan', style: head)),
                SizedBox(width: _c3, child: Text('Omset', style: head)),
                Expanded(child: Text('Pembayaran', style: head)),
              ],
            ),
          ),
          for (var i = 0; i < _rekap.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF3E3E4)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: _c1,
                    child: Text(_rekap[i].tanggal, style: _t(10.5)),
                  ),
                  SizedBox(
                    width: _c2,
                    child: Text('${_rekap[i].pesanan}', style: _t(10.5)),
                  ),
                  SizedBox(
                    width: _c3,
                    child: Text(_rp(_rekap[i].omset), style: _t(10.5)),
                  ),
                  Expanded(child: _Chips(_rekap[i].persen)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips(this.persen);
  final List<int> persen;

  static const _nama = ['QRIS', 'Tunai', 'Transfer', 'Lainnya'];
  static const _bg = [
    Color(0xFFFFE1E3),
    Color(0xFFDDF5E4),
    Color(0xFFDCE8FF),
    Color(0xFFEDEDF0),
  ];
  static const _fg = [
    _ink,
    Color(0xFF15803D),
    Color(0xFF2563EB),
    Color(0xFF55556A),
  ];

  Widget _chip(int i) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: _bg[i],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${_nama[i]} ',
                style: _t(8.5, w: FontWeight.w500, c: _fg[i]),
              ),
              TextSpan(text: '${persen[i]}%', style: _t(8.5)),
            ],
          ),
        ),
      );

  Widget _line(int a, int b) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(children: [_chip(a), _chip(b)]),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [_line(0, 1), const SizedBox(height: 4), _line(2, 3)],
    );
  }
}

// ---------------------------------------------------------------------------
// Navigasi bawah (Laporan aktif)
// ---------------------------------------------------------------------------

class _LaporanNav extends StatelessWidget {
  const _LaporanNav({required this.onTap, required this.onScan});
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  static const items = [
    (Icons.home_outlined, 'Beranda'),
    (Icons.receipt_long_outlined, 'Pesanan'),
    (Icons.bar_chart_rounded, 'Laporan'),
    (Icons.settings_outlined, 'Pengaturan'),
    (Icons.person_outline_rounded, 'Profil'),
  ];

  Widget _item(int i) {
    final active = i == 2;
    final color = active ? _red : _muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(i),
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
                Icon(items[i].$1, color: color, size: 24),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    items[i].$2,
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
                  Expanded(child: Row(children: [_item(0), _item(1)])),
                  const SizedBox(width: 78),
                  Expanded(
                    child: Row(children: [_item(2), _item(3), _item(4)]),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: onScan,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF5A60), Color(0xFFD0131F)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40C40F1B),
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
