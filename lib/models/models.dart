enum PrizeType { image, video, voice, letter }

class TaskItem {
  final String id;
  final String title;
  final int minSeconds;
  final String? link;
  bool isCompleted;
  DateTime? startTime;

  TaskItem({required this.id, required this.title, required this.minSeconds, this.link, this.isCompleted = false, this.startTime});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'minSeconds': minSeconds,
    'link': link,
    'isCompleted': isCompleted,
    // CRITICAL: We save the specific timestamp.
    // Even if app restarts, this time remains fixed.
    'startTime': startTime?.toIso8601String(),
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'],
    title: json['title'],
    minSeconds: json['minSeconds'],
    link: json['link'],
    isCompleted: json['isCompleted'] ?? false,
    startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
  );
}

class TaskCategory {
  final String title;
  final List<TaskItem> tasks;

  TaskCategory({required this.title, required this.tasks});

  bool get isComplete => tasks.every((t) => t.isCompleted);

  Map<String, dynamic> toJson() => {'title': title, 'tasks': tasks.map((t) => t.toJson()).toList()};

  factory TaskCategory.fromJson(Map<String, dynamic> json) => TaskCategory(title: json['title'], tasks: (json['tasks'] as List).map((t) => TaskItem.fromJson(t)).toList());
}

class DayModel {
  final String id;
  final String jalaliDate;
  final List<TaskCategory> categories;
  final PrizeType prizeType;
  final String prizeContent;

  // Status Flags
  bool isDayUnlocked; // Is it available to play?
  bool isPrizeClaimed; // Is it finished?
  bool isExpired; // Did we miss the date?

  DayModel({
    required this.id,
    required this.jalaliDate,
    required this.categories,
    required this.prizeType,
    required this.prizeContent,
    this.isDayUnlocked = false,
    this.isPrizeClaimed = false,
    this.isExpired = false, // New Flag
  });

  bool get isAllTasksComplete => categories.every((c) => c.isComplete);

  Map<String, dynamic> toJson() => {
    'id': id,
    'jalaliDate': jalaliDate,
    'categories': categories.map((c) => c.toJson()).toList(),
    'prizeType': prizeType.index,
    'prizeContent': prizeContent,
    'isDayUnlocked': isDayUnlocked,
    'isPrizeClaimed': isPrizeClaimed,
    'isExpired': isExpired,
  };

  factory DayModel.fromJson(Map<String, dynamic> json) => DayModel(
    id: json['id'],
    jalaliDate: json['jalaliDate'],
    categories: (json['categories'] as List).map((c) => TaskCategory.fromJson(c)).toList(),
    prizeType: PrizeType.values[json['prizeType']],
    prizeContent: json['prizeContent'],
    isDayUnlocked: json['isDayUnlocked'] ?? false,
    isPrizeClaimed: json['isPrizeClaimed'] ?? false,
    isExpired: json['isExpired'] ?? false,
  );
}
