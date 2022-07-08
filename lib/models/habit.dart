class Habit {
  String title;
  String category;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  double difficulty;
  List daysOfCompletion = [];
  Habit(
      {required this.title, required this.category, required this.difficulty});
}
