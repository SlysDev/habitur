import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:stacked/stacked.dart';
import '../../../constants.dart';
import 'admin_viewmodel.dart';

class AdminView extends StackedView<AdminViewModel> {
  const AdminView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, AdminViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: const Text('Total Users'),
                  subtitle: Text(viewModel.totalUsers.toString()),
                  leading: const Icon(Icons.people),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: const Text('Active Challenges'),
                  subtitle: Text(viewModel.activeChallenges.toString()),
                  leading: const Icon(Icons.emoji_events),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ExpansionTile(
                  title: const Text('Create Challenge'),
                  leading: const Icon(Icons.add_circle),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: viewModel.titleController,
                            decoration: const InputDecoration(
                              labelText: 'Challenge Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: viewModel.descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: viewModel.requiredCompletionsController,
                            decoration: const InputDecoration(
                              labelText: 'Required Completions',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: viewModel.createChallenge,
                            child: const Text('Create Challenge'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (viewModel.isBusy)
                const Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.users.length,
                  itemBuilder: (context, index) {
                    final user = viewModel.users[index];
                    return Card(
                      child: ListTile(
                        title: Text(user.username),
                        subtitle: Text(user.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.block),
                          onPressed: () => viewModel.toggleUserBlock(user),
                          color: user.isBlocked ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'settings',
      ),
    );
  }

  @override
  AdminViewModel viewModelBuilder(BuildContext context) => AdminViewModel();

  @override
  void onViewModelReady(AdminViewModel viewModel) => viewModel.initialize();
}
