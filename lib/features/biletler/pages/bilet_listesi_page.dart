import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sky_app/features/biletler/models/bilet.dart';
import 'package:sky_app/features/biletler/services/bilet_service.dart';

const _blue     = Color(0xFF3B82F6);
const _blueDark = Color(0xFF1E3A8A);
const _bgDark   = Color(0xFF070B14);
const _surface  = Color(0xFF0F1623);
const _surfaceL = Color(0xFF1A2235);
const _grey     = Color(0xFF4B5563);
const _greyL    = Color(0xFF9CA3AF);

class BiletListesiPage extends StatefulWidget {
  const BiletListesiPage({super.key});

  @override
  State<BiletListesiPage> createState() => _BiletListesiPageState();
}

class _BiletListesiPageState extends State<BiletListesiPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<Bilet> _aktif = [];
  List<Bilet> _gecmis = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await BiletService.getBiletler();
      setState(() {
        _aktif  = all.where((b) => b.status == BiletStatus.active).toList();
        _gecmis = all.where((b) => b.status == BiletStatus.past).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Biletlerim',
            style: TextStyle(color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: _surfaceL, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_blue, _blueDark]),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: _greyL,
                labelStyle: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 12, fontFamily: 'Poppins'),
                tabs: const [Tab(text: 'Aktif'), Tab(text: 'Geçmiş')],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _load)
          : TabBarView(
        controller: _tab,
        children: [
          _AktifListe(biletler: _aktif),
          _GecmisListe(biletler: _gecmis),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AKTİF LİSTE
// ─────────────────────────────────────────────────────────────────────────────
class _AktifListe extends StatelessWidget {
  const _AktifListe({required this.biletler});
  final List<Bilet> biletler;

  @override
  Widget build(BuildContext context) {
    if (biletler.isEmpty) {
      return const _EmptyView(
          icon: Icons.confirmation_number_outlined,
          message: 'Aktif biletiniz bulunmuyor');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: biletler.length,
      itemBuilder: (_, i) => _AktifBiletKarti(bilet: biletler[i]),
    );
  }
}

class _AktifBiletKarti extends StatelessWidget {
  const _AktifBiletKarti({required this.bilet});
  final Bilet bilet;

  void _showQrPopup(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => _QrPopup(bilet: bilet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Mavi başlık
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.circle, size: 6, color: Color(0xFF4ADE80)),
                      SizedBox(width: 5),
                      Text('Aktif Bilet',
                          style: TextStyle(color: Colors.white, fontSize: 9,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins')),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  Text(bilet.etkinlikAdi,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 20, fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins', height: 1.2)),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(bilet.yer,
                        style: const TextStyle(color: Colors.white70,
                            fontSize: 11, fontFamily: 'Poppins')),
                  ]),
                ],
              ),
            ),

            // ── Yırtma çizgisi
            _TearLine(),

            // ── Bilgiler + QR
            Container(
              color: _surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoBlock(label: 'TARİH', value: bilet.tarih),
                        const SizedBox(height: 12),
                        _InfoBlock(label: 'SAAT', value: bilet.saat),
                        const SizedBox(height: 12),
                        _InfoBlock(label: 'BİLET NO',
                            value: bilet.biletKodu, small: true),
                      ],
                    ),
                  ),
                  Container(
                    width: 1, height: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: _surfaceL,
                  ),
                  // QR — tıkla büyüt
                  GestureDetector(
                    onTap: () => _showQrPopup(context),
                    child: Stack(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: _blue.withValues(alpha: 0.2),
                                blurRadius: 12),
                          ],
                        ),
                        child: QrImageView(
                          data: bilet.qrData,
                          version: QrVersions.auto,
                          size: 96,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: 4, top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: _blue,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.zoom_out_map_rounded,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            // ── Ad soyad
            Container(
              width: double.infinity,
              color: _surfaceL,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 9),
              child: Row(children: [
                const Icon(Icons.person_rounded, size: 13, color: _greyL),
                const SizedBox(width: 6),
                Text(bilet.adSoyad,
                    style: const TextStyle(color: _greyL, fontSize: 12,
                        fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  GEÇMİŞ LİSTE
// ─────────────────────────────────────────────────────────────────────────────
class _GecmisListe extends StatelessWidget {
  const _GecmisListe({required this.biletler});
  final List<Bilet> biletler;

  @override
  Widget build(BuildContext context) {
    if (biletler.isEmpty) {
      return const _EmptyView(
          icon: Icons.history_rounded,
          message: 'Geçmiş biletiniz bulunmuyor');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: biletler.length,
      itemBuilder: (_, i) => _GecmisBiletKarti(bilet: biletler[i]),
    );
  }
}

class _GecmisBiletKarti extends StatelessWidget {
  const _GecmisBiletKarti({required this.bilet});
  final Bilet bilet;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _surfaceL),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bilet.etkinlikAdi,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 15, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: _grey),
                      const SizedBox(width: 3),
                      Text(bilet.yer,
                          style: const TextStyle(color: _grey,
                              fontSize: 11, fontFamily: 'Poppins')),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: _grey),
                      const SizedBox(width: 3),
                      Text('${bilet.tarih}  ·  ${bilet.saat}',
                          style: const TextStyle(color: _grey,
                              fontSize: 11, fontFamily: 'Poppins')),
                    ]),
                  ]),
            ),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: _surfaceL, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  size: 16, color: _greyL),
            ),
          ]),
        ),
        Positioned(
          top: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: _grey,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(10)),
            ),
            child: const Text('Tamamlandı',
                style: TextStyle(color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  QR POPUP
// ─────────────────────────────────────────────────────────────────────────────
class _QrPopup extends StatelessWidget {
  const _QrPopup({required this.bilet});
  final Bilet bilet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _surfaceL),
            boxShadow: [
              BoxShadow(
                  color: _blue.withValues(alpha: 0.25), blurRadius: 40),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bilet.etkinlikAdi,
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins')),
                            Text(bilet.yer,
                                style: const TextStyle(color: _greyL,
                                    fontSize: 11, fontFamily: 'Poppins')),
                          ]),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: _surfaceL, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded,
                            color: _greyL, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: QrImageView(
                    data: bilet.qrData,
                    version: QrVersions.auto,
                    size: MediaQuery.of(context).size.width - 140,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(bilet.biletKodu,
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, fontFamily: 'Poppins',
                      letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('${bilet.tarih}  ·  ${bilet.saat}',
                  style: const TextStyle(color: _greyL,
                      fontSize: 12, fontFamily: 'Poppins')),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: _surfaceL,
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_rounded,
                          size: 14, color: _greyL),
                      const SizedBox(width: 6),
                      Text(bilet.adSoyad,
                          style: const TextStyle(color: _greyL, fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins')),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  YARDIMCILAR
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBlock extends StatelessWidget {
  const _InfoBlock(
      {required this.label, required this.value, this.small = false});
  final String label, value;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(color: _greyL, fontSize: 9,
              letterSpacing: 1.5, fontFamily: 'Poppins')),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              color: Colors.white,
              fontSize: small ? 12 : 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins')),
    ]);
  }
}

class _TearLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      child: Row(children: [
        Container(
          width: 12, height: 22,
          decoration: const BoxDecoration(
            color: _bgDark,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(11),
                bottomRight: Radius.circular(11)),
          ),
        ),
        Expanded(
          child: LayoutBuilder(builder: (_, c) {
            return Row(
              children: List.generate(
                (c.maxWidth / 10).floor(),
                    (_) => Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: _surfaceL,
                  ),
                ),
              ),
            );
          }),
        ),
        Container(
          width: 12, height: 22,
          decoration: const BoxDecoration(
            color: _bgDark,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11)),
          ),
        ),
      ]),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: _grey.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text(message,
            style: const TextStyle(
                color: _greyL, fontSize: 14, fontFamily: 'Poppins')),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _greyL, fontFamily: 'Poppins')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: _blue),
          child: const Text('Tekrar Dene'),
        ),
      ]),
    );
  }
}