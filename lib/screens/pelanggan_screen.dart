import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/store.dart';
import '../widgets/common.dart';
import 'tambah_transaksi_screen.dart';

// Pelanggan: daftar, tambah (popup), pilih (popup), dan peta lokasi.

// ---------------------------------------------------------------------------
// Popup pilih jenis kelamin
// ---------------------------------------------------------------------------

/// Mengembalikan true = pria, false = wanita, null = dibatalkan.
Future<bool?> showGenderDialog(BuildContext context) {
  Widget pilihan(BuildContext ctx, bool pria) => Expanded(
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(pria),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: kTile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kLine),
            ),
            child: Column(
              children: [
                CustomerAvatar(
                    seed: pria ? 'pria' : 'wanita', pria: pria, size: 72),
                const SizedBox(height: 10),
                Text(pria ? 'Pria' : 'Wanita',
                    style: ts(15, w: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pelanggan pria atau wanita?',
                style: ts(16, w: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                pilihan(ctx, true),
                const SizedBox(width: 12),
                pilihan(ctx, false),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Popup tambah pelanggan
// ---------------------------------------------------------------------------

/// Alur: pilih pria/wanita (popup) lalu isi data (popup bawah).
/// Mengembalikan pelanggan yang baru disimpan, atau null bila dibatalkan.
Future<Customer?> showAddCustomer(BuildContext context) async {
  final pria = await showGenderDialog(context);
  if (pria == null || !context.mounted) return null;
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CustomerForm(pria: pria),
  );
}

InputDecoration fieldDecoration(String label, {String? hint, IconData? icon}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: kSlate, size: 20),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: b(kOutline),
    enabledBorder: b(kOutline),
    focusedBorder: b(kRed),
  );
}

class _CustomerForm extends StatefulWidget {
  const _CustomerForm({required this.pria});
  final bool pria;

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _nama = TextEditingController();
  final _hp = TextEditingController();
  final _alamat = TextEditingController();
  late bool _pria = widget.pria;
  double? _lat;
  double? _lng;
  bool _mencari = false;
  String? _lokasiError;
  String? _error;

  @override
  void dispose() {
    _nama.dispose();
    _hp.dispose();
    _alamat.dispose();
    super.dispose();
  }

  Future<void> _gantiGender() async {
    final v = await showGenderDialog(context);
    if (v != null && mounted) setState(() => _pria = v);
  }

  Future<void> _ambilLokasi() async {
    setState(() {
      _mencari = true;
      _lokasiError = null;
    });
    String? err;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        err = 'GPS belum aktif. Nyalakan lokasi di HP lalu coba lagi.';
      } else {
        var izin = await Geolocator.checkPermission();
        if (izin == LocationPermission.denied) {
          izin = await Geolocator.requestPermission();
        }
        if (izin == LocationPermission.denied ||
            izin == LocationPermission.deniedForever) {
          err = 'Izin lokasi ditolak. Izinkan lokasi untuk EWASHO di '
              'pengaturan HP.';
        } else {
          final pos = await Geolocator.getCurrentPosition();
          _lat = pos.latitude;
          _lng = pos.longitude;
        }
      }
    } catch (_) {
      err = 'Lokasi tidak bisa diambil. Coba lagi.';
    }
    if (!mounted) return;
    setState(() {
      _mencari = false;
      _lokasiError = err;
    });
  }

  void _simpan() {
    final nama = _nama.text.trim();
    final hp = _hp.text.trim();
    if (nama.isEmpty) {
      setState(() => _error = 'Nama pelanggan wajib diisi.');
      return;
    }
    if (hp.length < 8) {
      setState(() => _error = 'Nomor HP wajib diisi dengan benar.');
      return;
    }
    final c = AppStore.I.addCustomer(
      nama: nama,
      hp: hp,
      pria: _pria,
      alamat: _alamat.text.trim(),
      lat: _lat,
      lng: _lng,
    );
    Navigator.of(context).pop(c);
  }

  @override
  Widget build(BuildContext context) {
    final seed = _nama.text.trim().isEmpty ? 'baru' : _nama.text.trim();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Row(
              children: [
                GestureDetector(
                  onTap: _gantiGender,
                  child: CustomerAvatar(seed: seed, pria: _pria, size: 52),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tambah Pelanggan',
                          style: ts(17, w: FontWeight.w600)),
                      GestureDetector(
                        onTap: _gantiGender,
                        child: Text(
                            '${_pria ? 'Pria' : 'Wanita'}  •  ketuk untuk ganti',
                            style: ts(12, c: kMuted)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nama,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _error = null),
              decoration:
                  fieldDecoration('Nama', icon: Icons.person_outline_rounded),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hp,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _error = null),
              decoration: fieldDecoration('Nomor HP / WhatsApp',
                  hint: '08xxxxxxxxxx', icon: Icons.phone_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _alamat,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              decoration: fieldDecoration('Alamat (boleh kosong)',
                  icon: Icons.home_outlined),
            ),
            const SizedBox(height: 12),
            if (_lat != null && _lng != null) ...[
              MiniMap(lat: _lat!, lng: _lng!),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: kTeal, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Lokasi tersimpan',
                        style: ts(12, c: kTealDark)),
                  ),
                  GestureDetector(
                    onTap: _ambilLokasi,
                    child: Text('Perbarui',
                        style: ts(12, w: FontWeight.w600, c: kSlate)),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => setState(() {
                      _lat = null;
                      _lng = null;
                    }),
                    child: Text('Hapus',
                        style: ts(12, w: FontWeight.w600, c: kRed)),
                  ),
                ],
              ),
            ] else
              GestureDetector(
                onTap: _mencari ? null : _ambilLokasi,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kOutline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_mencari)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kRed),
                        )
                      else
                        const Icon(Icons.my_location_rounded,
                            color: kSlate, size: 19),
                      const SizedBox(width: 8),
                      Text(
                          _mencari
                              ? 'Mencari lokasi...'
                              : 'Gunakan lokasi saya sekarang',
                          style: ts(13, w: FontWeight.w500, c: kSlate)),
                    ],
                  ),
                ),
              ),
            if (_lokasiError != null) ...[
              const SizedBox(height: 6),
              Text(_lokasiError!, style: ts(12, c: kRed)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: ts(12.5, c: kRed)),
            ],
            const SizedBox(height: 16),
            PrimaryButton(label: 'SIMPAN PELANGGAN', onTap: _simpan),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Peta kecil (OpenStreetMap, butuh internet untuk gambar petanya)
