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

  /// Son yüklemenin hatası; yenileme hatası eldeki listeyi silmiyor.
  ApiException? get error => _error;

  Team? teamBySlug(String slug) {
    for (final team in _teams) {
      if (team.slug == slug) return team;
    }
    return null;
  }

  /// Kullanıcının carousel'deki ekipleri; [groupNames] `User.teams`.
  List<Team> teamsOf(Iterable<String> groupNames) {
    final names = groupNames.toSet();
    return [
      for (final team in _teams)
        if (names.contains(team.key)) team,
    ];
  }

  int _myTeamRequests = 0;

  /// "Ekibime git" basılma sayısı: buton shell'de, carousel sayfada. Bayrak
  /// değil sayaç, art arda basışların her biri ayrı istek.
  int get myTeamRequests => _myTeamRequests;

  void requestMyTeam() {
    _myTeamRequests++;
    notifyListeners();
  }

  /// Kaydedilen ekibi listede günceller; carousel ve açık detay yeni istek
  /// atmadan yeni hâli gösteriyor.
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
      // `finally`: beklenmedik hata da yükleme bayrağını kapatsın, yoksa sayfa bir
      // daha yenilenemezdi.
      _error = error;
      _isLoading = false;
      _isInitialized = true;
      _inFlight = null;
      notifyListeners();
    }
  }
}
