class Habit {
  String name;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  double difficulty;
  List daysOfCompletion = [];
  Habit({required this.name, required this.difficulty});
}
