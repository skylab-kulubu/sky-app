part of 'certificates_page.dart';

abstract class CertificatesPagemodel extends State<CertificatesPage> {
  final CertificateService _certificateService = CertificateService();

  List<Certificate> listOfCert = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    final certs = await _certificateService.getCertificates();
    if (!mounted) return;
    setState(() {
      listOfCert = certs;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
