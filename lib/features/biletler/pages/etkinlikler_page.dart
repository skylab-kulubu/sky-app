import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _bgDark   = Color(0xFF070B14);
const _surface  = Color(0xFF0F1623);
const _surfaceL = Color(0xFF1A2235);
const _grey     = Color(0xFF4B5563);
const _greyL    = Color(0xFF9CA3AF);

// ── Model ─────────────────────────────────────────────────────────────────────
class Etkinlik {
  final String id;
  final String baslik;
  final String aciklama;
  final String tarih;
  final String saat;
  final String yer;
  final String formUrl;
  final Color renk1;
  final Color renk2;
  final IconData ikon;
  final bool bitti;

  const Etkinlik({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.tarih,
    required this.saat,
    required this.yer,
    required this.formUrl,
    required this.renk1,
    required this.renk2,
    required this.ikon,
    this.bitti = false,
  });
}

// ── Mock data — yarın backend'den gelir ───────────────────────────────────────
final _aktifEtkinlikler = [
  const Etkinlik(
    id: '1',
    baslik: 'Hackathon 2026',
    aciklama: '48 saat boyunca kodla, tasarla ve sun. Kazananlar için ödül havuzu 50.000₺. Takımını kur, yerini ayırt!',
    tarih: '16 Şubat 2026',
    saat: '10:00',
    yer: 'Tarihi Hamam, Beyoğlu',
    formUrl: 'https://forms.gle/your-form-id',
    renk1: Color(0xFF6366F1),
    renk2: Color(0xFF4F46E5),
    ikon: Icons.code_rounded,
  ),
  const Etkinlik(
    id: '2',
    baslik: 'Flutter Summit',
    aciklama: 'Türkiye\'nin en büyük Flutter buluşması. Workshop\'lar, konuşmalar ve networking fırsatları seni bekliyor.',
    tarih: '20 Mart 2026',
    saat: '14:00',
    yer: 'Zorlu PSM, Beşiktaş',
    formUrl: 'https://forms.gle/your-form-id-2',
    renk1: Color(0xFF0EA5E9),
    renk2: Color(0xFF0284C7),
    ikon: Icons.flutter_dash_rounded,
  ),
  const Etkinlik(
    id: '3',
    baslik: 'AI Zirvesi 2026',
    aciklama: 'Yapay zekanın bugünü ve yarını. Sektörün öncüleriyle panel, sunum ve interaktif demo alanı.',
    tarih: '5 Nisan 2026',
    saat: '09:00',
    yer: 'İTÜ ARI Teknokent',
    formUrl: 'https://forms.gle/your-form-id-3',
    renk1: Color(0xFF10B981),
    renk2: Color(0xFF059669),
    ikon: Icons.auto_awesome_rounded,
  ),
];

final _gecmisEtkinlikler = [
  const Etkinlik(
    id: '4',
    baslik: 'UX Design Meetup',
    aciklama: 'Kullanıcı deneyimi tasarımının incelikleri ve güncel trendler üzerine kapsamlı bir buluşma.',
    tarih: '1 Şubat 2026',
    saat: '19:00',
    yer: 'Kolektif House',
    formUrl: '',
    renk1: Color(0xFF6B7280),
    renk2: Color(0xFF4B5563),
    ikon: Icons.design_services_rounded,
    bitti: true,
  ),
  const Etkinlik(
    id: '5',
    baslik: 'Startup Demo Day',
    aciklama: '20 startup 3 dakikada fikirlerini anlattı. Yatırımcılar seçimini yaptı, kazananlar belli oldu.',
    tarih: '10 Ocak 2026',
    saat: '13:00',
    yer: 'Galata Kulesi Meydanı',
    formUrl: '',
    renk1: Color(0xFF6B7280),
    renk2: Color(0xFF4B5563),
    ikon: Icons.rocket_launch_rounded,
    bitti: true,
  ),
];

// ── Sayfa ─────────────────────────────────────────────────────────────────────
class EtkinliklerPage extends StatefulWidget {
  const EtkinliklerPage({super.key});

  @override
  State<EtkinliklerPage> createState() => _EtkinliklerPageState();
}

class _EtkinliklerPageState extends State<EtkinliklerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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
        title: const Text('Etkinlikler',
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
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
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
      body: TabBarView(
        controller: _tab,
        children: [
          _EtkinlikListesi(etkinlikler: _aktifEtkinlikler),
          _EtkinlikListesi(etkinlikler: _gecmisEtkinlikler),
        ],
      ),
    );
  }
}

class _EtkinlikListesi extends StatelessWidget {
  const _EtkinlikListesi({required this.etkinlikler});
  final List<Etkinlik> etkinlikler;

  @override
  Widget build(BuildContext context) {
    if (etkinlikler.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_busy_rounded, size: 56,
              color: _grey.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          const Text('Etkinlik bulunamadı',
              style: TextStyle(color: _greyL, fontSize: 14, fontFamily: 'Poppins')),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: etkinlikler.length,
      itemBuilder: (_, i) => _EtkinlikKarti(etkinlik: etkinlikler[i]),
    );
  }
}

class _EtkinlikKarti extends StatelessWidget {
  const _EtkinlikKarti({required this.etkinlik});
  final Etkinlik etkinlik;

  Future<void> _kayitOl() async {
    final uri = Uri.parse(etkinlik.formUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bitti = etkinlik.bitti;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: bitti
            ? null
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [etkinlik.renk1, etkinlik.renk2],
        ),
        color: bitti ? _surface : null,
        borderRadius: BorderRadius.circular(20),
        border: bitti ? Border.all(color: _surfaceL) : null,
        boxShadow: bitti
            ? null
            : [
          BoxShadow(
            color: etkinlik.renk1.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık + ikon
            Row(children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: bitti
                      ? _surfaceL
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(etkinlik.ikon,
                    color: bitti ? _greyL : Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(etkinlik.baslik,
                        style: TextStyle(
                            color: bitti
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.location_on_rounded,
                          size: 11,
                          color: bitti ? _grey : Colors.white70),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(etkinlik.yer,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: bitti ? _grey : Colors.white70,
                                fontSize: 11,
                                fontFamily: 'Poppins')),
                      ),
                    ]),
                  ],
                ),
              ),
              if (bitti)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _surfaceL,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Bitti',
                      style: TextStyle(color: _greyL, fontSize: 11,
                          fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ),
            ]),

            const SizedBox(height: 12),

            // Açıklama
            Text(etkinlik.aciklama,
                style: TextStyle(
                    color: bitti
                        ? _greyL
                        : Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    height: 1.55)),

            const SizedBox(height: 14),

            // Tarih + saat
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bitti
                      ? _surfaceL
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 11,
                      color: bitti ? _greyL : Colors.white),
                  const SizedBox(width: 5),
                  Text('${etkinlik.tarih}  ·  ${etkinlik.saat}',
                      style: TextStyle(
                          color: bitti ? _greyL : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins')),
                ]),
              ),
            ]),

            // Kayıt ol butonu (sadece aktif)
            if (!bitti) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _kayitOl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: etkinlik.renk1,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Hemen Kayıt Ol  →',
                      style: TextStyle(
                          color: etkinlik.renk1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}