import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:file_picker/file_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController contentController = TextEditingController();
  File? selectedFile;

  bool isLoading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // FileType.image फक्त images साठी, FileType.any सर्वसाठी
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitPost() async {
    final content = contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Type something before posting!")),
      );
      return;
    }
    setState(() => isLoading = true);
    final result = await ApiService().createPost(
      userId: "1", // TODO: Replace with actual logged-in user id
      content: content,
      profilePic: selectedFile,
    );
    setState(() => isLoading = false);

    if (result['success'] == true) {
      Navigator.pop(context, 'posted');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to post")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = selectedFile != null &&
        (selectedFile!.path.endsWith('.png') ||
         selectedFile!.path.endsWith('.jpg') ||
         selectedFile!.path.endsWith('.jpeg') ||
         selectedFile!.path.endsWith('.gif') ||
         selectedFile!.path.endsWith('.webp'));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6C646),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar and visibility dropdown
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        "https://randomuser.me/api/portraits/men/61.jpg",
                      ),
                      backgroundColor: Colors.black12,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: const [
                          Text(
                            "Anyone",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 21)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Post text field
                TextField(
                  controller: contentController,
                  minLines: 4,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "What do you want to talk about?",
                    hintStyle: TextStyle(fontSize: 19, color: Colors.grey),
                  ),
                ),
                if (selectedFile != null) ...[
                  const SizedBox(height: 10),
                  isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(selectedFile!, height: 120),
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.insert_drive_file, size: 28, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                selectedFile!.path.split('/').last,
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                ],
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: pickFile,
                      icon: const Icon(Icons.attach_file, color: Color(0xFFF6C646), size: 29),
                    ),
                    IconButton(
                      onPressed: () {
                        // Optional: implement calendar/other features
                      },
                      icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFF6C646), size: 26),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Color(0xFFF6C646), size: 29),
                    ),
                  ],
                ),
                const SizedBox(height: 74), // Room for post button
              ],
            ),
          ),
          // Bottom-aligned Post button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6C646),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _submitPost,
                  child: isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Post",
                          style: TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
