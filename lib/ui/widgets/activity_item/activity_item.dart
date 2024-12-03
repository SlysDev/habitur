import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/ui/widgets/activity_item/activity_item_viewmodel.dart';

import '../../../app/app.locator.dart';
import '../../../enums/activity_type.dart';
import '../../../enums/reaction_type.dart';
import '../../../services/auth_service.dart';
import '../../../ui/widgets/user_avatar/user_avatar.dart';

class ActivityItem extends StatefulWidget {
  final ActivityEvent activity;
  final _authService = locator<AuthService>();

  ActivityItem({required this.activity});

  String _getActivityMessage() {
    switch (activity.type) {
      case ActivityType.habitProgress:
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

  @override
  _ActivityItemState createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  bool _showAllComments = false;
  int _initialCommentCount = 1;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ActivityItemViewModel>.reactive(
      viewModelBuilder: () => ActivityItemViewModel(),
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          color: kFadedBlue.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kFadedBlue.withOpacity(0.6),
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: LoadingOverlay(
          isLoading: model.isBusy,
          borderRadius: 12,
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
                        text: widget.activity.username,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: kPrimaryColor,
                        ),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: widget._getActivityMessage(),
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
                        timeago.format(widget.activity.timestamp),
                        style: TextStyle(
                          fontSize: 13,
                          color: kDarkGray.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (!widget.activity.hasLiked) {
                                    await model
                                        .likeActivity(widget.activity.id);
                                  } else {
                                    await model
                                        .unlikeActivity(widget.activity.id);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: widget.activity.hasLiked
                                        ? Colors.red.withOpacity(0.1)
                                        : kFadedBlue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: widget.activity.hasLiked
                                          ? Colors.red.withOpacity(0.2)
                                          : kFadedBlue.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: Duration(milliseconds: 400),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        child: widget.activity.hasLiked
                                            ? Icon(
                                                Icons.favorite,
                                                size: 18,
                                                color: Colors.red,
                                                key: ValueKey('liked'),
                                              )
                                            : Icon(
                                                Icons.favorite_border,
                                                size: 18,
                                                color: Colors.grey,
                                                key: ValueKey('unliked'),
                                              ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        widget.activity.likeCount.toString(),
                                        style: TextStyle(
                                          color: widget.activity.hasLiked
                                              ? Colors.red
                                              : Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.activity.reactions.isNotEmpty)
                                ...widget.activity.reactions.entries
                                    .where((entry) => entry.value.length > 0)
                                    .map((entry) {
                                  final reactionType = entry.key;
                                  final count = entry.value.length;
                                  String emoji =
                                      reactionIcons[reactionType] ?? '👍';

                                  return GestureDetector(
                                    onTap: () async {
                                      await model.toggleReaction(
                                          widget.activity.id, reactionType);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: kFadedBlue.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: kFadedBlue.withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(emoji,
                                              style: TextStyle(fontSize: 14)),
                                          SizedBox(width: 6),
                                          Text(
                                            count.toString(),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                        if (widget.activity.userId ==
                            widget._authService.currentUser?.uid)
                          IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () =>
                                model.deleteActivity(widget.activity.id),
                          ),
                      ],
                    ),
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => model.showReactionPicker(
                            context, widget.activity.id),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
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
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: kFadedBlue.withOpacity(0.6),
              ),
              SizedBox(height: 12),
              if (widget.activity.comments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...widget.activity.comments
                          .take(_showAllComments
                              ? widget.activity.comments.length
                              : _initialCommentCount)
                          .map((comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  children: [
                                    UserAvatar(
                                        username: comment.username, size: 0.8),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.username,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: kPrimaryColor,
                                            ),
                                          ),
                                          Text(
                                            comment.text,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: kGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      timeago.format(comment.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kDarkGray,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      if (widget.activity.comments.length >
                          _initialCommentCount)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAllComments = !_showAllComments;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              _showAllComments
                                  ? 'Show less'
                                  : 'Show all comments',
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: model.commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: kFadedBlue.withOpacity(0.1),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: kPrimaryColor),
                      onPressed: () => model.addComment(widget.activity.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
