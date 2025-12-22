import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:dobyob_1/widgets/main_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';
import 'connections_screen.dart';

// Name/title साठी – प्रत्येक शब्दाचा first letter capital
extension StringTitleCase on String {
  String toTitleCase() {
    if (trim().isEmpty) return '';
    return trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

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
  String userAddress = "";          // ✅ NEW
  String userEducation = "";        // ✅ NEW (comma string)
  List<String> userEducationList = []; // ✅ NEW (parsed list)
  String userProfilePicUrl = "";
  int connectionsCount = 0;

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

    final userFuture = apiService.getProfile(userId);
    final consFuture = apiService.getMyConnections(userId);

    final user = await userFuture;
    final myConnections = await consFuture;

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
        userAddress = user['address'] ?? "";            // ✅
        userEducation = user['education'] ?? "";        // ✅

        // education string -> list  ✅
        if (userEducation.trim().isNotEmpty) {
          userEducationList = userEducation
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else {
          userEducationList = [];
        }

        final apiCount =
            int.tryParse(user['connections_count']?.toString() ?? '0') ?? 0;
        final listCount = myConnections.length;
        connectionsCount = apiCount > 0 ? apiCount : listCount;

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
      final d = DateTime.parse(userDob);
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
        await apiService.logout(userId: uidInt.toString());
        await session.clearSession();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      } else {
        await session.clearSession();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      }
    } catch (e) {
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

    // Country mandatory, नंतर state/city
    final location = [
      if (userCountry.isNotEmpty) userCountry,
      if (userState.isNotEmpty) userState,
      if (userCity.isNotEmpty) userCity,
    ].join(", ");

    final connectionsLabel =
        connectionsCount > 500 ? "500+ connections" : "$connectionsCount connections";

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
      bottomNavigationBar: const MainBottomNav(currentIndex: 4),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : ListView(
              children: [
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    Text(
                                      userName.isEmpty
                                          ? "Your Name"
                                          : userName.toTitleCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Profession / Role
                                    if (userProfession.isNotEmpty)
                                      Text(
                                        userProfession,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    // Country + state/city
                                    if (location.isNotEmpty)
                                      Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    // Mobile / Email / DOB अजिबात दाखवायचे नाहीत
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: accent,
                                  size: 22,
                                ),
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
                                        initialAddress: userAddress,          // ✅
                                        initialEducation: userEducation,      // ✅
                                        initialEducationList: userEducationList, // ✅
                                        initialPositions: const [],
                                        initialProfilePicUrl: userProfilePicUrl,
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ConnectionsScreen(userId: userId),
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
