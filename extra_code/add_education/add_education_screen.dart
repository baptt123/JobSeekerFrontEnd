import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/add_education_view_model.dart';
import '../../../widgets/login/filter_and_add_information/custom_button.dart';
import '../../../widgets/login/filter_and_add_information/custom_text_field.dart';

class AddEducationScreen extends StatefulWidget {
  const AddEducationScreen({super.key});

  @override
  State<AddEducationScreen> createState() => _AddEducationScreenState();
}

class _AddEducationScreenState extends State<AddEducationScreen> {
  late final TextEditingController levelController;
  late final TextEditingController institutionController;
  late final TextEditingController fieldController;
  late final TextEditingController descriptionController;

  // Đặt biến để lưu giá trị ngày
  String getDateText(DateTime? date) =>
      date == null ? '' : "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<AddEducationViewModel>(context, listen: false);
    levelController = TextEditingController(text: vm.levelOfEducation);
    institutionController = TextEditingController(text: vm.institutionName);
    fieldController = TextEditingController(text: vm.fieldOfStudy);
    descriptionController = TextEditingController(text: vm.description);

    // Nếu muốn đồng bộ mỗi khi text đổi, có thể add listener, nhưng ở đây đã có onChanged rồi
  }

  @override
  void dispose() {
    levelController.dispose();
    institutionController.dispose();
    fieldController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddEducationViewModel>(context);

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
                const Text(
                  'Add Education',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Level of education',
                  controller: levelController,
                  onChanged: (val) => vm.updateLevel(val),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Institution name',
                  controller: institutionController,
                  onChanged: (val) => vm.updateInstitution(val),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Field of study',
                  controller: fieldController,
                  onChanged: (val) => vm.updateField(val),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: vm.startDate ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) vm.updateStartDate(date);
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: 'Start date',
                            controller: TextEditingController(
                              text: getDateText(vm.startDate),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: vm.endDate ?? DateTime.now(),
                            firstDate: DateTime(1980),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) vm.updateEndDate(date);
                        },
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: 'End date',
                            controller: TextEditingController(
                              text: getDateText(vm.endDate),
                            ),
                            readOnly: true,
                          ),
                        ),
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
                CustomButton(text: 'SAVE', onPressed: vm.save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
