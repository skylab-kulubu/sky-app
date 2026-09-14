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
dart format lib/             # before committing
flutter pub get
```

> Do not run `flutter build ios`. The iOS project is on Swift Package Manager; the build triggers CocoaPods and breaks that setup.

The project has **no tests** (there is no `test/` folder). The user has stated before that they do not want tests; do not write tests unless asked.

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
│                             # SkyButton, IconCircle, TileGroup, SectionHeader, SettingsTile, ClubMenuSheet ...
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

> ⚠️ **If you open something full screen while inside the shell**, put the route at top level or pass `parentNavigatorKey: _rootNavigatorKey`. Otherwise the page stays underneath the navbar. The same pitfall applies to `OpenContainer`: without `useRootNavigator: true` the detail page opens inside the shell.

### Backend

- REST: `https://api.yildizskylab.com` — responses come wrapped in a `{success, message, data, ...}` envelope, `data` is unwrapped before use (see `EventService`).
- Authentication: Keycloak, `https://e.yildizskylab.com/realms/e-skylab`, OAuth/PKCE via `flutter_appauth`. Tokens live in `flutter_secure_storage`.

> **Club sites log in automatically through the shared browser cookie — keep both halves in sync.** Login and logout run in `SFSafariViewController` on iOS (`AuthService._externalUserAgent`; Android always uses the default browser's Custom Tabs), and `WebviewService.openLink` opens club sites in the same browser as a sheet (`flutter_custom_tabs`). The Keycloak cookie written at login is therefore visible to the sites. Do not move links back to `webview_flutter` (separate cookie jar, no SSO), and do not change the login agent on its own: on iOS `ASWebAuthenticationSession` writes to Safari, which `SFSafariViewController` cannot read, and a logout in a different store leaves the user logged in on the sites. `WebviewPage` (`/webview`) is only the fallback when no browser can be opened.

> On logout `UserProvider.user` drops to null and pages rebuild in the same frame; the redirect to `/auth` only happens on the next frame. Pages that read the user must survive that single frame — writing `user!` blows up there (see `profile_page.dart`).

### Notable packages

| Package                    | Where                                                                                                      |
| -------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `reicon_flutter`           | All icons (through `AppIcon`)                                                                              |
| `animations`               | Only the `OpenContainer` transition of the news tile                                                       |
| `palette_generator_master` | Backdrop color from the event cover (`EventPaletteService`) — the maintained fork, not `palette_generator` |
| `share_plus`               | Share button on the event detail — **native dependency**, hot reload is not enough when it is added        |
| `timeago`                  | Relative time in the notification list (`tr` and `tr_short` locales are registered in `main.dart`)         |
| `flutter_nfc_kit`          | Student card scanning (`NfcService`) — **native dependency**, needs the iOS NFC entitlement                |
| `sensors_plus`             | The tilt of the SkyPass card (`TiltBuilder`)                                                               |
| `cached_network_image_ce`  | Network images (`CoverImage`)                                                                              |
| `dio`                      | All REST calls                                                                                             |
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

> **Exception — the event detail page.** `features/calendar/presentation/pages/event_detail/event_detail_page.dart` is dark in both themes: its backdrop is derived from the dominant color of the cover image (`palette_generator`) and that color washes out when blended into a light surface. Colors on this page are read from the `AppColors.coverBackdropBase` and `onCover*` constants instead of the `context` accessors. For the same reason `SkyButton` and `AppBarActions` skip the theme defaults when they are given explicit colors.

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

Currently wired actions: **menu** (`AppIcons.widget` → `ClubMenuSheet`), **notification** (`AppIcons.bell` → `/notification`), **settings** (`/settings`) and **search** on Events. On the Teams tab the only action is "ekibime git" (`AppIcons.myTeam`), shown only when the user's realm roles match a team in the carousel; the shell calls `TeamProvider.requestMyTeam()` and `TeamPage` scrolls to the user's next team. To wire one up, add it to `_onActionTap` in `core/pages/shell_page.dart`.

**Search on Events:** a tab gets search by setting `searchHint` in its `_AppBarConfig`. The search button opens `AppBarSearchField` in the title slot (title fades out, the box grows leftward from the button, the keyboard opens when the growth ends) and the button turns into a close button. The open state, controller and focus node live in `shell_pagemodel.dart`; the text goes to `EventProvider.setSearchQuery` and `CalendarPage` lists `searchedEvents`. Closing or leaving the tab clears the query.

**The navbar** is a floating pill; the selected tab reveals its label next to the icon. The expansion is animated with `Align.widthFactor` — since the label width depends on the text, no manual width math is done.

> If you use `AppBarActions` in the `leading` slot, wrap it in a `Center` and compute `leadingWidth` with `AppBarActions.widthFor(n)`. The slot imposes a tight height constraint, so without the wrapper the pill stretches vertically; without `leadingWidth` it gets clipped.

---

## State of the world you should know

**Waiting to be wired up:**

- `User.fromJson` and `mergeWith` are written but **never called**. They will be used once the profile API (`profilePictureUrl`, `faculty`, `linkedin` ...) is connected. The endpoint path is not known yet. **Important:** the API response carries no role information; `teams`/`teamsDisplay`/`isOrganizerFor` depend solely on `realmRoles` in the JWT. So the API object cannot replace the JWT, it is applied on top of it via `mergeWith`.
- The news on the home page (`NewsService`) is a static list of real club posts; there is no news endpoint. The notifications (`NotificationService`) list is empty until the backend adds notifications (issue #45). `CertificateService.getCertificates()` is wired as a `Future` but returns an empty list until the endpoint exists.
- The profile activities (`ActivityService`) are derived from `/api/tickets/me` (registration, or attendance if checked in) and `/api/competitors/me` (rank/score/winner). There is no activity-history endpoint and tickets carry no registration date, so a registration is dated by the event start.
- The profile quick actions: **Sertifikalarım** goes to `/profile/certificates`, **Öğrenci Kartını Eşle** checks NFC availability and opens `NfcScanOverlay` (`NfcService`, ISO 14443-A only) — but the read UID is not sent anywhere yet. **QR'ı Göster** flips the SkyPass card through `SkyPassCardController` (same as tapping the card).
- The QR is on the back of the SkyPass card (tap or **QR'ı Göster** flips it). It is drawn by `_MockQrPainter` — **a fake pattern**, not a real QR code.
- The Notifications and Permissions rows in settings are hidden: push does not exist yet (#45) and no runtime permission is requested anywhere, so a permissions page would be empty (#31). `permission_handler` is in `pubspec.yaml` but unused; on iOS (Swift Package Manager) it needs extra build configuration before it reports real statuses.

**The `/team` tab** is a carousel of AR-GE teams (`TeamPage`). Teams come from SkyCMS (`GET /api/cms/collections/Teams` — the collection name must be capitalized, the response is not wrapped in `{data: ...}`); members come from Super Skylab (`GET /api/teams/{SLUG}/members`, 404 unless the team is public in Keycloak — treated as "no members", not an error). CMS has no logo field: logos are bundled in `assets/images/teams/` (from `skylab-kulubu/skylab-assets`) and mapped by slug in `Team`. ALGOLAB and GAMELAB logos contain white parts, so the light theme uses their monochrome versions tinted with the text color. Of the recruiting fields only `recruiting` is used: when true the detail page's "Ekibe Katıl" opens the club short link `skyl.app/<slug>` (which redirects to the team's form), otherwise the button is disabled and reads "Başvurular Kapalı". CMS `applyUrl` is not used. Team leaders (realm role `<TEAM>_LEADER`, mapped in Keycloak to the team's `LIDERLER` subgroup; `User.isTeamLeader`) see an edit button on the team detail page that opens `TeamEditPage`: recruiting on/off, description, long description, topics, stack and works are saved with `PUT /api/cms/collections/Teams/{slug}` (`{data, version}`; 409 on a version conflict). CMS rejects unknown fields and requires `recruiting`, so `Team.toCmsData` sends only schema fields and carries `recruitingFor`/`applyUrl` through unchanged. Saving also needs `cms:access` and the `skycms` audience in the token — without them CMS answers 401 and the page says the user has no permission. A per-user team panel (announcements, projects, tasks) was discussed but has no backend yet.

**Recently removed** — ask before bringing any of them back: the tickets feature, the announcement carousel, the home page shortcuts, the `qr` feature (`qr_page.dart`), the welcome text on the home page. All of them are in the git history.

**Event filter:** the meaning of the `EventModel.active` flag is unknown; the "upcoming events" filter was deliberately built on **dates** (`EventProvider.upcomingEvents`, based on the end date so that multi-day events do not drop out while still running). In the UI, `active` is interpreted as "are applications open": the "Yakında" badge on the card, the status row on the detail page and the disabled Join button all depend on it.

---

## Event detail — what you need to know

This page is the screen with the most moving parts in the app; read this before touching it.

**It is opened from a single place:** `EventDetailPage.open(context, event)`. Both `EventCard` on the Events tab and `UpcomingEventTile` on the home page call it. The route is pushed onto the root navigator (otherwise it stays underneath the navbar) and the page enters with a `FadeTransition`.

**The cover image flies with a `Hero`.** The tag and the flight path live in the `EventCoverHero` widget; all three places that show the cover use it, so the setting changes in one place. The flight path is deliberately a `RectTween` (straight) — Hero's default `MaterialRectArcTween` throws the image around while it travels from a small row to a full-width cover.

> `OpenContainer` (container transform) **cannot be used** here: it grows the box but cross-fades the two contents, meaning the image does not move from its place. It does not work together with Hero either — both hide the source widget and draw it in their own layer.

**The backdrop color comes from the cover.** `EventPaletteService` extracts the dominant colors of the image and keeps them in memory; the page lays them over a dark base as scattered radial blobs. The service has two critical details:

- The image is decoded at ~120 pixels via `ResizeImage`. Without it the poster is decoded at full resolution, and on top of that **separately** from the copy the card shows (every request asking for a different size gets its own cache key).
- The computations are queued and each one starts after `endOfFrame`. Running them all at once dropped frames when the tab opened.

The computation is kicked off the moment the card/row becomes visible (`initState`); by the time the page opens the color is usually ready, and if it is not, it lands after the opening animation finishes.

**The cover is pinned on the page:** `_pinnedCover` is a `Positioned` whose height shrinks as scrolling progresses; the event name appears in the top bar only once the cover has scrolled out of sight.

---

## Working habits

- Run `flutter analyze --no-pub` after every change and leave it clean.
- When adding values to the constant files, give them meaningful names; look at ready-made solutions such as `AppRadiuses.stadium` (stays fully rounded even when the height changes).
- Before deleting anything, verify it is committed, and report what was deleted along with the command to undo it.
- When the user sends a screenshot, do not guess the problem; trace it from the code and explain the cause. Most layout problems come from constraints — a missing `Center`/`Expanded`/`stretch` and the like.
- When the task is done, give a summary and stop. Do not commit.
