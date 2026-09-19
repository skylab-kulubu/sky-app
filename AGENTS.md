# AGENTS.md

This file is for AI agents working on this project. Read it end to end before writing any code.

**`CONTRIBUTING.md` is the companion to this file and is binding for coding rules.** This file explains what the project is, how it is set up and which pitfalls exist; the folder structure, the Page/PageModel split, widget extraction and constant usage rules described there apply as written.

---

## Project

**sky-app** — the mobile app of the **SKY LAB** student club at Yıldız Technical University. Written in Flutter; targets iOS, Android and web.

The users are club member students. The app provides the membership card (SkyPass), event tracking, club news and access to the club's sub-services.

Flutter 3.47.1 (stable), Dart SDK `>=3.12.0`, Material 3. The font is set once in `theme.dart` via `fontFamily: 'Poppins'` and applies to every text scale; `textTheme` only carries an entry when it needs to say something beyond the font (such as the body text color).

---

## Communication and ways of working

**Write in Turkish.** The user writes in Turkish and expects Turkish answers. In-code comments, `///` doc comments and all user-facing strings are Turkish. Variable and class names stay English — that is the pattern of the existing codebase.

**Never commit.** Do not run `git commit` or `git push`. When a task is done, summarize the changed files and stop; the user commits themselves. This is an absolute rule.

**Visual verification is done by the user.** They are the one who runs the app, sends screenshots and asks for fixes. A clean `flutter analyze` means "it compiles", not "it looks right" — do not conflate the two. If you made a visual change, say explicitly that you did not verify it on screen and point out what to look at.

> The iOS simulator is unavailable on this machine: `xcode-select` is not pointed at Xcode and the fix requires sudo, so an agent cannot run it. It is worth trying, but if it fails, tell the user and move on.

**Design reference: Luma (lu.ma).** For UI work the user keeps sharing Luma screenshots and uses them as the benchmark. Take **patterns** from Luma, not colors — the app keeps its own theme. **Consistency** matters in particular: list items must have equal heights, typography scales must be measured.

---

## Commands

```bash
flutter analyze --no-pub     # after every change; must stay clean
flutter test                 # after every change; must stay green
dart format lib/             # before committing
flutter pub get
```

> Do not run `flutter build ios`. The iOS project is on Swift Package Manager; the build triggers CocoaPods and breaks that setup.

**Tests:** `test/` contains widget and unit tests (event provider, calendar/home pages, models, router, API errors) and CI runs format, analyze and `flutter test` on every PR. Run `flutter test` after changes and keep it green; when a page starts reading a new provider, add a fake of it to that page's test setup (see `test/helpers/`). Do not write new tests unless asked.

---

## Architecture

### Folder layout

```
lib/
├── main.dart                 # provider registrations + app entry point
├── core/                     # everything shared by more than one feature
│   ├── main_app.dart         # MaterialApp.router, themeMode, status bar style
│   ├── constants/            # AppColors, AppPaddings, AppRadiuses, AppSizes, AppAssets, AppIcons
│   ├── extensions/           # context_extensions.dart — theme colors are read from here
│   ├── models/               # link_item.dart
│   ├── pages/                # shell_page.dart (appbar + navbar shell), webview_page.dart (fallback only)
│   ├── router/               # router_manager.dart (GoRouter)
│   ├── services/             # links_service.dart, webview_service.dart
│   ├── theme/                # theme.dart (light/dark), theme_provider.dart
│   └── widgets/              # AppIcon, AppBarActions, NavItem, UserAvatar, CoverImage, BottomScrim, ColorGlow,
│                             # SkyButton, SkyTextField, SkyTagEditor, IconCircle, TileGroup, SectionHeader, SettingsTile, ClubMenuSheet ...
└── features/<name>/
    ├── data/{models,services}
    └── presentation/{pages,widgets,providers}
```

Features: `auth`, `calendar`, `home`, `notification`, `profile`, `settings`, `team`.

### State management

`provider` is used. Five global providers are registered in `main.dart`:

