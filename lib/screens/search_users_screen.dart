import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/other_profile_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  final String currentUserId;
  final String query;

  const SearchUsersScreen({
    super.key,
    required this.currentUserId,
    required this.query,
  });

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final ApiService _api = ApiService();
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = _api.searchUsers(
      currentUserId: widget.currentUserId,
      query: widget.query,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);
    const borderColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accent),
            );
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final users = snap.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final u = users[i];
              final String pic = (u['profile_pic'] ?? '').toString();
              final String status = (u['connection_status'] ?? '').toString();

              String btnText;
              bool enabled = true;
              if (status == 'accepted') {
                btnText = 'Connected';
                enabled = false;
              } else if (status == 'pending') {
                btnText = 'Pending';
                enabled = false;
              } else {
                btnText = 'Connect';
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OtherProfileScreen(userId: u['id'].toString()),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      // Profile Picture - Fixed size
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: accent,
                        backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : null,
                        child: pic.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 22)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      
                      // User Info - Perfectly aligned with baseline
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (u['full_name'] ?? '').toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      height: 1.2, // Perfect line height
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                    child: Text(
                                      (u['profession'] ?? u['business'] ?? '').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 13,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Connect Button - Perfect center alignment
                      SizedBox(
                        height: 36,
                        width: 85,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: enabled ? accent : const Color(0xFF4B5563),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: !enabled
                              ? null
                              : () async {
                                  final res = await _api.sendConnectionRequest(
                                    senderId: widget.currentUserId,
                                    receiverId: u['id'].toString(),
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        res['message']?.toString() ?? ''),
                                    ),
                                  );
                                  if (res['success'] == true) {
                                    setState(() {
                                      u['connection_status'] = 'pending';
                                    });
                                  }
                                },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              btnText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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
