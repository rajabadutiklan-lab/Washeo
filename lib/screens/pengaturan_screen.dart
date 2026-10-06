import 'package:flutter/material.dart';

import '../widgets/common.dart';

class _Menu {
  const _Menu(this.judul, this.sub, this.icon, this.warna);
  final String judul;
  final String sub;
  final IconData icon;
  final Color warna;
}

const _menus = [
  _Menu('Printer', 'Struk & label', Icons.print_outlined, kOrange),
  _Menu('Layanan', 'Jenis layanan', Icons.checkroom_rounded, kRed),
  _Menu('Parfum', 'Varian parfum', Icons.sanitizer_outlined, kSlate),
  _Menu('Manajemen Cabang', 'Outlet & cabang', Icons.storefront_outlined,
      kTeal),
  _Menu('Otomasi', 'WA & notifikasi', Icons.chat_outlined, kTeal),
  _Menu('Audit Aktivitas', 'Riwayat pengguna', Icons.description_outlined,
      kOrange),
  _Menu('Reminder Pekerjaan', 'Jadwal & notifikasi',
      Icons.notifications_none_rounded, kRed),
  _Menu('Database Pelanggan', 'Kelola pelanggan', Icons.people_outline_rounded,
      kSlate),
  _Menu('Upgrade Paket', 'Kelola langganan', Icons.workspace_premium_outlined,
      kRed),
  _Menu('Tentang Kami', 'Informasi aplikasi', Icons.info_outline_rounded,
      kSlate),
  _Menu('Bantuan', 'Pusat bantuan', Icons.help_outline_rounded, kTeal),
  _Menu('Profil', 'Akun pengguna', Icons.person_outline_rounded, kSlate),
];

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  String _outlet = 'Outlet Utama';

  // TODO: ganti dengan navigasi ke layar masing-masing.
  void _open(String name) => showInfo(context, 'Buka $name');

  @override
  Widget build(BuildContext context) {
    return EwashoPage(
      current: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EwashoHeader(
            outlet: _outlet,
            onOutletChanged: (v) => setState(() => _outlet = v),
            actionIcon: Icons.notifications_rounded,
            onAction: () => _open('Notifikasi'),
          ),
          const SizedBox(height: 18),
          const PageTitle('Pengaturan',
              subtitle: 'Kelola sistem sesuai kebutuhan usaha Anda'),
          const SizedBox(height: 14),
          for (var i = 0; i < _menus.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MenuCard(
                    data: _menus[i],
                    onTap: () => _open(_menus[i].judul),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MenuCard(
                    data: _menus[i + 1],
                    onTap: () => _open(_menus[i + 1].judul),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.data, required this.onTap});
  final _Menu data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 66,
        child: EwashoCard(
          padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kTile,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.warna, size: 23),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(data.judul,
                          style: ts(12.5, w: FontWeight.w600, h: 1.25)),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child:
                          Text(data.sub, style: ts(10.5, c: kMuted, h: 1.25)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: kRed, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}
