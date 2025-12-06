import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';

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
    _connectionsFuture = _api.getMyConnections(widget.userId);
    // NOTE: ApiService मध्ये getMyConnections(userId) असे method ठेव
    // जे LinkedIn सारखी connections list परत करेल.
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

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const borderColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Connections',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.filter_list, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _connectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No connections yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final connections = snapshot.data!;
          return ListView.separated(
            itemCount: connections.length,
            separatorBuilder: (_, __) => const Divider(
              color: borderColor,
              height: 1,
            ),
            itemBuilder: (context, i) {
              final c = connections[i];
              final String? pic = c['profile_pic']?.toString();
              final name = _titleCase(c['full_name']?.toString());
              final headline = c['headline'] ??
                  c['profession'] ??
                  c['business'] ??
                  '';
              final connectedOn = c['connected_on']?.toString(); // date string

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF111827),
                  backgroundImage:
                      (pic != null && pic.isNotEmpty) ? NetworkImage(pic) : null,
                  child: (pic == null || pic.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
                trailing: const Icon(Icons.near_me, color: Colors.white),
              );
            },
          );
        },
      ),
    );
  }
}
