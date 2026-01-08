import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController contentController = TextEditingController();
  File? selectedFile;

  bool isLoading = false;
  String? myUserId;

  String selectedVisibility = "Public";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final session = await DobYobSessionManager.getInstance();
    final uid = await session.getUserId();
    if (!mounted) return;
    setState(() => myUserId = uid?.toString());
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  /// ✅ Always go back to HomeShell Feed tab
  void _goToFeed({bool posted = false}) {
    // ✅ Prefer pop with result (FeedScreen waits for this result)
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context, posted);
      return;
    }

    // ✅ Fallback: try to return to root (avoids pushReplacement that may skip refresh)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submitPost() async {
    final content = contentController.text.trim();

    if (myUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Type something before posting!")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService().createPost(
      userId: myUserId!,
      content: content,
      profilePic: selectedFile,
    );

    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      // (optional) UI clean
      contentController.clear();
      selectedFile = null;

      _goToFeed(posted: true); // ✅ success नंतर feed ला TRUE result
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to post")),
      );
    }
  }

  void _openVisibilitySheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Who can see your post?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _visibilityTile(
                  title: "Public",
                  subtitle: "Public on or off the app",
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _visibilityTile({required String title, required String subtitle}) {
    final bool selected = selectedVisibility == title;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        radius: 20,
        backgroundColor: Color(0xFFE5E5E5),
        child: Icon(Icons.group, color: Colors.black54, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? const Color(0xFF0A66C2) : Colors.grey,
      ),
      onTap: () {
        setState(() => selectedVisibility = title);
        Navigator.pop(context, true);

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);
    const borderColor = Color(0xFF1F2937);

    final isImage = selectedFile != null &&
        (selectedFile!.path.toLowerCase().endsWith('.png') ||
            selectedFile!.path.toLowerCase().endsWith('.jpg') ||
            selectedFile!.path.toLowerCase().endsWith('.jpeg') ||
            selectedFile!.path.toLowerCase().endsWith('.gif') ||
            selectedFile!.path.toLowerCase().endsWith('.webp'));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _goToFeed(posted: false), // ✅ back => feed (false)
        ),
        title: const Text(
          "Create Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: isLoading ? null : _submitPost,
              child: Text(
                "Post",
                style: TextStyle(
                  color: isLoading ? Colors.white54 : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF111827),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _openVisibilitySheet,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4B5563)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedVisibility,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: contentController,
              minLines: 4,
              maxLines: 6,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              cursorColor: accent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "What do you want to talk about?",
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
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
                          const Icon(Icons.insert_drive_file,
                              size: 28, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selectedFile!.path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
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
                  icon: const Icon(Icons.attach_file, color: accent, size: 28),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today_outlined,
                      color: accent, size: 26),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: accent, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}