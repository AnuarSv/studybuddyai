import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:university_quiz_app/providers/generation_provider.dart';

class CreateTrainingScreen extends StatefulWidget {
  const CreateTrainingScreen({super.key});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trainingNameController = TextEditingController();
  final _numMcqController = TextEditingController(text: '5');
  final _numTfController = TextEditingController(text: '5');
  final _numFlashcardsController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    // Reset provider state when screen is entered, in case it was left in an error state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GenerationProvider>(context, listen: false).reset();
    });
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    _numMcqController.dispose();
    _numTfController.dispose();
    _numFlashcardsController.dispose();
    super.dispose();
  }

  Future<void> _generate(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GenerationProvider>(context, listen: false);
      if (provider.filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a PDF file first.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      final success = await provider.generateTrainingSession(
        trainingName: _trainingNameController.text.trim(),
        numMcq: int.tryParse(_numMcqController.text) ?? 0,
        numTrueFalse: int.tryParse(_numTfController.text) ?? 0,
        numFlashcards: int.tryParse(_numFlashcardsController.text) ?? 0,
      );

      if (mounted) {
        // Check if the widget is still in the tree
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.progressMessage.isNotEmpty
                    ? provider.progressMessage
                    : 'Training created!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to create training.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildNumberInput(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Cannot be empty (0 for none)';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (int.parse(value) < 0) {
          return 'Cannot be negative';
        }
        if (int.parse(value) > 50) {
          // Max limit
          return 'Max 50 items';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Training')),
      body: Consumer<GenerationProvider>(
        builder: (context, provider, child) {
          if (provider.state == GenerationState.parsingPdf ||
              provider.state == GenerationState.generatingContent) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    provider.progressMessage,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (provider.state == GenerationState.generatingContent)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "This can take a few moments depending on the PDF size and number of items requested. Please wait.",
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // PDF Selection Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 50,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            provider.fileName ?? 'No PDF Selected',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  provider.fileName != null
                                      ? theme.colorScheme.secondary
                                      : Colors.grey,
                              fontStyle:
                                  provider.fileName == null
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Select PDF Lecture'),
                            onPressed:
                                provider.state == GenerationState.pickingFile
                                    ? null
                                    : () => provider.pickPdf(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary
                                  .withOpacity(0.8),
                            ),
                          ),
                          if (provider.state == GenerationState.pickingFile)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: LinearProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Training Name
                  TextFormField(
                    controller: _trainingNameController,
                    decoration: const InputDecoration(
                      labelText: 'Training Session Name',
                      hintText: 'e.g., Chapter 1 Notes',
                      prefixIcon: Icon(Icons.label_important_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for the training session';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Number of Items to Generate:',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '(Set to 0 if not needed. Max 50 each.)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Number Inputs in a Row or Column based on space
                  _buildNumberInput(
                    _numMcqController,
                    'Multiple Choice',
                    Icons.list_alt_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildNumberInput(
                    _numTfController,
                    'True/False',
                    Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildNumberInput(
                    _numFlashcardsController,
                    'Flashcards (Theory)',
                    Icons.style_outlined,
                  ),

                  const SizedBox(height: 30),
                  if (provider.state == GenerationState.error &&
                      provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Generate Training'),
                    onPressed: () => _generate(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
