abstract class AppEvent {}

class LoadAppData extends AppEvent {}

class CompleteOnboarding extends AppEvent {}

class StartTask extends AppEvent {
  final String dayId;
  final String categoryTitle;
  final String taskId;
  StartTask(this.dayId, this.categoryTitle, this.taskId);
}

class CompleteTask extends AppEvent {
  final String dayId;
  final String categoryTitle;
  final String taskId;
  CompleteTask(this.dayId, this.categoryTitle, this.taskId);
}

class UnlockPrize extends AppEvent {
  final String dayId;
  UnlockPrize(this.dayId);
}
