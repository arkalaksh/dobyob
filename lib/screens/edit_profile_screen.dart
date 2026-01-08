import 'dart:io';

import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String initialName;
  final String initialBusiness;
  final String initialProfession;
  final String initialIndustry;
  final String initialCity;
  final String initialState;
  final String initialCountry;
  final String initialDob;
  final String initialEmail;
  final String initialMobile;
  final String initialAddress;

  // ✅ ABOUT (new)
  final String initialAbout;

  final String initialEducation; // comma-separated किंवा "[]"
  final List<String> initialEducationList;
  final List<String> initialPositions;
  final String initialProfilePicUrl;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.initialName,
    required this.initialBusiness,
    required this.initialProfession,
    required this.initialIndustry,
    required this.initialCity,
    required this.initialState,
    required this.initialCountry,
    required this.initialDob,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAddress,

    // ✅ ABOUT (new)
    required this.initialAbout,

    required this.initialEducation,
    required this.initialEducationList,
    required this.initialPositions,
    required this.initialProfilePicUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService apiService = ApiService();

  late TextEditingController nameController;
  late TextEditingController businessController;
  final TextEditingController dobController = TextEditingController();
  late TextEditingController professionController;
  late TextEditingController industryController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController addressController;

  late TextEditingController emailController;
  late TextEditingController mobileController;

  // ✅ ABOUT (new)
  late TextEditingController aboutController;
  String? aboutError;
  final int aboutMaxWords = 200;

  // education
  final TextEditingController educationInputController = TextEditingController();
  List<String> educationList = [];

  File? selectedProfilePic;
  String profilePicUrl = "";
  DateTime? selectedDate;

  String selectedCountry = "";
  final List<String> countries = [
    'India',
    'USA',
    'UK',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'China',
    'Brazil',
    'Russia',
    'South Africa',
    'UAE',
    'Singapore',
    'Others'
  ];

  String? nameError;
  String? businessError;
  String? dobError;
  String? professionError;
  String? industryError;
  String? cityError;
  String? stateError;
  String? addressError;
  String? countryError;
  String? emailError;
  String? mobileError;

  // ✅ FIX: prevent double save
  bool _isSaving = false;

  bool get _isFormValid {
    return nameError == null &&
        businessError == null &&
        dobError == null &&
        professionError == null &&
        industryError == null &&
        cityError == null &&
        stateError == null &&
        addressError == null &&
        countryError == null &&
        emailError == null &&
        mobileError == null &&
        aboutError == null && // ✅ ABOUT (new)
        nameController.text.trim().isNotEmpty &&
        selectedCountry.isNotEmpty &&
        selectedDate != null;
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialName);
    businessController = TextEditingController(text: widget.initialBusiness);
    professionController = TextEditingController(text: widget.initialProfession);
    industryController = TextEditingController(text: widget.initialIndustry);
    cityController = TextEditingController(text: widget.initialCity);
    stateController = TextEditingController(text: widget.initialState);
    countryController = TextEditingController(text: widget.initialCountry);
    addressController = TextEditingController(text: widget.initialAddress);

    emailController = TextEditingController(text: widget.initialEmail);
    mobileController = TextEditingController(text: widget.initialMobile);

    // ✅ ABOUT INIT (new)
    aboutController = TextEditingController(text: widget.initialAbout);

    // ---------- EDUCATION INIT ----------
    if (widget.initialEducationList.isNotEmpty) {
      educationList = List<String>.from(widget.initialEducationList);
    } else {
      final rawEdu = widget.initialEducation.trim();
      if (rawEdu.isNotEmpty && rawEdu != '[]' && rawEdu.toLowerCase() != 'null') {
        educationList = rawEdu
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else {
        educationList = [];
      }
    }
    // ---------- END EDUCATION INIT ----------

    profilePicUrl = widget.initialProfilePicUrl;
    selectedCountry = widget.initialCountry;

    if (widget.initialDob.isNotEmpty) {
      try {
        selectedDate = DateFormat('yyyy-MM-dd').parse(widget.initialDob);
        dobController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      } catch (_) {
        dobController.text = widget.initialDob;
      }
    }

    _attachListeners();
    _runInitialValidation();
  }

  void _attachListeners() {
    nameController.addListener(_validateName);
    businessController.addListener(_validateBusiness);
    dobController.addListener(_validateDob);
    professionController.addListener(_validateProfession);
    industryController.addListener(_validateIndustry);
    cityController.addListener(_validateCity);
    stateController.addListener(_validateState);
    addressController.addListener(_validateAddress);
    emailController.addListener(_validateEmail);
    mobileController.addListener(_validateMobile);

    // ✅ ABOUT listener (new)
    aboutController.addListener(_validateAbout);
  }

  void _runInitialValidation() {
    _validateName();
    _validateBusiness();
    _validateDob();
    _validateProfession();
    _validateIndustry();
    _validateCity();
    _validateState();
    _validateAddress();
    _validateCountry(selectedCountry);
    _validateEmail();
    _validateMobile();

    // ✅ ABOUT validate (new)
    _validateAbout();
  }

  @override
  void dispose() {
    nameController.dispose();
    businessController.dispose();
    dobController.dispose();
    professionController.dispose();
    industryController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    addressController.dispose();
    emailController.dispose();
    mobileController.dispose();
    educationInputController.dispose();

    // ✅ ABOUT dispose (new)
    aboutController.dispose();

    super.dispose();
  }

  // ===== VALIDATORS =====
  void _validateName() {
    final text = nameController.text.trim();
    setState(() {
      if (text.isEmpty) {
        nameError = 'Name is required';
      } else if (text.length < 2) {
        nameError = 'Minimum 2 characters required';
      } else if (text.length > 25) {
        nameError = 'Maximum 25 characters allowed';
      } else {
        nameError = null;
      }
    });
  }

  void _validateBusiness() {
    final text = businessController.text.trim();
    setState(() {
      if (text.length > 25) {
        businessError = 'Maximum 25 characters allowed';
      } else {
        businessError = null;
      }
    });
  }

  void _validateDob() {
    setState(() {
      if (selectedDate == null && dobController.text.trim().isEmpty) {
        dobError = 'Date of birth is required';
      } else {
        dobError = null;
      }
    });
  }

  void _validateProfession() {
    final text = professionController.text.trim();
    setState(() {
      if (text.length > 25) {
        professionError = 'Maximum 25 characters allowed';
      } else {
        professionError = null;
      }
    });
  }

  void _validateIndustry() {
    final text = industryController.text.trim();
    setState(() {
      if (text.length > 25) {
        industryError = 'Maximum 25 characters allowed';
      } else {
        industryError = null;
      }
    });
  }

  void _validateCity() {
    final text = cityController.text.trim();
    setState(() {
      if (text.length > 25) {
        cityError = 'Maximum 25 characters allowed';
      } else {
        cityError = null;
      }
    });
  }

  void _validateState() {
    final text = stateController.text.trim();
    setState(() {
      if (text.length > 25) {
        stateError = 'Maximum 25 characters allowed';
      } else {
        stateError = null;
      }
    });
  }

  void _validateAddress() {
    final text = addressController.text.trim();
    setState(() {
      if (text.length > 25) {
        addressError = 'Maximum 25 characters allowed';
      } else {
        addressError = null;
      }
    });
  }

  void _validateEmail() {
    final text = emailController.text.trim();
    setState(() {
      if (text.isEmpty) {
        emailError = 'Email is required';
      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$').hasMatch(text)) {
        emailError = 'Enter valid .com email address';
      } else {
        emailError = null;
      }
    });
  }

  void _validateMobile() {
    final text = mobileController.text.trim();
    final cleaned = text.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      if (text.isEmpty) {
        mobileError = 'Mobile is required';
      } else if (cleaned.length != 10) {
        mobileError = 'Enter valid 10-digit mobile number';
      } else {
        mobileError = null;
      }
    });
  }

  void _validateCountry(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        countryError = 'Please select a country';
      } else {
        countryError = null;
      }
    });
  }

  // ✅ ABOUT validator (new)
  void _validateAbout() {
    final text = aboutController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;

    setState(() {
      if (words > aboutMaxWords) {
        aboutError = 'Maximum $aboutMaxWords words allowed';
      } else {
        aboutError = null;
      }
    });
  }

  int _aboutWordCount() {
    final t = aboutController.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().subtract(const Duration(days: 7300)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0EA5E9),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImageWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedProfilePic = File(result.files.single.path!);
        profilePicUrl = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF020617);
    const accent = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImageWithFilePicker,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: selectedProfilePic != null
                          ? FileImage(selectedProfilePic!)
                          : (profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl) as ImageProvider
                              : null),
                      child: (selectedProfilePic == null && profilePicUrl.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white, size: 32)
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _pickImageWithFilePicker,
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black87,
                        child: Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Basic info",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // name
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Name *",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (nameError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(nameError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email *",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                errorText: emailError,
              ),
            ),
            const SizedBox(height: 12),

            // Mobile
            TextField(
              controller: mobileController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Mobile *",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                errorText: mobileError,
              ),
            ),
            const SizedBox(height: 12),

            // business
            TextField(
              controller: businessController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Business / Company",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (businessError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(businessError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            // DOB
            TextField(
              controller: dobController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Date of Birth *",
                labelStyle: TextStyle(color: Colors.white70),
                suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF0EA5E9)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
              onTap: () => _selectDate(context),
            ),
            if (dobError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(dobError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            // profession
            TextField(
              controller: professionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Profession / Role",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (professionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(professionError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            // industry
            TextField(
              controller: industryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Industry",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (industryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(industryError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),

            // ✅ ABOUT YOURSELF (new)
            const SizedBox(height: 20),
            const Text(
              "About yourself",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: aboutController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Write about yourself",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder:
                    const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                errorText: aboutError,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_aboutWordCount()} / $aboutMaxWords words',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),

            const SizedBox(height: 20),

            // EDUCATION SECTION
            const Text(
              "Education",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),

            if (educationList.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: educationList.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    educationList[index],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    onPressed: () => setState(() => educationList.removeAt(index)),
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: educationInputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Add education",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    final text = educationInputController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        educationList.add(text);
                        educationInputController.clear();
                      });
                    }
                  },
                  child: const Text('Add', style: TextStyle(color: accent)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Location",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedCountry.isEmpty ? null : selectedCountry,
              decoration: const InputDecoration(
                labelText: "Country *",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
              dropdownColor: bgColor,
              style: const TextStyle(color: Colors.white),
              items: countries.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                // ✅ FIX: ensure rebuild/validation
                setState(() {
                  selectedCountry = v ?? '';
                });
                _validateCountry(selectedCountry);
              },
            ),
            if (countryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(countryError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: cityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "City",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (cityError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(cityError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: stateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "State",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (stateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(stateError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Address",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
              ),
            ),
            if (addressError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(addressError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isFormValid && !_isSaving) ? accent : Colors.grey[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (_isFormValid && !_isSaving)
                    ? () async {
                        setState(() => _isSaving = true);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          String formattedDob = '';
                          if (selectedDate != null) {
                            formattedDob = DateFormat('yyyy-MM-dd').format(selectedDate!);
                          }

                          final res = await apiService.updateProfile(
                            userId: widget.userId,
                            fullName: nameController.text.trim(),
                            business: businessController.text.trim(),
                            profession: professionController.text.trim(),
                            industry: industryController.text.trim(),
                            dateOfBirth: formattedDob,
                            email: emailController.text.trim(),
                            phone: mobileController.text.trim(),
                            address: addressController.text.trim(),
                            city: cityController.text.trim(),
                            state: stateController.text.trim(),
                            country: selectedCountry,
                            educationList: educationList,
                            positionsList: const [],
                            profilePic: selectedProfilePic,

                            // ✅ ABOUT send (new)
                            about: aboutController.text.trim(),
                          );

                          // ✅ DEBUG (so you can confirm about is in response)
                          debugPrint('updateProfile res: $res');

                          Navigator.of(context, rootNavigator: true).pop();

                          if (res['success'] == true) {
                            final user = res['user'] ?? {};
                            final session = await DobYobSessionManager.getInstance();

                            final dynamic picAny = (user['profile_pic'] ?? res['profile_pic_url'] ?? '');
                            final String newProfilePic = (picAny ?? '').toString();

                            await session.saveUserSession(
                              userId: int.parse((user['id'] ?? widget.userId).toString()),
                              name: (user['full_name'] ?? nameController.text.trim()).toString(),
                              email: (user['email'] ?? emailController.text.trim()).toString(),
                              phone: (user['phone'] ?? mobileController.text.trim()).toString(),
                              deviceToken: await session.getDeviceToken() ?? '',
                              deviceType: await session.getDeviceType() ?? 'android',
                              profilePicture: newProfilePic,
                            );

                            if (newProfilePic.isNotEmpty) {
                              await session.updateProfilePicture(newProfilePic);
                            }

                            if (!mounted) return;
                            Navigator.pop(context, true);
                          } else {
                            if (!mounted) return;
                            final msg = (res['message'] ?? res['error'] ?? 'Failed to update profile!').toString();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }
                        } catch (e) {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      }
                    : null,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}