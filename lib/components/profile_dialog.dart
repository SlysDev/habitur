import 'package:flutter/material.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/stats_calculator.dart';
import 'package:habitur/providers/database.dart';

class ProfileDialog extends StatefulWidget {
  final String uid;

  const ProfileDialog({Key? key, required this.uid}) : super(key: key);

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
    try {
      Database db = Database();
      final user = await db.userDatabase.getUserById(widget.uid);
      setState(() {
        _userModel = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.all(15),
      content: AnimatedContainer(
        height: _userModel == null ? 200 : 450,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutSine,
        child: Center(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 6.0,
                  ),
                )
              : _userModel != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Avatar
                        CircleAvatar(
                          backgroundImage: _userModel!.profilePicture,
                          radius: 50,
                          backgroundColor: kDarkPrimaryColor.withOpacity(0.2),
                        ),
                        SizedBox(height: 10),
                        // Username
                        Text(
                          _userModel!.username,
                          style: kTitleTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 30,
                              color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _userModel!.bio == ''
                              ? 'No bio available.'
                              : _userModel!.bio,
                          style: kMainDescription.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: kGray,
                          ),
                        ),
                        SizedBox(height: 30),

                        // User Level with progress bar
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // The progress bar
                            Container(
                              width: 140,
                              child: RoundedProgressBar(
                                progress: _userModel!.userXP /
                                    _userModel!
                                        .levelUpRequirement, // Adjust this based on the scale you're using
                                color: kPrimaryColor,
                                lineHeight: 50.0, // Super fat bar
                              ),
                            ),
                            // The number overlaid on the progress bar
                            Text(
                              _userModel!.userLevel.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Confidence Level with emoji
                        Container(
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
                              Text(
                                '😎', // Emoji
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                StatsCalculator()
                                    .calculateAverageValueForStat(
                                        'confidenceLevel', _userModel!.stats)
                                    .toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'User not found',
                      style: TextStyle(
                        color: kGray,
                        fontFamily: 'DM Sans',
                      ),
                    ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(
              color: kLightPrimaryColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ],
    );
  }
}
