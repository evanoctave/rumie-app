import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/services/value_score.dart';
import 'package:roomie/services/value_score_service.dart';

void main() {
  group('ValueScore.computeOverall', () {
    test('all 100 → overall 100', () {
      expect(ValueScore.computeOverall(priceScore: 100, sqftScore: 100, transitScore: 100), 100);
    });

    test('0 price, 100 sqft, 100 transit → 60 (0*0.4 + 100*0.35 + 100*0.25)', () {
      expect(ValueScore.computeOverall(priceScore: 0, sqftScore: 100, transitScore: 100), 60);
    });

    test('great deal tier at 75+', () {
      final s = ValueScore(overall: 80, priceScore: 80, sqftScore: 80, transitScore: 80);
      expect(s.tier, 'Great deal');
      expect(s.isHigh, true);
    });

    test('fair deal tier at 50–74', () {
      final s = ValueScore(overall: 62, priceScore: 62, sqftScore: 62, transitScore: 62);
      expect(s.tier, 'Fair deal');
      expect(s.isMid, true);
    });

    test('below avg tier under 50', () {
      final s = ValueScore(overall: 30, priceScore: 30, sqftScore: 30, transitScore: 30);
      expect(s.tier, 'Below avg');
      expect(s.isHigh, false);
      expect(s.isMid, false);
    });
  });

  group('ValueScoreService.estimateFallback', () {
    test('same inputs always return same score', () {
      final svc = ValueScoreService();
      final a = svc.estimateFallback(rent: 1400, sqft: 800, location: 'Brooklyn');
      final b = svc.estimateFallback(rent: 1400, sqft: 800, location: 'Brooklyn');
      expect(a.overall, b.overall);
    });

    test('cheaper rent scores higher than expensive rent at same sqft', () {
      final svc = ValueScoreService();
      final cheap  = svc.estimateFallback(rent: 800,  sqft: 800, location: 'Brooklyn');
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
