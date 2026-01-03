import 'package:dobyob_1/screens/dobyob_session_manager.dart';
import 'package:dobyob_1/services/api_service.dart';
import 'package:flutter/material.dart';

class DobYobWizard extends StatefulWidget {
  final String userId;

  // ✅ Signup मधून आलेले basics
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

  // Slide 1 (Work)
  final TextEditingController businessController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController industryController = TextEditingController();

  // Slide 2 (Location)
  String selectedCountry = '';
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Slide 2 (Education)
  List<String> educationList = [];
  final TextEditingController educationInputController = TextEditingController();

  String? countryError;

  static const _bg = Color(0xFF020617);
  static const _accent = Color(0xFF0EA5E9);
  static const _fieldFill = Color(0xFF0B1220);
  static const _borderColor = Color(0xFF1F2937);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<String> countries = ['India', 'USA', 'UK', 'Canada', 'Others'];

  bool get _isSlide2Valid => selectedCountry.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initSession();
    _validateCountry(selectedCountry);
  }

  Future<void> _initSession() async {
    _session = await DobYobSessionManager.getInstance();
    if (mounted) setState(() {});
  }

  void _validateCountry(String value) {
    if (!mounted) return;
    setState(() => countryError = value.isEmpty ? 'Country required' : null);
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

  Future<void> _saveAll() async {
    if (_isLoading) return;

    if (widget.fullName.trim().isEmpty ||
        widget.email.trim().isEmpty ||
        widget.phone.trim().isEmpty ||
        widget.dateOfBirth.trim().isEmpty) {
      _snack('Signup data missing (name/email/phone/dob).');
      return;
    }

    if (!_isSlide2Valid) {
      _validateCountry(selectedCountry);
      return;
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final res = await apiService.updateProfile(
      userId: widget.userId,
      fullName: widget.fullName.trim(),
      business: businessController.text.trim(),
      profession: professionController.text.trim(),
      industry: industryController.text.trim(),
      dateOfBirth: widget.dateOfBirth.trim(),
      email: widget.email.trim(),
      phone: widget.phone.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: selectedCountry,
      educationList: educationList,
      positionsList: const <String>[],
      profilePic: null,
    );

    Navigator.of(context, rootNavigator: true).pop();

    if (res['success'] == true) {
      final user = res['user'] ?? {};
      try {
        final session = _session ?? await DobYobSessionManager.getInstance();
        await session.saveUserSession(
          userId: int.tryParse((user['id'] ?? widget.userId).toString()) ?? 0,
          name: (user['full_name'] ?? widget.fullName).toString(),
          email: (user['email'] ?? widget.email).toString(),
          phone: (user['phone'] ?? widget.phone).toString(),
          deviceToken: await session.getDeviceToken() ?? '',
          deviceType: await session.getDeviceType() ?? 'android',
          profilePicture: (user['profile_pic'] ?? '').toString(),
        );
      } catch (_) {}
      if (mounted) _snack('Profile Updated!');
    } else {
      if (mounted) _snack((res['message'] ?? 'Update failed').toString());
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _isLoading ? null : _saveAll,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Complete Profile', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip', style: TextStyle(color: _accent)),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 2.0,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation(_accent),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [_buildWorkSlide(), _buildLocationEduSlide()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentPage > 0 ? _previous : null,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isLoading ? _accent : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _next,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(_currentPage == 1 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 1 = Work
  Widget _buildWorkSlide() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Work',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: businessController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('Business / Company'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: professionController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('Profession / Role'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: industryController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('Industry'),
          ),
        ],
      );

  // Slide 2 = Location + Education
  Widget _buildLocationEduSlide() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Location & Education',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedCountry.isEmpty ? null : selectedCountry,
            decoration: _deco('Country *', errorText: countryError),
            dropdownColor: _bg,
            style: const TextStyle(color: Colors.white),
            items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) {
              selectedCountry = v ?? '';
              _validateCountry(selectedCountry);
            },
          ),
          const SizedBox(height: 14),

          TextField(
            controller: stateController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('State'),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: cityController,
            style: const TextStyle(color: Colors.white),
            decoration: _deco('City'),
          ),
          const SizedBox(height: 14),

          // ✅ Address boxed multi-line (single clean border)
          TextField(
            controller: addressController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.newline,
            minLines: 2,
            maxLines: 3,
            decoration: _deco('Address'),
          ),

          const SizedBox(height: 22),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),

          const Text(
            'Education',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 10),

          if (educationList.isNotEmpty)
            ...educationList.map(
              (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e, style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => educationList.remove(e)),
                ),
              ),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: educationInputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('Add Education'),
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
                child: const Text('Add', style: TextStyle(color: _accent)),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _saveButton(),
        ],
      );

  void _next() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAll().then((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  void _previous() => _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  void _skip() => Navigator.pushReplacementNamed(context, '/home');

  @override
  void dispose() {
    businessController.dispose();
    professionController.dispose();
    industryController.dispose();
    stateController.dispose();
    cityController.dispose();
    addressController.dispose();
    educationInputController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
