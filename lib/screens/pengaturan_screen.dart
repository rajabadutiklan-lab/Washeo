import 'package:flutter/material.dart';

import '../widgets/common.dart';

class _Menu {
  const _Menu(this.judul, this.sub, this.icon, this.bg, this.fg);
  final String judul;
  final String sub;
  final IconData icon;
  final Color bg;
  final Color fg;
}

const _menus = [
  _Menu('Printer', 'Struk & label', Icons.print_rounded, Color(0xFFFFE9D2),
      Color(0xFFF97316)),
  _Menu('Layanan', 'Jenis layanan', Icons.checkroom_rounded,
      Color(0xFFFFE4E6), kRed),
  _Menu('Parfum', 'Varian parfum', Icons.sanitizer_outlined,
      Color(0xFFEFE5FC), Color(0xFF7C3AED)),
  _Menu('Manajemen Cabang', 'Outlet & cabang', Icons.storefront_outlined,
      Color(0xFFE0ECFF), Color(0xFF2563EB)),
  _Menu('Otomasi', 'WA & notifikasi', Icons.chat_rounded, Color(0xFFDFF5E3),
      Color(0xFF16A34A)),
  _Menu('Audit Aktivitas', 'Riwayat pengguna', Icons.description_outlined,
      Color(0xFFFFF0D4), Color(0xFFF59E0B)),
  _Menu('Reminder Pekerjaan', 'Jadwal & notifikasi',
      Icons.notifications_none_rounded, Color(0xFFFFE4E6), kRed),
  _Menu('Database Pelanggan', 'Kelola pelanggan', Icons.people_outline_rounded,
      Color(0xFFE0ECFF), Color(0xFF2563EB)),
  _Menu('Upgrade Paket', 'Kelola langganan', Icons.workspace_premium_rounded,
      Color(0xFFFFE4E6), kRed),
  _Menu('Tentang Kami', 'Informasi aplikasi', Icons.info_outline_rounded,
      Color(0xFFEFE5FC), Color(0xFF7C3AED)),
  _Menu('Bantuan', 'Pusat bantuan', Icons.help_rounded, Color(0xFFDAF1F4),
      Color(0xFF0E9FB5)),
  _Menu('Profil', 'Akun pengguna', Icons.person_outline_rounded,
      Color(0xFFE9EAEE), Color(0xFF475467)),
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
      redHeight: 138,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EwashoHeader(
            outlet: _outlet,
            onOutletChanged: (v) => setState(() => _outlet = v),
            actionIcon: Icons.notifications_none_rounded,
            onAction: () => _open('Notifikasi'),
          ),
          const SizedBox(height: 18),
          const PageTitle('PENGATURAN',
              subtitle: 'Kelola sistem sesuai kebutuhan usaha Anda'),
          const SizedBox(height: 18),
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
          radius: 18,
          padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, color: data.fg, size: 24),
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
                          style: ts(11, w: FontWeight.w600, h: 1.3)),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child:
                          Text(data.sub, style: ts(9.5, c: kMuted, h: 1.3)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: kRed, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
