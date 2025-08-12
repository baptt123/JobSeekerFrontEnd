import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/logout_view_model.dart';
import '../../../widgets/login/logout_and_no_result/primary_button.dart';


class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});
  @override
  Widget build(BuildContext context) {
    var logoutVM = Provider.of<LogoutViewModel>(context);

    return Material(
      color: Colors.black.withOpacity(0.13),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 6),
              const Text('Are you sure you want to leave?', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              PrimaryButton(text: 'YES', onPressed: logoutVM.logout),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'CANCEL',
                color: Colors.deepPurple.shade100,
                enabled: true,
                textColor: Colors.deepPurple,
                onPressed: logoutVM.hideDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
