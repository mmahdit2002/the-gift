import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_event.dart';
import 'app_state.dart';
import '../models/models.dart';
import '../repositories/app_repository.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppRepository _repository = AppRepository();

  AppBloc() : super(AppState()) {
    on<LoadAppData>(_onLoadData);
    on<StartTask>(_onStartTask);
    on<CompleteTask>(_onCompleteTask);
    on<UnlockPrize>(_onUnlockPrize);
  }

  Future<void> _onLoadData(LoadAppData event, Emitter<AppState> emit) async {
    emit(AppState(isLoading: true));
    try {
      // 1. Load Data
      List<DayModel> days = await _repository.loadDays();
      DateTime? startDate = await _repository.loadStartDate();

      // 2. Recalculate Status based on Real Time
      if (startDate != null) {
        final now = DateTime.now();
        // Calculate difference in days (ignoring hours/minutes for safety)
        final startZero = DateTime(startDate.year, startDate.month, startDate.day);
        final nowZero = DateTime(now.year, now.month, now.day);
        final daysPassed = nowZero.difference(startZero).inDays;

        // Apply Logic to each day
        days = days.asMap().entries.map((entry) {
          int index = entry.key;
          DayModel day = entry.value;

          if (index < daysPassed) {
            // PAST DAYS: If not claimed, it's EXPIRED.
            return DayModel(
              id: day.id,
              jalaliDate: day.jalaliDate,
              categories: day.categories,
              prizeType: day.prizeType,
              prizeContent: day.prizeContent,
              isPrizeClaimed: day.isPrizeClaimed, // Keep claimed status
              isDayUnlocked: false, // Locked because it's past
              isExpired: !day.isPrizeClaimed, // Expired if you didn't finish it!
            );
          } else if (index == daysPassed) {
            // CURRENT DAY: Must be Unlocked.
            return DayModel(
              id: day.id,
              jalaliDate: day.jalaliDate,
              categories: day.categories,
              prizeType: day.prizeType,
              prizeContent: day.prizeContent,
              isPrizeClaimed: day.isPrizeClaimed,
              isDayUnlocked: true, // OPEN!
              isExpired: false,
            );
          } else {
            // FUTURE DAYS: Locked.
            return DayModel(
              id: day.id,
              jalaliDate: day.jalaliDate,
              categories: day.categories,
              prizeType: day.prizeType,
              prizeContent: day.prizeContent,
              isPrizeClaimed: day.isPrizeClaimed,
              isDayUnlocked: false, // Wait for your time
              isExpired: false,
            );
          }
        }).toList();

        // Save the recalculated states
        await _repository.saveDays(days);
      }

      emit(AppState(days: days, isLoading: false));
    } catch (e) {
      emit(AppState(error: "Error: $e", isLoading: false));
    }
  }

  Future<void> _onStartTask(StartTask event, Emitter<AppState> emit) async {
    // ... (Same as previous code - logic saves time immediately)
    final updatedDays = state.days.map((day) {
      if (day.id == event.dayId) {
        final newCategories = day.categories.map((cat) {
          if (cat.title == event.categoryTitle) {
            final newTasks = cat.tasks.map((task) {
              if (task.id == event.taskId && task.startTime == null) {
                task.startTime = DateTime.now(); // Saved instantly
              }
              return task;
            }).toList();
            return TaskCategory(title: cat.title, tasks: newTasks);
          }
          return cat;
        }).toList();
        return _cloneDay(day, newCategories);
      }
      return day;
    }).toList();

    emit(AppState(days: updatedDays));
    await _repository.saveDays(updatedDays);
  }

  Future<void> _onCompleteTask(CompleteTask event, Emitter<AppState> emit) async {
    // ... (Same as previous code)
    bool cheatDetected = false;
    final updatedDays = state.days.map((day) {
      if (day.id == event.dayId) {
        final newCategories = day.categories.map((cat) {
          if (cat.title == event.categoryTitle) {
            final newTasks = cat.tasks.map((task) {
              if (task.id == event.taskId) {
                // PERSISTENT CHECK: Compares Now vs Saved Time
                if (task.startTime != null) {
                  final duration = DateTime.now().difference(task.startTime!).inSeconds;
                  if (duration >= task.minSeconds) {
                    task.isCompleted = true;
                    task.startTime = null;
                  } else {
                    cheatDetected = true;
                  }
                } else {
                  task.startTime = DateTime.now();
                }
              }
              return task;
            }).toList();
            return TaskCategory(title: cat.title, tasks: newTasks);
          }
          return cat;
        }).toList();
        return _cloneDay(day, newCategories);
      }
      return day;
    }).toList();

    if (!cheatDetected) {
      emit(AppState(days: updatedDays));
      await _repository.saveDays(updatedDays);
    }
  }

  Future<void> _onUnlockPrize(UnlockPrize event, Emitter<AppState> emit) async {
    // Check if this is the FIRST DAY being completed
    // We used id "day_0" for the first day in repository
    if (event.dayId == "day_0") {
      DateTime? existingStart = await _repository.loadStartDate();
      if (existingStart == null) {
        // TRIGGER THE JOURNEY CALENDAR NOW
        await _repository.saveStartDate(DateTime.now());
      }
    }

    final updatedDays = state.days.map((day) {
      if (day.id == event.dayId) {
        return DayModel(
          id: day.id,
          jalaliDate: day.jalaliDate,
          categories: day.categories,
          prizeType: day.prizeType,
          prizeContent: day.prizeContent,
          isDayUnlocked: day.isDayUnlocked,
          isExpired: day.isExpired,
          isPrizeClaimed: true, // MARK CLAIMED
        );
      }
      return day;
    }).toList();

    emit(AppState(days: updatedDays));
    await _repository.saveDays(updatedDays);

    // RELOAD DATA to apply the calendar logic immediately
    // If we just finished Day 1, reloading will calculate that Day 2 is tomorrow (locked)
    add(LoadAppData());
  }

  // Helper to clone day easily
  DayModel _cloneDay(DayModel d, List<TaskCategory> newCats) {
    return DayModel(
      id: d.id,
      jalaliDate: d.jalaliDate,
      categories: newCats,
      prizeType: d.prizeType,
      prizeContent: d.prizeContent,
      isDayUnlocked: d.isDayUnlocked,
      isPrizeClaimed: d.isPrizeClaimed,
      isExpired: d.isExpired,
    );
  }
}
