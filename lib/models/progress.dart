import 'dart:math' as math;

/// Represents the progress of a habit towards its target goal.
/// This class ensures that progress is always valid and provides
/// type-safe operations for manipulating progress values.
class Progress {
  /// Current progress value
  final int current;

  /// Target goal to reach
  final int target;

  /// Creates a new Progress instance.
  /// [current] must not be negative and cannot exceed [target].
  Progress({
    required this.current,
    required this.target,
  })  : assert(current >= 0, 'Current progress cannot be negative'),
        assert(target > 0, 'Target must be positive'),
        assert(current <= target, 'Current progress cannot exceed target');

  /// Creates a new Progress instance starting at zero.
  Progress.zero({required int target}) : this(current: 0, target: target);

  /// Returns true if the current progress equals the target.
  bool get isComplete => current == target;

  /// Returns the completion percentage (0.0 to 1.0).
  double get percentage => current / target;

  /// Returns a new Progress instance with incremented current value.
  /// The new value will not exceed the target.
  /// Optionally accepts a difficulty rating for stats tracking.
  Progress increment({int amount = 1}) {
    assert(amount > 0, 'Increment amount must be positive');
    return Progress(
      current: math.min(current + amount, target),
      target: target,
    );
  }

  /// Returns a new Progress instance with decremented current value.
  /// The new value will not go below zero.
  Progress decrement({int amount = 1}) {
    assert(amount > 0, 'Decrement amount must be positive');
    return Progress(
      current: math.max(current - amount, 0),
      target: target,
    );
  }

  /// Creates a new Progress instance with a different target,
  /// maintaining the same completion percentage if possible.
  Progress withNewTarget(int newTarget) {
    assert(newTarget > 0, 'New target must be positive');
    final newCurrent = (percentage * newTarget).round();
    return Progress(
      current: newCurrent,
      target: newTarget,
    );
  }

  /// Returns a new Progress instance reset to zero with the same target.
  Progress reset() => Progress(current: 0, target: target);

  @override
  String toString() => '$current/$target';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Progress &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          target == other.target;

  @override
  int get hashCode => current.hashCode ^ target.hashCode;

  /// Converts the Progress instance to a Map for serialization.
  Map<String, dynamic> toJson() => {
        'current': current,
        'target': target,
      };

  /// Creates a Progress instance from a Map.
  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        current: json['current'] as int,
        target: json['target'] as int,
      );
}
