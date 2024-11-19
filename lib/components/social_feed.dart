import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:provider/provider.dart';
import 'package:habitur/components/community-habit-list.dart';
import 'package:habitur/components/activity_item.dart';
import 'package:habitur/providers/activity_provider.dart';
import 'package:habitur/models/activity_event.dart';

class SocialFeed extends StatefulWidget {
  final Future<void> Function() onRefresh;

  const SocialFeed({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await Provider.of<ActivityProvider>(context, listen: false).loadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kPrimaryColor,
      backgroundColor: Colors.transparent,
      strokeWidth: 4.0,
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Community Habits Section
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Community Habits',
                    style: kSubHeadingTextStyle,
                  ),
                ),
                CommunityHabitList(onRefresh: widget.onRefresh),
              ],
            ),
          ),

          // Activity Feed Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Friend Activity',
                    style: kSubHeadingTextStyle,
              ),
            ),
          ),

          // Activity Stream
          StreamBuilder<List<ActivityEvent>>(
            stream: Provider.of<ActivityProvider>(context).getActivitiesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Error in Activity Stream: ${snapshot.error}');
                debugPrint('Stack Trace: ${snapshot.stackTrace}');
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: kMainDescription,
                          ),
                          TextButton(
                            onPressed: widget.onRefresh,
                            child: Text('Try Again', style: kMainDescription.copyWith(color: kPrimaryColor),),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Only show loading indicator on initial load
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Theme.of(context).disabledColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No activity yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Complete habits or add friends to see activity',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == snapshot.data!.length) {
                      return _isLoadingMore
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : SizedBox.shrink();
                    }
                    final activity = snapshot.data![index];
                    return ActivityItem(activity: activity);
                  },
                  childCount: snapshot.data!.length + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
