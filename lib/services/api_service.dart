import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://arkalaksh.com/dobyob';

  // 1. Login (Send OTP to Email): verify_email.php
  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/verify_email.php');
    final body = { "email": email };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return { "success": false, "message": "Error: $e" };
    }
  }

  // 2. Login (Verify OTP for login, only email + otp): verify_otp.php
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify_otp.php');
    final body = { "email": email, "otp": otp };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return { "success": false, "message": "Error: $e" };
    }
  }

  // 3. Registration (Send OTP with user info): users.php
  Future<Map<String, dynamic>> sendOtp({
    required String fullName,
    required String email,
    required String dateOfBirth,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/users.php');
    final body = {
      "full_name": fullName,
      "email": email,
      "date_of_birth": dateOfBirth,
      "phone": phone,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return { "success": false, "message": "Error: $e" };
    }
  }

  // 4. Registration (Verify OTP with all user info): verify_otp.php
  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String email,
    required String otp,
    required String fullName,
    required String dateOfBirth,
    required String phone,
    required String deviceToken,
    required String deviceType,
  }) async {
    final url = Uri.parse('$baseUrl/verify_otp.php');
    final body = {
      "email": email,
      "otp": otp,
      "full_name": fullName,
      "date_of_birth": dateOfBirth,
      "phone": phone,
      "device_token": deviceToken,
      "device_type": deviceType,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return { "success": false, "message": "Error: $e" };
    }
  }

  // 5. Create Post: create_post.php (multipart file/image)
  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String content,
    File? profilePic,
  }) async {
    final url = Uri.parse('$baseUrl/create_post.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['user_id'] = userId;
    request.fields['content'] = content;

    if (profilePic != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePic.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return { "success": false, "message": "Error: $e" };
    }
  }

  // 6. Get Posts: get_posts.php (returns a List)
  Future<List<Map<String, dynamic>>> getPosts() async {
    final url = Uri.parse('$baseUrl/get_posts.php');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        // API returns a List<Map<String, dynamic>>
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
