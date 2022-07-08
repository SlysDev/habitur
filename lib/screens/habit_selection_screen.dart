import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

class HabitSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, 'settings_screen');
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: kDarkBlue,
              size: 30,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Habit Marketplace',
              style: kTitleTextStyle,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                  stream:
                      Provider.of<Database>(context).habitCatalogue.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> habitCards = [];
                      final habits = snapshot.data!.docs;
                      for (var habit in habits) {
                        String habitTitle = (habit.data() as Map)['title'];
                        String habitAuthor = (habit.data() as Map)['author'];
                        int habitRating = (habit.data() as Map)['rating'];
                        double habitDifficulty =
                            (habit.data() as Map)['difficulty'];
                        habitCards.add(
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 30),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.sports_gymnastics,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            habitTitle,
                                            style: kHeadingTextStyle.copyWith(
                                                color: Colors.white),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            habitAuthor,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$habitRating/10',
                                          style: kHeadingTextStyle.copyWith(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 80,
                                        ),
                                        Text(
                                          '$habitDifficulty',
                                          style: kHeadingTextStyle.copyWith(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.timer,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: habitCards,
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text('Unable to load marketplace.'),
                    );
                  }),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            const Text(
              'Mindful Habits',
              style: kHeadingTextStyle,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            const Text(
              'Dietary Habits',
              style: kHeadingTextStyle,
            ),
            const Text(
              'Other Habits',
              style: kHeadingTextStyle,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'marketplace',
      ),
    );
  }
}
