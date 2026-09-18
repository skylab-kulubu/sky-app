import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/data/services/team_service.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _service = TeamService();

  List<Team> _teams = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  ApiException? _error;

  /// Süren yükleme; aynı anda gelen çağrılar bunu paylaşır.
  Future<void>? _inFlight;

  List<Team> get teams => _teams;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Son yüklemenin hatası; başarılıysa null. Yenileme hatası eldeki listeyi
  /// silmiyor.
  ApiException? get error => _error;

  Team? teamBySlug(String slug) {
    for (final team in _teams) {
      if (team.slug == slug) return team;
    }
    return null;
  }

  /// Kullanıcının üyesi olduğu, carousel'de bulunan ekipler. [groupNames]
  /// `User.teams`: token'daki grup yollarından çıkan ekip adları
  /// (`MOBILAB`); lider alt grubundakiler de ekibin üyesi sayılıyor.
  List<Team> teamsOf(Iterable<String> groupNames) {
    final names = groupNames.toSet();
    return [
      for (final team in _teams)
        if (names.contains(team.key)) team,
    ];
  }

  int _myTeamRequests = 0;

  /// AppBar'daki "ekibime git" butonunun basılma sayısı. Buton shell'de,
  /// carousel sayfada; sayfa bu sayacın arttığını görünce kendi ekibine
  /// kayıyor. Sayaç (bir kerelik bayrak değil) sayesinde art arda basışların
  /// her biri ayrı bir istek.
  int get myTeamRequests => _myTeamRequests;

  void requestMyTeam() {
    _myTeamRequests++;
    notifyListeners();
  }

  /// Düzenlenip kaydedilen ekibi listede günceller; carousel ve açık detay
  /// sayfası yeniden istek atmadan yeni hâli gösteriyor.
  void replaceTeam(Team updated) {
    _teams = [
      for (final team in _teams) team.slug == updated.slug ? updated : team,
    ];
    notifyListeners();
  }

  /// Ekipler elde yoksa bir kez yükler; sayfa açılışta koşulsuz çağırabilir.
  Future<void> ensureLoaded() async {
    if (_isInitialized) return;
    await _load();
  }

  /// Elde ne olursa olsun yeniden yükler; hata ekranındaki "Tekrar Dene".
  Future<void> refresh() => _load();

  Future<void> _load() => _inFlight ??= _run();

  Future<void> _run() async {
    _isLoading = true;
    notifyListeners();

    ApiException? error;
    try {
      _teams = await _service.fetchTeams();
    } on ApiException catch (e) {
      log('Ekipler yüklenemedi: $e');
      error = e;
    } finally {
      // `finally`: beklenmedik bir hata (ör. yanıtta tip uyuşmazlığı) da
      // yükleme bayrağını kapatıyor; yoksa sayfa bir daha hiç yenilenemezdi.
      _error = error;
      _isLoading = false;
      _isInitialized = true;
      _inFlight = null;
      notifyListeners();
    }
  }
}
