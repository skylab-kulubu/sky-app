part of 'team_detail_page.dart';

abstract class TeamDetailPagemodel extends State<TeamDetailPage> {
  final ScrollController scrollController = ScrollController();
  final TeamService _teamService = TeamService();

  /// Ekibin herkese açık üyeleri; ekip herkese açık değilse boş kalıyor.
  List<TeamMember> members = const [];

  /// Provider'daki güncel hâl; düzenleme kaydedilince sayfa kendiliğinden
  /// yenileniyor. Listede yoksa (yenileme sırasında) açılıştaki hâl.
  Team get team =>
      context.watch<TeamProvider>().teamBySlug(widget.team.slug) ?? widget.team;

  /// Kullanıcı bu ekibin lideri mi; düzenleme butonu yalnızca liderlere.
  bool get canEdit =>
      context.watch<UserProvider>().user?.isTeamLeader(widget.team.key) ??
      false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMembers());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final result = await _teamService.fetchMembers(widget.team.key);
    if (!mounted || result.isEmpty) return;
    setState(() => members = result);
  }

  void onEditPressed() => TeamEditPage.open(context, widget.team.slug);

  /// Başvuru formu, kısa link üzerinden (`skyl.app/<ekip>`).
  void onJoinPressed() {
    WebviewService.openLink(
      context,
      LinkItem(
        name: widget.team.name,
        description: '',
        icon: AppIcons.users2,
        color: context.accentColor,
        url: widget.team.applyUrl,
      ),
    );
  }

  void onMemberTap(TeamMember member) {
    WebviewService.openLink(
      context,
      LinkItem(
        name: member.name,
        description: '',
        icon: AppIcons.linkedin,
        color: context.accentColor,
        url: member.linkedinUrl,
      ),
    );
  }
}
