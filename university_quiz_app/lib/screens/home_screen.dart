import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:university_quiz_app/models/training_session.dart';
import 'package:university_quiz_app/providers/home_provider.dart';
import 'package:university_quiz_app/screens/create_training_screen.dart';
import 'package:university_quiz_app/screens/training_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load sessions when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadTrainingSessions();
    });
  }

  Future<void> _showRenameDialog(TrainingSession session) async {
    final TextEditingController renameController = TextEditingController(
      text: session.name,
    );
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Training Session'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: renameController,
                decoration: const InputDecoration(
                  labelText: 'New Name',
                  hintText: 'Enter new session name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Rename'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Provider.of<HomeProvider>(
                    context,
                    listen: false,
                  ).renameTrainingSession(
                    session.id,
                    renameController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(TrainingSession session) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete "${session.name}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Provider.of<HomeProvider>(
                  context,
                  listen: false,
                ).deleteTrainingSession(session.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Buddy AI'),
        // actions: [ // For testing:
        //   IconButton(
        //     icon: Icon(Icons.delete_forever),
        //     onPressed: () {
        //       Provider.of<HomeProvider>(context, listen: false).clearAllDataForTesting();
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(content: Text("All data cleared (for testing)."))
        //       );
        //     }
        //   )
        // ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.state == HomeState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (homeProvider.state == HomeState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Sessions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      homeProvider.errorMessage ?? 'An unknown error occurred.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      onPressed: () => homeProvider.loadTrainingSessions(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (homeProvider.trainingSessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Training Sessions Yet!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap the "+" button to create your first study session from a PDF.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: homeProvider.trainingSessions.length,
            itemBuilder: (context, index) {
              final session = homeProvider.trainingSessions[index];
              return Slidable(
                key: ValueKey(session.id),
                startActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _showRenameDialog(session),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Rename',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _showDeleteConfirmDialog(session),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondary.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        Icons.folder_special_outlined,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      session.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'PDF: ${session.pdfFileName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Created: ${DateFormat.yMMMd().add_jm().format(session.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TrainingDetailScreen(session: session),
                        ),
                      ).then((value) {
                        // Refresh list if a session was modified (e.g., name change from detail screen if implemented)
                        // or if we want to ensure it's up-to-date after any interaction.
                        // Currently, rename is handled on this screen.
                        homeProvider.loadTrainingSessions();
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTrainingScreen(),
            ),
          ).then((value) {
            // If a new session was created, refresh the list
            if (value == true) {
              // Assuming CreateTrainingScreen returns true on success
              Provider.of<HomeProvider>(
                context,
                listen: false,
              ).loadTrainingSessions();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('New Training'),
        // backgroundColor: theme.colorScheme.primary,
        // foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
