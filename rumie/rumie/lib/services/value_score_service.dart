import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import 'value_score.dart';

class ValueScoreService {
  static final ValueScoreService _instance = ValueScoreService._();
  factory ValueScoreService() => _instance;
  ValueScoreService._();

  final Map<String, ValueScore> _cache = {};

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

  /// Deterministic local estimate — no API key required.
  ValueScore estimateFallback({
    required int rent,
    required int sqft,
    required String location,
  }) {
    // Price vs NYC median ~$2,000. Score 100 at $800, 0 at $3,500+.
    final priceScore = ((3500 - rent) / (3500 - 800) * 100).clamp(0, 100).toInt();

    // $/sqft vs NYC avg ~$3. Score 100 at ≤$1.50/sqft, 0 at ≥$5/sqft.
    final ppsf = sqft > 0 ? rent / sqft : 3.0;
    final sqftScore = ((5.0 - ppsf) / (5.0 - 1.5) * 100).clamp(0, 100).toInt();

    // Transit: stable hash from location string (45–95 range).
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
    int priceScore = 70;
    final rentcastResp = await http.get(
      Uri.parse('https://api.rentcast.io/v1/markets?zipCode=$zipCode'),
      headers: {'X-Api-Key': ApiKeys.rentcast},
    );
    if (rentcastResp.statusCode == 200) {
      final data = jsonDecode(rentcastResp.body);
      final median = (data['rentPrice']?['median'] as num?)?.toInt() ?? 2000;
      priceScore = ((median - rent) / median * 100 + 50).clamp(0, 100).toInt();
    }

    int transitScore = 70;
    final wsResp = await http.get(
      Uri.parse(
        'https://api.walkscore.com/score?format=json&address=${Uri.encodeComponent(location)}&wsapikey=${ApiKeys.walkScore}',
      ),
    );
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
