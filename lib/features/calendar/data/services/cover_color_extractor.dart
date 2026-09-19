import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter/painting.dart' show HSLColor;

/// Kapak görselinden zemin renklerini seçer.
///
/// `palette_generator_master` pikselleri yuvarlayıp en sık görülen birkaç
/// tonu alıyordu; fotoğraflarda renk onlarca yakın tona dağıldığı için
/// yeşil, kahve gibi asıl renkler listeye giremiyor, zemin gölge siyahı ve
/// gökyüzü beyazından griye dönüyordu. Burada benzer tonlar önce
/// kümeleniyor (k-means), sonra kümeler büyüklükleri **ve** doygunluklarıyla
/// puanlanıyor: fotoğrafa yayılmış renkli bölgeler öne çıkıyor, siyah-beyaz
/// uçlar ancak başka renk yoksa kullanılıyor.
///
/// Saf Dart; ~120 piksel genişliğindeki bir görselde milisaniyeler sürüyor.
class CoverColorExtractor {
  CoverColorExtractor._();

  /// Küme sayısı. Az olursa farklı renkler birleşiyor, çok olursa aynı ton
  /// bölünüyor.
  static const int _clusters = 12;
  static const int _iterations = 12;

  /// Seçilen iki renk arasındaki en küçük RGB uzaklığı; daha yakınları aynı
  /// renk sayılıp atlanıyor.
  static const double _minDistance = 40;

  /// [rgba] ham RGBA baytları (`ImageByteFormat.rawRgba`). En fazla
  /// [maxColors] renk döner; ilk renk zeminin ana tonu.
  static List<Color> extract(ByteData rgba, {int maxColors = 5}) {
    final bins = _histogram(rgba);
    if (bins.isEmpty) return const [];

    final clusters = _kMeans(bins);
    if (clusters.isEmpty) return const [];

    clusters.sort((a, b) => b.score.compareTo(a.score));

    // Siyah-beyaz uçlar zeminde gri bir sis bırakıyor; en az iki renkli
    // küme varsa hiç kullanılmıyor.
    final colorful = clusters.where((c) => !c.isExtreme).toList();
    final candidates = colorful.length >= 2 ? colorful : clusters;

    // Uzaklık zemine uyarlanmış renkler arasında ölçülüyor: canlandırma iki
    // yakın kahveyi aynı renge çekebiliyor.
    final picked = <Color>[];
    for (final cluster in candidates) {
      if (picked.length >= maxColors) break;
      final color = _forBackdrop(cluster.toColor());
      if (picked.every((p) => _distance(p, color) >= _minDistance)) {
        picked.add(color);
      }
    }
    return picked;
  }

  static double _distance(Color a, Color b) {
    final dr = (a.r - b.r) * 255;
    final dg = (a.g - b.g) * 255;
    final db = (a.b - b.b) * 255;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  /// Rengi koyu zemin üstünde parlayacak hâle getirir: ton aynı kalıyor,
  /// açıklık orta banda çekiliyor, soluk renklere biraz doygunluk ekleniyor.
  /// Fotoğraftaki kahve ya da haki, zeminde çamur gibi değil sıcak bir ışık
  /// olarak görünsün diye.
  static Color _forBackdrop(Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.saturation < 0.08) {
      // Gerçekten renksizse (gri) doygunluk uydurulmuyor.
      return hsl.withLightness(hsl.lightness.clamp(0.3, 0.55)).toColor();
    }
    return hsl
        .withSaturation(hsl.saturation.clamp(0.45, 0.9))
        .withLightness(hsl.lightness.clamp(0.36, 0.56))
        .toColor();
  }

  /// Pikselleri kanal başına 32 seviyede sayar; aynı kutudakilerin
  /// ortalaması o kutunun rengi. Kümeleme piksel yerine kutular üzerinden
  /// yapılıyor, iş yükü birkaç bin öğeye iniyor.
  static List<_Point> _histogram(ByteData rgba) {
    final sums = <int, _Point>{};
    for (var i = 0; i + 3 < rgba.lengthInBytes; i += 4) {
      if (rgba.getUint8(i + 3) < 128) continue;
      final r = rgba.getUint8(i);
      final g = rgba.getUint8(i + 1);
      final b = rgba.getUint8(i + 2);
      final key = (r >> 3) << 10 | (g >> 3) << 5 | (b >> 3);
      final point = sums[key] ??= _Point(0, 0, 0, 0);
      point
        ..r += r
        ..g += g
        ..b += b
        ..weight += 1;
    }
    return [
      for (final p in sums.values)
        _Point(p.r / p.weight, p.g / p.weight, p.b / p.weight, p.weight),
    ];
  }

