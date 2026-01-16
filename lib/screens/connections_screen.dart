import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/screens/other_profile_screen.dart';

class ConnectionsScreen extends StatefulWidget {
  final String userId;

  const ConnectionsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final ApiService _api = ApiService();
  late Future<List<Map<String, dynamic>>> _connectionsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF020617),
          statusBarIconBrightness: Brightness.light,
        ),
      );
    });
    _connectionsFuture = _api.getMyConnections(widget.userId);
  }

  String _titleCase(String? s) {
    if (s == null || s.trim().isEmpty) return '';
    return s
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) =>
            w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  // ✅ FIXED: Smooth navigation to OtherProfileScreen
  void _navigateToProfile(String friendId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OtherProfileScreen(userId: friendId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        opaque: false,
        barrierColor: Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF020617),
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Connections',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _connectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No connections yet',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final connections = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: connections.length,
            separatorBuilder: (_, __) => Divider(
              color: borderColor.withOpacity(0.5),
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, i) {
              final c = connections[i];

              final String friendId =
                  c['friend_id']?.toString() ?? c['user_id']?.toString() ?? '';

              final rawPic = (c['profile_pic'] ?? '').toString().trim();
              String profilePic = '';
              if (rawPic.isNotEmpty) {
                profilePic = DobYobSessionManager.resolveUrl(rawPic).trim();
              }
              if (profilePic.isNotEmpty && !profilePic.startsWith('http')) {
                profilePic = '';
              }

              final name = _titleCase(c['full_name']?.toString());
              final headline =
                  c['headline'] ?? c['profession'] ?? c['business'] ?? '';
              final connectedOn = c['connected_on']?.toString();

              return InkWell(
                onTap: friendId.isEmpty ? null : () => _navigateToProfile(friendId),
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GestureDetector(
                    onTap: friendId.isEmpty ? null : () => _navigateToProfile(friendId),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF111827),
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      child: profilePic.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: friendId.isEmpty ? null : () => _navigateToProfile(friendId),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (headline.toString().isNotEmpty)
                        Text(
                          headline.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      if (connectedOn != null && connectedOn.isNotEmpty)
                        Text(
                          'Connected on $connectedOn',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
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
