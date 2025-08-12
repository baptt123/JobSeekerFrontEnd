import 'package:flutter/material.dart';

class CVUploadBox extends StatelessWidget {
  final String? fileName;
  final VoidCallback? onUpload;
  final VoidCallback? onRemove;

  const CVUploadBox({
    super.key,
    this.fileName,
    this.onUpload,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (fileName == null) {
      return InkWell(
        onTap: onUpload,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!)),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('Upload CV/Resume', style: TextStyle(color: Colors.deepPurple)),
            ],
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.deepPurple.withOpacity(0.06),
          border: Border.all(color: Colors.deepPurple.shade100)
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fileName!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    "867 Kb · 14 Feb 2022 at 11:30 am",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )),
          IconButton(onPressed: onRemove, icon: Icon(Icons.delete_outline, color: Colors.red))
        ],
      ),
    );
  }
}