| Provider        | Responsibility                                                    |
| --------------- | ----------------------------------------------------------------- |
| `ThemeProvider` | `ThemeMode` (system/light/dark), persisted in `SharedPreferences` |
| `UserProvider`  | Session and `User`; through `AuthService`                         |
| `EventProvider` | Event lists; filled on splash                                     |
| `ActivityProvider` | Profile activities; keyed by user id so a new login never sees the previous user's list |
| `TeamProvider` | AR-GE teams from SkyCMS for the Team tab |

### Routing

`go_router`. A single `GoRouter` inside `router_manager.dart`. Structure:

- **Top level** (full screen, root navigator): `/`, `/auth`, `/notification`, `/webview`, `/settings` (sub-routes: `/settings/account`, `/settings/contact`)
- **`ShellRoute`** (inside the appbar + navbar shell): `/home`, `/calendar`, `/team`, `/profile`. `/profile/certificates` is nested under `/profile` but carries `parentNavigatorKey: _rootNavigatorKey`, so it opens full screen.

`redirect` routes between `/`, `/auth` and `/home` depending on session state.

**Deep links:** shared links are `https://app.yildizskylab.com/news/<slug>` and `/events/<id>` (`LinksService.newsLink/eventLink`). `RouterManager._redirect` rewrites them to nested routes `/home/news/:slug` and `/calendar/events/:id` (root navigator, so back returns to the tab) and stores the target while splash/auth runs, then goes there instead of `/home`. `ContentLinkPage` loads the single item (`NewsService.fetchNewsItem`, `EventService.fetchEvent`) with loading / not-found states. Verification files live in `web/.well-known/` (copied into `build/web` by `flutter build web`) with content types in `web/_headers` (Cloudflare Pages). `assetlinks.json` currently holds only the **debug** keystore SHA-256 — add the release/Play signing fingerprint before release; `apple-app-site-association` has a `TEAM_ID` placeholder. iOS entitlement `applinks:app.yildizskylab.com` requires Associated Domains on the Apple account that signs the app.

> ⚠️ **If you open something full screen while inside the shell**, put the route at top level or pass `parentNavigatorKey: _rootNavigatorKey`. Otherwise the page stays underneath the navbar. The same pitfall applies to `OpenContainer`: without `useRootNavigator: true` the detail page opens inside the shell.

### Backend

- **Main API: core-backend (Go), `https://api.yildizskylab.com/v1/...`.** Every core call goes through `CoreApi` (`core/services/core_api.dart`): it adds the `/v1` prefix, returns the decoded body (no envelope — objects/arrays directly; 201 on create, 204 with no body on delete) and turns errors into `ApiException`. Errors are `application/problem+json`; `ApiException.serverMessage` carries its `detail`/`title` for logs, users see the Turkish `userMessage`. Use `CoreApi.object()` / `CoreApi.list()` to validate the body shape. The old Java API (`/api/events`, `/api/users` …) is gone and answers 404.
- **CMS stays at `/api/cms/collections/{News|Teams}`** (separate .NET service, not enveloped, never `/v1`). `NewsService` and `TeamService` call it with the raw Dio.
- **Dates:** core sends and expects RFC 3339 with a zone (`…Z`). Parse with `ApiDateTime.parse` (converts to local time — plain `DateTime.parse` keeps UTC and shows times 3 hours off) and send with `DateTime.toApiString()` (`core/extensions/date_time_extensions.dart`).
- **Contracts:** the core router is `core-backend/internal/httpx/server.go` in the workspace; the workspace `CLAUDE.md` has the endpoint table and the authorization rules.
- Authentication: Keycloak, `https://e.yildizskylab.com/realms/e-skylab`, OAuth/PKCE via `flutter_appauth`, public client `skyapp`. Tokens live in `flutter_secure_storage`. Core requires `aud` to contain `core`.

