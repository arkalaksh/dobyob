import 'dart:io';

import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DobYobWizard extends StatefulWidget {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String dateOfBirth; // yyyy-MM-dd

  const DobYobWizard({
    super.key,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
  });

  @override
  State<DobYobWizard> createState() => _DobYobWizardState();
}

class _DobYobWizardState extends State<DobYobWizard> {
  final ApiService apiService = ApiService();
  DobYobSessionManager? _session;

  // COLORS (Bluesky style)
  static const _bg = Color(0xFF020617);
  static const _accent = Color(0xFF0EA5E9);
  static const _fieldFill = Color(0xFF0B1220);
  static const _borderColor = Color(0xFF1F2937);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Step‑1 (Profile + Location)
  File? selectedProfilePic;
  String profilePicUrl = "";
  String selectedCountry = '';
  final TextEditingController cityController = TextEditingController();

  final List<String> countries = const [
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

  // Step‑2 (Work)
  String selectedWorkType = '';
  final TextEditingController companyController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  // Step‑3 (About)
  final TextEditingController aboutController = TextEditingController();
  final int aboutMaxWords = 200;

  // errors (Finish validation साठी)
  String? countryError;
  String? cityError;
  String? workTypeError;
  String? aboutError;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    _session = await DobYobSessionManager.getInstance();
    if (mounted) setState(() {});
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _deco(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accent, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }

  // ---------- helpers ----------
  String? _opt(String? v) {
    final t = (v ?? '').trim();
    return t.isEmpty ? null : t;
  }

  String? _optCtrl(TextEditingController c) => _opt(c.text);

  bool _hasAnythingToSave() {
    return selectedProfilePic != null ||
        _opt(selectedCountry) != null ||
        _optCtrl(cityController) != null ||
        _opt(selectedWorkType) != null ||
        _optCtrl(companyController) != null ||
        _optCtrl(designationController) != null ||
        _optCtrl(aboutController) != null;
  }

  bool _hasStep1ToSave() {
    return selectedProfilePic != null ||
        _opt(selectedCountry) != null ||
        _optCtrl(cityController) != null;
  }

  bool _hasStep2ToSave() {
    return _opt(selectedWorkType) != null ||
        _optCtrl(companyController) != null ||
        _optCtrl(designationController) != null;
  }
  // ----------------------------

  // Finish validation (optional)
  bool _validateStep1ForFinish() {
    countryError = selectedCountry.trim().isEmpty ? 'Country required' : null;
    cityError = cityController.text.trim().isEmpty ? 'City required' : null;
    if (mounted) setState(() {});
    return countryError == null && cityError == null;
  }

  bool _validateStep2ForFinish() {
    workTypeError = selectedWorkType.isEmpty ? 'This field is required' : null;
    if (mounted) setState(() {});
    return workTypeError == null;
  }

  bool _validateStep3ForFinish() {
    final text = aboutController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    aboutError = (words > aboutMaxWords) ? 'Maximum $aboutMaxWords words allowed' : null;
    if (mounted) setState(() {});
    return aboutError == null;
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

  // ✅ core saver (send only filled fields)
  Future<bool> _savePartial({
    String? onlyCountry,
    String? onlyCity,
    String? onlyBusiness,
    String? onlyIndustry,
    String? onlyProfession,
    String? onlyAbout,
    File? onlyProfilePic,
    bool showToast = true,
  }) async {
    if (_isLoading) return false;

    if (!_hasAnythingToSave()) {
      if (showToast) _snack('Nothing to save');
      return false;
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final res = await apiService.updateProfile(
      userId: widget.userId,

      // critical
      fullName: widget.fullName.trim(),
      email: widget.email.trim(),
      phone: widget.phone.trim(),
      dateOfBirth: widget.dateOfBirth.trim(),

      // optional (only what we pass here)
      country: _opt(onlyCountry),
      city: _opt(onlyCity),
      business: _opt(onlyBusiness),
      industry: _opt(onlyIndustry),
      profession: _opt(onlyProfession),
      about: _opt(onlyAbout),

      // do not touch these in wizard partial
      address: null,
      state: null,
      educationList: null,
      positionsList: null,

      profilePic: onlyProfilePic,
    );

    Navigator.of(context, rootNavigator: true).pop();

    bool ok = false;

    if (res['success'] == true) {
      ok = true;
      final user = res['user'] ?? {};
      try {
        final session = _session ?? await DobYobSessionManager.getInstance();
        final newPicUrl =
            (user['profile_pic'] ?? res['profile_pic_url'] ?? '').toString();

        await session.saveUserSession(
          userId: int.tryParse((user['id'] ?? widget.userId).toString()) ?? 0,
          name: (user['full_name'] ?? widget.fullName).toString(),
          email: (user['email'] ?? widget.email).toString(),
          phone: (user['phone'] ?? widget.phone).toString(),
          deviceToken: await session.getDeviceToken() ?? '',
          deviceType: await session.getDeviceType() ?? 'android',
          profilePicture: newPicUrl,
        );

        if (newPicUrl.isNotEmpty) {
          await session.updateProfilePicture(newPicUrl);
        }
      } catch (_) {}

      if (showToast && mounted) _snack('Saved');
    } else {
      if (mounted) _snack((res['message'] ?? 'Update failed').toString());
    }

    if (mounted) setState(() => _isLoading = false);
    return ok;
  }

  // ✅ Step 1 -> if nothing filled, allow next without save
  Future<void> _saveAndNextStep1() async {
    if (!_hasStep1ToSave()) {
      _next();
      return;
    }

    final ok = await _savePartial(
      onlyCountry: selectedCountry,
      onlyCity: cityController.text,
      onlyProfilePic: selectedProfilePic,
    );

    if (!mounted) return;
    if (ok) _next();
  }

  // ✅ Step 2 -> if nothing filled, allow next without save
  Future<void> _saveAndNextStep2() async {
    if (!_hasStep2ToSave()) {
      _next();
      return;
    }

    final ok = await _savePartial(
      onlyBusiness: selectedWorkType,
      onlyIndustry: companyController.text,
      onlyProfession: designationController.text,
    );

    if (!mounted) return;
    if (ok) _next();
  }

  // ✅ Save only (third step - no next) (kept as-is)
  Future<void> _saveStep3() async {
    _validateStep3ForFinish();
    if (aboutError != null) return;

    await _savePartial(
      onlyAbout: aboutController.text,
    );
  }

  // ✅ Finish (ONLY Step-3 About) + home redirect
  Future<void> _finish() async {
    // only validate step-3 (word limit)
    _validateStep3ForFinish();
    if (aboutError != null) return;

    final aboutText = aboutController.text.trim();

    // if nothing written -> directly home
    if (aboutText.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // save only about
    final ok = await _savePartial(
      onlyAbout: aboutText,
      showToast: false,
    );

    if (!mounted) return;
    if (ok) Navigator.pushReplacementNamed(context, '/home');
  }

  // Skip = go home (no save - shows filled info but doesn't save)
  void _skip() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previous() => _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${_currentPage + 1} of 3',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 2),
            const Text(
              'Your profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip', style: TextStyle(color: _accent)),
          ),
        ],
      ),

      // Buttons fixed at bottom (safe)
      bottomNavigationBar: Container(
        color: _bg,
        padding: EdgeInsets.only(bottom: bottomSafe + 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _currentPage > 0 ? _previous : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _currentPage > 0
                          ? Colors.white54
                          : Colors.grey.shade700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_isLoading ? _accent : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_currentPage == 0) {
                            _saveAndNextStep1();
                          } else if (_currentPage == 1) {
                            _saveAndNextStep2();
                          } else if (_currentPage == 2) {
                            _finish(); // ✅ ONLY about save + home
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _currentPage == 2 ? 'Finish' : 'Next',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You are creating your profile on DobYob.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentPage + 1) / 3.0,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation(_accent),
            minHeight: 3,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1 - NO SAVE BUTTON
  Widget _buildStep1() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _pickImageWithFilePicker,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: _accent.withOpacity(0.2),
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
                      child:
                          Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedCountry.isEmpty ? null : selectedCountry,
            decoration: _deco('Country *', errorText: countryError),
            dropdownColor: _bg,
            style: const TextStyle(color: Colors.white),
            items: countries
                .map((c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() {
                selectedCountry = v ?? '';
                countryError = null;
              });
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: cityController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('City', errorText: cityError),
          ),
        ],
      );

