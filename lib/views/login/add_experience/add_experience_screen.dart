import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/add_experience_view_model.dart';
import '../../../widgets/login/filter_and_add_information/custom_button.dart';
import '../../../widgets/login/filter_and_add_information/custom_text_field.dart';

class AddExperienceScreen extends StatefulWidget {
  const AddExperienceScreen({super.key});

  @override
  State<AddExperienceScreen> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  late final TextEditingController jobController;
  late final TextEditingController companyController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<AddExperienceViewModel>(context, listen: false);
    jobController = TextEditingController(text: vm.jobTitle);
    companyController = TextEditingController(text: vm.company);
    descriptionController = TextEditingController(text: vm.description);
  }

  @override
  void dispose() {
    jobController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddExperienceViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    const Text('Add work experience',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Job title',
                      controller: jobController,
                      onChanged: (val) => vm.updateJobTitle(val),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Company',
                      controller: companyController,
                      onChanged: (val) => vm.updateCompany(val),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Start date',
                            controller: TextEditingController(
                              text: vm.startDate == null
                                  ? ""
                                  : "${vm.startDate!.year}-${vm.startDate!.month.toString().padLeft(2, '0')}-${vm.startDate!.day.toString().padLeft(2, '0')}",
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: vm.startDate ?? DateTime.now(),
                                firstDate: DateTime(1980),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) vm.updateStartDate(date);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: 'End date',
                            controller: TextEditingController(
                              text: vm.endDate == null
                                  ? ""
                                  : "${vm.endDate!.year}-${vm.endDate!.month.toString().padLeft(2, '0')}-${vm.endDate!.day.toString().padLeft(2, '0')}",
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: vm.endDate ?? DateTime.now(),
                                firstDate: DateTime(1980),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) vm.updateEndDate(date);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: vm.isCurrent,
                          onChanged: (value) {
                            if (value != null) vm.updateIsCurrent(value);
                          },
                        ),
                        const Text('This is my position now'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Description',
                      maxLines: 5,
                      controller: descriptionController,
                      onChanged: (val) => vm.updateDescription(val),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'SAVE',
                      onPressed: vm.save,
                    ),
                  ]),
            )),
      ),
    );
  }
}
