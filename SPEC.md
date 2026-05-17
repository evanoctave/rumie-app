# SPEC

## §G GOAL
Flutter app `roomie` (`rumie/rumie/`) ! swap mock data → live Rumie API @ `https://rumie.xyz`. Clean Architecture; dio + json_serializable.

## §C CONSTRAINTS
- Dart SDK `>=3.3.0 <4.0.0` (existing `pubspec.yaml`)
- package name: `roomie`
- deps add: `dio`, `json_annotation`, `json_serializable` (dev), `build_runner` (dev), `flutter_secure_storage`, `get_it`
- ⊥ `retrofit` codegen — hand-written Dio call sites under repositories
- Clean Architecture layers: `lib/data/api/` (client+interceptors), `lib/data/models/` (DTOs+`*.g.dart`), `lib/data/repositories/` (`*RepositoryImpl`), `lib/domain/entities/` (plain Dart types ?if distinct from DTO), `lib/domain/repositories/` (abstract repo ifaces), `lib/di/` (locator)
- screens depend on `lib/domain/repositories/` ifaces, ⊥ on `lib/data/`
- OpenAPI canonical: `https://rumie.xyz/openapi.json` — schemas + endpoints derived, ⊥ hand-spec
- snapshot OpenAPI → `lib/data/api/openapi.json` (committed) for reproducible codegen
- screens ! untouched in behavior; data source swap only
- JWT bearer; refresh token persisted via `flutter_secure_storage`
- env override: `--dart-define=RUMIE_BASE_URL=...`, default `https://rumie.xyz`
- API base path prefix: `/api/v1` (! prepended by `DioClient` baseUrl, ⊥ in each call site)
- `sample_data.dart` removed only after all screens migrated (T15)

## §I INTERFACES
- env: `RUMIE_BASE_URL` ? set; default `https://rumie.xyz` → DioClient baseUrl = `<RUMIE_BASE_URL>/api/v1`
- http: single `Dio` instance @ `lib/data/api/dio_client.dart` w/ interceptors `[AuthInterceptor, ErrorInterceptor, LoggingInterceptor]` (logging debug-only)
- storage: `flutter_secure_storage` keys: `rumie_access_token`, `rumie_refresh_token`
- exceptions: `ApiException` (base), `UnauthorizedException` (401 after refresh fail), `ValidationException(Map<String,List<String>> fieldErrors)` (422), `ServerException` (5xx), `NetworkException` (no conn/timeout)
- DI: `GetIt` locator in `lib/di/locator.dart`

repos (each = abstract @ `lib/domain/repositories/<x>_repository.dart`, impl @ `lib/data/repositories/<x>_repository_impl.dart`):

- `AuthRepository`:
  - `login(email, password) → TokensOut` ; impl auto-persists tokens via `SecureTokenStore`
  - `register(RegisterIn) → RegisterOut {user, tokens}` ; impl auto-persists tokens
  - `me() → UserOut`
  - `logout()` → client-side: clear `SecureTokenStore` ; ⊥ server call (no endpoint)
  - `refresh(refreshToken) → TokensOut` ! `internal` — only `AuthInterceptor` calls ; ⊥ exposed to UI
- `GroupsRepository`:
  - `getMyGroup() → GroupOut`
  - `patchMyGroup(GroupPatch) → GroupOut`
  - `leaveGroup() → void` (204)
  - `createInvite(InviteCreate) → InviteOut`
  - `acceptInvite(inviteId) → InviteOut`
  - `rejectInvite(inviteId) → void` (204)
- `ListingsRepository` (landlord CRUD):
  - `create(ListingCreate) → ListingOut`
  - `get(listingId) → ListingOut`
  - `patch(listingId, ListingPatch) → ListingOut`
  - `delete(listingId) → void` (204)
- `DiscoveryRepository`:
  - `discoverGroups({limit=20}) → List<GroupOut>`
  - `discoverListings({limit=20}) → List<ListingOut>`
- `SwipeRepository`:
  - `swipe(SwipeIn{target_id, target_type, direction}) → SwipeOut{matched, merge?, inquiry?, reason?}`
- `InquiriesRepository` (landlord):
  - `list({status?}) → List<InquiryOut>`
  - `accept(inquiryId) → Map<String,dynamic>` (server returns open object)
  - `reject(inquiryId) → void` (204)
- `ConversationRepository`:
  - `listConversations() → List<ConversationOut>`
  - `listMessages(convId, {limit=50, before?}) → List<MessageOut>`
  - `sendMessage(convId, body) → MessageOut`
- `AssetRepository`:
  - `presign(AssetKind kind, String contentType) → PresignOut{put_url, asset_url, key, expires_at}`
  - `upload({required AssetKind kind, required Uint8List bytes, required String contentType}) → String assetUrl` ! 2-step: presign → PUT bytes → return `asset_url`. ⊥ confirm endpoint exists.

