import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/upload_cv_view_model.dart';
import '../../../widgets/login/uploadcv/apply_button.dart';
import '../../../widgets/login/uploadcv/cv_upload_box.dart';
import '../../../widgets/login/uploadcv/info_input_box.dart';
import '../../../widgets/login/uploadcv/job_header.dart';
import '../../../widgets/login/uploadcv/upload_success_content.dart';
import '../../../widgets/login/uploadcv/uploading_content.dart';

class UploadCVScreen extends StatefulWidget {
  const UploadCVScreen({super.key});

  @override
  State<UploadCVScreen> createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen> {
  final TextEditingController _infoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadCVViewModel>(builder: (context, vm, child) {
      if (vm.status == UploadCVStatus.uploading) return const UploadingView();
      if (vm.status == UploadCVStatus.success) {
        return UploadSuccessView(
          fileName: vm.fileName ?? '',
          onFindSimilar: () => vm.reset(),
          onBackHome: () {
            vm.reset();
            Navigator.pop(context);
          },
        );
      }
      return Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const JobHeader(),
              const SizedBox(height: 8),
              Text('Upload CV', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('Add your CV/Resume to apply for a job', style: TextStyle(color: Colors.black54, fontSize: 13)),
              SizedBox(height: 10),
              CVUploadBox(
                fileName: vm.fileName,
                onUpload: () => vm.selectFile('Jamet kudasi - CV - UI/UX Designer.pdf'),
                onRemove: vm.removeFile,
              ),
              SizedBox(height: 24),
              InfoInputBox(controller: _infoCtrl),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ApplyButton(
                  onPressed: vm.fileName != null
                      ? () => vm.submit()
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
