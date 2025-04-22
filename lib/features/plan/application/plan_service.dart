// features/plan/application/plan_service.dart
import 'dart:io';
import '../data/plan_remote_datasource.dart';
import '../domain/event_model.dart';

class PlanService {
  final PlanRemoteDataSource _remote = PlanRemoteDataSource();

  Future<List<EventModel>> uploadAndExtractEvents(File file) {
    return _remote.extractEventsFromPDF(file);
  }

  Future<void> addEvent(EventModel event) {
    return _remote.addEventToCalendar(event);
  }
}
