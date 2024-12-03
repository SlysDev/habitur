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
    await runBusyFuture(_activityService.likeActivity(activityId));
    rebuildUi();
  }

  Future<void> unlikeActivity(String activityId) async {
    await runBusyFuture(_activityService.unlikeActivity(activityId));
    rebuildUi();
  }

  Future<void> deleteActivity(String activityId) async {
    await runBusyFuture(_activityService.deleteActivity(activityId));
  }

  Future<void> showReactionPicker(
      BuildContext context, String activityId) async {
    final reactionTypes =
        ReactionType.values.where((type) => type != ReactionType.none);
    await runBusyFuture(showModalBottomSheet(
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
                String emoji = reactionIcons[type] ?? '👍';
                String label =
                    type.name[0].toUpperCase() + type.name.substring(1);

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
    ));

    rebuildUi();
  }
}