// ---------------------------------------------------------------------------

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.lat,
    required this.lng,
    this.height = 150,
  });

  final double lat;
  final double lng;
  final double height;

  @override
  Widget build(BuildContext context) {
    final titik = LatLng(lat, lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        color: kTile,
        child: Stack(
          children: [
            FlutterMap(
              key: ValueKey('$lat,$lng'),
              options: MapOptions(
                initialCenter: titik,
                initialZoom: 16,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ewasho.ewasho',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: titik,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on_rounded,
                          color: kRed, size: 40),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                color: wOp(.75),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Text('© OpenStreetMap',
                    style: ts(8.5, c: kMuted, h: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Baris pelanggan + popup pilih pelanggan
// ---------------------------------------------------------------------------

class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, required this.onTap});
  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            CustomerAvatar(seed: customer.nama, pria: customer.pria, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(14, w: FontWeight.w600, h: 1.25)),
                  Text(
                    customer.alamat.isEmpty
                        ? customer.hp
                        : '${customer.hp}  •  ${customer.alamat}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(12, c: kMuted, h: 1.3),
                  ),
                ],
              ),
            ),
            if (customer.adaLokasi)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child:
                    Icon(Icons.location_on_outlined, color: kTeal, size: 18),
              ),
            const Icon(Icons.chevron_right_rounded, color: kOutline, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Popup untuk memilih pelanggan saat membuat transaksi.
Future<Customer?> showCustomerPicker(BuildContext context) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _CustomerPicker(),
  );
}

class _CustomerPicker extends StatefulWidget {
  const _CustomerPicker();

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.toLowerCase();
    final list = AppStore.I.customers
        .where((c) => c.nama.toLowerCase().contains(q) || c.hp.contains(q))
        .toList();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              Text('Pilih Pelanggan', style: ts(17, w: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _q = v.trim()),
                decoration: fieldDecoration('Cari nama atau nomor HP',
                    icon: Icons.search_rounded),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final nav = Navigator.of(context);
                  final c = await showAddCustomer(context);
                  if (c != null) nav.pop(c);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: kRed),
                        child: const Icon(Icons.person_add_alt_1_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text('Tambah pelanggan baru',
                          style: ts(14, w: FontWeight.w600, c: kRed)),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: kLine),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text('Pelanggan tidak ditemukan',
                            style: ts(13, c: kMuted)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: kLine),
                        itemBuilder: (_, i) => CustomerTile(
                          customer: list[i],
                          onTap: () => Navigator.of(context).pop(list[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layar daftar pelanggan
// ---------------------------------------------------------------------------

class PelangganScreen extends StatefulWidget {
  const PelangganScreen({super.key});

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  String _q = '';

  void _detail(Customer c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Row(
              children: [
                CustomerAvatar(seed: c.nama, pria: c.pria, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.nama, style: ts(17, w: FontWeight.w600)),
                      Text(
                          '${c.pria ? 'Pria' : 'Wanita'}  •  '
                          '${AppStore.I.jumlahPesanan(c)} pesanan',
                          style: ts(12.5, c: kMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Info(Icons.phone_outlined, c.hp),
            if (c.alamat.isNotEmpty) _Info(Icons.home_outlined, c.alamat),
            if (c.adaLokasi) ...[
              const SizedBox(height: 8),
              MiniMap(lat: c.lat!, lng: c.lng!, height: 160),
            ] else
              _Info(Icons.location_off_outlined, 'Lokasi belum disimpan'),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'BUAT TRANSAKSI',
              icon: Icons.add_rounded,
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TambahTransaksiScreen(pelanggan: c),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.I,
      builder: (context, _) {
        final q = _q.toLowerCase();
        final list = AppStore.I.customers
            .where((c) => c.nama.toLowerCase().contains(q) || c.hp.contains(q))
            .toList();
        return SubPage(
          title: 'Pelanggan',
          action: GestureDetector(
            onTap: () => showAddCustomer(context),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kRed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('Tambah',
                      style: ts(13, w: FontWeight.w600, c: Colors.white)),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  onChanged: (v) => setState(() => _q = v.trim()),
                  decoration: fieldDecoration('Cari nama atau nomor HP',
                      icon: Icons.search_rounded),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                            _q.isEmpty
                                ? 'Belum ada pelanggan'
                                : 'Pelanggan tidak ditemukan',
                            style: ts(13, c: kMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: list.length,
                        itemBuilder: (_, i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomerTile(
                            customer: list[i],
                            onTap: () => _detail(list[i]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kSlate, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: ts(13.5, h: 1.3))),
        ],
      ),
    );
  }
}