## §V INVARIANTS
V1: ∀ req ∉ {`/api/v1/auth/login`, `/api/v1/auth/register`, `/api/v1/auth/refresh`, `/api/v1/health`} & ∉ presigned `put_url` (S3 PUT) → `Authorization: Bearer <access>` header
V2: resp 401 & refresh_token ∃ → refresh once → retry orig req ; refresh fail → clear tokens & emit logout event
V3: ⊥ ≥2 concurrent refresh calls — queue waiting reqs onto single in-flight refresh future
V4: tokens ! `flutter_secure_storage` ; ⊥ `SharedPreferences` ; ⊥ plain memory only
V5: resp 422 → `ValidationException` w/ field→msgs map parsed from FastAPI shape `{detail:[{loc,msg,type}...]}` ; UI ! show per-field
V6: resp 5xx | network err → `ServerException`|`NetworkException` w/ user-safe msg ; ⊥ raw Dio msg → UI
V7: ∀ model JSON ⇄ Dart via `json_serializable` codegen (`*.g.dart`) ; ⊥ hand-written `fromJson`/`toJson`
V8: image upload = 2 step: (a) `POST /api/v1/uploads/presign {kind, content_type}` → `PresignOut{put_url, asset_url, key, expires_at}` (b) `PUT <put_url>` w/ raw bytes & header `Content-Type: <content_type>` & ⊥ `Authorization` header. Caller receives `asset_url` as final reference. ⊥ confirm step.
V9: repository methods throw typed exceptions (per §I) ; ⊥ raw `DioException` past repo boundary
V10: ⊥ direct `Dio` access from `lib/screens/` | `lib/widgets/` ; only via repositories
V11: base URL ! from `--dart-define=RUMIE_BASE_URL=...` w/ default `https://rumie.xyz` ; ⊥ hardcoded elsewhere
V12: ∀ schema field nullable ∈ OpenAPI → Dart `?` ; non-nullable → `required`
V13: ⊥ secret/token logged ; `LoggingInterceptor` redacts `Authorization` header, `password` field in body, `refresh` field in body, `access`/`refresh` in response
V14: `register` & `login` responses → `SecureTokenStore.write(access, refresh)` ! before returning ; failure to persist → throw, do ⊥ return success
V15: `logout()` → `SecureTokenStore.clear()` ! ; ⊥ network call (server has no endpoint)
V16: `SwipeOut.inquiry` ≠ null → caller ! receives full inquiry payload (landlord-match path) ; `SwipeOut.merge` ≠ null → caller receives merge proposal (group-match path)
V17: screens import ! from `lib/domain/repositories/` ; ⊥ import from `lib/data/` (enforced by analyzer rule if feasible, else code review)
V18: ∀ repo method → exactly one of: returns typed model | throws typed exception. ⊥ returns null on error.

## §T TASKS
id|status|task|cites
T1|x|add deps to `pubspec.yaml` (`dio`, `json_annotation`, `json_serializable`, `build_runner`, `flutter_secure_storage`, `get_it`)|C
T2|x|fetch `openapi.json` → commit `lib/data/api/openapi.json`|C
T3|x|scaffold `lib/data/api/` (`dio_client.dart`, `exceptions.dart`, `interceptors/`)|V10,V11
T4|x|`SecureTokenStore` wrap `flutter_secure_storage` (read/write/clear access+refresh)|V4
T5|.|`AuthInterceptor` attach bearer ; 401→refresh-and-retry ; single-flight refresh|V1,V2,V3
T6|.|`ErrorInterceptor` map 422→`ValidationException`, 5xx→`ServerException`, timeout→`NetworkException`|V5,V6,V9
T7|x|`LoggingInterceptor` w/ redaction (debug only)|V13
T8|.|gen DTO models from OpenAPI schemas → `lib/data/models/*.dart` + `*.g.dart` (build_runner)|V7,V12
T9|.|`AuthRepository` iface + impl: `login`, `register`, `me`, `logout` (client-clear) ; internal `refresh` for interceptor|I,V9,V14,V15
T10|.|`DiscoveryRepository` iface + impl: `discoverGroups({limit})`, `discoverListings({limit})`|I,V9
T11|.|`SwipeRepository` iface + impl: `swipe(SwipeIn) → SwipeOut`|I,V9,V16
T12|.|`ConversationRepository` iface + impl: `listConversations`, `listMessages(convId,{limit,before})`, `sendMessage(convId,body)`|I,V9
T13|.|`AssetRepository` iface + impl: `presign`, `upload` (2-step PUT, ⊥ auth header on `put_url`)|V8,V9
T18|.|`GroupsRepository` iface + impl: `getMyGroup`, `patchMyGroup`, `leaveGroup`, `createInvite`, `acceptInvite`, `rejectInvite`|I,V9
T19|.|`ListingsRepository` iface + impl (landlord CRUD): `create`, `get`, `patch`, `delete`|I,V9
T20|.|`InquiriesRepository` iface + impl (landlord): `list({status?})`, `accept`, `reject`|I,V9
T14|~|`lib/di/locator.dart` w/ `GetIt` register Dio + all 8 repos + token store|I
T15|.|wire `lib/screens/*` & `lib/widgets/*` → domain repo ifaces ; rm imports of `sample_data.dart`|V10,V17
T16|.|delete `lib/data/sample_data.dart` & legacy `lib/models/{roommate,trait}.dart` once unused|-
T17|.|tests: `AuthInterceptor` refresh single-flight (V2,V3) ; 422 parser (V5) ; 2-step upload ⊥ auth on PUT (V8) ; register auto-persist (V14) ; logout clears store (V15)|V2,V3,V5,V8,V14,V15
T21|.|tests: each repo happy-path against mocked `Dio` ; one 422 path per repo|V9,V18
T22|.|README: doc `--dart-define=RUMIE_BASE_URL=...` + how to refresh `openapi.json` snapshot|C

## §B BUGS
id|date|cause|fix
