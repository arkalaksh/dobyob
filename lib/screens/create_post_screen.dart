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
      type: FileType.any,
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
    const bgColor = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);
    const borderColor = Color(0xFF1F2937);

    final isImage = selectedFile != null &&
        (selectedFile!.path.endsWith('.png') ||
            selectedFile!.path.endsWith('.jpg') ||
            selectedFile!.path.endsWith('.jpeg') ||
            selectedFile!.path.endsWith('.gif') ||
            selectedFile!.path.endsWith('.webp'));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar and visibility
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF111827),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: const [
                          Text(
                            "Anyone",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 21,
                            color: Colors.white,
                          ),
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
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  cursorColor: accent,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "What do you want to talk about?",
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                size: 28,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedFile!.path.split('/').last,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
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
                      icon: const Icon(
                        Icons.attach_file,
                        color: accent,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Optional: implement calendar/other features
                      },
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        color: accent,
                        size: 26,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add,
                        color: accent,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 74),
              ],
            ),
          ),

          // Bottom Post button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _submitPost,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Post",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
