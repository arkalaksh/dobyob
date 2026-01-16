import 'package:dobyob_1/screens/dobyob_session_manager.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';
import 'connections_screen.dart';
import 'package:flutter/services.dart';

extension StringTitleCase on String {
  String toTitleCase() {
    if (trim().isEmpty) return '';
    return trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToFeed;

  const ProfileScreen({super.key, this.onBackToFeed});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String userId = "";
  int? userDobDay;
  int? userDobMonth;
  int? userDobYear;
  String userName = "";
  String userBusiness = "";
  String userProfession = "";
  String userIndustry = "";
  String userCity = "";
  String userState = "";
  String userCountry = "";
  String userEmail = "";
  String userMobile = "";
  String userAddress = "";
  String userEducation = "";
  List<String> userEducationList = [];
  String userAbout = "";
  String userProfilePicUrl = "";
  int connectionsCount = 0;

  final ApiService apiService = ApiService();
  bool isLoading = false;

  static const String _imageBase = 'https://dobyob.arkalaksh.com/';

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
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final session = await DobYobSessionManager.getInstance();

    final ok = await session.validateSession();
    if (!ok) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      return;
    }

    final uidInt = await session.getUserId();
    if (uidInt == null) {
      await session.clearSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      return;
    }

    userId = uidInt.toString();
    await loadProfile();
  }

  Future<void> loadProfile() async {
    final session = await DobYobSessionManager.getInstance();

    final ok = await session.validateSession();
    if (!ok) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      return;
    }

    if (userId.isEmpty) {
      final uidInt = await session.getUserId();
      if (uidInt == null) {
        await session.clearSession();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
        return;
      }
      userId = uidInt.toString();
    }

    if (mounted) setState(() => isLoading = true);

    final userFuture = apiService.getProfile(userId);
    final consFuture = apiService.getMyConnections(userId);

    final user = await userFuture;
    final myConnections = await consFuture;

    if (!mounted) return;

    userDobDay = user?['dob_day']?.toString().isNotEmpty == true 
        ? int.tryParse(user!['dob_day'].toString()) 
        : null;
    userDobMonth = user?['dob_month']?.toString().isNotEmpty == true 
        ? int.tryParse(user!['dob_month'].toString()) 
        : null;
    userDobYear = user?['dob_year']?.toString().isNotEmpty == true 
        ? int.tryParse(user!['dob_year'].toString()) 
        : null;

    if (userDobDay != null && userDobMonth != null && userDobYear != null) {
      final dobForSession = DateTime(userDobYear!, userDobMonth!, userDobDay!);
      final sessionDob = DateFormat('dd-MM-yyyy').format(dobForSession);
      await session.setDob(sessionDob);
      if (kDebugMode) {
        print('Profile → Session DOB (dd-MM-yyyy): "$sessionDob"');
      }
    }

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

        userAddress = user['address'] ?? "";
        userEducation = user['education'] ?? "";
        userAbout = (user['about'] ?? "").toString();

        if (userEducation.trim().isNotEmpty) {
          userEducationList = userEducation
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else {
          userEducationList = [];
        }

        connectionsCount = myConnections.length;

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
    if (userDobDay == null || userDobMonth == null || userDobYear == null) return "";
    final dt = DateTime(userDobYear!, userDobMonth!, userDobDay!);
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  Future<void> _logout() async {
    try {
      final session = await DobYobSessionManager.getInstance();
      final uidInt = await session.getUserId();

      if (uidInt != null) {
        await apiService.logout(userId: uidInt.toString());
      }

      await session.clearSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    } catch (_) {
      final session = await DobYobSessionManager.getInstance();
      await session.clearSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    }
  }

  void _handleBack() {
    if (widget.onBackToFeed != null) {
      widget.onBackToFeed!();
      return;
    }

    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed('/home');
    }
  }

  // ✅ PERFECT SMOOTH NAVIGATION - NO WHITE FLASH
  void _navigateToConnections() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            ConnectionsScreen(userId: userId),
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
        opaque: false, // ✅ Key for no flash
        barrierColor: Colors.black54, // ✅ Dark barrier
      ),
    ).then((_) {
      // ✅ No immediate reload - only if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          loadProfile();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardColor = Color(0xFF020817);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF020617),
          statusBarIconBrightness: Brightness.light,
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBack,
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
                              ? const Icon(Icons.person, color: Colors.white, size: 40)
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
                                    Text(
                                      userName.isEmpty ? "Your Name" : userName.toTitleCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (userProfession.isNotEmpty)
                                      Text(
                                        userProfession,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    if (location.isNotEmpty)
                                      Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white60,
                                        ),
                                      ),
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
                                        initialDobDay: userDobDay,
                                        initialDobMonth: userDobMonth,
                                        initialDobYear: userDobYear,
                                        initialEmail: userEmail,
                                        initialMobile: userMobile,
                                        initialAddress: userAddress,
                                        initialAbout: userAbout,
                                        initialEducation: userEducation,
                                        initialEducationList: userEducationList,
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
                          // ✅ SMOOTH CONNECTIONS NAVIGATION - NO FLASH
                          GestureDetector(
                            onTap: _navigateToConnections,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: accent.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_outline, 
                                    color: accent, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    connectionsLabel,
                                    style: const TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