  // STEP 2 - NO SAVE BUTTON
  Widget _buildStep2() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Work',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedWorkType.isEmpty ? null : selectedWorkType,
            decoration: _deco(
              'Business/professional/student/homemaker',
              errorText: workTypeError,
            ),
            dropdownColor: _bg,
            style: const TextStyle(color: Colors.white),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'Business', child: Text('Business')),
              DropdownMenuItem(
                  value: 'Professional', child: Text('Professional')),
              DropdownMenuItem(value: 'Student', child: Text('Student')),
              DropdownMenuItem(value: 'Homemaker', child: Text('Homemaker')),
            ],
            onChanged: (v) => setState(() {
              selectedWorkType = v ?? '';
              workTypeError = null;
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: companyController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('Name of company/college/institution'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: designationController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('Designation'),
          ),
        ],
      );

  // STEP 3 - NO BOTTOM BUTTON (Finish is in bottomNavigationBar)
  Widget _buildStep3() {
    final text = aboutController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Describe yourself',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Max $aboutMaxWords words. This will appear below your profile photo.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: aboutController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 5,
          maxLines: 8,
          onChanged: (_) => _validateStep3ForFinish(),
          decoration: _deco('Describe yourself', errorText: aboutError),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$words / $aboutMaxWords words',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    companyController.dispose();
    designationController.dispose();
    aboutController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
