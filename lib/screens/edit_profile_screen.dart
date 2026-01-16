import 'dart:io'; 
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  
  final int? initialDobDay;
  final int? initialDobMonth;
  final int? initialDobYear;
  
  final String initialEmail;
  final String initialMobile;
  final String initialAddress;
  final String initialAbout;
  final String initialEducation;
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
    this.initialDobDay,
    this.initialDobMonth,
    this.initialDobYear,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAddress,
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

  late TextEditingController aboutController;
  String? aboutError;
  final int aboutMaxWords = 200;

  final TextEditingController educationInputController = TextEditingController();
  List<String> educationList = [];

  File? selectedProfilePic;
  String profilePicUrl = "";
  DateTime? selectedDate;

  String selectedCountry = "";
  final List<String> countries = [
    'India', 'USA', 'UK', 'Canada', 'Australia', 'Germany', 'France',
    'Japan', 'China', 'Brazil', 'Russia', 'South Africa', 'UAE',
    'Singapore', 'Others'
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

  bool _isSaving = false;
  final RegExp _emojiRegex = RegExp(
    r'[\u{1F300}-\u{1FAD6}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
    unicode: true,
  );

  @override
  bool get _isFormValid {
    return nameError == null &&
        businessError == null &&
        professionError == null &&
        industryError == null &&
        cityError == null &&
        stateError == null &&
        addressError == null &&
        countryError == null &&
        emailError == null &&
        mobileError == null &&
        aboutError == null &&
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        mobileController.text.trim().isNotEmpty &&
        selectedCountry.isNotEmpty;
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
    aboutController = TextEditingController(text: widget.initialAbout);

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

    profilePicUrl = widget.initialProfilePicUrl;
    selectedCountry = widget.initialCountry;

    if (widget.initialDobDay != null && 
        widget.initialDobMonth != null && 
        widget.initialDobYear != null) {
      selectedDate = DateTime(
        widget.initialDobYear!, 
        widget.initialDobMonth!, 
        widget.initialDobDay!
      );
      dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      dobError = null;
    }

    _attachListeners();
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _runInitialValidation();
    });
  }

  void _attachListeners() {
    nameController.addListener(_validateName);
    businessController.addListener(_validateBusiness);
    professionController.addListener(_validateProfession);
    industryController.addListener(_validateIndustry);
    cityController.addListener(_validateCity);
    stateController.addListener(_validateState);
    addressController.addListener(_validateAddress);
    emailController.addListener(_validateEmail);
    mobileController.addListener(_validateMobile);
    aboutController.addListener(_validateAbout);
    educationInputController.addListener(_validateEducationInput);
    countryController.addListener(() {});
  }

  void _runInitialValidation() {
    _validateName();
    _validateBusiness();
    _validateProfession();
    _validateIndustry();
    _validateCity();
    _validateState();
    _validateAddress();
    _validateCountry(selectedCountry);
    _validateEmail();
    _validateMobile();
    _validateAbout();
    _validateEducationInput();
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
    aboutController.dispose();
    super.dispose();
  }

  // 🔥 FIXED VALIDATORS - Empty = No Error
  void _validateName() {
    final text = nameController.text.trim();
    setState(() {
      if (text.isEmpty) {
        nameError = 'Name is required';
      } else if (_emojiRegex.hasMatch(text)) {
        nameError = 'Emojis are not allowed';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
        nameError = 'Only letters allowed';
      } else if (text.length < 2) {
        nameError = 'Minimum 2 characters required';
      } else if (text.length > 25) {
        nameError = 'Maximum 25 characters allowed';
      } else {
        nameError = null;
      }
    });
  }

  // ✅ FIXED: Business - Empty OK, allows alphanum + symbols
  void _validateBusiness() {
    final text = businessController.text.trim();
    setState(() {
      if (text.isEmpty) {
        businessError = null;  // ✅ Optional field
      } else if (_emojiRegex.hasMatch(text)) {
        businessError = 'Emojis not allowed';
      } else if (!RegExp(r'^[a-zA-Z0-9\s&.,-/()]+$').hasMatch(text)) {
        businessError = 'Invalid characters';
      } else if (text.length > 25) {
        businessError = 'Max 25 characters';
      } else {
        businessError = null;
      }
    });
  }

  // ✅ FIXED: Profession - Empty OK, letters only
  void _validateProfession() {
    final text = professionController.text.trim();
    setState(() {
      if (text.isEmpty) {
        professionError = null;  // ✅ Optional field
      } else if (_emojiRegex.hasMatch(text)) {
        professionError = 'Emojis not allowed';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
        professionError = 'Only letters allowed';
      } else if (text.length > 25) {
        professionError = 'Max 25 characters';
      } else {
        professionError = null;
      }
    });
  }

  // ✅ FIXED: Industry - Empty OK, allows alphanum + symbols
  void _validateIndustry() {
    final text = industryController.text.trim();
    setState(() {
      if (text.isEmpty) {
        industryError = null;  // ✅ Optional field
      } else if (_emojiRegex.hasMatch(text)) {
        industryError = 'Emojis not allowed';
      } else if (!RegExp(r'^[a-zA-Z0-9\s&.,-/()]+$').hasMatch(text)) {
        industryError = 'Invalid characters';
      } else if (text.length > 25) {
        industryError = 'Max 25 characters';
      } else {
        industryError = null;
      }
    });
  }

  void _validateCity() {
    final text = cityController.text.trim();
    setState(() {
      if (text.isEmpty) {
        cityError = null;
      } else if (_emojiRegex.hasMatch(text)) {
        cityError = 'Emojis not allowed';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
        cityError = 'Only letters allowed';
      } else if (text.length > 25) {
        cityError = 'Max 25 characters';
      } else {
        cityError = null;
      }
    });
  }

  void _validateState() {
    final text = stateController.text.trim();
    setState(() {
      if (text.isEmpty) {
        stateError = null;
      } else if (_emojiRegex.hasMatch(text)) {
        stateError = 'Emojis not allowed';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
        stateError = 'Only letters allowed';
      } else if (text.length > 25) {
        stateError = 'Max 25 characters';
      } else {
        stateError = null;
      }
    });
  }

  void _validateAddress() {
    final text = addressController.text.trim();
    setState(() {
      if (text.isEmpty) {
        addressError = null;
      } else if (_emojiRegex.hasMatch(text)) {
        addressError = 'Emojis not allowed';
      } else if (!RegExp(r'^[a-zA-Z0-9\s,.-/()]+$').hasMatch(text)) {
        addressError = 'Invalid characters';
      } else if (text.length > 25) {
        addressError = 'Max 25 characters';
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
        emailError = 'Enter valid .com email';
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
        mobileError = 'Enter 10-digit mobile';
      } else {
        mobileError = null;
      }
    });
  }

  void _validateCountry(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        countryError = 'Please select country';
      } else {
        countryError = null;
      }
    });
  }

  // 🔥 NEW: About validation - No emojis, max words
  void _validateAbout() {
    final text = aboutController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      if (text.isEmpty) {
        aboutError = null;  // ✅ Optional
      } else if (_emojiRegex.hasMatch(text)) {
        aboutError = 'Emojis not allowed';
      } else if (words > aboutMaxWords) {
        aboutError = 'Max $aboutMaxWords words allowed';
      } else {
        aboutError = null;
      }
    });
  }

  // 🔥 NEW: Education input validation - No emojis
  void _validateEducationInput() {
    final text = educationInputController.text.trim();
    if (text.isNotEmpty && _emojiRegex.hasMatch(text)) {
      // Show visual feedback but don't block save
      debugPrint('Education: Emojis not allowed');
    }
  }

  int _aboutWordCount() {
    final t = aboutController.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
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
        automaticallyImplyLeading: false,
        leading: SafeArea(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Edit profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFF1F2937)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16, 
            12, 
            16, 
            MediaQuery.of(context).padding.bottom + 16
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
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
                            : (profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) as ImageProvider : null),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Name *
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Name *",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: nameError,
                ),
              ),
              const SizedBox(height: 12),

              // Email *
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

              // Mobile *
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

              // Business (optional)
              TextField(
                controller: businessController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Business / Company",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: businessError,
                ),
              ),
              const SizedBox(height: 12),

              // DOB Display Only
              TextField(
                controller: dobController,
                readOnly: true,
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  labelStyle: const TextStyle(color: Colors.white70),
                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.white54),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  errorText: dobError,
                ),
              ),
              const SizedBox(height: 12),

              // Profession (optional)
              TextField(
                controller: professionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Profession / Role",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: professionError,
                ),
              ),
              const SizedBox(height: 12),

              // Industry (optional)
              TextField(
                controller: industryController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Industry",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: industryError,
                ),
              ),
              const SizedBox(height: 20),

              // About yourself (optional + emoji validation)
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
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
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

              // Education (emoji blocked)
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
                      if (text.isNotEmpty && !_emojiRegex.hasMatch(text)) {  // ✅ Block emojis
                        setState(() {
                          educationList.add(text);
                          educationInputController.clear();
                        });
                      } else if (_emojiRegex.hasMatch(text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Emojis not allowed in education')),
                        );
                      }
                    },
                    child: const Text('Add', style: TextStyle(color: accent)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location
              const Text(
                "Location",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedCountry.isEmpty ? null : selectedCountry,
                decoration: InputDecoration(
                  labelText: "Country *",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: countryError,
                ),
                dropdownColor: bgColor,
                style: const TextStyle(color: Colors.white),
                items: countries.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  setState(() => selectedCountry = v ?? '');
                  _validateCountry(selectedCountry);
                },
              ),
              const SizedBox(height: 12),

              TextField(
                controller: cityController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "City",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: cityError,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: stateController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "State",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: stateError,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Address",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                  errorText: addressError,
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
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
                                String dobForDb = selectedDate != null 
                                    ? DateFormat('yyyy-MM-dd').format(selectedDate!) 
                                    : '';

                                final res = await apiService.updateProfile(
                                  userId: widget.userId,
                                  fullName: nameController.text.trim(),
                                  business: businessController.text.trim(),
                                  profession: professionController.text.trim(),
                                  industry: industryController.text.trim(),
                                  dateOfBirth: dobForDb,
                                  email: emailController.text.trim(),
                                  phone: mobileController.text.trim(),
                                  address: addressController.text.trim(),
                                  city: cityController.text.trim(),
                                  state: stateController.text.trim(),
                                  country: selectedCountry,
                                  educationList: educationList,
                                  positionsList: const [],
                                  profilePic: selectedProfilePic,
                                  about: aboutController.text.trim(),
                                );

                                debugPrint('updateProfile res: $res');
                                Navigator.of(context, rootNavigator: true).pop();

                                if (res['success'] == true) {
                                  final user = res['user'] ?? {};
                                  final session = await DobYobSessionManager.getInstance();

                                  final String sessionDob = selectedDate != null 
                                      ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                                      : '';
                                  if (sessionDob.isNotEmpty) {
                                    await session.setDob(sessionDob);
                                    debugPrint('EditProfile → Session DOB: $sessionDob');
                                  }

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
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                }
                              } catch (e) {
                                Navigator.of(context, rootNavigator: true).pop();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              } finally {
                                if (mounted) setState(() => _isSaving = false);
                              }
                            }
                          : null,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Save", style: TextStyle(color: Colors.white, fontSize: 17)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
