import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dobyob.arkalaksh.com';

  // 1. Login (Send OTP to Email): verify_email.php
  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
    String deviceToken = '',
    String deviceType = '',
  }) async {
    final url = Uri.parse('$baseUrl/verify_email.php');
    final body = {
      "email": email,
      "deviceToken": deviceToken,
      "deviceType": deviceType,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
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
Future<Map<String, dynamic>> verifyLoginOtp({
  required String email,
  required String mpin,
  String deviceToken = '',
  String deviceType = '',
}) async {
  final url = Uri.parse('$baseUrl/login_mpin.php');  // ← login_mpin.php
  final body = {
    "email": email,
    "mpin": mpin,
    "deviceToken": deviceToken,
    "deviceType": deviceType,
  };
  
  print("🔍 MPIN LOGIN: $email + $mpin");
  
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body,  // ← NO json.encode() - FORM DATA!
    );
    
    print("🔍 RAW RESPONSE (${response.statusCode}): ${response.body}");
    
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print("🔍 JSON ERROR: ${response.body}");
        return {"success": false, "message": "Invalid response"};
      }
    } else {
      return {"success": false, "message": "Server: ${response.statusCode}"};
    }
  } catch (e) {
    return {"success": false, "message": "Network: $e"};
  }
}
 // 🔥 MPIN Create/Update (OTP popup नंतर)
Future<Map<String, dynamic>> updateMpin({
  required String userId,
  required String mpin,
}) async {
  // ✅ Path: तुमचा actual upload path match करा
  final url = Uri.parse('$baseUrl/update_mpin.php'); // or '$baseUrl/api/update_mpin.php'

  final body = {
    "user_id": userId, // ✅ PHP expects user_id
    "mpin": mpin,      // 6-digit plain
  };

  print("🔍 UPDATE MPIN REQUEST → $url");
  print("🔍 BODY: $body");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body, // Map<String, String> -> form-urlencoded [web:156]
    );

    print("🔍 UPDATE MPIN RAW (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        return Map<String, dynamic>.from(decoded);
      } catch (e) {
        return {
          "success": false,
          "message": "Invalid JSON from server",
          "raw": response.body,
        };
      }
    } else {
      return {
        "success": false,
        "message": "Server error: ${response.statusCode}",
        "raw": response.body,
      };
    }
  } catch (e) {
    return {"success": false, "message": "Network error: $e"};
  }
}
  // 3. Registration (Send OTP with user info): request_otp.php
  Future<Map<String, dynamic>> sendOtp({
    required String fullName,
    required String email,
    required String dateOfBirth,
    required String phone,
    String deviceToken = '',
    String deviceType = '',
  }) async {
    final url = Uri.parse('$baseUrl/request_otp.php');
    final body = {
      "full_name": fullName,
      "email": email,
      "date_of_birth": dateOfBirth,
      "phone": phone,
      "deviceToken": deviceToken,
      "deviceType": deviceType,
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

  // 5. Create Post: create_post.php
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
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
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

  // 6. Get Posts: get_posts.php
  Future<List<Map<String, dynamic>>> getPosts({required String userId}) async {
    final url = Uri.parse('$baseUrl/get_posts.php?user_id=$userId');
    try {
      final response = await http.get(url);
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
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
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
      final response = await http.get(url);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded["success"] == true && decoded["user"] != null) {
          return Map<String, dynamic>.from(decoded["user"]);
        }
      }
    } catch (e) {
      print("ERROR: $e");
    }

    return null;
  }

  // Upload ONLY profile image for a user.
  Future<Map<String, dynamic>> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/upload_profile_pic.php');
    final req = http.MultipartRequest('POST', uri);
    req.fields['user_id'] = userId;
    req.files.add(
      await http.MultipartFile.fromPath('profile_pic', imageFile.path),
    );

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

  // 10. Toggle like: toggle_like.php
  Future<Map<String, dynamic>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/toggle_like.php');
    final body = {
      "post_id": int.parse(postId),
      "user_id": int.parse(userId),
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

  // 11. Get post likes list: get_post_likes.php
  Future<List<Map<String, dynamic>>> getPostLikes(String postId) async {
    final url = Uri.parse('$baseUrl/get_post_likes.php?post_id=$postId');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["likes"] is List) {
          return (decoded["likes"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {}
    return [];
  }

  // 12. Add comment: add_comment.php
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/add_comment.php');
    final body = {
      "post_id": int.parse(postId),
      "user_id": int.parse(userId),
      "content": content,
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

  // 13. Get comments list: get_comments.php
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final url = Uri.parse('$baseUrl/get_comments.php?post_id=$postId');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["comments"] is List) {
          return (decoded["comments"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {}
    return [];
  }

  // ================= CONNECTIONS / NETWORK APIs =================

  // A. Send connection request: send_request.php
  Future<Map<String, dynamic>> sendConnectionRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final url = Uri.parse('$baseUrl/send_request.php');
    final body = {
      "sender_id": senderId,
      "receiver_id": receiverId,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
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

  // B. People suggestions: people_suggestions.php
  Future<List<Map<String, dynamic>>> getPeopleSuggestions(String userId) async {
    final url = Uri.parse('$baseUrl/people_suggestions.php?user_id=$userId');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["data"] is List) {
          return (decoded["data"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {}
    return [];
  }

  // C. My connections: my_connections.php
  Future<List<Map<String, dynamic>>> getMyConnections(String userId) async {
    final url = Uri.parse('$baseUrl/my_connections.php?user_id=$userId');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["data"] is List) {
          return (decoded["data"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {}
    return [];
  }

  // D. Pending requests list: connection_requests.php
  Future<List<Map<String, dynamic>>> getConnectionRequests(String userId) async {
    final url = Uri.parse('$baseUrl/connection_requests.php?user_id=$userId');
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["data"] is List) {
          return (decoded["data"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {}
    return [];
  }

  // E. Respond to request (accept / reject): respond_request.php
  Future<Map<String, dynamic>> respondToRequest({
    required String connectionId,
    required String action, // "accept" / "reject"
  }) async {
    final url = Uri.parse('$baseUrl/respond_request.php');
    final body = {
      "connection_id": int.parse(connectionId),
      "action": action,
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

  // ================= NEW: SEARCH + PROFILE (LinkedIn style) =================

  // F. Search users: search_users.php
  Future<List<Map<String, dynamic>>> searchUsers({
    required String currentUserId,
    required String query,
  }) async {
    final url = Uri.parse('$baseUrl/search_users.php');
    final body = {
      "user_id": int.parse(currentUserId),
      "query": query,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["users"] is List) {
          return (decoded["users"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    } catch (e) {}
    return [];
  }

  Future<Map<String, dynamic>?> logout({required String userId}) async {
    try {
      final response = await http.get(
        Uri.parse('https://dobyob.arkalaksh.com/api/logout.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // G. Get other user's profile: user_profile.php
  Future<Map<String, dynamic>?> getUserProfile({
    required String userId,   // profile owner id
    required String viewerId, // logged‑in user id
  }) async {
    final url = Uri.parse('$baseUrl/user_profile.php?user_id=$userId&viewer_id=$viewerId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["success"] == true && decoded["user"] != null) {
          return Map<String, dynamic>.from(decoded["user"]);
        }
      }
    } catch (e) {}
    return null;
  }
}
