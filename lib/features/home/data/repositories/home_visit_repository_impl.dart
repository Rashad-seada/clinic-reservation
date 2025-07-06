import 'package:arwa_app/features/home/data/services/home_visit_service.dart';
import 'package:arwa_app/features/home/domain/entities/home_visit_request.dart';
import 'package:arwa_app/features/home/domain/repositories/home_visit_repository.dart';

class HomeVisitRepositoryImpl implements HomeVisitRepository {
  final HomeVisitService _homeVisitService;
  
  HomeVisitRepositoryImpl(this._homeVisitService);
  
  @override
  Future<Map<String, dynamic>> scheduleHomeVisit(HomeVisitRequest request) {
    return _homeVisitService.scheduleHomeVisit(request);
  }
} 