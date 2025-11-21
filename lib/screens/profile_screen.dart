import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// Main Profile Page
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Your Name";
  String userBusiness = "";
  String userProfession = "";
  String userIndustry = "";
  String userEducation = ""; // This now can be a joined string from list
  String userCity = "Mumbai";
  String userState = "Maharashtra";
  String userCountry = "India";
  String userDob = "01/01/2000";
  String userEmail = "your@email.com";
  String userMobile = "+91 9820012345";
  String userAddress = "";

  // Added lists for multiple positions and education
  List<String> userPositions = [];
  List<String> userEducationList = [];

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF6C646);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: gold), label: ''),
        ],
        currentIndex: 3,
        selectedItemColor: gold,
        unselectedItemColor: gold,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i != 3) {
            if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            if (i == 1) Navigator.pushReplacementNamed(context, '/invite');
            if (i == 2) Navigator.pushReplacementNamed(context, '/addpost');
            if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: ListView(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                color: gold.withOpacity(0.2),
              ),
              Positioned(
                left: 22,
                bottom: -32,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: gold,
                  child: CircleAvatar(
                    radius: 43,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/44.jpg",
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.settings, color: gold, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 1.4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit, color: gold, size: 22),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  initialName: userName,
                                  initialBusiness: userBusiness,
                                  initialProfession: userProfession,
                                  initialIndustry: userIndustry,
                                  initialEducation: userEducation,
                                  initialEducationList: userEducationList,
                                  initialPositions: userPositions,
                                  initialCity: userCity,
                                  initialState: userState,
                                  initialCountry: userCountry,
                                  initialDob: userDob,
                                  initialEmail: userEmail,
                                  initialMobile: userMobile,
                                  initialAddress: userAddress,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                userName = result['name'];
                                userBusiness = result['business'];
                                userProfession = result['profession'];
                                userIndustry = result['industry'];
                                userEducation = result['education'];
                                userEducationList = List<String>.from(result['educationList'] ?? []);
                                userPositions = List<String>.from(result['positions'] ?? []);
                                userCity = result['city'];
                                userState = result['state'];
                                userCountry = result['country'];
                                userDob = result['dob'];
                                userEmail = result['email'];
                                userMobile = result['mobile'];
                                userAddress = result['address'];
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    if (userBusiness.isNotEmpty)
                      Text("Business: $userBusiness", style: const TextStyle(fontSize: 15)),
                    if (userIndustry.isNotEmpty)
                      Text("Industry: $userIndustry", style: const TextStyle(fontSize: 15)),
                    if (userProfession.isNotEmpty)
                      Text("Profession: $userProfession", style: const TextStyle(fontSize: 15)),
                    if (userEducationList.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Education:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ...userEducationList.map((edu) => Text(edu, style: const TextStyle(fontSize: 15))).toList(),
                        ],
                      )
                    else if (userEducation.isNotEmpty)
                      Text("Education: $userEducation", style: const TextStyle(fontSize: 15)),
                    if (userPositions.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text("Positions:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ...userPositions.map((pos) => Text(pos, style: const TextStyle(fontSize: 15))).toList(),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text("City: $userCity", style: const TextStyle(fontSize: 15)),
                    Text("State: $userState", style: const TextStyle(fontSize: 15)),
                    Text("Country: $userCountry", style: const TextStyle(fontSize: 15)),
                    const Divider(height: 18),
                    Text("Email: $userEmail", style: const TextStyle(fontSize: 15)),
                    Text("Mobile: $userMobile", style: const TextStyle(fontSize: 15)),
                    if (userAddress.isNotEmpty)
                      Text("Address: $userAddress", style: const TextStyle(fontSize: 15)),
                    Text("DOB: $userDob", style: const TextStyle(fontSize: 15)),
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

class EditProfileScreen extends StatefulWidget {
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

  const EditProfileScreen({
    super.key,
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

  // Controllers for multiple positions and education entries
  List<TextEditingController> positionControllers = [];
  List<TextEditingController> educationControllers = [];

  @override
  void initState() {
    nameController = TextEditingController(text: widget.initialName);
    businessController = TextEditingController(text: widget.initialBusiness);
    professionController = TextEditingController(text: widget.initialProfession);
    industryController = TextEditingController(text: widget.initialIndustry);
    educationController = TextEditingController(text: widget.initialEducation);
    cityController = TextEditingController(text: widget.initialCity);
    stateController = TextEditingController(text: widget.initialState);
    countryController = TextEditingController(text: widget.initialCountry);
    dobController = TextEditingController(text: widget.initialDob);

    email = widget.initialEmail;
    mobile = widget.initialMobile.replaceAll(RegExp('[^0-9]'), '');
    address = widget.initialAddress;

    // Init dynamic education controllers
    educationControllers = widget.initialEducationList.isNotEmpty
        ? widget.initialEducationList.map((e) => TextEditingController(text: e)).toList()
        : [TextEditingController()];

    // Init dynamic position controllers
    positionControllers = widget.initialPositions.isNotEmpty
        ? widget.initialPositions.map((p) => TextEditingController(text: p)).toList()
        : [TextEditingController()];

    super.initState();
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

  void updateContactInfoFromEdit(Map<String, dynamic> result) {
    setState(() {
      email = result['email'];
      mobile = result['mobile'].replaceAll(RegExp('[^0-9]'), '');
      address = result['address'];
    });
  }

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 5),
    child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
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
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: suffixIcon,
        ),
      );

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF6C646);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: gold), label: ''),
        ],
        currentIndex: 3,
        selectedItemColor: gold,
        unselectedItemColor: gold,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i != 3) {
            if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            if (i == 1) Navigator.pushReplacementNamed(context, '/invite');
            if (i == 2) Navigator.pushReplacementNamed(context, '/addpost');
            if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Full Name"),
              _entry(nameController, 'Enter your name'),
              _label("Business Info"),
              _entry(businessController, 'Tell us about your business'),
              _label("Industry / Professional Field"),
              _entry(industryController, 'Enter your industry or professional field'),
              _label("Profession"),
              _entry(professionController, 'Enter your profession'),

              // Positions Section with dynamic entries
              _label("Positions"),
              ...positionControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(child: _entry(controller, "Enter position details")),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (positionControllers.length > 1) {
                            positionControllers.removeAt(idx);
                          }
                        });
                      },
                    )
                  ],
                );
              }).toList(),
              TextButton.icon(
                icon: Icon(Icons.add),
                label: Text("Add New Position"),
                onPressed: () {
                  setState(() {
                    positionControllers.add(TextEditingController());
                  });
                },
              ),

              // Education Section with dynamic entries
              _label("Education"),
              ...educationControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(child: _entry(controller, "Enter education details")),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (educationControllers.length > 1) {
                            educationControllers.removeAt(idx);
                          }
                        });
                      },
                    )
                  ],
                );
              }).toList(),
              TextButton.icon(
                icon: Icon(Icons.add),
                label: Text("Add New Education"),
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
                suffixIcon: Icon(Icons.calendar_today, color: gold),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                },
              ),
              const SizedBox(height: 32),
              GestureDetector(
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.contact_mail, color: Colors.blue, size: 21),
                        const SizedBox(width: 8),
                        const Text('Contact Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
                    updateContactInfoFromEdit(result);
                  }
                },
              ),
              if (address.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8, top: 14),
                  child: Text("Address: $address", style: const TextStyle(fontSize: 15)),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final joinedMobile = '+91 $mobile';

                    // Extract lists of positions and education text values to send back
                    List<String> positions = positionControllers.map((c) => c.text).toList();
                    List<String> educationList = educationControllers.map((c) => c.text).toList();

                    Navigator.pop(context, {
                      'name': nameController.text,
                      'business': businessController.text,
                      'profession': professionController.text,
                      'industry': industryController.text,
                      'education': educationController.text, // fallback for original usage
                      'educationList': educationList,
                      'positions': positions,
                      'city': cityController.text,
                      'state': stateController.text,
                      'country': countryController.text,
                      'dob': dobController.text,
                      'email': email,
                      'mobile': joinedMobile,
                      'address': address,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  State<EditContactInfoScreen> createState() => _EditContactInfoScreenState();
}

class _EditContactInfoScreenState extends State<EditContactInfoScreen> {
  late TextEditingController emailController;
  late TextEditingController addressController;
  String mobile = '';
  String mobileCountryCode = 'IN';

  @override
  void initState() {
    emailController = TextEditingController(text: widget.initialEmail);
    addressController = TextEditingController(text: widget.initialAddress);
    mobile = widget.initialMobile;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF6C646);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Edit Contact Info', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded, color: gold), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: gold), label: ''),
        ],
        currentIndex: 3,
        selectedItemColor: gold,
        unselectedItemColor: gold,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          if (i != 3) {
            if (i == 0) Navigator.pushReplacementNamed(context, '/home');
            if (i == 1) Navigator.pushReplacementNamed(context, '/invite');
            if (i == 2) Navigator.pushReplacementNamed(context, '/addpost');
            if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Email"),
              _entry(emailController, 'Enter your email', keyboardType: TextInputType.emailAddress),
              _label("Mobile Number"),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: gold)),
                ),
                initialCountryCode: mobileCountryCode,
                controller: TextEditingController(text: mobile),
                onChanged: (phone) {
                  mobile = phone.number;
                  mobileCountryCode = phone.countryISOCode ?? 'IN';
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
                    final joinedMobile = '+${mobileCountryCode} $mobile';
                    Navigator.pop(context, {
                      'email': emailController.text,
                      'mobile': joinedMobile,
                      'address': addressController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
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
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: suffixIcon,
        ),
      );
}

