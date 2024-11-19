import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatefulWidget {
  final String uid;
  final bool isFriendProfile;

  const ProfileDialog({
    Key? key, 
    required this.uid,
    this.isFriendProfile = false,
  }) : super(key: key);

  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> with SingleTickerProviderStateMixin {
  UserModel? _userModel;
  bool _isLoading = true;
  late TabController _tabController;
  final _tabs = ['Overview', 'Habits', 'Stats'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    debugPrint('ProfileDialog: Starting to load user data for uid: ${widget.uid}');
    try {
      Database db = Database();
      debugPrint('ProfileDialog: Attempting to fetch user from database...');
      final user = await db.userDatabase.getUserModelById(widget.uid);
      debugPrint('ProfileDialog: User data received: ${user?.toMap()}');
      setState(() {
        _userModel = user;
        _isLoading = false;
      });
      debugPrint('ProfileDialog: User data loaded successfully');
    } catch (e) {
      debugPrint('ProfileDialog: Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateHabitVisibility(String habitId, bool isVisible) async {
    if (_userModel == null) return;

    // Initialize habitVisibilitySettings if null
    _userModel!.habitVisibilitySettings ??= [];
    
    // Find existing setting or create new one
    var settingIndex = _userModel!.habitVisibilitySettings!
        .indexWhere((s) => s.habitId == habitId);
        
    if (settingIndex == -1) {
      _userModel!.habitVisibilitySettings!.add(
        HabitVisibility(habitId: habitId, isVisible: isVisible)
      );
    } else {
      _userModel!.habitVisibilitySettings![settingIndex].isVisible = isVisible;
    }
    
    setState(() {});
    
    // Update user in LS & upload to DB
    Provider.of<UserLocalStorage>(context, listen: false).currentUser = _userModel;
    Database db = Database();
    await db.userDatabase.uploadUserData(context);
  }

  Widget _buildOverviewTab() {
    if (_userModel == null) return Container();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          UserAvatar(
            username: _userModel!.username,
            size: 80.0,
          ),
          SizedBox(height: 16),
          Text(
            _userModel!.username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _userModel?.bio?.isEmpty ?? true ? 'No bio available.' : _userModel!.bio!,
            style: kMainDescription.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: kGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildLevelProgressBar(),
          const SizedBox(height: 20),
          _buildConfidenceIndicator(),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar() {
    if (_userModel == null) return Container();
    
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          child: RoundedProgressBar(
            progress: _userModel!.userXP / _userModel!.levelUpRequirement,
            color: kPrimaryColor,
            lineHeight: 50.0,
          ),
        ),
        Text(
          _userModel!.userLevel.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator() {
    if (_userModel == null) return Container();
    
    final confidenceLevel = StatsCalculator()
        .calculateAverageValueForStat('confidenceLevel', _userModel?.stats ?? []);
    
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: kLightGreenAccent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😎', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            confidenceLevel.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsTab() {
    final habitManager = Provider.of<HabitManager>(context);
    final habits = habitManager.habits;

    if (widget.isFriendProfile) {
      return _buildVisibleHabitsList(habits);
    }
    
    return _buildOwnHabitsList(habits);
  }

  Widget _buildOwnHabitsList(List<Habit> habits) {
    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No habits yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isVisible = _userModel?.habitVisibilitySettings
            ?.firstWhere(
              (s) => s.habitId == habit.id.toString(),
              orElse: () => HabitVisibility(habitId: habit.id.toString()),
            )
            .isVisible ?? false;

        return Card(
          color: kDarkPrimaryColor.withOpacity(0.2),
          child: ListTile(
            title: Text(
              habit.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak: ${habit.streak} days',
                  style: const TextStyle(color: kLightGreenAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${habit.confidenceLevel.toStringAsFixed(1)}%',
                  style: const TextStyle(color: kLightGreenAccent),
                ),
                const SizedBox(height: 8),
                RoundedProgressBar(
                  progress: habit.confidenceLevel / 100,
                  color: kPrimaryColor,
                  lineHeight: 8.0,
                ),
              ],
            ),
            trailing: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: isVisible ? kLightGreenAccent : kGray,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisibleHabitsList(List<Habit> habits) {
    final visibleHabits = habits.where((habit) {
      return _userModel?.habitVisibilitySettings
          ?.firstWhere(
            (s) => s.habitId == habit.id.toString(),
            orElse: () => HabitVisibility(habitId: habit.id.toString()),
          )
          .isVisible ?? false;
    }).toList();

    if (visibleHabits.isEmpty) {
      return const Center(
        child: Text(
          'No habits shared yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: visibleHabits.length,
      itemBuilder: (context, index) {
        final habit = visibleHabits[index];
        return Card(
          color: kDarkPrimaryColor.withOpacity(0.2),
          child: ListTile(
            title: Text(
              habit.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak: ${habit.streak} days',
                  style: const TextStyle(color: kLightGreenAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${habit.confidenceLevel.toStringAsFixed(1)}%',
                  style: const TextStyle(color: kLightGreenAccent),
                ),
                const SizedBox(height: 8),
                RoundedProgressBar(
                  progress: habit.confidenceLevel / 100,
                  color: kPrimaryColor,
                  lineHeight: 8.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_userModel?.stats?.isEmpty ?? true) {
      return const Center(
        child: Text(
          'No stats available yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    debugPrint('Building stats tab with ${_userModel!.stats!.length} stat points');
    
    try {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            LineGraph(
              data: _userModel!.stats!,
              title: 'Confidence Level',
              statName: 'confidenceLevel',
              color: kLightGreenAccent,
            ),
            const SizedBox(height: 20),
            LineGraph(
              data: _userModel!.stats!,
              title: 'Consistency',
              statName: 'consistencyFactor',
              color: kPrimaryColor,
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building stats tab: $e');
      return Center(
        child: Text(
          'Error loading stats',
          style: TextStyle(color: kGray),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(15),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 6.0,
                ),
              )
            : _userModel != null
                ? Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: _tabs.map((tab) => Tab(
                          text: tab,
                          height: 40,
                        )).toList(),
                        labelColor: kLightGreenAccent,
                        unselectedLabelColor: kGray,
                        indicatorColor: kLightGreenAccent,
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(),
                            _buildHabitsTab(),
                            _buildStatsTab(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'User not found',
                      style: TextStyle(
                        color: kGray,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
      ),
    );
  }
}
