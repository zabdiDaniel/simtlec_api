import 'package:flutter/material.dart';
import '../constants.dart';

class HelpContent extends StatelessWidget {
  const HelpContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpSection(
            title: AppStrings.registerTabletTitle,
            steps: AppStrings.registerTabletSteps,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            title: AppStrings.historyTitle,
            steps: AppStrings.historySteps,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            title: AppStrings.supportTitle,
            steps: AppStrings.supportSteps,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required List<String> steps,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.cfeDarkGreen,
              ),
            ),
            const SizedBox(height: 10),
            ...steps
                .map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      step,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}