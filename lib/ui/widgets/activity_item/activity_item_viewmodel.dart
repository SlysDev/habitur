import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../enums/reaction_type.dart';
import '../../../models/activity_event.dart';
import '../../../services/activity_service.dart';

class ActivityItemViewModel extends BaseViewModel {
  final _activityService = locator<ActivityService>();

  Future<void> toggleReaction(String activityId, ReactionType type) async {
    await runBusyFuture(_activityService.toggleReaction(activityId, type));
  }

  Future<void> likeActivity(String activityId) async {
    await _activityService.likeActivity(activityId);
    notifyListeners();
  }

  Future<void> unlikeActivity(String activityId) async {
    await _activityService.unlikeActivity(activityId);
    notifyListeners();
  }

  Future<void> deleteActivity(String activityId) async {
    await runBusyFuture(_activityService.deleteActivity(activityId));
  }

  Future<void> showReactionPicker(
      BuildContext context, String activityId) async {
    final reactionTypes =
        ReactionType.values.where((type) => type != ReactionType.none);

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'React to this activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: reactionTypes.map((type) {
                String emoji;
                String label = type.name;

                switch (type) {
                  case ReactionType.like:
                    emoji = '❤️';
                    label = 'Like';
                    break;
                  case ReactionType.love:
                    emoji = '😍';
                    label = 'Love';
                    break;
                  case ReactionType.inspire:
                    emoji = '💪';
                    label = 'Inspire';
                    break;
                  case ReactionType.celebrate:
                    emoji = '🎉';
                    label = 'Celebrate';
                    break;
                  case ReactionType.support:
                    emoji = '🙌';
                    label = 'Support';
                    break;
                  case ReactionType.proud:
                    emoji = '🦁';
                    label = 'Proud';
                    break;
                  case ReactionType.fire:
                    emoji = '🔥';
                    label = 'Fire';
                    break;
                  case ReactionType.strong:
                    emoji = '💪';
                    label = 'Strong';
                    break;
                  case ReactionType.none:
                    emoji = '';
                    label = '';
                    break;
                }

                return InkWell(
                  onTap: () {
                    _activityService.toggleReaction(activityId, type);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
    notifyListeners();
  }
}
