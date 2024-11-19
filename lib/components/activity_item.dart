import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/providers/activity_provider.dart';

class ActivityItem extends StatelessWidget {
  final ActivityEvent activity;

  const ActivityItem({Key? key, required this.activity}) : super(key: key);

  String _getActivityMessage() {
    switch (activity.type) {
      case ActivityType.habitCompletion:
        return 'completed "${activity.habitTitle}"';
      case ActivityType.streakMilestone:
        final days = activity.metadata['streakDays'] as int;
        return 'reached a ${days}-day streak on "${activity.habitTitle}"! 🎉';
      case ActivityType.newHabit:
        final frequency = activity.metadata['frequency'] as String;
        final goal = activity.metadata['targetGoal'] as int;
        return 'started a new habit: "${activity.habitTitle}" (${goal}x ${frequency})';
      default:
        return 'did something';
    }
  }

  Widget _buildReactionButton(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final reactionIcons = {
      ReactionType.like: Icons.favorite,
      ReactionType.celebrate: Icons.celebration,
      ReactionType.support: Icons.volunteer_activism,
      ReactionType.inspire: Icons.lightbulb,
    };
    final reactionLabels = {
      ReactionType.like: 'Like',
      ReactionType.celebrate: 'Celebrate',
      ReactionType.support: 'Support',
      ReactionType.inspire: 'Inspire',
    };

    return PopupMenuButton<ReactionType>(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activity.userReaction != null
                  ? reactionIcons[activity.userReaction]!
                  : Icons.add_reaction_outlined,
              size: 20,
              color: activity.userReaction != null ? Theme.of(context).primaryColor : null,
            ),
            if (activity.reactions.isNotEmpty) ...[
              SizedBox(width: 4),
              Text(
                activity.reactions.values
                    .expand((reactions) => reactions)
                    .length
                    .toString(),
                style: TextStyle(
                  color: activity.userReaction != null
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ),
            ],
          ],
        ),
      ),
      onSelected: (ReactionType type) {
        activityProvider.toggleReaction(activity.id, type);
      },
      itemBuilder: (context) => ReactionType.values
          .map(
            (type) => PopupMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(reactionIcons[type]),
                  SizedBox(width: 8),
                  Text(reactionLabels[type]!),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReactionsList(context) {
    final reactionGroups = activity.reactions.entries.where((e) => e.value.isNotEmpty);
    if (reactionGroups.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: reactionGroups.map((entry) {
          final type = entry.key;
          final reactions = entry.value;
          final reactionIcons = {
            ReactionType.like: '❤️',
            ReactionType.celebrate: '🎉',
            ReactionType.support: '💪',
            ReactionType.inspire: '💡',
          };

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(reactionIcons[type]!),
                SizedBox(width: 4),
                Text(reactions.length.toString()),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(12.0),
            title: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: activity.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(text: _getActivityMessage()),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    timeago.format(activity.timestamp),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                _buildReactionsList(context),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Row(
              children: [
                _buildReactionButton(context),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement comment dialog
                  },
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined, size: 20),
                      SizedBox(width: 4),
                      Text(activity.comments.length.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
