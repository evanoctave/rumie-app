import '../../data/models/swipe_in.dart';
import '../../data/models/swipe_out.dart';

abstract class SwipeRepository {
  Future<SwipeOut> swipe(SwipeIn body);
}
