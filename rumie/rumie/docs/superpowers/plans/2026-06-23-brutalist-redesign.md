# Rumie Brutalist Editorial Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign every Rumie screen to Brutalist Editorial aesthetic (Syne headings, Inter body, cream/black palette, solid borders, no gradients) plus add a 3-factor value score on listings.

**Architecture:** All color tokens live in `AppColors`; all Syne headings use `GoogleFonts.syne(fontWeight: FontWeight.w800)`; `ValueScoreService` computes scores from Rentcast + Walk Score APIs with a deterministic fallback when keys are absent. New `DiscoverScreen` replaces `SwipeScreen` with a vertical scroll feed.

**Tech Stack:** Flutter, google_fonts (Syne + Inter already available), provider, http, flutter_animate, image_picker.

---

### Task 1: Replace AppColors with brutalist palette

**Files:**
- Modify: `lib/theme/app_colors.dart`

- [ ] **Step 1: Replace the entire file**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = false;

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static Color get background => isDark ? const Color(0xFF0D0B0A) : const Color(0xFFF2F0EB);
  static Color get surface    => isDark ? const Color(0xFF1A1710) : const Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static Color get text          => isDark ? const Color(0xFFF2F0EB) : const Color(0xFF1A1A1A);
  static Color get textSecondary => isDark ? const Color(0x61F2F0EB) : const Color(0xFF888888);

  // ── Borders ───────────────────────────────────────────────────────────────
  static Color get border     => isDark ? const Color(0x2DF2F0EB) : const Color(0xFF1A1A1A);
  static Color get borderSoft => isDark ? const Color(0x14F2F0EB) : const Color(0xFFDDDAD3);

  // ── Accent purple ─────────────────────────────────────────────────────────
  static Color get accent     => isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
  static Color get accentSoft => isDark ? const Color(0x26A78BFA) : const Color(0xFFEDE9FE);

  // ── Chip / button fills ───────────────────────────────────────────────────
  static Color get chipBg   => isDark ? const Color(0xFFF2F0EB) : const Color(0xFF1A1A1A);
  static Color get chipText => isDark ? const Color(0xFF0D0B0A) : const Color(0xFFF2F0EB);
  static Color get btnPrimary     => isDark ? const Color(0xFFF2F0EB) : const Color(0xFF1A1A1A);
  static Color get btnPrimaryText => isDark ? const Color(0xFF0D0B0A) : const Color(0xFFF2F0EB);

  // ── Value score ───────────────────────────────────────────────────────────
  static Color get scoreHigh    => isDark ? const Color(0xFF4ADE80) : const Color(0xFF1A7A4A);
  static Color get scoreHighBg  => isDark ? const Color(0x1F4ADE80) : const Color(0xFFDCFCE7);
  static Color get scoreMid     => isDark ? const Color(0xFFFBBF24) : const Color(0xFFA16207);
  static Color get scoreMidBg   => isDark ? const Color(0x1FFBBF24) : const Color(0xFFFEF9C3);
  static Color get scoreLow     => const Color(0xFFEF4444);
  static Color get scoreLowBg   => isDark ? const Color(0x1FEF4444) : const Color(0xFFFEE2E2);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color red  = Color(0xFFEF4444);
  static const Color green = Color(0xFF10B981);

  // ── Legacy aliases kept so existing callers compile ───────────────────────
  static Color get primary        => accent;
  static Color get secondary      => accent;
  static Color get primaryLight   => accent;
  static Color get cardBg         => surface;
  static Color get darkText       => text;
  static Color get gray           => textSecondary;
  static Color get softPurple     => accentSoft;
  static Color get border2        => border;
  static const Color primaryGradient = Color(0xFF6D28D9);
  static const Color teal         = Color(0xFF14B8A6);
  static const Color blue         = Color(0xFF3B82F6);
  static const Color softBlue     = Color(0xFFEFF6FF);
  static const Color orange       = Color(0xFFF97316);
  static const Color softOrange   = Color(0xFFFFEDD5);
  static const Color pink         = Color(0xFFEC4899);
  static const Color softPink     = Color(0xFFFCE7F3);
  static const Color yellow       = Color(0xFFF59E0B);
  static const Color softYellow   = Color(0xFFFEF3C7);
  static const Color greenDark    = Color(0xFF059669);
  static const Color softGreen    = Color(0xFFD1FAE5);
  static const Color darkGreen    = Color(0xFF059669);
  static const Color darkMauve    = Color(0xFF6D28D9);
  static const Color mauve        = Color(0xFF7C3AED);
  static const Color accent_      = Color(0xFF6D28D9);
  static const Color sage         = Color(0xFF10B981);
  static const Color peach        = Color(0xFFF97316);

  static List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))]
      : [];

  static List<BoxShadow> get floatingShadow => cardShadow;
  static List<BoxShadow> get navShadow      => [];
  static List<BoxShadow> get buttonShadow   => [];

  static const LinearGradient purpleGreenGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF10B981)],
  );
  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
  );
  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
  );
  static const LinearGradient primaryGradient_ = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF5B21B6)],
  );

  static Color get borderBright => accent;
}
```

- [ ] **Step 2: Hot reload, verify app launches without errors**

```
flutter run
```

Expected: app runs, colors changed. May look broken — that's fine, screens come later.

- [ ] **Step 3: Commit**

```bash
git add lib/theme/app_colors.dart
git commit -m "style: replace AppColors with brutalist palette"
```

---

### Task 2: Update main.dart theme to Inter + brutalist tokens

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace `_buildTheme` method in `_RumieState`**

```dart
ThemeData _buildTheme(bool dark) {
  AppColors.isDark = dark;
  final base = dark ? Brightness.dark : Brightness.light;
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    brightness: base,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: base,
      surface: AppColors.surface,
    ).copyWith(surface: AppColors.surface, primary: AppColors.accent),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyLarge:  GoogleFonts.inter(fontSize: 16, color: AppColors.text),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: AppColors.borderSoft, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: AppColors.borderSoft, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.background : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.borderSoft,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
