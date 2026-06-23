class ValueScore {
  final int overall;
  final int priceScore;
  final int sqftScore;
  final int transitScore;

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

  static int computeOverall({
    required int priceScore,
    required int sqftScore,
    required int transitScore,
  }) {
    return ((priceScore * 0.40) + (sqftScore * 0.35) + (transitScore * 0.25)).round();
  }
}
