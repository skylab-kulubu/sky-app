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

  /// Sertifikanın PDF'ini kulüp siteleri gibi tarayıcı sayfasında açar.
  void onCertificateTap(Certificate certificate) {
    if (certificate.pdfUrl.isEmpty) return;
    WebviewService.openLink(
      context,
      LinkItem(
        name: certificate.eventName,
        description: 'Sertifika',
        icon: AppIcons.certificate,
        color: AppColors.blue,
        url: certificate.pdfUrl,
      ),
    );
  }
}