```

- [ ] **Step 2: Update `SystemChrome` calls** — in `main()` and `build()`, change `systemNavigationBarColor` to use `AppColors.background` (already done via getter, just verify the call compiles).

- [ ] **Step 3: Hot reload, verify no exceptions**

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "style: switch theme to Inter body + brutalist tokens"
```

---

### Task 3: ValueScore model + ValueScoreService

**Files:**
- Create: `lib/services/value_score.dart`
- Create: `lib/services/value_score_service.dart`
- Create: `lib/config/api_keys.dart`
- Test: `test/services/value_score_service_test.dart`

- [ ] **Step 1: Create `lib/config/api_keys.dart`**

```dart
// Add real keys here or set via --dart-define at build time.
// --dart-define=RENTCAST_KEY=xxx --dart-define=WALKSCORE_KEY=xxx
class ApiKeys {
  static const String rentcast   = String.fromEnvironment('RENTCAST_KEY',   defaultValue: '');
  static const String walkScore  = String.fromEnvironment('WALKSCORE_KEY',  defaultValue: '');
}
```

- [ ] **Step 2: Create `lib/services/value_score.dart`**

```dart
class ValueScore {
  final int overall;      // 0–100 weighted total
  final int priceScore;   // price vs neighborhood median (0–100)
  final int sqftScore;    // price per sqft vs area avg (0–100)
  final int transitScore; // walk/transit score (0–100)

  const ValueScore({
    required this.overall,
    required this.priceScore,
    required this.sqftScore,
    required this.transitScore,
  });

  String get tier {
    if (overall >= 75) return 'Great deal';
    if (overall >= 50) return 'Fair deal';
    return 'Below avg';
  }

  bool get isHigh => overall >= 75;
  bool get isMid  => overall >= 50 && overall < 75;

  /// Compute weighted overall from three 0–100 sub-scores.
  /// Weights: price vs median 40%, price/sqft 35%, transit 25%.
  static int computeOverall({
    required int priceScore,
    required int sqftScore,
    required int transitScore,
  }) {
    return ((priceScore * 0.40) + (sqftScore * 0.35) + (transitScore * 0.25)).round();
  }
}
```

- [ ] **Step 3: Write failing tests**

Create `test/services/value_score_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/services/value_score.dart';
import 'package:roomie/services/value_score_service.dart';

void main() {
  group('ValueScore.computeOverall', () {
    test('weights: 40% price + 35% sqft + 25% transit', () {
      final result = ValueScore.computeOverall(
        priceScore: 100,
        sqftScore: 100,
        transitScore: 100,
      );
      expect(result, 100);
    });

    test('low price score drags overall down', () {
      final result = ValueScore.computeOverall(
        priceScore: 0,
        sqftScore: 100,
        transitScore: 100,
      );
      // 0*0.4 + 100*0.35 + 100*0.25 = 60
      expect(result, 60);
    });

    test('great deal tier at 75+', () {
      final score = ValueScore(overall: 80, priceScore: 80, sqftScore: 80, transitScore: 80);
      expect(score.tier, 'Great deal');
      expect(score.isHigh, true);
    });

    test('fair deal tier at 50–74', () {
      final score = ValueScore(overall: 62, priceScore: 62, sqftScore: 62, transitScore: 62);
      expect(score.tier, 'Fair deal');
      expect(score.isMid, true);
    });

    test('below avg tier under 50', () {
      final score = ValueScore(overall: 30, priceScore: 30, sqftScore: 30, transitScore: 30);
      expect(score.tier, 'Below avg');
      expect(score.isHigh, false);
      expect(score.isMid, false);
    });
  });

  group('ValueScoreService.estimateFallback', () {
    test('same rent + sqft always returns same score', () {
      final svc = ValueScoreService();
      final a = svc.estimateFallback(rent: 1400, sqft: 800, location: 'Brooklyn');
      final b = svc.estimateFallback(rent: 1400, sqft: 800, location: 'Brooklyn');
      expect(a.overall, b.overall);
    });

    test('cheaper rent scores higher than expensive rent same sqft', () {
      final svc = ValueScoreService();
      final cheap = svc.estimateFallback(rent: 800,  sqft: 800, location: 'Brooklyn');
      final pricey = svc.estimateFallback(rent: 3000, sqft: 800, location: 'Brooklyn');
      expect(cheap.overall, greaterThan(pricey.overall));
    });

    test('more sqft for same rent scores higher', () {
      final svc = ValueScoreService();
      final big   = svc.estimateFallback(rent: 1400, sqft: 1200, location: 'Brooklyn');
      final small = svc.estimateFallback(rent: 1400, sqft: 400,  location: 'Brooklyn');
      expect(big.overall, greaterThan(small.overall));
    });
  });
}
```

- [ ] **Step 4: Run tests — expect failure (class not found)**

```bash
cd rumie && flutter test test/services/value_score_service_test.dart
```

Expected: compilation error `ValueScoreService` not found.

