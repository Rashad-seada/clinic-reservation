import 'package:arwa_app/features/home/domain/entities/home_visit_request.dart';

abstract class HomeVisitRepository {
  Future<Map<String, dynamic>> scheduleHomeVisit(HomeVisitRequest request);
} 