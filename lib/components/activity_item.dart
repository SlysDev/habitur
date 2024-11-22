import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/auth_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/providers/activity_provider.dart';

class ActivityItem extends StatelessWidget {
  final ActivityEvent activity;

  ActivityItem({required this.activity});

  final Map<ReactionType, String> reactionIcons = {
    ReactionType.like: '❤️',
    ReactionType.celebrate: '🎉',
    ReactionType.support: '💪',
    ReactionType.inspire: '💡',
  };

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

  Future<void> _handleReactionPickerTap(BuildContext context, entry) async {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    showStatusOverlay(
        context,
        'Adding reaction...',
        () async =>
            await activityProvider.toggleReaction(activity.id, entry.key),
        successMessage: 'Reaction added!');
  }

  void _showReactionPicker(BuildContext context) {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: kBackgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: kFadedBlue,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  Text(
                    'Add Reaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: reactionIcons.entries.map((entry) {
                      final isSelected = activity.userReaction == entry.key;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await _handleReactionPickerTap(context, entry);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kPrimaryColor.withOpacity(0.8)
                                  : kGray.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? kPrimaryColor.withOpacity(1)
                                    : kGray.withOpacity(0.8),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  entry.value,
                                  style: TextStyle(fontSize: 32),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionDetails(BuildContext context) {
    // Get all reactions in a single list
    final allReactions = activity.reactions.entries.expand((entry) {
      final reactionType = entry.key;
      return entry.value.map((reaction) => MapEntry(reactionType, reaction));
    }).toList();

    // Sort by timestamp, most recent first
    allReactions.sort((a, b) => b.value.timestamp.compareTo(a.value.timestamp));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: kBackgroundColor.withOpacity(0.95),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: kFadedBlue,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Reactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
            ),
            Divider(height: 1, color: kFadedBlue),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allReactions.length,
                itemBuilder: (context, index) {
                  final reaction = allReactions[index];
                  final isCurrentUser =
                      reaction.value.userId == AuthService().currentUser!.uid;
                  return ListTile(
                    leading: Text(
                      reactionIcons[reaction.key]!,
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      isCurrentUser ? 'You' : reaction.value.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: kDarkGray,
                      ),
                    ),
                    subtitle: Text(
                      timeago.format(reaction.value.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: kDarkGray.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showReactionPicker(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_reaction_outlined,
                    size: 20, color: kPrimaryColor),
                SizedBox(width: 6),
                Text(
                  'React',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleReactionTap(
      ReactionType type, BuildContext context) async {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    showStatusOverlay(context, 'Updating reaction...', () async {
      await activityProvider.toggleReaction(activity.id, type);
    }, successMessage: 'Reaction updated!');
  }

  Widget _buildReactionsList(context) {
    // Filter out reactions with no reactions and empty lists
    final nonEmptyReactions = activity.reactions.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (nonEmptyReactions.isEmpty) return SizedBox.shrink();

    final isActivityOwner = activity.userId == AuthService().currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: nonEmptyReactions.map((entry) {
              final type = entry.key;
              final reactions = entry.value;
              final hasUserReacted = reactions
                  .any((r) => r.userId == AuthService().currentUser!.uid);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    _handleReactionTap(type, context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasUserReacted
                          ? kPrimaryColor.withOpacity(0.3)
                          : kFadedBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: hasUserReacted
                          ? Border.all(
                              color: kPrimaryColor.withOpacity(0.4),
                              width: 1,
                            )
                          : null,
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reactionIcons[type]!,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          reactions.length.toString(),
                          style: TextStyle(
                            color: hasUserReacted ? kPrimaryColor : kDarkGray,
                            fontWeight: hasUserReacted
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (isActivityOwner) ...[
            SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _showReactionDetails(context),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kFadedBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: kDarkGray,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kFadedBlue.withOpacity(0.6),
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: activity.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: kPrimaryColor,
                    ),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: _getActivityMessage(),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    timeago.format(activity.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: kDarkGray.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                _buildReactionsList(context),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: kFadedBlue.withOpacity(0.6),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                _buildReactionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
