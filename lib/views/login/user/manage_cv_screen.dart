import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/user/manage_cv_view_model.dart';
import 'cv_preview_screen.dart'; // Import màn hình xem PDF

class ManageCvScreen extends StatefulWidget {
  @override
  _ManageCvScreenState createState() => _ManageCvScreenState();
}

class _ManageCvScreenState extends State<ManageCvScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi fetch data khi init
    Future.microtask(() =>
        Provider.of<ManageCvViewModel>(context, listen: false).fetchCvs()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý CV")),
      body: Consumer<ManageCvViewModel>(
        builder: (ctx, vm, child) {
          if (vm.isLoading) return Center(child: CircularProgressIndicator());
          if (vm.cvList.isEmpty) return Center(child: Text("Bạn chưa có CV nào."));

          return ListView.builder(
            itemCount: vm.cvList.length,
            itemBuilder: (ctx, i) {
              final cv = vm.cvList[i];
              return Card(
                color: (cv.isDefault == true) ? Colors.green[50] : Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(cv.title ?? "CV #${cv.cvId}"),
                  subtitle: Text((cv.isDefault == true) ? "Mặc định" : "Ngày tạo: ${cv.createdAt?.toIso8601String().split('T')[0]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Xem
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          if (cv.cvUrl != null) {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => CvPreviewScreen(url: cv.cvUrl, title: cv.title ?? "Xem CV")
                            ));
                          }
                        },
                      ),
                      // Nút Set Default
                      if (cv.isDefault != true)
                        IconButton(
                          icon: Icon(Icons.check_circle_outline),
                          onPressed: () => vm.setDefault(cv.cvId!),
                        ),
                      // Nút Xoá
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => vm.deleteCv(cv.cvId!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}