> **Permissions come from the JWT `groups` claim, not realm roles.** `User` derives everything from group paths such as `/UYELER/ARGE/MOBILAB/LIDERLER`: `teams` (deepest meaningful segment, hiding `UYELER`/`ARGE`/`ORGANIZASYON`/`ADMIN`), `leaderTeams` (`LIDERLER`/`KOORDINATORLER`), `isPrivileged` (`ADMIN`/`YK`/`DK`), event permissions (`eventOwnerOptions`, `canEditEvent`, `canDeleteEvent`, mirroring `core-backend/internal/authz/policy.go`). `cmsRoles` are the roles of the token's own client (`resource_access[azp]`, i.e. `skyapp`) — that is where CMS reads `cms:access`. `canManageNews` = `cms:access` **and** privileged; `canEditTeam(key)` = `cms:access` **and** leader of that team. `realmRoles` is kept only for information; do not use it for permissions.

> **Club sites log in automatically through the shared browser cookie — keep both halves in sync.** Login and logout run in `SFSafariViewController` on iOS (`AuthService._externalUserAgent`; Android always uses the default browser's Custom Tabs), and `WebviewService.openLink` opens club sites in the same browser as a sheet (`flutter_custom_tabs`). The Keycloak cookie written at login is therefore visible to the sites. Do not move links back to `webview_flutter` (separate cookie jar, no SSO), and do not change the login agent on its own: on iOS `ASWebAuthenticationSession` writes to Safari, which `SFSafariViewController` cannot read, and a logout in a different store leaves the user logged in on the sites. `WebviewPage` (`/webview`) is only the fallback when no browser can be opened.

> On logout `UserProvider.user` drops to null and pages rebuild in the same frame; the redirect to `/auth` only happens on the next frame. Pages that read the user must survive that single frame — writing `user!` blows up there (see `profile_page.dart`).

### Notable packages

| Package                    | Where                                                                                                      |
| -------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `reicon_flutter`           | All icons (through `AppIcon`)                                                                              |
| `animations`               | Only the `OpenContainer` transition of the news tile                                                       |
| `share_plus`               | Share button on the event detail — **native dependency**, hot reload is not enough when it is added        |
| `timeago`                  | Relative time in the notification list (`tr` and `tr_short` locales are registered in `main.dart`)         |
| `pretty_qr_code`           | SkyPass door QR (`SkyPassQr`); pulls in `qr` |
| `mobile_scanner`           | Door scanner camera (`DoorScannerPage`) — **native dependency**, needs camera permission |
| `flutter_nfc_kit`          | Student card scanning (`NfcService`) — **native dependency**, needs the iOS NFC entitlement                |
| `sensors_plus`             | The tilt of the SkyPass card (`TiltBuilder`)                                                               |
| `cached_network_image_ce`  | Network images (`CoverImage`)                                                                              |
| `dio`                      | All REST calls                                                                                             |
| `image_picker`             | Cover image for event create/edit — **native dependency**, iOS needs `NSPhotoLibraryUsageDescription` |
| `flutter_localizations`    | App locale is Turkish (`main_app.dart`); date/time pickers and system menus are Turkish |
| `flutter_custom_tabs`      | Club sites open in a browser sheet (`WebviewService`): Partial Custom Tabs / `SFSafariViewController` page sheet. They share the Keycloak cookie with the login, so e-skylab sites log the user in automatically — **native dependency** |

---

## Theme and color — the most critical rule

The app supports light and dark themes together. Colors are split across **two sources** and mixing them silently breaks the light theme.

**Colors that change with the theme are read from `context`** (`core/extensions/context_extensions.dart`):

`backgroundColor` · `tileColor` · `elevatedColor` · `textPrimary` · `textSecondary` · `textTertiary` · `dividerColor` · `accentColor` · `onAccentColor`

> `onAccentColor` is for content on top of an `accentColor` surface. Because the accent is light lilac in the dark theme and dark purple in the light theme, the text on top of it flips as well; `AppColors.onAccent`, which stays white in both themes, cannot be used in its place.

**Theme-independent colors stay in `AppColors`:** brand colors (`primaryColor`, `primaryStrong`, `blue`, `red`, `green` ...), content on a saturated surface (`onAccent`), SkyPass card colors, navbar shadows.

```dart
// ❌ breaks in the light theme
color: Colors.white
color: AppColors.darkTextPrimary

// ✅
color: context.textPrimary
color: AppColors.red   // brand color
```

The `dark*` / `light*` constants inside `AppColors` **only** feed the `ColorScheme`s in `theme.dart`; they are not used directly in widgets.

> **Exception — the event detail page.** `features/calendar/presentation/pages/event_detail/event_detail_page.dart` is dark in both themes: its backdrop is derived from the dominant color of the cover image (`EventPaletteService` / `CoverColorExtractor`) and that color washes out when blended into a light surface. Colors on this page are read from the `AppColors.coverBackdropBase` and `onCover*` constants instead of the `context` accessors. For the same reason `SkyButton` and `AppBarActions` skip the theme defaults when they are given explicit colors.

A color coming from `context` is not a compile-time constant, so that widget cannot be `const` — remove the `const`. This is the compile error you will hit most often while refactoring.

Shared AppBar properties (`backgroundColor`, `elevation`, `centerTitle`, `actionsPadding`, `iconTheme`, `titleTextStyle`, `systemOverlayStyle`) are centralized in `appBarTheme`; they are not repeated in pages.

---

## Icons

Material icons are **not used**. Icons come from the `reicon_flutter` package.

**Critical difference:** Reicon does not return `IconData`, it gives a raw SVG path string. So an `Icon(Icons.x)` → `Icon(Reicon...)` find-and-replace is not possible; drawing goes through `SvgPicture.string` and that work is collected in the `AppIcon` widget.

```dart
AppIcon(AppIcons.home)
AppIcon(AppIcons.home, filled: true, size: AppSizes.icon, color: context.accentColor)
```

Icon names live in `core/constants/app_icons.dart`. In widget signatures, icon fields are typed **`String`**, not `IconData`.

When adding a new icon, verify the name exists in **both the Outline and the Filled** weight; a missing name silently draws an empty box:

```bash
grep -o "^  '[a-zA-Z0-9]*':" ~/.pub-cache/hosted/pub.dev/reicon_flutter-*/lib/src/icons.dart \
  | sed "s/^  '//;s/'://" | sort -u
```

Names are camelCase: `info-square` → `infoSquare`.

**An icon Reicon does not have** (brand logos such as LinkedIn) goes into `core/constants/app_custom_icons.dart` in the same format — raw SVG content for a 24×24 `viewBox`, colored with `currentColor`. `AppIcon` falls back to that map when a name is missing from Reicon, so the icon works everywhere a `String` name is accepted. Reicon leaves a 2-unit margin inside the box; logos drawn edge to edge are wrapped in `translate(2 2) scale(0.833333)` to match its visual size.

---

## The shell: AppBar and Navbar

`core/pages/shell_page.dart` draws the shared shell of the shell routes.

**The AppBar changes per tab.** `_AppBarConfig` holds the title, action icons and logo/avatar display for each tab. Actions are collected in the `AppBarActions` pill and it grows or shrinks with the icon count as the tab changes.

Currently wired actions: **menu** (`AppIcons.widget` → `ClubMenuSheet`), **notification** (`AppIcons.bell` → `/notification`), **settings** (`/settings`) and **search** on Events. On the Teams tab the only action is "ekibime git" (`AppIcons.myTeam`), shown only when one of `User.teams` (from `groups`) matches a team in the carousel; the shell calls `TeamProvider.requestMyTeam()` and `TeamPage` scrolls to the user's next team. To wire one up, add it to `_onActionTap` in `core/pages/shell_page.dart`.

**Search on Events:** a tab gets search by setting `searchHint` in its `_AppBarConfig`. The search button opens `AppBarSearchField` in the title slot (title fades out, the box grows leftward from the button, the keyboard opens when the growth ends) and the button turns into a close button. The open state, controller and focus node live in `shell_pagemodel.dart`; the text goes to `EventProvider.setSearchQuery` and `CalendarPage` lists `searchedEvents`. Closing or leaving the tab clears the query.

**The navbar** is a floating pill; the selected tab reveals its label next to the icon. The expansion is animated with `Align.widthFactor` — since the label width depends on the text, no manual width math is done.

> If you use `AppBarActions` in the `leading` slot, wrap it in a `Center` and compute `leadingWidth` with `AppBarActions.widthFor(n)`. The slot imposes a tight height constraint, so without the wrapper the pill stretches vertically; without `leadingWidth` it gets clipped.

---

## State of the world you should know

**Waiting to be wired up:**

- The profile comes from `GET /v1/users/me` (`AuthService.getUser`): the JWT user is built first and the API object is applied on top via `mergeWith`, because the API response carries no groups/roles. If the call fails the JWT user is used as is.
- The news on the home page come from SkyCMS `News` (`NewsService`/`NewsProvider`, public read, not enveloped; slug is generated from the title and will be used for deep links #44). Users allowed by `User.canManageNews` (`cms:access` on the `skyapp` client **and** a YK/DK/ADMIN group — the CMS rule) get a FAB on the home page and an edit button on the news detail; `NewsEditPage` posts/puts to CMS. No delete (CMS has no endpoint) and no image upload — only an image URL (the CMS field is a URL). The notifications (`NotificationService`) list is empty until the backend adds notifications (issue #45).
- The profile activities (`ActivityService`) are derived from `/v1/tickets/me` (registration, or attendance if checked in — core checks in per **session**, so several check-ins read "N oturuma katıldın") and `/v1/competitors/me` (`isWinner`/score). There is no activity-history endpoint and tickets carry no registration date, so a registration is dated by the event start.
- **Certificates** (`/profile/certificates`, #46) follow core's contract `core-backend/docs/mobile-certificates-v2.md`: `GET /v1/certificates/me` returns `{id, serial, event{id,name,ownerTeam}, status, issuedAt, revokedAt?, pdfUrl?, verifyUrl, share{title,text,url}}`. Valid **and** revoked certificates are listed (revoked as history), newest first; unknown statuses render as "Belirsiz", never valid. Row: event name (2 lines), issuer (`SKY LAB` for empty/YK/DK) • date, status "Geçerli"/"İptal". Tap opens `CertificateActionsSheet`: **Sertifikayı Aç** (`pdfUrl`, valid only), **Doğrula** (`verifyUrl`, `https://skyl.app/c/{serial}` → redirects to the public page), **Paylaş** (`share_plus` with `share.title/text/url` — the verify URL, never the PDF). URLs are used as given and only if `https`; they open in the browser sheet (`WebviewService`). Errors show retry, never an empty state. No template/admin certificate endpoints are called.
- The profile quick actions: **Sertifikalarım** goes to `/profile/certificates`, **Öğrenci Kartını Eşle** checks NFC availability and opens `NfcScanOverlay` (`NfcService`, ISO 14443-A only); the read UID (`NfcCard.normalizedHex`) is bound to the account with `SkyPassService.bindCard` → `POST /v1/skypass/card-bind` (409 = card bound to another account). Core hides the UID but returns `studentCardLinked` on `/v1/users/me` (`User.studentCardLinked`); when true the SkyPass front shows a large faded YTÜ star (`AppAssets.ytuStar`, `SkyPassCard.showStudentCardMark`). Binding happens inside `NfcScanOverlay`: the card keeps pulsing while `POST /v1/skypass/card-bind` runs; on success it is pulled up, the star fades in (`AnimatedOpacity` in `SkyPassCard`), the profile is reloaded (`onLinked` → `UserProvider.reloadProfile`) and the card flies back with the star; errors (409 bound to another account, 400) are shown in the overlay. On the profile, a linked user no longer sees **Öğrenci Kartını Eşle** — the slot shows **QR Okut** (no action yet; planned session-QR attendance). The swap fades in only after the card has returned (`_isLinkRevealPending`). Unbinding: `card-bind` with an empty `uid` (no UI yet); re-binding is still possible. **QR'ı Göster** flips the SkyPass card through `SkyPassCardController` (same as tapping the card).
- The QR is on the back of the SkyPass card (tap or **QR'ı Göster** flips it). `SkyPassQr` draws the **signed door token** from `POST /v1/skypass/qr` (`SkyPassService.token`, RS256, 60 s) with `pretty_qr_code` and refreshes it 10 s before expiry; the token is cached per owner (SKY number) so flips/reopens do not mint again and a new login never sees the previous user's code. It only exists while the back face is visible (timer stops when the card turns back); the token is fetched as soon as the back face appears but the QR matrix is built only after the flip animation completes (`active`) and fades in — building the dense QR mid-flip stuttered the animation. On failure the QR box shows "Kod alınamadı" and retries on tap. The staff side is `DoorScannerPage` (below).
- Password / sessions / security settings are not in the app yet. The backend team is building an account center (planned domain `my.yildizskylab.com`); link it from the account page once it is live — do not link the raw Keycloak Account Console.
- **Hesabımı Sil** on the account page (`AccountPagemodel.onDeleteAccountTap`) is required by App Store rule 5.1.1(v). There is no delete endpoint, so after a confirm dialog it opens a prefilled mail to `info@yildizskylab.com` (name, username, e-mail, SKY number); without a mail app the address is copied. Replace it with a real call once the backend has one.
- **Door scanner** (`DoorScannerPage`, `features/calendar`): staff pick an event and a session, then scan attendees' SkyPass QR with `mobile_scanner`; each scan calls `POST /v1/sessions/{id}/check-in/skypass` (`DoorService`). The token is compact ES256 with only `sub`/`exp` (`DoorService.isSkyPassToken` checks `alg == ES256` + `sub` before sending); both QR and card go through `DoorService.checkIn` (`{token}` or `{uid}`), and the person's name is then read from the session's check-in log `GET /v1/sessions/{id}/check-ins` (`personName`, `total`; open to door staff) — `/v1/skypass/verify` and `/v1/skypass/card` are YK/DK/ADMIN-only and are not used. The session row shows the running check-in count. Results: success / 409 already checked in / 404 no ticket for this event / 401 expired code / 403 no permission; the scanner stays open and ignores the same code for 4 s. A **QR Okut / Öğrenci Kartı** switch above the scanner area changes the mode (default: **Öğrenci Kartı**, so the camera — and its permission prompt — only starts when staff switch to QR): in card mode the camera is stopped and a "Kartı Okut" button reads the student card with `NfcService` and checks in with `{uid}` on the same endpoint (404 there means either the card is not bound or the person has no ticket — core does not distinguish). The name after a card check-in also comes from the check-in log, so leaders and door staff see it too. Sessions come from `/v1/events/{id}/days` + `/v1/event-days/{id}/sessions` (cancelled ones hidden; default = the one running now). The event list comes from core `GET /v1/door/events` (events the user may check in at, including teams with `team_door_scan=true`), filtered to not-ended ones. The profile button shows when that list has an upcoming event **or** the local rule `User.canCheckIn` (YK/DK/ADMIN, leader/coordinator of `ownerTeam`, id in `doorStaffIds`) matches — the local rule answers instantly, the endpoint adds `team_door_scan` members. On the profile the third quick action becomes **Giriş Al** (door icon `AppIcons.checkIn`, opens the scanner titled "Giriş Al") when the user can scan at least one upcoming event; otherwise it stays **QR'ı Göster**.
- Camera: Android declares `CAMERA` (+ `uses-feature` camera not required); iOS `NSCameraUsageDescription` explains the SkyPass scanning. Usage descriptions in `Info.plist` are Turkish.
- The Notifications and Permissions rows in settings are hidden: push does not exist yet (#45) and no runtime permission is requested anywhere, so a permissions page would be empty (#31). `permission_handler` was removed as unused; if a permissions page or QR reader comes back, re-adding it on iOS (Swift Package Manager) needs `PERMISSION_*` build flags (see its `Package.swift`) or it reports wrong statuses. `EventProvider` does not load `/v1/events/active` (nothing read it); the check-in flow in #43 should pick the event and session explicitly.

**The `/team` tab** is a carousel of AR-GE teams (`TeamPage`). Teams come from SkyCMS (`GET /api/cms/collections/Teams` — the collection name must be capitalized, the response is not wrapped in `{data: ...}`); members come from core (`GET /v1/teams/{KEY}/members`, body `{members: [...]}` at the root; 404 unless the Keycloak group has `public_listing=true` — treated as "no members", not an error). CMS has no logo field: logos are bundled in `assets/images/teams/` (from `skylab-kulubu/skylab-assets`) and mapped by slug in `Team`. ALGOLAB and GAMELAB logos contain white parts, so the light theme uses their monochrome versions tinted with the text color. Of the recruiting fields only `recruiting` is used: when true the detail page's "Ekibe Katıl" opens the club short link `skyl.app/<slug>` (which redirects to the team's form), otherwise the button is disabled and reads "Başvurular Kapalı". CMS `applyUrl` is not used. Team leaders (member of the team's `LIDERLER`/`KOORDINATORLER` subgroup with `cms:access` on `skyapp`; `User.canEditTeam`) see an edit button on the team detail page that opens `TeamEditPage`: recruiting on/off, description, long description, topics, stack and works are saved with `PUT /api/cms/collections/Teams/{slug}` (`{data, version}`; 409 on a version conflict). CMS rejects unknown fields and requires `recruiting`, so `Team.toCmsData` sends only schema fields and carries `recruitingFor`/`applyUrl` through unchanged. Without `cms:access` on the `skyapp` client or the leader group CMS answers 401/403 and the page says the user has no permission. A per-user team panel (announcements, projects, tasks) was discussed but has no backend yet.

**Recently removed** — ask before bringing any of them back: the tickets feature, the announcement carousel, the home page shortcuts, the `qr` feature (`qr_page.dart`), the welcome text on the home page. All of them are in the git history.

**Event creation:** the Events tab shows a `+` FAB to users who may create events (`User.eventOwnerOptions`, from the JWT `groups` claim mirroring `core-backend/internal/authz/policy.go`: YK/DK/ADMIN → any team, `<TEAM>/LIDERLER|KOORDINATORLER` → that team, GECEKODU members → GECEKODU). `EventCreatePage` uploads the cover to `POST /v1/media` (`file` part), then sends `POST /v1/events` as **JSON** (`EventCreateService`, form fields in `EventDraft`, dates via `toApiString()`). The season is not part of the body: only YK/DK/ADMIN see the Sezon row, and for them the event is assigned afterwards with `POST /v1/seasons/{id}/events/{eventId}`; other users create season-less events. After creation the list refreshes and the new event's detail page opens. The same page edits an event (`EventCreatePage.edit`): users allowed by `User.canEditEvent` see a settings button left of share on the detail page. Edit sends `PUT /v1/events/{id}` — **core overwrites every field**, so fields the form does not show (`ranked`, `prizeInfo`, `attendanceRule/Ratio`, current `coverImageId`) are copied from the original `EventModel`; cover and capacity can be changed on edit. Users allowed by `User.canDeleteEvent` get a trash action (`DELETE` → 204; core cascades tickets, check-ins and certificates, the confirm dialog says so).

**Event program (days + sessions):** `ScheduleService` reads `/v1/events/{id}/days` and `/v1/event-days/{id}/sessions` (public) and creates/updates/deletes days (`/v1/event-days`) and sessions (`/v1/sessions`). Models in `event_session.dart` (`EventDay`, `EventSession`, `ScheduleDay`); core requires a session `title`, `speakerName` and `sessionType` (`EventSession.types`, same keys as the admin panel) and overwrites every field on PUT, so `toJson` sends the untouched ones back. The event detail shows a public **Program** section (times, titles, speaker • type, cancelled sessions struck through; day titles only when there are several days). Users with `canEditEvent` get a pencil on that header (or a "Program ekle" row when it is empty) and a "Programı Düzenle" row in the edit form, both opening `EventSchedulePage` → `ScheduleDayFormPage` / `ScheduleSessionFormPage`; deleting needs `canDeleteEvent`. Core cascades: deleting a day removes its sessions and check-ins, deleting a session removes its check-ins — the confirm dialogs say so and suggest "İptal edildi" instead. The door scanner uses the same sessions and offers "Programı Düzenle" when there are none.

**Event filter:** the meaning of the `EventModel.active` flag is unknown; the "upcoming events" filter was deliberately built on **dates** (`EventProvider.upcomingEvents`, based on the end date so that multi-day events do not drop out while still running). In the UI, `active` is interpreted as "are applications open": the "Yakında" badge on the card, the status row on the detail page and the disabled Join button all depend on it.

---

## Event detail — what you need to know

This page is the screen with the most moving parts in the app; read this before touching it.

**It is opened from a single place:** `EventDetailPage.open(context, event)`. Both `EventCard` on the Events tab and `UpcomingEventTile` on the home page call it. The route is pushed onto the root navigator (otherwise it stays underneath the navbar) and the page enters with a `FadeTransition`.

**The cover image flies with a `Hero`.** The tag and the flight path live in the `EventCoverHero` widget; all three places that show the cover use it, so the setting changes in one place. The flight path is deliberately a `RectTween` (straight) — Hero's default `MaterialRectArcTween` throws the image around while it travels from a small row to a full-width cover.

> `OpenContainer` (container transform) **cannot be used** here: it grows the box but cross-fades the two contents, meaning the image does not move from its place. It does not work together with Hero either — both hide the source widget and draw it in their own layer.

**The backdrop color comes from the cover.** `EventPaletteService` extracts the colors of the image with `CoverColorExtractor` (own k-means over a 120 px sample, clusters scored by share × saturation, near-black/white dropped when colorful clusters exist, then each color pulled to a mid lightness and minimum saturation so it glows on the dark base — `palette_generator_master` only kept the most frequent exact tones, so photos with spread-out greens/browns came out grey); the page lays them over a dark base as scattered radial blobs. Details that matter:

- **Server colors first:** core computes `coverColors` at upload with the same algorithm (Go port of `CoverColorExtractor`) and returns them on events; `EventModel.coverColors` is passed as `known:` to `EventPaletteService.cached/resolve`, and cards skip the on-device work when present. The on-device path below is only the fallback.
- **Keyed by cover URL, not event id.** A new cover is a new media id and therefore a new CDN URL, so an edited cover gets fresh colors automatically. The detail page re-resolves when an edit returns a different `coverImageUrl`.
- **Persisted:** results are kept in memory and in `SharedPreferences` (`event_palette_cache_v4`, last 150 covers), so each cover is computed once per device, not on every launch. Empty results (download failed) are not persisted.
- The image is decoded at 120 px wide via `ResizeImage` (smaller samples visibly dulled the colors). Without it the poster is decoded at full resolution, and **separately** from the copy the card shows.
- Work runs on the main isolate but one job at a time, each after `endOfFrame` (`_enqueue`), so opening the tab does not drop frames. There is no `compute`/isolate any more (PR #48's isolate-per-cover was suspected of stalls). Decoding has a 15 s timeout.
- Long term the backend could compute `coverColors` once at upload and send them with the event; then this service is only a fallback.

The computation is kicked off the moment the card/row becomes visible (`initState`); by the time the page opens the color is usually ready, and if it is not, it lands after the opening animation finishes.

**The cover is pinned on the page:** `_pinnedCover` is a `Positioned` whose height shrinks as scrolling progresses; the event name appears in the top bar only once the cover has scrolled out of sight.

---

## Working habits

- Run `flutter analyze --no-pub` after every change and leave it clean.
- When adding values to the constant files, give them meaningful names; look at ready-made solutions such as `AppRadiuses.stadium` (stays fully rounded even when the height changes).
- Before deleting anything, verify it is committed, and report what was deleted along with the command to undo it.
- When the user sends a screenshot, do not guess the problem; trace it from the code and explain the cause. Most layout problems come from constraints — a missing `Center`/`Expanded`/`stretch` and the like.
- When the task is done, give a summary and stop. Do not commit.