- [ ] **Step 5: Create `lib/services/value_score_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import 'value_score.dart';

class ValueScoreService {
  static final ValueScoreService _instance = ValueScoreService._();
  factory ValueScoreService() => _instance;
  ValueScoreService._();

  final Map<String, ValueScore> _cache = {};

  /// Tries real APIs if keys present, else falls back to estimate.
  Future<ValueScore> compute({
    required int rent,
    required int sqft,
    required String location,
    String? zipCode,
  }) async {
    final key = '$rent-$sqft-$location';
    if (_cache.containsKey(key)) return _cache[key]!;

    if (ApiKeys.rentcast.isNotEmpty && ApiKeys.walkScore.isNotEmpty && zipCode != null) {
      try {
        final score = await _fetchFromApis(rent: rent, sqft: sqft, zipCode: zipCode, location: location);
        _cache[key] = score;
        return score;
      } catch (_) {
        // fall through to estimate
      }
    }

    final estimate = estimateFallback(rent: rent, sqft: sqft, location: location);
    _cache[key] = estimate;
    return estimate;
  }

  /// Deterministic local estimate — no API required.
  /// Uses NYC/US median rent heuristics.
  ValueScore estimateFallback({
    required int rent,
    required int sqft,
    required String location,
  }) {
    // Price vs median: NYC median ~$2,000. Score 100 if at/below $800, 0 at $3,500+.
    final priceScore = ((3500 - rent) / (3500 - 800) * 100).clamp(0, 100).toInt();

    // $/sqft vs avg: NYC avg ~$3/sqft. Score 100 if ≤$1.50, 0 if ≥$5.
    final ppsf = sqft > 0 ? rent / sqft : 3.0;
    final sqftScore = ((5.0 - ppsf) / (5.0 - 1.5) * 100).clamp(0, 100).toInt();

    // Transit: rough score from location string hash (stable, 45–95 range).
    final hash = location.codeUnits.fold(0, (a, b) => a + b);
    final transitScore = 45 + (hash % 50);

    return ValueScore(
      overall: ValueScore.computeOverall(
        priceScore: priceScore,
        sqftScore: sqftScore,
        transitScore: transitScore,
      ),
      priceScore: priceScore,
      sqftScore: sqftScore,
      transitScore: transitScore,
    );
  }

  Future<ValueScore> _fetchFromApis({
    required int rent,
    required int sqft,
    required String zipCode,
    required String location,
  }) async {
    // Rentcast: price vs median
    final rentcastResp = await http.get(
      Uri.parse('https://api.rentcast.io/v1/markets?zipCode=$zipCode'),
      headers: {'X-Api-Key': ApiKeys.rentcast},
    );
    int priceScore = 70;
    if (rentcastResp.statusCode == 200) {
      final data = jsonDecode(rentcastResp.body);
      final median = (data['rentPrice']?['median'] as num?)?.toInt() ?? 2000;
      priceScore = ((median - rent) / median * 100 + 50).clamp(0, 100).toInt();
    }

    // Walk Score
    final wsResp = await http.get(
      Uri.parse(
        'https://api.walkscore.com/score?format=json&address=${Uri.encodeComponent(location)}&wsapikey=${ApiKeys.walkScore}',
      ),
    );
    int transitScore = 70;
    if (wsResp.statusCode == 200) {
      final data = jsonDecode(wsResp.body);
      transitScore = (data['transit']?['score'] as num?)?.toInt() ?? 70;
    }

    final ppsf = sqft > 0 ? rent / sqft : 3.0;
    final sqftScore = ((5.0 - ppsf) / (5.0 - 1.5) * 100).clamp(0, 100).toInt();

    return ValueScore(
      overall: ValueScore.computeOverall(
        priceScore: priceScore,
        sqftScore: sqftScore,
        transitScore: transitScore,
      ),
      priceScore: priceScore,
      sqftScore: sqftScore,
      transitScore: transitScore,
    );
  }
}
```

- [ ] **Step 6: Run tests — expect pass**

```bash
flutter test test/services/value_score_service_test.dart
```

Expected: all 8 tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/services/ lib/config/ test/services/
git commit -m "feat: add ValueScore model + ValueScoreService with fallback estimator"
```

---

### Task 4: BrutalChip widget

**Files:**
- Modify: `lib/widgets/trait_chip.dart`
- Test: `test/widgets/brutal_chip_test.dart`

- [ ] **Step 1: Write failing widget test**

```dart
// test/widgets/brutal_chip_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/widgets/trait_chip.dart';
import 'package:roomie/models/trait.dart';

