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
    final body = {"email": email};
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
      return {"success": false, "message": "Error: $e"};
    }
  }

  // 2. Login (Verify OTP for login)
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify_otp.php');
    final body = {"email": email, "otp": otp};
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
      return {"success": false, "message": "Error: $e"};
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
      return {"success": false, "message": "Error: $e"};
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
      return {"success": false, "message": "Error: $e"};
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
      request.files
          .add(await http.MultipartFile.fromPath('profile_pic', profilePic.path));
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
      return {"success": false, "message": "Error: $e"};
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
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 7. Profile Update: profile_update.php
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String fullName,
    required String business,
    required String profession,
    required String industry,
    required String dateOfBirth,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String country,
    required List<String> educationList,
    required List<String> positionsList,
    File? profilePic,
  }) async {
    final url = Uri.parse('$baseUrl/profile_update.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['user_id'] = userId;
    request.fields['full_name'] = fullName;
    request.fields['business'] = business;
    request.fields['profession'] = profession;
    request.fields['industry'] = industry;
    request.fields['date_of_birth'] = dateOfBirth;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['address'] = address;
    request.fields['city'] = city;
    request.fields['state'] = state;
    request.fields['country'] = country;
    request.fields['education'] = jsonEncode(educationList);
    request.fields['positions'] = jsonEncode(positionsList);

    if (profilePic != null) {
      request.files
          .add(await http.MultipartFile.fromPath('profile_pic', profilePic.path));
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
      return {"success": false, "message": "Error: $e"};
    }
  }

  // 8. Get Profile: profile_get.php
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final url = Uri.parse('$baseUrl/profile_get.php?user_id=$userId');
    try {
      final response =
          await http.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["user"] != null) {
          return decoded["user"];
        }
      }
    } catch (e) {}
    return null;
  }

  // Upload ONLY profile image for a user. Returns the URL.
  Future<Map<String, dynamic>> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/upload_profile_pic.php');
    final req = http.MultipartRequest('POST', uri);
    req.fields['user_id'] = userId;
    req.files
        .add(await http.MultipartFile.fromPath('profile_pic', imageFile.path));

    final resp = await req.send();
    final respStr = await resp.stream.bytesToString();
    return resp.statusCode == 200
        ? Map<String, dynamic>.from(jsonDecode(respStr))
        : {"success": false, "error": "HTTP ${resp.statusCode}"};
  }

  // 9. Invite friend: invite_friend.php
  Future<Map<String, dynamic>> inviteFriend({
    required String userId,
    required String friendName,
    required String friendEmail,
  }) async {
    final url = Uri.parse('$baseUrl/invite_friend.php');
    final body = {
      "user_id": int.parse(userId),
      "friend_name": friendName,
      "friend_email": friendEmail,
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
      return {"success": false, "message": "Error: $e"};
    }
  }
}
