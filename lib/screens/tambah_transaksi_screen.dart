import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/store.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import 'pelanggan_screen.dart';

// Tambah Transaksi - 5 langkah, urutannya sama dengan alur di Goyana:
//   1. Pilih Pelanggan (halaman)   -> popup Pilih Durasi
//   2. Tambahkan Layanan (halaman) -> tombol LANJUT
//   3. Atur Pesanan (popup)
//   4. Pembayaran (popup)
//   5. Pesanan Berhasil (popup)

const _parfum = ['Tidak', 'Akasia', 'Junjung Buih', 'Lavender', 'Ocean', 'Sakura'];
const _penyerahan = ['Datang Langsung', 'Antar ke Pelanggan', 'Jemput & Antar'];
const _diskon = [0, 10, 20];

RoundedRectangleBorder get _sheetShape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    );

class _Opsi {
  const _Opsi(this.parfum, this.penyerahan, this.prioritas, this.diskon,
      this.catatan);
  final String parfum;
  final String penyerahan;
  final bool prioritas;
  final int diskon;
  final String catatan;
}

class _Bayar {
  const _Bayar(this.status, this.metode, this.dibayar);
  final String status;
  final String metode;
  final int dibayar;
}

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key, this.pelanggan});

  /// Pelanggan yang sudah dipilih dari layar lain (boleh kosong).
  final Customer? pelanggan;

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  int _step = 1;
  Customer? _pelanggan;
  Durasi _durasi = kDurasi.first;
  final Map<String, double> _qty = {};
  String _cariPelanggan = '';
  String _cariLayanan = '';

  @override
  void initState() {
    super.initState();
    final awal = widget.pelanggan;
    if (awal != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pilih(awal));
    }
  }

  int _harga(Service s) => (s.harga * _durasi.kali).round();

  int get _subtotal {
    var t = 0;
    for (final s in kServices) {
      final q = _qty[s.id] ?? 0;
      if (q > 0) t += (_harga(s) * q).round();
    }
    return t;
  }

  bool get _adaLayanan => _qty.values.any((q) => q > 0);

  String get _ringkas {
    var kg = 0.0;
    var lain = 0.0;
    for (final s in kServices) {
      final q = _qty[s.id] ?? 0;
      if (s.satuan == 'kg') {
        kg += q;
      } else {
        lain += q;
      }
    }
    return '${fmtQty(kg)} kg · ${fmtQty(lain)} pcs';
  }

  void _setQty(Service s, double v) {
    final baru = v.clamp(0.0, 999.0).toDouble();
    setState(() {
      if (baru <= 0) {
        _qty.remove(s.id);
      } else {
        _qty[s.id] = baru;
      }
    });
  }

  // ---- Langkah 1 -> popup durasi -----------------------------------------

  Future<Durasi?> _popupDurasi() {
    return showModalBottomSheet<Durasi>(
      context: context,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 0, 18, 18 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Text('Pilih Durasi', style: ts(17, w: FontWeight.w600)),
            const SizedBox(height: 12),
            for (final d in kDurasi) ...[
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(d),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: d == _durasi && _step == 2
                        ? const Color(0xFFFCE6E4)
                        : kTile,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: d == _durasi && _step == 2 ? kRed : kLine),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.nama, style: ts(15, w: FontWeight.w600)),
                            Text(d.keterangan, style: ts(12.5, c: kMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: kSlate, size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pilih(Customer c) async {
    final d = await _popupDurasi();
    if (d == null || !mounted) return;
    setState(() {
      _pelanggan = c;
      _durasi = d;
      _step = 2;
    });
  }

  Future<void> _gantiDurasi() async {
    final d = await _popupDurasi();
    if (d != null && mounted) setState(() => _durasi = d);
  }

  Future<void> _tambahPelanggan() async {
    final c = await showAddCustomer(context);
    if (c != null && mounted) _pilih(c);
  }

  // ---- Langkah 2: jumlah lewat popup --------------------------------------

  Future<void> _ketikQty(Service s) async {
    final ctrl = TextEditingController(text: fmtQty(_qty[s.id] ?? 1));
    final v = await showDialog<double>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Jumlah ${s.nama}', style: ts(16, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Dalam ${s.satuan}. Boleh pakai koma, contoh 1,3',
                  style: ts(12, c: kMuted)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                textAlign: TextAlign.center,
                style: ts(22, w: FontWeight.w700),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: fieldDecoration(''),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'SIMPAN',
                onTap: () => Navigator.of(ctx).pop(
                    double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Batal',
                    style: ts(13, w: FontWeight.w600, c: kSlate)),
              ),
            ],
          ),
        ),
      ),
    );
    if (v != null && mounted) _setQty(s, v);
  }

  // ---- Langkah 3-5: popup berurutan ---------------------------------------

  Future<void> _lanjut() async {
    final pelanggan = _pelanggan;
    if (pelanggan == null) return;
    if (!_adaLayanan) {
      showInfo(context, 'Tambahkan minimal satu layanan.');
      return;
    }
    final subtotal = _subtotal;

    // 3. Atur Pesanan
    final opsi = await showModalBottomSheet<_Opsi>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (_) => const _OpsiSheet(),
    );
    if (opsi == null || !mounted) return;

    // 4. Pembayaran
    final total = subtotal - (subtotal * opsi.diskon / 100).round();
    final bayar = await showModalBottomSheet<_Bayar>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (_) => _BayarSheet(total: total, diskon: opsi.diskon),
    );
    if (bayar == null || !mounted) return;

    final order = AppStore.I.addOrder(
      customer: pelanggan,
      durasi: _durasi,
      items: [
        for (final s in kServices)
          if ((_qty[s.id] ?? 0) > 0)
            OrderItem(
              nama: s.nama,
              satuan: s.satuan,
              harga: _harga(s),
              qty: _qty[s.id]!,
            ),
      ],
      bayar: bayar.status,
      metode: bayar.metode,
      dibayar: bayar.dibayar,
      catatan: opsi.catatan,
      parfum: opsi.parfum == 'Tidak' ? '' : opsi.parfum,
      penyerahan: opsi.penyerahan,
      prioritas: opsi.prioritas,
      diskon: opsi.diskon,
    );

    // 5. Pesanan Berhasil
    final lihat = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: _sheetShape,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, 16 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const Icon(Icons.check_circle_rounded, color: kTeal, size: 58),
            const SizedBox(height: 8),
            Text('Pesanan Berhasil',
                textAlign: TextAlign.center,
                style: ts(18, w: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
                order.bayar == 'Belum Bayar'
                    ? 'Pesanan tersimpan sebagai Belum Lunas.'
                    : order.bayar == 'DP'
                        ? 'DP ${rupiah(order.dibayar)} tersimpan. '
                            'Sisa ${rupiah(order.sisa)}.'
                        : 'Pembayaran ${order.metode} berhasil disimpan.',
                textAlign: TextAlign.center,
                style: ts(13, c: kMuted)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: kTile,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('ORDER ID', style: ts(11, c: kMuted)),
                  Text(order.kode, style: ts(17, w: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Selesai: ${fmtWaktu(order.estimasi)}',
                      style: ts(12, c: kMuted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'LIHAT PESANAN',
              onTap: () => Navigator.of(ctx).pop(true),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Buat transaksi lagi',
                  style: ts(13, w: FontWeight.w600, c: kSlate)),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (lihat == true) {
      goTab(context, -1, 1);
    } else {
      setState(() {
        _step = 1;
        _pelanggan = null;
        _qty.clear();
        _durasi = kDurasi.first;
        _cariPelanggan = '';
        _cariLayanan = '';
      });
    }
  }

  // ---- Tampilan ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step = 1);
      },
      child: SubPage(
        title: _step == 1 ? 'Pilih Pelanggan' : 'Tambahkan Layanan',
        action: Text('Langkah $_step dari 5', style: ts(12.5, c: kMuted)),
        bottom: _step == 2 ? _footer(context) : null,
        body: _step == 1 ? _langkah1() : _langkah2(),
      ),
    );
  }

  Widget _langkah1() {
    return ListenableBuilder(
      listenable: AppStore.I,
      builder: (context, _) {
        final q = _cariPelanggan.toLowerCase();
        final list = AppStore.I.customers
            .where((c) => c.nama.toLowerCase().contains(q) || c.hp.contains(q))
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            TextField(
              onChanged: (v) => setState(() => _cariPelanggan = v.trim()),
              decoration: fieldDecoration('Cari nama / no handphone',
                  icon: Icons.search_rounded),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _tambahPelanggan,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kRed),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: kRed, size: 20),
                    const SizedBox(width: 6),
                    Text('Tambah Pelanggan',
                        style: ts(14, w: FontWeight.w600, c: kRed)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('Pelanggan tidak ditemukan',
                      style: ts(13, c: kMuted)),
                ),
              ),
            for (final c in list)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomerAvatar(seed: c.nama, pria: c.pria, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ts(14, w: FontWeight.w600, h: 1.25)),
                          Text(c.hp, style: ts(12, c: kMuted, h: 1.3)),
                          if (c.alamat.isNotEmpty)
                            Text(c.alamat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ts(12, c: kMuted, h: 1.3)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _pilih(c),
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kRed,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text('Pilih',
                            style: ts(13,
                                w: FontWeight.w600, c: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _langkah2() {
    final p = _pelanggan!;
    final q = _cariLayanan.toLowerCase();
    final list =
        kServices.where((s) => s.nama.toLowerCase().contains(q)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: kDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CustomerAvatar(seed: p.nama, pria: p.pria, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(14,
                            w: FontWeight.w600, c: Colors.white, h: 1.25)),
                    Text('${_durasi.nama} · ${_durasi.keterangan}',
                        style: ts(12, c: wOp(.85), h: 1.3)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _gantiDurasi,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text('Ganti durasi',
                      style: ts(12, w: FontWeight.w600, c: kDark)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (v) => setState(() => _cariLayanan = v.trim()),
          decoration: fieldDecoration('Cari nama layanan',
              icon: Icons.search_rounded),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
          child: Text(
              'Tekan + untuk menambahkan layanan. Ketuk angkanya untuk '
              'mengisi jumlah atau berat sendiri.',
              style: ts(12, c: kMuted, h: 1.35)),
        ),
        for (final s in list)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _BarisLayanan(
              layanan: s,
              durasi: _durasi.nama,
              harga: _harga(s),
              qty: _qty[s.id] ?? 0,
              onKurang: () => _setQty(s, (_qty[s.id] ?? 0) - s.langkah),
              onTambah: () => _setQty(s, (_qty[s.id] ?? 0) + s.langkah),
              onKetik: () => _ketikQty(s),
            ),
          ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 12, 10 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pelanggan?.nama ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, w: FontWeight.w600, h: 1.25)),
                Text(_ringkas, style: ts(11.5, c: kMuted, h: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total Layanan', style: ts(11, c: kMuted, h: 1.2)),
              Text(rupiah(_subtotal),
                  style: ts(16, w: FontWeight.w700, h: 1.25)),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 104,
            child: PrimaryButton(
              label: 'LANJUT ›',
              enabled: _adaLayanan,
              onTap: _lanjut,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Baris layanan
// ---------------------------------------------------------------------------

class _BarisLayanan extends StatelessWidget {
  const _BarisLayanan({
    required this.layanan,
    required this.durasi,
    required this.harga,
    required this.qty,
    required this.onKurang,
    required this.onTambah,
    required this.onKetik,
  });

  final Service layanan;
  final String durasi;
  final int harga;
  final double qty;
  final VoidCallback onKurang;
  final VoidCallback onTambah;
  final VoidCallback onKetik;

  Widget _tombol(IconData icon, VoidCallback onTap, bool isi) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isi ? kRed : Colors.white,
            border: isi ? null : Border.all(color: kOutline),
          ),
          child: Icon(icon, size: 20, color: isi ? Colors.white : kSlate),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final jenis = layanan.satuan == 'kg' ? 'Kiloan' : 'Satuan';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$durasi · $jenis', style: ts(11, c: kMuted, h: 1.3)),
              Text(layanan.nama, style: ts(14, w: FontWeight.w600, h: 1.25)),
              Text('${rupiah(harga)} / ${layanan.satuan}',
                  style: ts(12.5, w: FontWeight.w600, c: kRed, h: 1.3)),
            ],
          ),
        ),
        if (qty > 0) ...[
          _tombol(Icons.remove_rounded, onKurang, false),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onKetik,
            child: Container(
              width: 58,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kTile,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(fmtQty(qty), style: ts(14, w: FontWeight.w700)),
              ),
            ),
          ),
        ],
        _tombol(Icons.add_rounded, onTambah, true),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Popup 3: Atur Pesanan
// ---------------------------------------------------------------------------

class _OpsiSheet extends StatefulWidget {
  const _OpsiSheet();

  @override
  State<_OpsiSheet> createState() => _OpsiSheetState();
}

class _OpsiSheetState extends State<_OpsiSheet> {
  String _p = _parfum.first;
  String _serah = _penyerahan.first;
  bool _prioritas = false;
  int _disk = 0;
  final _catatan = TextEditingController();

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(t, style: ts(13.5, w: FontWeight.w600)),
      );

  Widget _chip(String teks, bool aktif, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: aktif ? const Color(0xFFFCE6E4) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: aktif ? kRed : kLine, width: aktif ? 1.5 : 1),
          ),
          child: Text(teks,
              style: ts(12.5, w: FontWeight.w500, c: aktif ? kRed : kInk)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            18, 0, 18, 16 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Row(
              children: [
                Expanded(
                  child:
                      Text('Atur Pesanan', style: ts(17, w: FontWeight.w600)),
                ),
                Text('Langkah 3 dari 5', style: ts(12, c: kMuted)),
              ],
            ),
            _label('Parfum'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _parfum)
                  _chip(v, v == _p, () => setState(() => _p = v)),
              ],
            ),
            _label('Penyerahan'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _penyerahan)
                  _chip(v, v == _serah, () => setState(() => _serah = v)),
              ],
            ),
            _label('Diskon'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _diskon)
                  _chip(v == 0 ? 'Tidak' : '$v%', v == _disk,
                      () => setState(() => _disk = v)),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _prioritas = !_prioritas),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jadikan Prioritas',
                            style: ts(13.5, w: FontWeight.w600)),
                        Text('Naik ke atas antrian',
                            style: ts(12, c: kMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _prioritas,
                    activeTrackColor: kRed,
                    onChanged: (v) => setState(() => _prioritas = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _catatan,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 3,
              decoration: fieldDecoration('Catatan',
                  hint: 'Contoh: 12 pcs, rak B2, kemeja luntur'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'BUAT PESANAN',
              icon: Icons.receipt_long_outlined,
              onTap: () => Navigator.of(context).pop(
                  _Opsi(_p, _serah, _prioritas, _disk, _catatan.text.trim())),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Popup 4: Pembayaran
// ---------------------------------------------------------------------------

class _BayarSheet extends StatelessWidget {
  const _BayarSheet({required this.total, required this.diskon});
  final int total;
  final int diskon;

  Future<void> _dp(BuildContext context) async {
    final ctrl = TextEditingController();
    var metode = 'Tunai';
    String? err;
    final hasil = await showDialog<_Bayar>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('DP / Uang Muka', style: ts(16, w: FontWeight.w600)),
                Text('Total tagihan ${rupiah(total)}',
                    style: ts(12.5, c: kMuted)),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: fieldDecoration('Jumlah DP (Rp)',
                      icon: Icons.payments_outlined),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final m in const ['Tunai', 'QRIS', 'Transfer']) ...[
                      if (m != 'Tunai') const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => metode = m),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: m == metode
                                  ? const Color(0xFFFCE6E4)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: m == metode ? kRed : kLine),
                            ),
                            child: Text(m,
                                style: ts(12.5,
                                    w: FontWeight.w600,
                                    c: m == metode ? kRed : kInk)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (err != null) ...[
                  const SizedBox(height: 8),
                  Text(err!, style: ts(12, c: kRed)),
                ],
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'SIMPAN DP',
                  onTap: () {
                    final v = int.tryParse(ctrl.text) ?? 0;
                    if (v <= 0) {
                      setS(() => err = 'Isi jumlah DP.');
                    } else if (v >= total) {
                      setS(() =>
                          err = 'DP harus lebih kecil dari total tagihan.');
                    } else {
                      Navigator.of(ctx).pop(_Bayar('DP', metode, v));
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Batal',
                      style: ts(13, w: FontWeight.w600, c: kSlate)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (hasil != null && context.mounted) Navigator.of(context).pop(hasil);
  }

  Widget _kotak(IconData icon, String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: kTile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLine),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: kSlate, size: 26),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: ts(12.5, w: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    void lunas(String metode) =>
        Navigator.of(context).pop(_Bayar('Lunas', metode, total));
    return Padding(
      padding: EdgeInsets.fromLTRB(
          18, 0, 18, 12 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          Row(
            children: [
              Expanded(
                child: Text('Pembayaran', style: ts(17, w: FontWeight.w600)),
              ),
              Text('Langkah 4 dari 5', style: ts(12, c: kMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Total Tagihan', style: ts(12, c: wOp(.85))),
                Text(rupiah(total),
                    style: ts(24, w: FontWeight.w700, c: Colors.white)),
                if (diskon > 0)
                  Text('Sudah termasuk diskon $diskon%',
                      style: ts(11.5, c: wOp(.85))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _kotak(Icons.payments_outlined, 'Tunai', () => lunas('Tunai')),
              const SizedBox(width: 8),
              _kotak(Icons.qr_code_2_rounded, 'QRIS', () => lunas('QRIS')),
              const SizedBox(width: 8),
              _kotak(Icons.swap_horiz_rounded, 'Transfer',
                  () => lunas('Transfer')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _kotak(
                  Icons.schedule_rounded,
                  'Bayar Nanti',
                  () => Navigator.of(context)
                      .pop(const _Bayar('Belum Bayar', '', 0))),
              const SizedBox(width: 8),
              _kotak(Icons.pie_chart_outline_rounded, 'DP / Uang Muka',
                  () => _dp(context)),
            ],
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Kembali, belum jadi bayar',
                style: ts(13, w: FontWeight.w600, c: kSlate)),
          ),
        ],
      ),
    );
  }
}
