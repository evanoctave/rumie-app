// Exception types live in the domain layer so screens can catch them without
// importing `lib/data/` (V17). Re-exported here for the data layer.
export '../../domain/errors/api_exception.dart';
