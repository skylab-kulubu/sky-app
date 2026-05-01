import 'package:flutter/material.dart';
import 'package:sky_app/features/biletler/pages/etkinlikler_page.dart';
import 'package:sky_app/features/biletler/pages/bilet_listesi_page.dart';
import 'package:sky_app/features/qr/presentation/pages/qr_page.dart';

const _bgDark = Color(0xFF070B14);

class BiletlerPage extends StatelessWidget {
  const BiletlerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          child: Column(
            children: [
              _AnaKart(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EtkinliklerPage())),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
                ikon: Icons.bolt_rounded,
                baslik: 'Güncel Etkinlikler',
                aciklama: 'Hackathon, zirve, meetup...\nYeteneklerini sahneye koy.',
                butonYazi: 'Keşfet & Kayıt Ol  →',
                butonYaziRenk: const Color(0xFF4F46E5),
              ),
              const SizedBox(height: 14),
              _AnaKart(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BiletListesiPage())),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                ),
                ikon: Icons.confirmation_number_rounded,
                baslik: 'Biletlerim',
                aciklama: 'Aktif biletlerin ve geçmiş\netkinliklerin burada.',
                butonYazi: 'Biletlere Git  →',
                butonYaziRenk: const Color(0xFF0284C7),
              ),
              const SizedBox(height: 14),
              _AnaKart(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const _QrSayfa())),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                ikon: Icons.qr_code_scanner_rounded,
                baslik: 'QR Tara',
                aciklama: 'Etkinliğe geldin mi?\nQR kodunu tara, yoklamayı al.',
                butonYazi: 'Kamerayı Aç  →',
                butonYaziRenk: const Color(0xFF059669),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnaKart extends StatelessWidget {
  const _AnaKart({
    required this.onTap,
    required this.gradient,
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.butonYazi,
    required this.butonYaziRenk,
  });

  final VoidCallback onTap;
  final LinearGradient gradient;
  final IconData ikon;
  final String baslik;
  final String aciklama;
  final String butonYazi;
  final Color butonYaziRenk;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(ikon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(baslik,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins')),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(aciklama,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13, fontFamily: 'Poppins', height: 1.5)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(butonYazi,
                        style: TextStyle(
                            color: butonYaziRenk, fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(ikon, size: 70,
                color: Colors.white.withValues(alpha: 0.1)),
          ],
        ),
      ),
    );
  }
}

class _QrSayfa extends StatelessWidget {
  const _QrSayfa();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('QR Tara',
            style: TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      ),
      body: const QrPage(),
    );
  }
}