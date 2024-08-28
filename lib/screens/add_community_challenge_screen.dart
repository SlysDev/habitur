import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/filled_text_field.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddCommunityChallengeScreen extends StatefulWidget {
  AddCommunityChallengeScreen({super.key});
  Map<String, dynamic> newChallenge = {
    'title': '',
    'description': '',
    'currentFullCompletions': 0,
    'startDate': DateTime.now(),
    'endDate': DateTime.now(),
    'id': Random().nextInt(100000),
    'requiredFullCompletions': 0,
    'participantDataList': [],
    'habit': {
      'title': '',
      'requiredCompletions': 0,
      'resetPeriod': 'Daily',
      'id': Random().nextInt(100000),
      'dateCreated': DateTime.now()
    },
  };

  @override
  State<AddCommunityChallengeScreen> createState() =>
      _AddCommunityChallengeScreenState();
}

class _AddCommunityChallengeScreenState
    extends State<AddCommunityChallengeScreen> {
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.newChallenge['endDate']) {
      setState(() {
        widget.newChallenge['endDate'] = picked;
      });
      print(widget.newChallenge['endDate']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.65,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              const Text(
                'New Challenge',
                style: kTitleTextStyle,
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
                hintText: 'Title',
                onChanged: (value) {
                  widget.newChallenge['title'] = value;
                  widget.newChallenge['habit']['title'] = value;
                },
              ),
              Text(
                'Challenge Description',
                style: kMainDescription,
                textAlign: TextAlign.center,
              ),
              FilledTextField(
                hintText: 'Challenge Description',
                onChanged: (value) {
                  widget.newChallenge['description'] = value;
                },
              ),
              Text(
                'Required Reps',
                style: kMainDescription,
                textAlign: TextAlign.center,
              ),
              FilledTextField(
                hintText: '##',
                onChanged: (value) {
                  widget.newChallenge['habit']['requiredCompletions'] =
                      int.parse(value);
                },
              ),
              Text(
                'Completion Goal',
                style: kMainDescription,
                textAlign: TextAlign.center,
              ),
              FilledTextField(
                hintText: '##',
                onChanged: (value) {
                  widget.newChallenge['requiredFullCompletions'] =
                      int.parse(value);
                },
              ),
              // FilledTextField(
              //   hintText: 'Current Full Completions',
              //   onChanged: (value) {
              //     widget.newChallenge['currentFullCompletions'] =
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
                          widget.newChallenge['habit']['resetPeriod'] = 'Daily';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: widget.newChallenge['habit']
                                        ['resetPeriod'] ==
                                    'Daily'
                                ? kPrimaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Daily',
                          style: TextStyle(
                              color: widget.newChallenge['habit']
                                          ['resetPeriod'] ==
                                      'Daily'
                                  ? Colors.white
                                  : kGray),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.newChallenge['habit']['resetPeriod'] =
                              'Weekly';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: widget.newChallenge['habit']
                                        ['resetPeriod'] ==
                                    'Weekly'
                                ? kPrimaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Weekly',
                          style: TextStyle(
                              color: widget.newChallenge['habit']
                                          ['resetPeriod'] ==
                                      'Weekly'
                                  ? Colors.white
                                  : kGray),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.newChallenge['habit']['resetPeriod'] =
                              'Monthly';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: widget.newChallenge['habit']
                                        ['resetPeriod'] ==
                                    'Monthly'
                                ? kPrimaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Monthly',
                          style: TextStyle(
                              color: widget.newChallenge['habit']
                                          ['resetPeriod'] ==
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
                          .format(widget.newChallenge['endDate']),
                      onPressed: () {
                        _selectDate(context);
                      }),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () async {
                  Database db = Database();
                  print(widget.newChallenge);
                  db.communityChallengeDatabase
                      .addCommunityChallenge(widget.newChallenge, context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
