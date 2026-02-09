import '../models/models.dart';

class AppState {
  final List<DayModel> days;
  final bool isLoading;
  final String? error;

  AppState({this.days = const [], this.isLoading = false, this.error});
}
