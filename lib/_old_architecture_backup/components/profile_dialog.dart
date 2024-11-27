import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/components/stat-chips/confidence_level_stat_chip.dart';
import 'package:habitur/components/stat-chips/difficulty_rating_stat_chip.dart';
import 'package:habitur/components/stat-chips/stat_chip.dart';
import 'package:habitur/components/streak_stat_chip.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/components/visible_habit_list.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/auth_service.dart';
import 'package:habitur/modules/stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/ui/widgets/line_graph/line_graph.dart';

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

class _ProfileDialogState extends State<ProfileDialog> {
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.uid == AuthService().currentUser!.uid) {
      _userModel =
          Provider.of<UserLocalStorage>(context, listen: false).currentUser;
      _isLoading = false;
      return;
    }
    debugPrint(
        'ProfileDialog: Starting to load user data for uid: ${widget.uid}');
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

    _userModel!.habitVisibilitySettings ??= [];
    var settingIndex = _userModel!.habitVisibilitySettings!
        .indexWhere((s) => s.habitId == habitId);

    if (settingIndex == -1) {
      _userModel!.habitVisibilitySettings!
          .add(HabitVisibility(habitId: habitId, isVisible: isVisible));
    } else {
      _userModel!.habitVisibilitySettings![settingIndex].isVisible = isVisible;
    }

    setState(() {});

    Provider.of<UserLocalStorage>(context, listen: false).currentUser =
        _userModel;
    Database db = Database();
    await db.userDatabase.uploadUserData(context);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
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
            username: _userModel?.username ?? 'No username found',
            size: 80.0,
          ),
          SizedBox(height: 16),
          Text(
            _userModel?.username ?? 'No username found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _userModel?.bio?.isEmpty ?? true
                ? 'No bio available.'
                : _userModel!.bio!,
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

    final confidenceLevel = StatsCalculator().calculateAverageValueForStat(
        'confidenceLevel', _userModel?.stats ?? []);
    return StatChip(
      icon: Icons.sentiment_satisfied_rounded,
      label: confidenceLevel.toStringAsFixed(2),
      color: kLightGreenAccent,
      size: 1.8,
    );

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
    if (_userModel == null) return Container();

    return VisibleHabitList(
      userId: widget.uid,
      isFriendProfile: widget.isFriendProfile,
      habitsScope: _userModel?.privacySettings?.habitsScope,
      habits: _userModel?.uid == AuthService().currentUser!.uid
          ? Provider.of<HabitManager>(context).habits
          : null,
    );
  }

  Widget _buildStatsTab() {
    bool userHasChosenToShareStats =
        _userModel?.privacySettings?.statsScope == SharingScope.everyone ||
            (_userModel?.privacySettings?.statsScope == SharingScope.friends &&
                widget.isFriendProfile);
    debugPrint('User model: ${_userModel?.toString()}');
    debugPrint(
        'Profile dialog: User has ${userHasChosenToShareStats ? '' : 'not '}chosen to share their stats');
    if (_userModel?.stats?.isEmpty ?? true) {
      return const Center(
        child: Text(
          'No stats to display',
          style: TextStyle(color: kGray),
        ),
      );
    }

    debugPrint(
        'Building stats tab with ${_userModel?.stats.length} stat points');

    try {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            LineGraph(
              data: _userModel?.stats ?? [],
              title: 'Confidence Level',
              statName: 'confidenceLevel',
              color: kLightGreenAccent,
            ),
            const SizedBox(height: 20),
            LineGraph(
              data: _userModel?.stats ?? [],
              title: 'Consistency',
              statName: 'consistencyFactor',
              color: kPrimaryColor,
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      debugPrint('Error building stats tab: $e');
      debugPrint('User model: ${_userModel?.toString()}');
      return Center(
        child: Text(
          'Error loading stats',
          style: TextStyle(color: kGray),
        ),
      );
    }
  }

  Widget _buildHabitsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _buildHabitsTab(),
    );
  }

  Widget _buildStatsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _buildStatsTab(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.82,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: _userModel == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 250),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: kPrimaryColor.withOpacity(0.1),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 64,
                                  color: kPrimaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'User not found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This user profile could not be found',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Overview Section
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                UserAvatar(
                                  username: _userModel?.username ??
                                      'No username found',
                                  size: 80.0,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _userModel?.username ?? 'No username found',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_userModel?.bio?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _userModel?.bio ?? 'No bio available',
                                    style: kMainDescription.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      color: kGray,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildLevelProgressBar(),
                                    _buildConfidenceIndicator(),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Habits Section
                          if (_userModel?.privacySettings?.habitsScope !=
                                  SharingScope.none ||
                              !widget.isFriendProfile) ...[
                            _buildSectionHeader('Habits'),
                            _buildHabitsContent(),
                          ],

                          // Stats Section
                          if (_userModel?.privacySettings?.statsScope !=
                                  SharingScope.none ||
                              !widget.isFriendProfile) ...[
                            _buildSectionHeader('Stats'),
                            _buildStatsContent(),
                          ],

                          const SizedBox(height: 30),
                        ],
                      ),
              ),
      ),
    );
  }
}

class MiniHabitCard extends StatelessWidget {
  const MiniHabitCard({Key? key, required this.habit}) : super(key: key);

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: 4,
        color: kFadedBlue.withOpacity(habit.isCompleted ? 0.3 : 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: kPrimaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StreakStatChip(streak: habit.streak),
                  const SizedBox(width: 12),
                  ConfidenceLevelStatChip(
                      confidenceLevel: double.parse(
                          habit.confidenceLevel.toStringAsFixed(2))),
                  const SizedBox(width: 12),
                  DifficultyRatingStatChip(
                      difficultyRating: habit.stats.length > 0
                          ? double.parse(habit.stats.last.difficultyRating
                              .toStringAsFixed(2))
                          : 0.0),
                ],
              ),
              const SizedBox(height: 12),
              RoundedProgressBar(
                progress: habit.currentProgress / habit.targetGoal,
                color: kPrimaryColor,
                lineHeight: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
