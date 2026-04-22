
part of "cert_page.dart";

abstract class CertPagemodel extends State<CertPage> {

  final List<Certificate> listOfCert = [
    Certificate(
      title: "Flutter Bootcamp 2025",
      subtitle: "SKY LAB × MOBİLAb · Ocak 2025",
    ),
    Certificate(
      title: "Yapay Zeka Temelleri",
      subtitle: "SKY LAB × AIR LAB · Mart 2025",
    ),
    Certificate(
      title: "Siber Güvenlik 101",
      subtitle: "SKY LAB × SKY-SEC · Nisan 2025",
    ),
    Certificate(
      title: "Web Geliştirme Eğitimi",
      subtitle: "SKY LAB × WEBLAB · Şubat 2025",
    ),
    Certificate(
      title: "Algoritma Kampı",
      subtitle: "SKY LAB × ALGOLAB · Aralık 2024",
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