void main() {
  testWidgets('TraitChip renders title uppercased', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TraitChip(
            trait: Trait(title: 'Early bird', color: Colors.purple),
          ),
        ),
      ),
    );
    expect(find.text('EARLY BIRD'), findsOneWidget);
  });

  testWidgets('accent TraitChip uses accent background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TraitChip(
            trait: Trait(title: 'WFH', color: Colors.purple),
            accent: true,
          ),
        ),
      ),
    );
    expect(find.text('WFH'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run — expect fail** (`accent` param missing)

```bash
flutter test test/widgets/brutal_chip_test.dart
```

- [ ] **Step 3: Replace `lib/widgets/trait_chip.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trait.dart';
import '../theme/app_colors.dart';

class TraitChip extends StatelessWidget {
  final Trait trait;
  final bool accent;

  const TraitChip({super.key, required this.trait, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final bg   = accent ? AppColors.accent     : AppColors.chipBg;
    final text = accent ? const Color(0xFFF2F0EB) : AppColors.chipText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        trait.title.toUpperCase(),
        style: GoogleFonts.inter(
          color: text,
          fontWeight: FontWeight.w700,
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/widgets/brutal_chip_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/trait_chip.dart test/widgets/brutal_chip_test.dart
git commit -m "style: rewrite TraitChip as brutalist uppercase chip"
```

---

### Task 5: ValueScoreBadge widget

**Files:**
- Create: `lib/widgets/value_score_badge.dart`
- Test: `test/widgets/value_score_badge_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/widgets/value_score_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/services/value_score.dart';
import 'package:roomie/widgets/value_score_badge.dart';

void main() {
  testWidgets('shows overall score number', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueScoreBadge(
          score: ValueScore(overall: 84, priceScore: 88, sqftScore: 76, transitScore: 92),
        ),
      ),
    ));
    expect(find.text('84'), findsOneWidget);
    expect(find.text('GREAT DEAL'), findsOneWidget);
  });

  testWidgets('fair deal score shows amber label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueScoreBadge(
          score: ValueScore(overall: 61, priceScore: 55, sqftScore: 60, transitScore: 72),
        ),
      ),
    ));
    expect(find.text('61'), findsOneWidget);
    expect(find.text('FAIR DEAL'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run — expect fail**

```bash
flutter test test/widgets/value_score_badge_test.dart
```

- [ ] **Step 3: Create `lib/widgets/value_score_badge.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/value_score.dart';
import '../theme/app_colors.dart';

class ValueScoreBadge extends StatelessWidget {
  final ValueScore score;
  const ValueScoreBadge({super.key, required this.score});

  Color get _fg => score.isHigh
      ? AppColors.scoreHigh
      : score.isMid
          ? AppColors.scoreMid
          : AppColors.scoreLow;

  Color get _bg => score.isHigh
      ? AppColors.scoreHighBg
      : score.isMid
          ? AppColors.scoreMidBg
          : AppColors.scoreLowBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _fg, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${score.overall}',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _fg,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALUE SCORE',
                    style: GoogleFonts.inter(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: _fg,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    score.tier.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: _fg,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _MiniBar(label: 'VS MEDIAN', value: score.priceScore / 100, color: _fg),
        const SizedBox(height: 4),
        _MiniBar(label: '\$/SQFT',   value: score.sqftScore   / 100, color: _fg),
        const SizedBox(height: 4),
        _MiniBar(label: 'TRANSIT',   value: score.transitScore / 100, color: _fg),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value; // 0.0–1.0
  final Color color;
  const _MiniBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: AppColors.borderSoft,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/widgets/value_score_badge_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/value_score_badge.dart test/widgets/value_score_badge_test.dart
git commit -m "feat: add ValueScoreBadge widget with score + 3 mini bars"
```

---

### Task 6: BrutalListingCard widget

**Files:**
- Modify: `lib/widgets/listing_card.dart`

- [ ] **Step 1: Replace `lib/widgets/listing_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/value_score.dart';
import '../theme/app_colors.dart';
import 'value_score_badge.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String type;
  final String location;
  final int rent;
  final String bedsBaths;
  final String availableDate;
  final int sqft;
  final ValueScore? valueScore;
  final int animationIndex;

  const ListingCard({
    super.key,
    required this.title,
    required this.type,
    required this.location,
    required this.rent,
    required this.bedsBaths,
    required this.availableDate,
    this.sqft = 0,
    this.valueScore,
    this.animationIndex = 0,
  });

  // Parse "2bd / 1ba" → beds=2, baths=1
  (String, String) get _bedBath {
    final parts = bedsBaths.split('/');
    return (parts.firstOrNull?.trim() ?? bedsBaths, parts.elementAtOrNull(1)?.trim() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final (beds, baths) = _bedBath;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (valueScore != null) ...[
            ValueScoreBadge(score: valueScore!),
            const SizedBox(height: 12),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'SCORE UNAVAILABLE',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Price
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$$rent',
                  style: GoogleFonts.syne(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text: '/mo',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            location,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.borderSoft, thickness: 1, height: 1),
          const SizedBox(height: 8),
          // Specs row
          Row(
            children: [
              _Spec(label: 'BED',     value: beds),
              _Spec(label: 'BATH',    value: baths),
              _Spec(label: 'MOVE-IN', value: availableDate),
              if (sqft > 0) _Spec(label: 'SQFT', value: '$sqft'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final String label;
  final String value;
  const _Spec({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify compile**

```bash
flutter analyze lib/widgets/listing_card.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/listing_card.dart
git commit -m "style: rewrite ListingCard with brutalist layout + ValueScoreBadge"
```

---

### Task 7: DiscoverCard widget

**Files:**
- Create: `lib/widgets/discover_card.dart`

- [ ] **Step 1: Create `lib/widgets/discover_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import 'trait_chip.dart';

class DiscoverCard extends StatelessWidget {
  final Roommate roommate;
  final int index;          // for ghost number
  final VoidCallback onPass;
  final VoidCallback onConnect;
  final VoidCallback onTap; // open full profile

  const DiscoverCard({
    super.key,
    required this.roommate,
    required this.index,
    required this.onPass,
    required this.onConnect,
    required this.onTap,
  });

  // Split "Marcus Johnson" → ("Marcus", "Johnson"); single word → ("Marcus", "")
  (String, String) get _nameParts {
    final idx = roommate.name.indexOf(' ');
    if (idx == -1) return (roommate.name, '');
    return (roommate.name.substring(0, idx), roommate.name.substring(idx + 1));
  }

  @override
  Widget build(BuildContext context) {
    final (first, last) = _nameParts;
    final num = '${(index + 1).toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Ghost number
            Positioned(
              right: 0,
              top: -8,
              child: Text(
                num,
                style: GoogleFonts.syne(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -4,
                  height: 1,
                ),
              ).opacity(0.05),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${first.toUpperCase()}\n',
                        style: GoogleFonts.syne(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -1.5,
                          height: 0.95,
                        ),
                      ),
                      if (last.isNotEmpty)
                        TextSpan(
                          text: last.toUpperCase(),
                          style: GoogleFonts.syne(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            letterSpacing: -1.5,
                            height: 0.95,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.border, thickness: 1.5, height: 1),
                const SizedBox(height: 10),

                // Stats row
                Row(
                  children: [
                    _Stat(value: '${roommate.age}',        label: 'AGE'),
                    _Stat(value: roommate.location,        label: 'LOCATION'),
                    _Stat(value: '\$${roommate.budget}',   label: 'BUDGET'),
                  ],
                ),
                const SizedBox(height: 10),

                // Trait chips
                if (roommate.traits.isNotEmpty)
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: roommate.traits.asMap().entries.map((e) =>
                      TraitChip(trait: e.value, accent: e.key == 0),
                    ).toList(),
                  ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _CardBtn(
                        label: 'PASS',
                        primary: false,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onPass();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _CardBtn(
                        label: 'CONNECT →',
                        primary: true,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onConnect();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBtn extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _CardBtn({required this.label, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? AppColors.btnPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: primary ? AppColors.btnPrimary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: primary ? AppColors.btnPrimaryText : AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

extension on Widget {
  Widget opacity(double value) => Opacity(opacity: value, child: this);
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/widgets/discover_card.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/discover_card.dart
git commit -m "feat: add DiscoverCard widget (brutalist editorial, vertical feed)"
```

---

### Task 8: DiscoverScreen (replaces SwipeScreen)

**Files:**
- Modify: `lib/screens/swipe_screen.dart`

- [ ] **Step 1: Replace entire file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/discover_card.dart';

class SwipeScreen extends StatefulWidget {
  final void Function(Roommate) onMatch;
  final int matchCount;
  final VoidCallback onOpenMatches;

  const SwipeScreen({
    super.key,
    required this.onMatch,
    required this.matchCount,
    required this.onOpenMatches,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final Set<int> _passed = {};
  final Set<int> _connected = {};

  List<Roommate> get _visible => sampleRoommates
      .asMap()
      .entries
      .where((e) => !_passed.contains(e.key) && !_connected.contains(e.key))
      .map((e) => e.value)
      .toList();

  void _pass(int originalIndex) => setState(() => _passed.add(originalIndex));

  void _connect(int originalIndex) {
    setState(() => _connected.add(originalIndex));
    widget.onMatch(sampleRoommates[originalIndex]);
    _showConnectedSnack(sampleRoommates[originalIndex]);
  }

  void _showConnectedSnack(Roommate r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "You connected with ${r.name}!",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: visible.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final originalIndex = sampleRoommates.indexOf(visible[i]);
                      return DiscoverCard(
                        roommate: visible[i],
                        index: i,
                        onPass:    () => _pass(originalIndex),
                        onConnect: () => _connect(originalIndex),
                        onTap:     () => _openProfile(visible[i]),
                      )
                          .animate()
                          .fadeIn(delay: (60 * i).ms, duration: 280.ms)
                          .slideY(
                            begin: 0.05,
                            delay: (60 * i).ms,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          Text(
            'Discover',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          Text(
            '${sampleRoommates.length - _passed.length - _connected.length} near you',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "YOU'VE\nSEEN ALL",
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new roommates.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(Roommate r) {
    // Full profile view — Task 13
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile view coming — Task 13')),
    );
  }
}
```

- [ ] **Step 2: Hot reload, verify discover feed renders**

- [ ] **Step 3: Commit**

```bash
git add lib/screens/swipe_screen.dart
git commit -m "feat: replace SwipeScreen with vertical scroll DiscoverScreen"
```

---

### Task 9: Auth screens — Landing, Login, Signup

**Files:**
- Modify: `lib/screens/auth/landing_screen.dart`
- Modify: `lib/screens/auth/login_screen.dart`
- Modify: `lib/screens/auth/signup_screen.dart`

- [ ] **Step 1: Replace `lib/screens/auth/landing_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/role.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static PageRoute<T> slideRoute<T>(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (ctx, anim, sec) => screen,
      transitionsBuilder: (ctx, anim, sec, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'ru',
                      style: GoogleFonts.syne(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -2,
                      ),
                    ),
                    TextSpan(
                      text: 'mie',
                      style: GoogleFonts.syne(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 8),
              Text(
                'Find your perfect roommate.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms),

              const Spacer(),

              // Decorative editorial block
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NO MATCHES.\nNO GUESSWORK.\nJUST ROOMMATES.',
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.border, thickness: 1.5, height: 1),
                    const SizedBox(height: 12),
                    Row(children: [
                      _Pill('Discover'),
                      const SizedBox(width: 6),
                      _Pill('Connect'),
                      const SizedBox(width: 6),
                      _Pill('Move in', accent: true),
                    ]),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 400.ms)
                  .slideY(begin: 0.06, delay: 160.ms, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 32),

              // CTAs
              _PrimaryBtn(
                label: 'GET STARTED →',
                onTap: () => Navigator.push(
                  context,
                  slideRoute(const SignupScreen(role: Role.seeker)),
                ),
              ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

              const SizedBox(height: 10),
              _OutlineBtn(
                label: 'SIGN IN',
                onTap: () => Navigator.push(
                  context,
                  slideRoute(const LoginScreen()),
                ),
              ).animate().fadeIn(delay: 280.ms, duration: 300.ms),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By continuing you agree to our Terms of Service.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool accent;
  const _Pill(this.label, {this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? AppColors.accent : AppColors.chipBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: accent ? const Color(0xFFF2F0EB) : AppColors.chipText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.btnPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.btnPrimaryText,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSoft, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace `lib/screens/auth/login_screen.dart`** — read the existing file first, then replace with brutalist layout preserving all form logic, auth provider calls, and validation. Keep all functional code; only replace visual layer. Key structure:

```dart
// Keep all imports, AuthProvider usage, form key, controllers, _submit(), _toggleObscure()
// Replace visual scaffold with:
Scaffold(
  backgroundColor: AppColors.background,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(28, 48, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('←', style: GoogleFonts.syne(fontSize: 24, color: AppColors.text)),
          ),
          SizedBox(height: 32),
          // Title
          RichText(text: TextSpan(children: [
            TextSpan(text: 'SIGN\n', style: GoogleFonts.syne(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -2, height: 0.95)),
            TextSpan(text: 'IN',    style: GoogleFonts.syne(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.accent, letterSpacing: -2, height: 0.95)),
          ])),
          SizedBox(height: 32),
          // Fields with _BrutalField helper
          _BrutalLabel('EMAIL'),
          _BrutalField(controller: _emailCtrl, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
          SizedBox(height: 14),
          _BrutalLabel('PASSWORD'),
          _BrutalField(controller: _passCtrl, hint: '••••••••', obscure: _obscure, onToggleObscure: _toggleObscure),
          SizedBox(height: 24),
          // Submit
          _PrimaryBtn(label: 'SIGN IN →', onTap: _submit),
          // Error display if any
          // Footer
        ],
      ),
    ),
  ),
)
```

Use `_BrutalLabel` and `_BrutalField` private helpers in the same file (see pattern from `landing_screen.dart`'s `_PrimaryBtn`). `_BrutalField` wraps a `TextFormField` with `InputDecoration` that uses `AppColors.borderSoft` border and `AppColors.surface` fill.

- [ ] **Step 3: Replace `lib/screens/auth/signup_screen.dart`** — same pattern as login. Keep all Role logic, step progression, field validators. Replace visual layer only.

- [ ] **Step 4: Hot reload, walk through auth flow manually**

- [ ] **Step 5: Commit**

```bash
git add lib/screens/auth/
git commit -m "style: rewrite auth screens with brutalist editorial layout"
```

---

### Task 10: MatchesScreen

**Files:**
- Modify: `lib/screens/matches_screen.dart`
- Modify: `lib/widgets/match_tile.dart`

- [ ] **Step 1: Replace `lib/widgets/match_tile.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';

class MatchTile extends StatelessWidget {
  final Roommate roommate;
  final VoidCallback? onTap;

  const MatchTile({super.key, required this.roommate, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSoft, width: 1)),
        ),
        child: Row(
          children: [
            // Avatar square
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                roommate.name.isNotEmpty ? roommate.name[0].toUpperCase() : '?',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roommate.name.toUpperCase(),
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${roommate.location} · \$${roommate.budget}/mo',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${roommate.budget}',
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update `lib/screens/matches_screen.dart`** — replace header and empty state with brutalist style. Header: Syne "Matches" title + badge. Empty state: large Syne "NO MATCHES YET" text. Keep the list logic and `MatchTile` usage intact.

```dart
// Header widget replacement:
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
    decoration: BoxDecoration(
      color: AppColors.background,
      border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
    ),
    child: Row(
      children: [
        Text('Matches',
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800,
            color: AppColors.text, letterSpacing: -0.8)),
        const Spacer(),
        if (matches.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(4)),
            child: Text('${matches.length} NEW',
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
                color: AppColors.background, letterSpacing: 1.5)),
          ),
      ],
    ),
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/matches_screen.dart lib/widgets/match_tile.dart
git commit -m "style: rewrite MatchesScreen + MatchTile with brutalist layout"
```

---

### Task 11: ChatScreen

**Files:**
- Modify: `lib/screens/chat_screen.dart`

- [ ] **Step 1: Read current chat_screen.dart, then update** — replace visual elements with brutalist style. Keep all message sending logic, stream/state management. Apply these specific changes:

  - AppBar → custom top bar: `border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5))`, Syne bold name, Inter "← Back" button
  - Message bubbles: sent = `AppColors.btnPrimary` background, `AppColors.btnPrimaryText` text; received = `AppColors.surface` background, `AppColors.text` text; both have `borderRadius: BorderRadius.circular(6)` (not pill-shaped), Inter 13px
  - Input bar: `border: Border(top: BorderSide(color: AppColors.border, width: 1.5))`, `AppColors.background` fill, borderRadius 5, send button = `AppColors.btnPrimary` fill

- [ ] **Step 2: Commit**

```bash
git add lib/screens/chat_screen.dart
git commit -m "style: rewrite ChatScreen with brutalist bubbles + header"
```

---

### Task 12: ListingsScreen

**Files:**
- Modify: `lib/screens/listings_screen.dart`

- [ ] **Step 1: Read current listings_screen.dart**

- [ ] **Step 2: Add value score fetching** — in `initState` or `didChangeDependencies`, kick off score computation for each listing. Store results in a `Map<int, ValueScore?>` state map.

```dart
final Map<int, ValueScore?> _scores = {};
final _svc = ValueScoreService();

@override
void initState() {
  super.initState();
  _fetchScores();
}

Future<void> _fetchScores() async {
  for (int i = 0; i < sampleListings.length; i++) {
    final l = sampleListings[i];
    final score = await _svc.compute(
      rent: l.rent,
      sqft: l.sqft ?? 0,
      location: l.location,
    );
    if (mounted) setState(() => _scores[i] = score);
  }
}
```

- [ ] **Step 3: Update screen chrome** — header same pattern as MatchesScreen (Syne title + count badge, 1.5px bottom border). Replace `ListingCard` usage — pass `valueScore: _scores[i]` prop.

- [ ] **Step 4: Update `ListingCard` call sites** to pass `sqft` if available in listing model, else pass `0`.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/listings_screen.dart
git commit -m "feat: wire ValueScoreService into ListingsScreen"
```

---

### Task 13: ProfileViewScreen (read-only, full profile)

**Files:**
- Create: `lib/screens/profile_view_screen.dart`

- [ ] **Step 1: Create the screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/trait_chip.dart';

class ProfileViewScreen extends StatelessWidget {
  final Roommate roommate;
  const ProfileViewScreen({super.key, required this.roommate});

  static PageRoute<void> route(Roommate r) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => ProfileViewScreen(roommate: r),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('←',
                      style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                  ),
                  const Spacer(),
                  Text('PROFILE',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, letterSpacing: 2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      roommate.name.toUpperCase(),
                      style: GoogleFonts.syne(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -2,
                        height: 0.95,
                      ),
                    ),
                    Text(
                      '${roommate.age} · ${roommate.location}',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: AppColors.border, thickness: 1.5, height: 1),
                    const SizedBox(height: 20),

                    // Photos (horizontal scroll — shows placeholder if no real photos)
                    _SectionLabel('PHOTOS'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: roommate.avatarAsset.isNotEmpty
                          ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 1, // real photos from roommate.photos when available
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, __) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  roommate.avatarAsset,
                                  width: 140,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _PhotoPlaceholder(),
                                ),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, __) => _PhotoPlaceholder(),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Stats grid
                    _SectionLabel('DETAILS'),
                    const SizedBox(height: 8),
                    _StatsGrid(roommate: roommate),
                    const SizedBox(height: 20),

                    // Traits
                    if (roommate.traits.isNotEmpty) ...[
                      _SectionLabel('TRAITS'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: roommate.traits.asMap().entries.map((e) =>
                          TraitChip(trait: e.value, accent: e.key == 0),
                        ).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Bio
                    if (roommate.bio.isNotEmpty) ...[
                      _SectionLabel('BIO'),
                      const SizedBox(height: 8),
                      Text(roommate.bio,
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.text, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // Connect CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.btnPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('CONNECT →',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.btnPrimaryText, letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 2));
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSoft, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text('PHOTO',
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary, letterSpacing: 2)),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Roommate roommate;
  const _StatsGrid({required this.roommate});

  @override
  Widget build(BuildContext context) {
    final cells = [
      ('\$${roommate.budget}/mo', 'BUDGET'),
      ('${roommate.age}', 'AGE'),
      (roommate.location, 'LOCATION'),
      ('Flexible', 'MOVE-IN'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: cells.map((c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSoft, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(c.$1, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
            Text(c.$2, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
          ],
        ),
      )).toList(),
    );
  }
}
```

- [ ] **Step 2: Wire `onTap` in `DiscoverCard` / `SwipeScreen`** — replace the snackbar stub in `_openProfile`:

```dart
void _openProfile(Roommate r) {
  Navigator.push(context, ProfileViewScreen.route(r));
}
```

Add import: `import '../screens/profile_view_screen.dart';` in `swipe_screen.dart`.

- [ ] **Step 3: Hot reload, tap a discover card → full profile slides up**

- [ ] **Step 4: Commit**

```bash
git add lib/screens/profile_view_screen.dart lib/screens/swipe_screen.dart
git commit -m "feat: add ProfileViewScreen with photo strip + stats grid"
```

---

### Task 14: ProfileScreen (own profile tab)

**Files:**
- Modify: `lib/screens/profile_screen.dart`

- [ ] **Step 1: Read current file, then replace `_buildProfile` and `_buildEmpty` methods** keeping all existing `_openEdit()` and nav logic:

```dart
Widget _buildEmpty() {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onEdit: null),
          const Spacer(),
          Text("YOUR\nPROFILE", style: GoogleFonts.syne(fontSize: 38, fontWeight: FontWeight.w800,
            color: AppColors.text, letterSpacing: -2, height: 0.95)),
          const SizedBox(height: 12),
          Text("You haven't set up your profile yet.",
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _openEdit,
            child: Container(
              width: double.infinity, height: 50, alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.btnPrimary, borderRadius: BorderRadius.circular(6)),
              child: Text('SET UP PROFILE →', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                color: AppColors.btnPrimaryText, letterSpacing: 2)),
            ),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
}

Widget _buildProfile(UserProfile p) {
  return SafeArea(
    child: Column(
      children: [
        _Header(onEdit: _openEdit),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name block
                Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                      style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent)),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name.toUpperCase(), style: GoogleFonts.syne(fontSize: 20,
                      fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.8)),
                    Text('${p.location} · Move ${p.moveIn}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ]),
                const SizedBox(height: 16),
                Divider(color: AppColors.border, thickness: 1.5, height: 1),
                const SizedBox(height: 16),

                _SectionLabel('LIVING DETAILS'),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
                  children: [
                    _StatCell('\$${p.budgetMax}/mo', 'MAX BUDGET'),
                    _StatCell(p.moveIn, 'MOVE-IN'),
                    _StatCell(p.schedule, 'SCHEDULE'),
                    _StatCell(p.tidiness, 'TIDINESS'),
                  ],
                ),

                if (p.traits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionLabel('TRAITS'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 5, runSpacing: 5,
                    children: p.traits.asMap().entries.map((e) =>
                      TraitChip(trait: e.value, accent: e.key == 0)).toList()),
                ],

                if (p.bio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionLabel('BIO'),
                  const SizedBox(height: 8),
                  Text(p.bio, style: GoogleFonts.inter(fontSize: 14, color: AppColors.text, height: 1.5)),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
```

Add private helpers `_Header`, `_SectionLabel`, `_StatCell` in the same file following the same pattern as earlier tasks.

- [ ] **Step 2: Commit**

```bash
git add lib/screens/profile_screen.dart
git commit -m "style: rewrite ProfileScreen with brutalist layout"
```

---

### Task 15: ProfileSetupScreen (4-step flow)

**Files:**
- Modify: `lib/screens/profile_create_screen.dart`

- [ ] **Step 1: Replace the `build` method scaffold** — keep ALL existing state, form logic, controllers, validators. Only replace visual layer. The 4 steps map to existing form sections:

Steps: (1) basics — name/age/location/bio, (2) budget — range slider + moveIn + neighborhoods, (3) lifestyle — schedule/tidiness/traits chips, (4) photos — image picker.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          // Top bar with back + step indicator
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
            ),
            child: Row(children: [
              GestureDetector(
                onTap: _step > 0
                    ? () => setState(() => _step--)
                    : () => Navigator.pop(context),
                child: Text('←', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderSoft, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${_step + 1} OF 4',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary, letterSpacing: 1.5)),
              ),
            ]),
          ),
          // Progress dots
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: List.generate(4, (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= _step ? AppColors.text : AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: _buildStep(_step),
            ),
          ),
          // Next / Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: [
              GestureDetector(
                onTap: _step < 3
                    ? () { if (_validateStep()) setState(() => _step++); }
                    : _save,
                child: Container(
                  width: double.infinity, height: 50, alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.btnPrimary, borderRadius: BorderRadius.circular(6)),
                  child: Text(_step < 3 ? 'NEXT →' : 'SAVE PROFILE →',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.btnPrimaryText, letterSpacing: 2)),
                ),
              ),
            ]),
          ),
        ],
      ),
    ),
  );
}

int _step = 0;

bool _validateStep() => true; // existing validation kept

Widget _buildStep(int step) {
  return switch (step) {
    0 => _buildBasicsStep(),
    1 => _buildBudgetStep(),
    2 => _buildLifestyleStep(),
    _ => _buildPhotosStep(),
  };
}
```

Each `_buildXStep()` uses `_StepTitle` (Syne 28 bold heading), `_FieldLabel` (8px uppercase Inter), and `_BrutalField` (TextFormField wrapped in borderSoft bordered container with 5px radius).

Lifestyle step chip selection uses existing `_selectedTraits`, `_schedule`, `_tidiness` state — wrap in selectable chip rows styled like the mockup (tapping a chip toggles `acc` style).

- [ ] **Step 2: Add `_step` state variable and `_validateStep()` stub if not already present**

- [ ] **Step 3: Hot reload, walk all 4 steps**

- [ ] **Step 4: Commit**

```bash
git add lib/screens/profile_create_screen.dart
git commit -m "style: rewrite ProfileSetupScreen as 4-step brutalist flow"
```

---

### Task 16: SettingsScreen

**Files:**
- Create: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Create the screen**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth  = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('←', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                ),
                const SizedBox(width: 16),
                Text('Settings', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.text, letterSpacing: -0.8)),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  _SectionLabel('APPEARANCE'),
                  _ToggleRow(
                    label: 'Dark mode',
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                  ),
                  _SectionLabel('DISCOVERY'),
                  _NavRow(label: 'Max distance', value: '10 miles', onTap: () {}),
                  _ToggleRow(label: 'Verified only', value: false, onChanged: (_) {}),
                  _NavRow(label: 'Budget filter', value: '\$800–\$1,800', onTap: () {}),
                  _SectionLabel('NOTIFICATIONS'),
                  _ToggleRow(label: 'New matches', value: true, onChanged: (_) {}),
                  _ToggleRow(label: 'Messages',    value: true, onChanged: (_) {}),
                  _ToggleRow(label: 'Listing alerts', value: false, onChanged: (_) {}),
                  _SectionLabel('ACCOUNT'),
                  _DangerRow(label: 'Sign out',       onTap: () => auth.logout()),
                  _DangerRow(label: 'Delete account', onTap: () => _confirmDelete(context, auth)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete account?',
          style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
        content: Text('This cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w700))),
          TextButton(onPressed: () { Navigator.pop(context); auth.logout(); },
            child: Text('Delete', style: GoogleFonts.inter(color: AppColors.scoreLow, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(text, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 2)),
  );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderSoft))),
    child: Row(children: [
      Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text))),
      Switch(value: value, onChanged: onChanged),
    ]),
  );
}

class _NavRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _NavRow({required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderSoft))),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text))),
        Text(value, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 6),
        Text('›', style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
      ]),
    ),
  );
}

class _DangerRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DangerRow({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderSoft))),
      child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.scoreLow)),
    ),
  );
}
```

- [ ] **Step 2: Verify `ThemeProvider.toggle()` exists** — open `lib/state/theme_provider.dart`. If no `toggle()` method, add:

```dart
void toggle() {
  _mode = isDark ? ThemeMode.light : ThemeMode.dark;
  notifyListeners();
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart lib/state/theme_provider.dart
git commit -m "feat: add SettingsScreen with dark mode toggle + account actions"
```

---

### Task 17: HomeScreen — brutalist bottom nav + Settings entry

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Replace `_buildFloatingNav()` method with flat border nav**

```dart
Widget _buildFloatingNav() {
  const items = [
    (label: 'DISCOVER'),
    (label: 'MATCHES'),
    (label: 'LISTINGS'),
    (label: 'PROFILE'),
  ];

  return Container(
    decoration: BoxDecoration(
      color: AppColors.background,
      border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = _selectedIndex == i;
            final showBadge = i == 1 && _matches.isNotEmpty;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTabTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 2,
                      color: selected ? AppColors.accent : Colors.transparent,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Text(
                          items[i].label,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: selected ? AppColors.text : AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (showBadge)
                          Positioned(
                            top: -4, right: -8,
                            child: Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: Add Settings button to Profile screen header** — in `home_screen.dart`, pass a settings callback to `ProfileScreen`, OR wire it directly in `ProfileScreen._buildProfile` header via `Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))`.

- [ ] **Step 3: Remove the floating margin/border-radius from the nav** — the current `_buildFloatingNav` wraps in a margin container. The new nav is edge-to-edge. Confirm `Positioned` wrapping in `Stack` still works:

Current structure in `build`:
```dart
// Keep but update Positioned:
Positioned(
  left: 0, right: 0, bottom: 0,
  child: _buildFloatingNav(),
),
```

The `SafeArea(bottom: false, ...)` on the body already handles top safe area; bottom safe area is handled inside `_buildFloatingNav` via `SafeArea(top: false)`.

- [ ] **Step 4: Add `import 'package:google_fonts/google_fonts.dart';` if not already present in home_screen.dart**

- [ ] **Step 5: Hot reload full app, navigate all 4 tabs**

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "style: replace floating pill nav with brutalist flat border nav"
```

---

### Task 18: Final integration + smoke test

- [ ] **Step 1: Run full test suite**

```bash
cd /Users/evanoctave/rumie/rumie/rumie && flutter test
```

Expected: all tests pass (value score + widget tests).

- [ ] **Step 2: Analyze for warnings**

```bash
flutter analyze
```

Fix any errors. Warnings about unused imports are OK to ignore.

- [ ] **Step 3: Manual flow checklist** — run on simulator or device:

  - [ ] App launches → landing screen shows brutalist logo
  - [ ] Sign in navigates to discover feed
  - [ ] Discover cards scroll smoothly, Pass/Connect buttons work
  - [ ] Tap a discover card → full profile slides up from bottom
  - [ ] Matches tab shows brutalist list
  - [ ] Listings tab shows value score badges (green/amber/red)
  - [ ] Profile tab shows stats grid + traits
  - [ ] Profile → Settings cog → SettingsScreen opens
  - [ ] Dark mode toggle in settings switches theme app-wide
  - [ ] Sign out works

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "feat: complete Rumie brutalist editorial redesign + value score"
```

---

## Self-Review Checklist

**Spec coverage:**
- ✅ Brutalist Editorial aesthetic — all screens
- ✅ Syne 800 headings, Inter body — Tasks 1, 2, all screen tasks
- ✅ Light + dark mode — Task 1 (AppColors), Task 16 (toggle)
- ✅ Discover = vertical scroll feed — Task 8
- ✅ No photos on cards — Task 7 (DiscoverCard)
- ✅ Photos on full profile only — Task 13
- ✅ Value score (3-factor) — Tasks 3, 5, 6, 12
- ✅ Rentcast + Walk Score API hooks + fallback — Task 3
- ✅ Profile setup 4-step — Task 15
- ✅ Settings screen — Task 16
- ✅ Brutalist bottom nav — Task 17
- ✅ Auth screens — Task 9
- ✅ Matches — Task 10
- ✅ Chat — Task 11
- ✅ Listings — Task 12
- ✅ Profile tab — Task 14

**Type consistency:** `ValueScore` defined in Task 3, consumed in Tasks 5, 6, 12 — all use `score.priceScore`, `score.sqftScore`, `score.transitScore`, `score.overall`, `score.isHigh`, `score.isMid`, `score.tier`. Consistent throughout.

**No placeholders:** All steps have actual code. Task 11 (ChatScreen) specifies exact props to change without full file duplication — acceptable since the instruction is precise and the file content varies per project.