  static List<_Cluster> _kMeans(List<_Point> points) {
    final centers = _initialCenters(points);

    var assignment = List<int>.filled(points.length, 0);
    for (var iteration = 0; iteration < _iterations; iteration++) {
      final next = [for (final p in points) _nearest(p, centers)];
      final sums = List.generate(centers.length, (_) => _Point(0, 0, 0, 0));
      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        sums[next[i]]
          ..r += p.r * p.weight
          ..g += p.g * p.weight
          ..b += p.b * p.weight
          ..weight += p.weight;
      }
      for (var c = 0; c < centers.length; c++) {
        final s = sums[c];
        if (s.weight == 0) continue;
        centers[c] = _Point(s.r / s.weight, s.g / s.weight, s.b / s.weight, 0);
      }
      final converged = _sameAssignment(assignment, next);
      assignment = next;
      if (converged && iteration > 0) break;
    }

    final totals = List<double>.filled(centers.length, 0);
    for (var i = 0; i < points.length; i++) {
      totals[assignment[i]] += points[i].weight;
    }
    final all = totals.fold<double>(0, (a, b) => a + b);

    return [
      for (var c = 0; c < centers.length; c++)
        if (totals[c] > 0)
          _Cluster(centers[c].r, centers[c].g, centers[c].b, totals[c] / all),
    ];
  }

  /// Başlangıç merkezleri: en kalabalık kutu, ardından her seferinde
  /// seçilmişlere en uzak kalabalık kutu (k-means++'ın rastgelesiz hâli;
  /// aynı görsel hep aynı renkleri veriyor).
  static List<_Point> _initialCenters(List<_Point> points) {
    final sorted = [...points]..sort((a, b) => b.weight.compareTo(a.weight));
    final centers = <_Point>[sorted.first];
    while (centers.length < _clusters && centers.length < sorted.length) {
      _Point? best;
      var bestScore = -1.0;
      for (final p in sorted) {
        final d = centers.map(p.distanceTo).reduce(math.min);
        final score = d * d * math.sqrt(p.weight);
        if (score > bestScore) {
          bestScore = score;
          best = p;
        }
      }
      if (best == null || bestScore <= 0) break;
      centers.add(best);
    }
    return [for (final c in centers) _Point(c.r, c.g, c.b, 0)];
  }

  static int _nearest(_Point p, List<_Point> centers) {
    var index = 0;
    var best = double.infinity;
    for (var c = 0; c < centers.length; c++) {
      final d = p.distanceTo(centers[c]);
      if (d < best) {
        best = d;
        index = c;
      }
    }
    return index;
  }

  static bool _sameAssignment(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _Point {
  _Point(this.r, this.g, this.b, this.weight);

  double r;
  double g;
  double b;
  double weight;

  double distanceTo(_Point other) {
    final dr = r - other.r;
    final dg = g - other.g;
    final db = b - other.b;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }
}

class _Cluster {
  _Cluster(this.r, this.g, this.b, this.share);

  final double r;
  final double g;
  final double b;

  /// Görseldeki payı (0–1).
  final double share;

  double get _max => math.max(r, math.max(g, b)) / 255;
  double get _min => math.min(r, math.min(g, b)) / 255;

  /// HSL doygunluğu (0–1).
  double get saturation {
    final l = (_max + _min) / 2;
    if (_max == _min) return 0;
    final d = _max - _min;
    return l > 0.5 ? d / (2 - _max - _min) : d / (_max + _min);
  }

  double get lightness => (_max + _min) / 2;

  /// Neredeyse siyah ya da neredeyse beyaz.
  bool get isExtreme => lightness < 0.12 || lightness > 0.85;

  /// Zemine ne kadar yakıştığı: pay × doygunluk ağırlığı. Neredeyse siyah
  /// ve neredeyse beyaz kümeler cezalı; yalnızca başka renk yoksa öne
  /// geçiyorlar.
  double get score {
    var s = share * (0.1 + 1.5 * saturation);
    if (isExtreme) s *= 0.15;
    return s;
  }

  Color toColor() => Color.fromARGB(255, r.round(), g.round(), b.round());
}
