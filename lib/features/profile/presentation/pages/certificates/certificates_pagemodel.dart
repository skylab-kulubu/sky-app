part of 'certificates_page.dart';

abstract class CertificatesPagemodel extends State<CertificatesPage> {
  final CertificateService _certificateService = CertificateService();

  List<Certificate> certificates = const [];
  ApiException? error;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    try {
      final result = await _certificateService.getCertificates();
      if (!mounted) return;
      setState(() {
        certificates = result;
        error = null;
        isLoading = false;
      });
    } catch (e) {
      final apiError = ApiException.from(e);
      log('Sertifikalar alınamadı: $apiError');
      if (!mounted) return;
      setState(() {
        error = apiError;
        isLoading = false;
      });
    }
  }

  Future<void> onRetry() async {
    setState(() => isLoading = true);
    await _fetchCertificates();
  }

  /// Aşağı çekerek yenileme; gösterge istek bitene kadar dönüyor.
  Future<void> onRefresh() => _fetchCertificates();

  /// İşlemleri gösterir: PDF'i aç (yalnızca geçerli), doğrula, paylaş.
  Future<void> onCertificateTap(Certificate certificate) async {
    final action = await CertificateActionsSheet.show(context, certificate);
    if (action == null || !mounted) return;

    switch (action) {
      case CertificateAction.openPdf:
        _open(certificate.pdfUrl, certificate.eventName);
      case CertificateAction.verify:
        _open(certificate.verifyUrl, 'Sertifika Doğrulama');
      case CertificateAction.share:
        final url = certificate.shareUrl;
        if (url == null) return;
        await SharePlus.instance.share(
          ShareParams(
            title: certificate.shareTitle,
            subject: certificate.shareTitle,
            text: [
              certificate.shareText,
              url,
            ].where((p) => p.isNotEmpty).join('\n'),
          ),
        );
    }
  }

  /// Adresler core'dan olduğu gibi (yalnızca https) açılıyor; kulüp siteleri
  /// gibi tarayıcı sayfasında.
  void _open(String? url, String title) {
    if (url == null) return;
    WebviewService.openLink(
      context,
      LinkItem(
        name: title,
        description: 'Sertifika',
        icon: AppIcons.certificate,
        color: AppColors.blue,
        url: url,
      ),
    );
  }
}
