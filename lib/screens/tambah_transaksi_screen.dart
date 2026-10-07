import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/store.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import 'pelanggan_screen.dart';

// Tambah Transaksi: satu halaman, urut dari atas ke bawah:
// 1 Pelanggan  2 Durasi  3 Layanan  4 Pembayaran  ->  Simpan.

const _statusBayar = ['Belum Bayar', 'DP', 'Lunas'];
const _metodeBayar = ['Tunai', 'QRIS', 'Transfer'];

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key, this.pelanggan});

  /// Pelanggan yang sudah dipilih dari layar lain (boleh kosong).
  final Customer? pelanggan;

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  late Customer? _pelanggan = widget.pelanggan;
  Durasi _durasi = kDurasi.first;
  final Map<String, double> _qty = {};
  String _bayar = 'Belum Bayar';
  String _metode = 'Tunai';
  final _dp = TextEditingController();
  final _catatan = TextEditingController();

  @override
  void dispose() {
    _dp.dispose();
    _catatan.dispose();
    super.dispose();
  }

  int _harga(Service s) => (s.harga * _durasi.kali).round();

  int get _total {
    var t = 0;
    for (final s in kServices) {
      final q = _qty[s.id] ?? 0;
      if (q > 0) t += (_harga(s) * q).round();
    }
    return t;
  }

  bool get _adaLayanan => _qty.values.any((q) => q > 0);

  void _ubahQty(Service s, double delta) {
    final baru = ((_qty[s.id] ?? 0) + delta).clamp(0.0, 999.0).toDouble();
    setState(() {
      if (baru <= 0) {
        _qty.remove(s.id);
      } else {
        _qty[s.id] = baru;
      }
    });
  }

  Future<void> _pilihPelanggan() async {
    final c = await showCustomerPicker(context);
    if (c != null && mounted) setState(() => _pelanggan = c);
  }

  void _pesan(String text) => showInfo(context, text);

  Future<void> _simpan() async {
    final pelanggan = _pelanggan;
    if (pelanggan == null) return _pesan('Pilih pelanggan dulu.');
    if (!_adaLayanan) return _pesan('Tambahkan minimal satu layanan.');

    final total = _total;
    var dibayar = 0;
    if (_bayar == 'Lunas') {
      dibayar = total;
    } else if (_bayar == 'DP') {
      dibayar = int.tryParse(_dp.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (dibayar <= 0) return _pesan('Isi jumlah DP.');
      if (dibayar >= total) {
        return _pesan('DP harus lebih kecil dari total. Pilih Lunas.');
      }
    }

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
      bayar: _bayar,
      metode: _bayar == 'Belum Bayar' ? '' : _metode,
      dibayar: dibayar,
      catatan: _catatan.text.trim(),
    );

    final lihat = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: kTeal, size: 56),
              const SizedBox(height: 10),
              Text('Pesanan Tersimpan', style: ts(17, w: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(order.kode, style: ts(13, c: kMuted)),
              const SizedBox(height: 14),
              _Baris('Pelanggan', order.nama),
              _Baris('Total', rupiah(order.total)),
              if (order.bayar == 'DP') _Baris('Sisa', rupiah(order.sisa)),
              _Baris('Pembayaran', order.bayar),
              _Baris('Selesai', fmtWaktu(order.estimasi)),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'LIHAT PESANAN',
                onTap: () => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Buat transaksi lagi',
                    style: ts(13, w: FontWeight.w600, c: kSlate)),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (lihat == true) {
      goTab(context, -1, 1);
    } else {
      setState(() {
        _pelanggan = null;
        _qty.clear();
        _bayar = 'Belum Bayar';
        _dp.clear();
        _catatan.clear();
        _durasi = kDurasi.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final selesai = DateTime.now().add(Duration(hours: _durasi.jam));
    return SubPage(
      title: 'Tambah Transaksi',
      bottom: Container(
        padding: EdgeInsets.fromLTRB(
            16, 10, 16, 12 + MediaQuery.paddingOf(context).bottom),
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
                  Text('Total', style: ts(12, c: kMuted, h: 1.2)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(rupiah(total),
                        style: ts(19, w: FontWeight.w700, h: 1.2)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: PrimaryButton(
                label: 'SIMPAN',
                icon: Icons.check_rounded,
                enabled: _pelanggan != null && _adaLayanan,
                onTap: _simpan,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // 1. Pelanggan
          const _Judul('1', 'Pelanggan'),
          GestureDetector(
            onTap: _pilihPelanggan,
            child: _Kotak(
              child: _pelanggan == null
                  ? Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: kTile),
                          child: const Icon(Icons.person_add_alt_1_rounded,
                              color: kRed, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Pilih atau tambah pelanggan',
                              style: ts(14, w: FontWeight.w500, c: kRed)),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: kOutline, size: 20),
                      ],
                    )
                  : Row(
                      children: [
                        CustomerAvatar(
                            seed: _pelanggan!.nama,
                            pria: _pelanggan!.pria,
                            size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_pelanggan!.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ts(14, w: FontWeight.w600, h: 1.25)),
                              Text(_pelanggan!.hp,
                                  style: ts(12, c: kMuted, h: 1.3)),
                            ],
                          ),
                        ),
                        Text('Ganti',
                            style: ts(13, w: FontWeight.w600, c: kRed)),
                      ],
                    ),
            ),
          ),

          // 2. Durasi
          const _Judul('2', 'Durasi'),
          Row(
            children: [
              for (var i = 0; i < kDurasi.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Pilihan(
                    aktif: _durasi == kDurasi[i],
                    onTap: () => setState(() => _durasi = kDurasi[i]),
                    child: Column(
                      children: [
                        Text(kDurasi[i].nama,
                            style: ts(13.5,
                                w: FontWeight.w600,
                                c: _durasi == kDurasi[i] ? kRed : kInk)),
                        Text(kDurasi[i].keterangan,
                            style: ts(11.5, c: kMuted, h: 1.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 2),
            child: Text('Perkiraan selesai: ${fmtWaktu(selesai)}',
                style: ts(12, c: kMuted)),
          ),

          // 3. Layanan
          const _Judul('3', 'Layanan'),
          _Kotak(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                for (var i = 0; i < kServices.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: kLine),
                  _BarisLayanan(
                    layanan: kServices[i],
                    harga: _harga(kServices[i]),
                    qty: _qty[kServices[i].id] ?? 0,
                    onKurang: () =>
                        _ubahQty(kServices[i], -kServices[i].langkah),
                    onTambah: () =>
                        _ubahQty(kServices[i], kServices[i].langkah),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _catatan,
            textCapitalization: TextCapitalization.sentences,
            decoration: fieldDecoration('Catatan (boleh kosong)',
                hint: 'Contoh: jangan pakai pewangi',
                icon: Icons.sticky_note_2_outlined),
          ),

          // 4. Pembayaran
          const _Judul('4', 'Pembayaran'),
          Row(
            children: [
              for (var i = 0; i < _statusBayar.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Pilihan(
                    aktif: _bayar == _statusBayar[i],
                    onTap: () => setState(() => _bayar = _statusBayar[i]),
                    child: Text(_statusBayar[i],
                        style: ts(13,
                            w: FontWeight.w600,
                            c: _bayar == _statusBayar[i] ? kRed : kInk)),
                  ),
                ),
              ],
            ],
          ),
          if (_bayar != 'Belum Bayar') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < _metodeBayar.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _Pilihan(
                      aktif: _metode == _metodeBayar[i],
                      onTap: () => setState(() => _metode = _metodeBayar[i]),
                      child: Text(_metodeBayar[i],
                          style: ts(13,
                              w: FontWeight.w500,
                              c: _metode == _metodeBayar[i] ? kRed : kInk)),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (_bayar == 'DP') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _dp,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: fieldDecoration('Jumlah DP (Rp)',
                  icon: Icons.payments_outlined),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Potongan tampilan
// ---------------------------------------------------------------------------

class _Judul extends StatelessWidget {
  const _Judul(this.nomor, this.teks);
  final String nomor;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: kDark),
            child: Text(nomor,
                style: ts(11.5, w: FontWeight.w600, c: Colors.white, h: 1.1)),
          ),
          const SizedBox(width: 8),
          Text(teks, style: ts(15, w: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Kotak extends StatelessWidget {
  const _Kotak({required this.child, this.padding = const EdgeInsets.all(12)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _Pilihan extends StatelessWidget {
  const _Pilihan({
    required this.aktif,
    required this.onTap,
    required this.child,
  });

  final bool aktif;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: aktif ? const Color(0xFFFCE6E4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: aktif ? kRed : kLine, width: aktif ? 1.5 : 1),
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );
  }
}

class _BarisLayanan extends StatelessWidget {
  const _BarisLayanan({
    required this.layanan,
    required this.harga,
    required this.qty,
    required this.onKurang,
    required this.onTambah,
  });

  final Service layanan;
  final int harga;
  final double qty;
  final VoidCallback onKurang;
  final VoidCallback onTambah;

  Widget _tombol(IconData icon, VoidCallback onTap, bool isi) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isi ? kRed : Colors.white,
            border: isi ? null : Border.all(color: kOutline),
          ),
          child: Icon(icon, size: 19, color: isi ? Colors.white : kSlate),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final dipilih = qty > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(layanan.nama,
                    style: ts(14, w: FontWeight.w600, h: 1.25)),
                Text('${rupiah(harga)} / ${layanan.satuan}',
                    style: ts(12, c: kMuted, h: 1.3)),
              ],
            ),
          ),
          if (dipilih) ...[
            _tombol(Icons.remove_rounded, onKurang, false),
            SizedBox(
              width: 62,
              child: Text('${fmtQty(qty)} ${layanan.satuan}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: ts(13, w: FontWeight.w600)),
            ),
          ],
          _tombol(Icons.add_rounded, onTambah, true),
        ],
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.label, this.nilai);
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: ts(13, c: kMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(nilai,
                textAlign: TextAlign.right,
                style: ts(13, w: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
