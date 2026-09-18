import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/team/data/models/team.dart';
import 'package:sky_app/features/team/data/models/team_member.dart';

class TeamService {
  final Dio _dio = ApiClient.instance.dio;

  /// CMS en fazla 100 kayıt döndürüyor; kulüpte ekip sayısı bunun çok
  /// altında, sayfalama gerekmiyor.
  static const int _pageLimit = 100;

  /// SkyCMS'teki ekipler. Giriş gerektirmiyor.
  ///
  /// Koleksiyon adı büyük harfle başlamalı (`Teams`); küçük harfle CMS 400
  /// dönüyor. Yanıt zarfsız: `{items, total, offset, limit}`.
  Future<List<Team>> fetchTeams() async {
    final body = await _getJson(
      '/api/cms/collections/Teams',
      query: {'limit': _pageLimit},
    );

    final items = body['items'];
    if (items is! List) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Yanıtta ekip listesi yok',
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(Team.fromJson)
        .where((team) => team.slug.isNotEmpty)
        .toList(growable: false);
  }

  /// Tek ekip, düzenleme için taze hâliyle.
  ///
  /// Liste yanıtı herkese 60 sn önbelleğe alınabiliyor; düzenlemeye eski
  /// sürümle başlanırsa kayıt 409 alır. Token'la yapılan istek CMS'te
  /// önbelleğe alınmıyor.
  Future<Team> fetchTeam(String slug) async {
    final body = await _getJson('/api/cms/collections/Teams/$slug');
    return Team.fromJson(body);
  }

  /// Ekibi CMS'e kaydeder ve kaydedilmiş hâlini (yeni sürümüyle) döner.
  ///
  /// Yetki CMS'te: token'ın `skyapp` client'ında `cms:access` rolü olmalı ve
  /// kullanıcı ekibin `LIDERLER` grubunda bulunmalı. Hatalar [ApiException] olarak fırlıyor;
  /// `statusCode` 409 ise kayıt arada başkası tarafından değiştirilmiş.
  Future<Team> updateTeam(Team team) async {
    final Response<dynamic> response;
    try {
      response = await _dio.put<dynamic>(
        '/api/cms/collections/Teams/${team.slug}',
        data: {'data': team.toCmsData(), 'version': team.version},
      );
    } catch (e) {
      throw ApiException.from(e);
    }

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Beklenmeyen yanıt gövdesi',
      );
    }
    return Team.fromJson(body);
  }

  /// Ekibin herkese açık üyeleri, liderler önce (core
  /// `/v1/teams/{team}/members`).
  ///
  /// Hata fırlatmıyor, boş liste dönüyor: üyeler detay sayfasında isteğe
  /// bağlı bir bölüm. Ekip Keycloak'ta herkese açık değilse
  /// (`public_listing`) core 404 dönüyor; bu bir arıza değil, bölüm
  /// görünmüyor.
  Future<List<TeamMember>> fetchMembers(String teamKey) async {
    try {
      final body = CoreApi.object(
        await CoreApi.get('/teams/$teamKey/members'),
        what: 'ekip üyeleri',
      );
      final members = body['members'];
      if (members is! List) return const [];

      return members
          .whereType<Map<String, dynamic>>()
          .map(TeamMember.fromJson)
          .where((member) => member.name.isNotEmpty)
          .toList()
        ..sort((a, b) {
          if (a.isLeader == b.isLeader) return 0;
          return a.isLeader ? -1 : 1;
        });
    } on ApiException catch (e) {
      // 404 beklenen durum (ekip herkese açık değil); loglanmıyor ki gerçek
      // hatalar arasında gürültü olmasın.
      if (e.type != ApiErrorType.notFound) {
        log('Ekip üyeleri alınamadı ($teamKey): $e');
      }
      return const [];
    }
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path, queryParameters: query);
    } catch (e) {
      throw ApiException.from(e);
    }

    dynamic body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        throw const ApiException(
          ApiErrorType.server,
          message: 'Yanıt çözümlenemedi',
        );
      }
    }

    if (body is! Map<String, dynamic>) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Beklenmeyen yanıt gövdesi',
      );
    }
    return body;
  }
}
