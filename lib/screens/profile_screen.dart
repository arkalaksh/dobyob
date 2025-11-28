import 'dart:io';
import 'package:dobyob_1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';

/// ===================== PROFILE SCREEN =====================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = "5"; // TODO: Replace with actual userId

  String userName = "";
  String userBusiness = "";
  String userProfession = "";
  String userIndustry = "";
  String userEducation = "";
  String userCity = "";
  String userState = "";
  String userCountry = "";
  String userDob = "";
  String userEmail = "";
  String userMobile = "";
  String userAddress = "";
  String userProfilePicUrl = "";

  List<String> userPositions = <String>[];
  List<String> userEducationList = <String>[];

  ApiService apiService = ApiService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    final user = await apiService.getProfile(userId);
    setState(() {
      isLoading = false;
      if (user != null) {
        userName = user['full_name'] ?? "";
        userBusiness = user['business'] ?? "";
        userProfession = user['profession'] ?? "";
        userIndustry = user['industry'] ?? "";
        userEducation = user['education'] ?? "";
        userProfilePicUrl = user['profile_pic'] ?? "";

        userEducationList = userEducation.isNotEmpty
            ? userEducation
                .split(',')
                .map<String>((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];

        final String positionsRaw = user['positions'] ?? "";
        userPositions = positionsRaw.isNotEmpty
            ? positionsRaw
                .split(',')
                .map<String>((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];

        userCity = user['city'] ?? "";
        userState = user['state'] ?? "";
        userCountry = user['country'] ?? "";
        userDob = user['date_of_birth'] ?? "";
        userEmail = user['email'] ?? "";
        userMobile = user['phone'] ?? "";
        userAddress = user['address'] ?? "";
      }
    });
  }

  Text _infoText(String t) =>
      Text(t, style: const TextStyle(fontSize: 15, color: Colors.white));

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const cardColor = Color(0xFF020817);
    const borderColor = Color(0xFF1F2937);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF020817),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 3,
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xFF6B7280),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i != 3) {
            if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            if (i == 1) Navigator.pushReplacementNamed(context, '/invite');
            if (i == 2) Navigator.pushReplacementNamed(context, '/addpost');
          }
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accent),
            )
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
                              ? NetworkImage(
                                  'https://arkalaksh.com/dobyob/$userProfilePicUrl',
                                )
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
                      top: 16,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF020817),
                        child: const Icon(Icons.settings,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: borderColor),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName.isEmpty ? "Profile" : userName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: accent, size: 22),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        userId: userId,
                                        initialName: userName,
                                        initialBusiness: userBusiness,
                                        initialProfession: userProfession,
                                        initialIndustry: userIndustry,
                                        initialEducation: userEducation,
                                        initialEducationList:
                                            List<String>.from(
                                                userEducationList),
                                        initialPositions:
                                            List<String>.from(userPositions),
                                        initialCity: userCity,
                                        initialState: userState,
                                        initialCountry: userCountry,
                                        initialDob: userDob,
                                        initialEmail: userEmail,
                                        initialMobile: userMobile,
                                        initialAddress: userAddress,
                                        initialProfilePicUrl:
                                            userProfilePicUrl,
                                      ),
                                    ),
                                  );

                                  if (result != null &&
                                      result is Map<String, dynamic>) {
                                    setState(() {
                                      userName =
                                          result['name'] ?? userName;
                                      userBusiness =
                                          result['business'] ??
                                              userBusiness;
                                      userProfession =
                                          result['profession'] ??
                                              userProfession;
                                      userIndustry =
                                          result['industry'] ??
                                              userIndustry;
                                      userEducation =
                                          result['education'] ??
                                              userEducation;
                                      userEducationList =
                                          (result['educationList']
                                                      as List?)
                                                  ?.cast<String>() ??
                                              userEducationList;
                                      userPositions =
                                          (result['positions'] as List?)
                                                  ?.cast<String>() ??
                                              userPositions;
                                      userCity =
                                          result['city'] ?? userCity;
                                      userState =
                                          result['state'] ?? userState;
                                      userCountry =
                                          result['country'] ??
                                              userCountry;
                                      userDob =
                                          result['dob'] ?? userDob;
                                      userEmail =
                                          result['email'] ?? userEmail;
                                      userMobile =
                                          result['mobile'] ?? userMobile;
                                      userAddress =
                                          result['address'] ??
                                              userAddress;
                                      userProfilePicUrl =
                                          result['profile_pic_url'] ??
                                              userProfilePicUrl;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 28, color: borderColor),
                          if (userBusiness.isNotEmpty)
                            _infoText("Business: $userBusiness"),
                          if (userIndustry.isNotEmpty)
                            _infoText("Industry: $userIndustry"),
                          if (userProfession.isNotEmpty)
                            _infoText("Profession: $userProfession"),
                          if (userEducationList.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Education:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                ...userEducationList
                                    .map((edu) => _infoText(edu))
                                    .toList(),
                              ],
                            )
                          else if (userEducation.isNotEmpty)
                            _infoText("Education: $userEducation"),
                          if (userPositions.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text(
                                  "Positions:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                ...userPositions
                                    .map((pos) => _infoText(pos))
                                    .toList(),
                              ],
                            ),
                          if (userCity.isNotEmpty)
                            _infoText("City: $userCity"),
                          if (userState.isNotEmpty)
                            _infoText("State: $userState"),
                          if (userCountry.isNotEmpty)
                            _infoText("Country: $userCountry"),
                          const Divider(height: 18, color: borderColor),
                          if (userEmail.isNotEmpty)
                            _infoText("Email: $userEmail"),
                          if (userMobile.isNotEmpty)
                            _infoText("Mobile: $userMobile"),
                          if (userAddress.isNotEmpty)
                            _infoText("Address: $userAddress"),
                          if (userDob.isNotEmpty)
                            _infoText("DOB: $userDob"),
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

/// ===================== EDIT PROFILE SCREEN =====================

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String initialName;
  final String initialBusiness;
  final String initialProfession;
  final String initialIndustry;
  final String initialEducation;
  final List<String> initialEducationList;
  final List<String> initialPositions;
  final String initialCity;
  final String initialState;
  final String initialCountry;
  final String initialDob;
  final String initialEmail;
  final String initialMobile;
  final String initialAddress;
  final String initialProfilePicUrl;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.initialName,
    required this.initialBusiness,
    required this.initialProfession,
    required this.initialIndustry,
    required this.initialEducation,
    required this.initialEducationList,
    required this.initialPositions,
    required this.initialCity,
    required this.initialState,
    required this.initialCountry,
    required this.initialDob,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAddress,
    required this.initialProfilePicUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController businessController;
  late TextEditingController professionController;
  late TextEditingController industryController;
  late TextEditingController educationController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController dobController;

  String email = '';
  String mobile = '';
  String mobileCountryCode = 'IN';
  String address = '';

  File? selectedProfilePic;
  String profilePicUrl = '';

  List<TextEditingController> positionControllers = [];
  List<TextEditingController> educationControllers = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    businessController =
        TextEditingController(text: widget.initialBusiness);
    professionController =
        TextEditingController(text: widget.initialProfession);
    industryController =
        TextEditingController(text: widget.initialIndustry);
    educationController =
        TextEditingController(text: widget.initialEducation);
    cityController = TextEditingController(text: widget.initialCity);
    stateController = TextEditingController(text: widget.initialState);
    countryController =
        TextEditingController(text: widget.initialCountry);
    dobController = TextEditingController(text: widget.initialDob);

    email = widget.initialEmail;
    mobile = widget.initialMobile.replaceAll(RegExp('[^0-9]'), '');
    address = widget.initialAddress;

    profilePicUrl = widget.initialProfilePicUrl;

    educationControllers = widget.initialEducationList.isNotEmpty
        ? widget.initialEducationList
            .map<TextEditingController>(
                (e) => TextEditingController(text: e))
            .toList()
        : <TextEditingController>[TextEditingController()];

    positionControllers = widget.initialPositions.isNotEmpty
        ? widget.initialPositions
            .map<TextEditingController>(
                (p) => TextEditingController(text: p))
            .toList()
        : <TextEditingController>[TextEditingController()];
  }

  @override
  void dispose() {
    nameController.dispose();
    businessController.dispose();
    professionController.dispose();
    industryController.dispose();
    educationController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    dobController.dispose();
    for (var c in positionControllers) {
      c.dispose();
    }
    for (var c in educationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickProfilePic() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedProfilePic = File(picked.path);
        profilePicUrl = "";
      });
    }
  }

  void updateContactInfoFromEdit(Map<String, dynamic> result) {
    setState(() {
      email = result['email'];
      mobile = result['mobile'].replaceAll(RegExp('[^0-9]'), '');
      address = result['address'];
    });
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          s,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      );

  Widget _entry(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1F2937)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
          ),
          suffixIcon: suffixIcon,
        ),
      );

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: pickProfilePic,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFF111827),
                    child: selectedProfilePic != null
                        ? ClipOval(
                            child: Image.file(
                              selectedProfilePic!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (profilePicUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                'https://arkalaksh.com/dobyob/$profilePicUrl',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ))
                            : const Icon(Icons.camera_alt,
                                size: 40, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _label("Full Name"),
              _entry(nameController, 'Enter your name'),
              _label("Business Info"),
              _entry(businessController, 'Tell us about your business'),
              _label("Industry / Professional Field"),
              _entry(industryController,
                  'Enter your industry or professional field'),
              _label("Profession"),
              _entry(professionController, 'Enter your profession'),
              _label("Positions"),
              ...positionControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                        child: _entry(
                            controller, "Enter position details")),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (positionControllers.length > 1) {
                            positionControllers.removeAt(idx);
                          }
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                icon: const Icon(Icons.add, color: accent),
                label: const Text("Add New Position",
                    style: TextStyle(color: accent)),
                onPressed: () {
                  setState(() {
                    positionControllers.add(TextEditingController());
                  });
                },
              ),
              _label("Education"),
              ...educationControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                        child:
                            _entry(controller, "Enter education details")),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (educationControllers.length > 1) {
                            educationControllers.removeAt(idx);
                          }
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                icon: const Icon(Icons.add, color: accent),
                label: const Text("Add New Education",
                    style: TextStyle(color: accent)),
                onPressed: () {
                  setState(() {
                    educationControllers.add(TextEditingController());
                  });
                },
              ),
              _label("City"),
              _entry(cityController, 'Enter your city'),
              _label("State"),
              _entry(stateController, 'Enter your state'),
              _label("Country"),
              _entry(countryController, 'Enter your country'),
              _label("DOB"),
              _entry(
                dobController,
                'Select DOB',
                readOnly: true,
                suffixIcon:
                    const Icon(Icons.calendar_today, color: accent),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now()
                        .subtract(const Duration(days: 365 * 20)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    dobController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 32),
              GestureDetector(
                child: Card(
                  color: const Color(0xFF0B1120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    child: Row(
                      children: const [
                        Icon(Icons.contact_mail,
                            color: Colors.white, size: 21),
                        SizedBox(width: 8),
                        Text('Contact Info',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditContactInfoScreen(
                        initialEmail: email,
                        initialMobile: mobile,
                        initialAddress: address,
                      ),
                    ),
                  );
                  if (result != null) {
                    updateContactInfoFromEdit(
                        result as Map<String, dynamic>);
                  }
                },
              ),
              if (address.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8, top: 14),
                  child: Text("Address: $address",
                      style: const TextStyle(
                          fontSize: 15, color: Colors.white)),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final joinedMobile = '+91 $mobile';
                    List<String> positions = positionControllers
                        .map((c) => c.text)
                        .where((e) => e.isNotEmpty)
                        .toList();
                    List<String> educationList = educationControllers
                        .map((c) => c.text)
                        .where((e) => e.isNotEmpty)
                        .toList();

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    final res = await apiService.updateProfile(
                      userId: widget.userId,
                      fullName: nameController.text,
                      business: businessController.text,
                      profession: professionController.text,
                      industry: industryController.text,
                      dateOfBirth: dobController.text,
                      email: email,
                      phone: joinedMobile,
                      address: address,
                      city: cityController.text,
                      state: stateController.text,
                      country: countryController.text,
                      educationList: educationList,
                      positionsList: positions,
                      profilePic: selectedProfilePic,
                    );

                    Navigator.of(context, rootNavigator: true).pop();

                    if (res['success'] == true) {
                      Navigator.pop(context, {
                        'name': nameController.text,
                        'business': businessController.text,
                        'profession': professionController.text,
                        'industry': industryController.text,
                        'education': educationController.text,
                        'educationList': educationList,
                        'positions': positions,
                        'city': cityController.text,
                        'state': stateController.text,
                        'country': countryController.text,
                        'dob': dobController.text,
                        'email': email,
                        'mobile': joinedMobile,
                        'address': address,
                        'profile_pic_url': res['profile_pic_url'] ?? '',
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update profile!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Save",
                      style:
                          TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== EDIT CONTACT INFO =====================

class EditContactInfoScreen extends StatefulWidget {
  final String initialEmail;
  final String initialMobile;
  final String initialAddress;

  const EditContactInfoScreen({
    super.key,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAddress,
  });

  @override
  State<EditContactInfoScreen> createState() =>
      _EditContactInfoScreenState();
}

class _EditContactInfoScreenState extends State<EditContactInfoScreen> {
  late TextEditingController emailController;
  late TextEditingController addressController;
  String mobile = '';
  String mobileCountryCode = 'IN';

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
    addressController =
        TextEditingController(text: widget.initialAddress);
    mobile = widget.initialMobile;
  }

  @override
  void dispose() {
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          s,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      );

  Widget _entry(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1F2937)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Edit Contact Info',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Email"),
              _entry(emailController, 'Enter your email',
                  keyboardType: TextInputType.emailAddress),
              _label("Mobile Number"),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  labelStyle:
                      const TextStyle(color: Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF1F2937)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: accent, width: 1.5),
                  ),
                ),
                initialCountryCode: mobileCountryCode,
                controller: TextEditingController(text: mobile),
                style: const TextStyle(color: Colors.white),
                dropdownTextStyle:
                    const TextStyle(color: Colors.white),
                onChanged: (phone) {
                  mobile = phone.number;
                  mobileCountryCode =
                      phone.countryISOCode ?? 'IN';
                },
              ),
              _label("Address"),
              _entry(addressController, 'Enter your address'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final joinedMobile =
                        '+$mobileCountryCode $mobile';
                    Navigator.pop(context, {
                      'email': emailController.text,
                      'mobile': joinedMobile,
                      'address': addressController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Save",
                      style:
                          TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
