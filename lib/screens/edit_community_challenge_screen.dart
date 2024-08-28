import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/filled_text_field.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditCommunityChallengeScreen extends StatefulWidget {
  CommunityChallenge challenge;
  EditCommunityChallengeScreen({super.key, required this.challenge});

  @override
  State<EditCommunityChallengeScreen> createState() =>
      _EditCommunityChallengeScreenState();
}

class _EditCommunityChallengeScreenState
    extends State<EditCommunityChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> modifiedChallenge = {
      'title': widget.challenge.habit.title,
      'description': widget.challenge.description,
      'currentFullCompletions': widget.challenge.currentFullCompletions,
      'startDate': widget.challenge.startDate,
      'endDate': widget.challenge.endDate,
      'id': widget.challenge.id,
      'requiredFullCompletions': widget.challenge.requiredFullCompletions,
      'habit': {
        'title': widget.challenge.habit.title,
        'requiredCompletions': widget.challenge.habit.requiredCompletions,
        'resetPeriod': widget.challenge.habit.resetPeriod,
        'dateCreated': widget.challenge.habit.dateCreated,
      },
    };
    void _selectStartDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != modifiedChallenge['startDate']) {
        setState(() {
          modifiedChallenge['startDate'] = picked;
        });
        print(modifiedChallenge['startDate']);
      }
    }

    void _selectEndDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != modifiedChallenge['endDate']) {
        setState(() {
          modifiedChallenge['endDate'] = picked;
        });
        print(modifiedChallenge['endDate']);
      }
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            const Text(
              'Edit Challenge',
              style: kTitleTextStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Items left blank will remain unchanged',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 60,
            ),
            Text(
              'Challenge Title',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),
            FilledTextField(
              hintText: widget.challenge.habit.title,
              onChanged: (value) {
                if (value == '') {
                  modifiedChallenge['title'] = widget.challenge.habit.title;
                  modifiedChallenge['habit']['title'] =
                      widget.challenge.habit.title;
                } else {
                  modifiedChallenge['title'] = value;
                  modifiedChallenge['habit']['title'] = value;
                }
              },
            ),
            Text(
              'Challenge Description',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),
            FilledTextField(
              hintText: widget.challenge.description,
              onChanged: (value) {
                if (value == '') {
                  modifiedChallenge['description'] =
                      widget.challenge.description;
                } else {
                  modifiedChallenge['description'] = value;
                }
              },
            ),
            Text(
              'Required Reps',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),
            FilledTextField(
              hintText: widget.challenge.habit.requiredCompletions.toString(),
              onChanged: (value) {
                if (value == '') {
                  modifiedChallenge['habit']['requiredCompletions'] =
                      widget.challenge.habit.requiredCompletions;
                } else {
                  modifiedChallenge['habit']['requiredCompletions'] =
                      int.parse(value);
                }
              },
            ),
            Text(
              'Completion Goal',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),
            FilledTextField(
              hintText: widget.challenge.requiredFullCompletions.toString(),
              onChanged: (value) {
                if (value == '') {
                  modifiedChallenge['requiredFullCompletions'] =
                      widget.challenge.requiredFullCompletions;
                } else {
                  modifiedChallenge['requiredFullCompletions'] =
                      int.parse(value);
                }
              },
            ),
            // FilledTextField(
            //   hintText: 'Current Full Completions',
            //   onChanged: (value) {
            //     modifiedChallenge['currentFullCompletions'] =
            //         int.parse(value);
            //   },
            // ),
            Text(
              'Completion Period',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        modifiedChallenge['habit']['resetPeriod'] = 'Daily';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: modifiedChallenge['habit']['resetPeriod'] ==
                                  'Daily'
                              ? kPrimaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        'Daily',
                        style: TextStyle(
                            color: modifiedChallenge['habit']['resetPeriod'] ==
                                    'Daily'
                                ? Colors.white
                                : kGray),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        modifiedChallenge['habit']['resetPeriod'] = 'Weekly';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: modifiedChallenge['habit']['resetPeriod'] ==
                                  'Weekly'
                              ? kPrimaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        'Weekly',
                        style: TextStyle(
                            color: modifiedChallenge['habit']['resetPeriod'] ==
                                    'Weekly'
                                ? Colors.white
                                : kGray),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        modifiedChallenge['habit']['resetPeriod'] = 'Monthly';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: modifiedChallenge['habit']['resetPeriod'] ==
                                  'Monthly'
                              ? kPrimaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        'Monthly',
                        style: TextStyle(
                            color: modifiedChallenge['habit']['resetPeriod'] ==
                                    'Monthly'
                                ? Colors.white
                                : kGray),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            Text(
              'End Date',
              style: kMainDescription,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: kFadedBlue,
                ),
                child: AsideButton(
                    text: DateFormat('MM/dd/yyyy')
                        .format(modifiedChallenge['endDate']),
                    onPressed: () {
                      _selectEndDate(context);
                    }),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                Database db = Database();
                print(modifiedChallenge);
                db.communityChallengeDatabase.editCommunityChallenge(
                    widget.challenge.id, modifiedChallenge, context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
