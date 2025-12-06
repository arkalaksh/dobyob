import 'dart:io';
import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_contact_info_screen.dart';

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
    required this.initialDob,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialAddress,
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

  String email = "";
  String joinedMobile = "";
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

    email = widget.initialEmail;
    joinedMobile = widget.initialMobile;
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
    super.dispose();
  }

  // ===== VALIDATORS (25 chars max where needed) =====

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

  void _validateCountry(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        countryError = 'Please select a country';
      } else {
        countryError = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? DateTime.now().subtract(const Duration(days: 7300)),
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
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
                      child: (selectedProfilePic == null &&
                              profilePicUrl.isEmpty)
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 32)
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
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
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

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Name *",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (nameError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  nameError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: businessController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Business / Company",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (businessError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  businessError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: dobController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Date of Birth *",
                labelStyle: const TextStyle(color: Colors.white70),
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Color(0xFF0EA5E9)),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
              onTap: () => _selectDate(context),
            ),
            if (dobError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  dobError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: professionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Profession / Role",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (professionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  professionError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: industryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Industry",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (industryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  industryError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            const Text(
              "Location",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedCountry.isEmpty ? null : selectedCountry,
              decoration: const InputDecoration(
                labelText: "Country *",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
              dropdownColor: bgColor,
              style: const TextStyle(color: Colors.white),
              items: countries
                  .map((c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (v) {
                selectedCountry = v ?? '';
                _validateCountry(selectedCountry);
              },
            ),
            if (countryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  countryError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: cityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "City",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (cityError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  cityError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: stateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "State",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (stateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  stateError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Address",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accent)),
              ),
            ),
            if (addressError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  addressError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            const Text(
              "Contact info",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                email,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              subtitle: Text(
                joinedMobile.isEmpty
                    ? "Tap to edit contact info"
                    : "Phone: $joinedMobile",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right,
                  color: Colors.white70, size: 20),
              onTap: () async {
                final result = await Navigator.push<Map<String, String>?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContactInfoScreen(
                      initialEmail: email,
                      initialMobile: joinedMobile,
                      initialAddress: addressController.text,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    email = result['email'] ?? email;
                    joinedMobile = result['mobile'] ?? joinedMobile;
                    addressController.text =
                        result['address'] ?? addressController.text;
                    _validateAddress();
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? accent : Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isFormValid
                    ? () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        String formattedDob = '';
                        if (selectedDate != null) {
                          formattedDob =
                              DateFormat('yyyy-MM-dd').format(selectedDate!);
                        }

                        final res = await apiService.updateProfile(
                          userId: widget.userId,
                          fullName: nameController.text.trim(),
                          business: businessController.text.trim(),
                          profession: professionController.text.trim(),
                          industry: industryController.text.trim(),
                          dateOfBirth: formattedDob,
                          email: email,
                          phone: joinedMobile,
                          address: addressController.text.trim(),
                          city: cityController.text.trim(),
                          state: stateController.text.trim(),
                          country: selectedCountry,
                          educationList: const [],
                          positionsList: const [],
                          profilePic: selectedProfilePic,
                        );

                        Navigator.of(context, rootNavigator: true).pop();

                        if (res['success'] == true) {
                          final user = res['user'];
                          final session =
                              await DobYobSessionManager.getInstance();

                          await session.saveUserSession(
                            userId: int.parse(user['id'].toString()),
                            name: user['full_name'] ??
                                nameController.text.trim(),
                            email: user['email'] ?? email,
                            phone: user['phone'] ?? joinedMobile,
                            deviceToken:
                                await session.getDeviceToken() ?? '',
                            deviceType:
                                await session.getDeviceType() ?? 'android',
                            profilePicture: user['profile_pic'] ??
                                (res['profile_pic_url'] ?? ''),
                          );

                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update profile!'),
                            ),
                          );
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
