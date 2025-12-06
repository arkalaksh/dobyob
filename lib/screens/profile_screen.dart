import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/widgets/main_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';
import 'connections_screen.dart'; // NEW import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = "";
  String userDob = "";
  String userName = "";
  String userBusiness = "";
  String userProfession = "";
  String userIndustry = "";
  String userCity = "";
  String userState = "";
  String userCountry = "";
  String userEmail = "";
  String userMobile = "";
  String userProfilePicUrl = "";
  int connectionsCount = 0; // NEW

  final ApiService apiService = ApiService();
  bool isLoading = false;

  static const String _imageBase = 'https://dobyob.arkalaksh.com/';

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final session = await DobYobSessionManager.getInstance();
    final uidInt = await session.getUserId();
    if (uidInt == null) return;
    userId = uidInt.toString();
    await loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    final user = await apiService.getProfile(userId);
    setState(() {
      isLoading = false;
      if (user != null) {
        userName = user['full_name'] ?? user['name'] ?? "";
        userBusiness = user['business'] ?? "";
        userProfession = user['profession'] ?? "";
        userIndustry = user['industry'] ?? "";
        userCity = user['city'] ?? "";
        userState = user['state'] ?? "";
        userCountry = user['country'] ?? "";
        userEmail = user['email'] ?? "";
        userMobile = user['phone'] ?? "";
        userDob = user['date_of_birth'] ?? "";
        // total connections from API (if available)
        connectionsCount = int.tryParse(user['connections_count']?.toString() ?? '0') ?? 0;

        final rawPic = (user['profile_pic'] ?? "").toString();
        if (rawPic.isEmpty) {
          userProfilePicUrl = "";
        } else if (rawPic.startsWith('http')) {
          userProfilePicUrl = rawPic;
        } else {
          userProfilePicUrl = '$_imageBase$rawPic';
        }
      }
    });
  }
String get dobLabel {
  if (userDob.isEmpty) return "";
  try {
    final d = DateTime.parse(userDob); // yyyy-MM-dd from your API
    return DateFormat('dd/MM/yyyy').format(d);
  } catch (_) {
    return userDob;
  }
}
  Future<void> _logout() async {
  try {
    final session = await DobYobSessionManager.getInstance();
    final uidInt = await session.getUserId();
    
    if (uidInt != null) {
      // Call logout API
      final response = await apiService.logout(userId: uidInt.toString());
      
      if (response?['success'] == true) {
        // Clear local session
        await session.clearSession();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      } else {
        // API failed but still clear local session
        await session.clearSession();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      }
    } else {
      // No user ID, just clear session
      await session.clearSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    }
  } catch (e) {
    // Network error, still clear local session
    final session = await DobYobSessionManager.getInstance();
    await session.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
  }
}

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardColor = Color(0xFF020817);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    final location = [
      if (userCity.isNotEmpty) userCity,
      if (userState.isNotEmpty) userState,
      if (userCountry.isNotEmpty) userCountry,
    ].join(", ");

    // display string like "500+ connections"
    final connectionsLabel = connectionsCount > 500
        ? "500+ connections"
        : "$connectionsCount connections";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : ListView(
              children: [
                // header + profile image
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 110,
                      width: double.infinity,
                      color: const Color(0xFF0B1120),
                    ),
                    Positioned(
                      left: 22,
                      bottom: -32,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: accent,
                        child: CircleAvatar(
                          radius: 43,
                          backgroundColor: const Color(0xFF020817),
                          backgroundImage: (userProfilePicUrl.isNotEmpty)
                              ? NetworkImage(userProfilePicUrl)
                              : null,
                          child: (userProfilePicUrl.isEmpty)
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 40)
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 10,
                      child: TextButton(
                        onPressed: _logout,
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 42),

                // main card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: borderColor),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name + edit
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName.isEmpty ? "Your Name" : userName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height:6),
                                     if (dobLabel.isNotEmpty)
  Text(
    "DOB: $dobLabel",
    style: const TextStyle(fontSize: 12, color: Colors.white70),
  ),
                                    const SizedBox(height: 6),
                                    if (userBusiness.isNotEmpty)
                                      Text(
                                        userBusiness,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    if (userProfession.isNotEmpty)
                                      Text(
                                        userProfession,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    if (userIndustry.isNotEmpty)
                                      Text(
                                        userIndustry,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    if (location.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    if (userEmail.isNotEmpty)
                                      Text(
                                        "Email: $userEmail",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    if (userMobile.isNotEmpty)
                                      Text(
                                        "Mobile: $userMobile",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: accent, size: 22),
                                onPressed: () async {
                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProfileScreen(
                                        userId: userId,
                                        initialName: userName,
                                        initialBusiness: userBusiness,
                                        initialProfession: userProfession,
                                        initialIndustry: userIndustry,
                                        initialCity: userCity,
                                        initialState: userState,
                                        initialCountry: userCountry,
                                        initialDob: userDob,
                                        initialEmail: userEmail,
                                        initialMobile: userMobile,
                                        initialAddress: '',
                                        initialEducation: '',
                                        initialEducationList: const [],
                                        initialPositions: const [],
                                        initialProfilePicUrl:
                                            userProfilePicUrl,
                                      ),
                                    ),
                                  );
                                  if (changed == true) {
                                    await loadProfile();
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // CLICKABLE "500+ connections"
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConnectionsScreen(
                                    userId: userId,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              connectionsLabel,
                              style: const TextStyle(
                                color: Color(0xFF0EA5E9),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
