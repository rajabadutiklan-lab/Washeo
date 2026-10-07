import 'package:flutter/material.dart';

import '../data/store.dart';
import '../widgets/common.dart';
import 'tambah_transaksi_screen.dart';

// Layar Pesanan. Kartu tembus pandang (kaca tipis TANPA blur) di atas latar
// putih dengan variasi abu lembut. Data diambil dari AppStore.

(Color, Color, IconData) _statusStyle(String s) => switch (s) {
      'Antrian' => (const Color(0xFFE9EDF2), kSlate, Icons.description_outlined),
      'Proses' => (const Color(0xFFFAEDDF), kOrange, Icons.schedule_rounded),
      'Siap Ambil' => (
          const Color(0xFFDFF3F2),
          kTealDark,
          Icons.check_circle_outline_rounded
        ),
      'Penjemputan' => (
          const Color(0xFFDFF3F2),
          kTealDark,
          Icons.local_shipping_outlined
        ),
      'Diantar' => (
          const Color(0xFFDFF3F2),
          kTealDark,
          Icons.local_shipping_outlined
        ),
      'Diambil' => (const Color(0xFFECEEF1), kMuted, Icons.inventory_2_outlined),
      _ => (const Color(0xFFFCE6E4), kRed, Icons.error_outline_rounded),
    };

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  String _outlet = 'Outlet Utama';
  String _tab = 'Antrian';
  String _q = '';
  bool _cari = false;

  void _tambah() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const TambahTransaksiScreen(),
    ));
  }

  void _detail(Order o) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderSheet(order: o),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.I,
      builder: (context, _) {
        final store = AppStore.I;
        final q = _q.toLowerCase();
        int count(String s) => store.orders.where((o) => o.status == s).length;
        final list = store.orders.where((o) {
          if (q.isNotEmpty) {
            return o.nama.toLowerCase().contains(q) ||
                o.kode.toLowerCase().contains(q);
          }
          return o.status == _tab;
        }).toList();

        return EwashoPage(
          current: 1,
          background: const SoftGreyBackground(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EwashoHeader(
                outlet: _outlet,
                onOutletChanged: (v) => setState(() => _outlet = v),
                actionIcon: Icons.notifications_rounded,
                onAction: () => showInfo(context, 'Buka Notifikasi'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const PageTitle('Pesanan'),
                  const Spacer(),
                  _RoundButton(
                    icon: _cari ? Icons.close_rounded : Icons.search_rounded,
                    filled: false,
                    onTap: () => setState(() {
                      _cari = !_cari;
                      if (!_cari) _q = '';
                    }),
                  ),
                  const SizedBox(width: 8),
                  _RoundButton(
                    icon: Icons.add_rounded,
                    filled: true,
                    onTap: _tambah,
                  ),
                ],
              ),
              if (_cari) ...[
                const SizedBox(height: 10),
                TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _q = v.trim()),
                  style: ts(13.5),
                  decoration: InputDecoration(
                    hintText: 'Cari nama pelanggan atau kode pesanan',
                    hintStyle: ts(13, c: kMuted),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: kSlate, size: 19),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kOutline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kOutline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kRed),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (q.isEmpty)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: kLine)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final s in kStatuses)
                          _Tab(
                            label: s,
                            count: count(s),
                            active: s == _tab,
                            onTap: () => setState(() => _tab = s),
                          ),
                      ],
                    ),
                  ),
                )
              else
                Text('Hasil pencarian "$_q"', style: ts(12.5, c: kMuted)),
              const SizedBox(height: 12),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 56),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kTile,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_outlined,
                            color: kMuted, size: 26),
                      ),
                      const SizedBox(height: 12),
                      Text(
                          q.isEmpty
                              ? 'Belum ada pesanan $_tab'
                              : 'Pesanan tidak ditemukan',
                          style: ts(13, c: kMuted)),
                    ],
                  ),
                )
              else
                for (final o in list) ...[
                  _OrderCard(order: o, onTap: () => _detail(o)),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Popup detail pesanan: rincian, ubah status, tandai lunas
// ---------------------------------------------------------------------------

class _OrderSheet extends StatelessWidget {
  const _OrderSheet({required this.order});
  final Order order;

  Widget _baris(String a, String b, {bool tebal = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(a, style: ts(13, c: kMuted))),
            Text(b,
                style: ts(13, w: tebal ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.I,
      builder: (context, _) {
        final o = order;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              18, 0, 18, 18 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              Row(
                children: [
                  CustomerAvatar(seed: o.nama, pria: o.pria, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.nama, style: ts(16, w: FontWeight.w600)),
                        Text('${o.kode}  •  ${o.durasi}',
                            style: ts(12, c: kMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final i in o.items)
                _baris('${i.nama}  (${fmtQty(i.qty)} ${i.satuan})',
                    rupiah(i.subtotal)),
              const Divider(height: 16, color: kLine),
              if (o.diskon > 0)
                _baris('Diskon ${o.diskon}%', '- ${rupiah(o.potongan)}'),
              _baris('Total', rupiah(o.total), tebal: true),
              _baris(
                  'Pembayaran',
                  o.bayar == 'Belum Bayar'
                      ? o.bayar
                      : '${o.bayar} • ${o.metode}'),
              if (o.bayar == 'DP') _baris('Sisa', rupiah(o.sisa)),
              _baris('Penyerahan', o.penyerahan),
              if (o.parfum.isNotEmpty) _baris('Parfum', o.parfum),
              if (o.prioritas) _baris('Prioritas', 'Ya'),
              _baris('Masuk', fmtWaktu(o.masuk)),
              _baris('Perkiraan selesai', fmtWaktu(o.estimasi)),
              if (o.catatan.isNotEmpty) _baris('Catatan', o.catatan),
              const SizedBox(height: 14),
              Text('Ubah status', style: ts(13.5, w: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in kStatuses)
                    GestureDetector(
                      onTap: () => AppStore.I.setStatus(o, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: s == o.status
                              ? const Color(0xFFFCE6E4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: s == o.status ? kRed : kLine,
                              width: s == o.status ? 1.5 : 1),
                        ),
                        child: Text(s,
                            style: ts(12.5,
                                w: FontWeight.w500,
                                c: s == o.status ? kRed : kInk)),
                      ),
                    ),
                ],
              ),
              if (o.bayar != 'Lunas') ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'TANDAI LUNAS (${rupiah(o.sisa)})',
                  icon: Icons.payments_outlined,
                  onTap: () => AppStore.I
                      .setLunas(o, o.metode.isEmpty ? 'Tunai' : o.metode),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tombol bulat, tab status, kartu pesanan
// ---------------------------------------------------------------------------

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? kRed : wOp(.7),
          border: filled ? null : Border.all(color: kOutline),
        ),
        child: Icon(icon, color: filled ? Colors.white : kSlate, size: 21),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hot = active && count > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? kRed : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: ts(13.5,
                  w: active ? FontWeight.w600 : FontWeight.w500,
                  c: active ? const Color(0xFF222222) : const Color(0xFF8A8FA3)),
            ),
            const SizedBox(width: 7),
            Container(
              constraints: const BoxConstraints(minWidth: 21),
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hot ? kRed : const Color(0xFFEEF0F5),
                borderRadius: BorderRadius.circular(10.5),
              ),
              child: Text(
                '$count',
                style: ts(10.5,
                    w: FontWeight.w500,
                    c: hot ? Colors.white : const Color(0xFF8A8FA3),
                    h: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});
  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _statusStyle(order.status);
    final berat = order.beratKg;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
        // Kaca tipis tanpa blur: putih tembus pandang + garis tepi putih.
        decoration: BoxDecoration(
          color: wOp(.62),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerAvatar(seed: order.nama, pria: order.pria),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(order.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ts(14, w: FontWeight.w600, h: 1.25)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: fg, size: 14),
                            const SizedBox(width: 5),
                            Text(order.status,
                                style: ts(11,
                                    w: FontWeight.w600, c: fg, h: 1.15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                      '${order.kode}  •  ${order.durasi}'
                      '${order.prioritas ? '  •  Prioritas' : ''}',
                      style: ts(11.5, c: kMuted, h: 1.3)),
                  Text('Masuk: ${fmtWaktu(order.masuk)}',
                      style: ts(11.5, c: kMuted, h: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.checkroom_outlined,
                                  color: kSlate, size: 17),
                              const SizedBox(width: 6),
                              Text('${order.items.length} layanan',
                                  style: ts(11.5, c: kMuted)),
                              if (berat > 0) ...[
                                const SizedBox(width: 10),
                                Text('${fmtQty(berat)} kg',
                                    style: ts(11.5, w: FontWeight.w500)),
                              ],
                              const SizedBox(width: 8),
                              if (order.bayar == 'Lunas')
                                Text('Lunas',
                                    style: ts(11, w: FontWeight.w600, c: kTealDark))
                              else
                                Text(order.bayar,
                                    style: ts(11, w: FontWeight.w600, c: kRed)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(rupiah(order.total),
                          style: ts(14.5, w: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(Icons.chevron_right_rounded, color: kRed, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
