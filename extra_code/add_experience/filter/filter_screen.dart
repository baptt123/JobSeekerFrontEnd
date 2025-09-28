import 'package:flutter/material.dart';

import '../../../../../widgets/login/extra_widget/chat/filter_and_add_information/custom_button.dart';
import '../../../../../widgets/login/filter_and_add_information/custom_text_box.dart';
import '../../../../../widgets/login/extra_widget/chat/filter_and_add_information/filter_chip_button.dart';


class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Text('Filter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              // Last update
              const Text('Last update', style: TextStyle(fontWeight: FontWeight.w600)),
              ...['Recent', 'Last week', 'Last month', 'Any time'].map(
                    (e) => Row(
                  children: [
                    CustomCheckbox(), // custom radio được cải tiến nếu muốn
                    Text(e),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Type of workplace
              const Text('Type of workplace', style: TextStyle(fontWeight: FontWeight.w600)),
              ...['On-site', 'Hybrid', 'Remote'].map(
                    (e) => Row(
                  children: [
                    CustomCheckbox(),
                    Text(e),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Job Type
              const Text('Job type', style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 10,
                children: [
                  FilterChipButton(label: 'Apprenticeship'),
                  FilterChipButton(label: 'Part-time'),
                  FilterChipButton(label: 'Full time', highlighted: true),
                  FilterChipButton(label: 'Contract'),
                  FilterChipButton(label: 'Project-based'),
                ],
              ),

              const SizedBox(height: 14),
              // Position level
              const Text('Position level', style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 10,
                children: [
                  FilterChipButton(label: 'Junior'),
                  FilterChipButton(label: 'Senior', highlighted: true),
                  FilterChipButton(label: 'Leader'),
                  FilterChipButton(label: 'Manager'),
                ],
              ),

              const SizedBox(height: 14),
              // City
              const Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
              ...['California, USA', 'Texas, USA', 'New York, USA', 'Florida, USA'].map(
                    (e) => Row(
                  children: [
                    CustomCheckbox(),
                    Text(e),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Salary
              const Text('Salary', style: TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: 19, min: 10, max: 50, divisions: 8,
                      onChanged: (v){},
                    ),
                  ),
                  Text('\$19k'),
                  Text('\$25k'),
                ],
              ),

              const SizedBox(height: 14),
              // Experience
              const Text('Experience', style: TextStyle(fontWeight: FontWeight.w600)),
              ...[
                'No experience', 'Less than a year', '1-3 years',
                '3-6 years', '6-10 years', 'More than 10 years',
              ].map((e) => Row(
                children: [
                  CustomCheckbox(),
                  Text(e),
                ],
              ),
              ),

              const SizedBox(height: 14),
              // Specialization
              const Text('Specialization', style: TextStyle(fontWeight: FontWeight.w600)),
              ...['Design', 'Finance', 'Education', 'Health', 'Restaurant', 'Programmer'].map(
                    (e) => Row(
                  children: [
                    CustomCheckbox(checked: e == 'Design' || e == 'Programmer'),
                    Text(e),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: CustomButton(text: 'Reset', outlined: true, onPressed: () {})),
                  const SizedBox(width: 10),
                  Expanded(child: CustomButton(text: 'APPLY NOW', onPressed: () {})),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
