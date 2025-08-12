import 'package:job_seeker_frontend/views/login/setting/setting_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/logout_view_model.dart';
import '../../../widgets/login/setting_and_update_password/primary_button.dart';
import '../logout/logout_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var logoutVM = Provider.of<LogoutViewModel>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: const [
                SettingsList(),
                Spacer(),
                SaveButton(),
              ],
            ),
          ),
        ),
        if (logoutVM.dialogVisible) const LogoutDialog()
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: PrimaryButton(text: 'SAVE', onPressed: () {}),
  );
}
