import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ApiService {
  static const String baseUrl = 'https://admin-mamamona.atwdemo.com/api/v1/admin';

  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
      String emailOrPhone,
      String password,
      String fcmToken,
      ) async {
    final url = Uri.parse('$baseUrl/login');
    final body = {
      'email_or_phone': emailOrPhone,
      'password': password,
      'type': 'email',
      'fcm_token': fcmToken, // FCM token for push notifications
    };

    try {
      // 🔵 Log request details
      debugPrint('🔵 [LOGIN] Sending POST request to: $url');
      debugPrint('🔵 [LOGIN] Request body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      // 🟢 Log response details
      debugPrint('🟢 [LOGIN] Response status: ${response.statusCode}');
      debugPrint('🟢 [LOGIN] Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // ✅ Successful login
        debugPrint('✅ [LOGIN] Login successful. Token: ${data['token']}');

        // Save token to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        return {'success': true, 'token': data['token']};
      } else {
        // ❌ Login failed
        debugPrint('❌ [LOGIN] Login failed: ${data['message']}');
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      // 🔴 Log network error
      debugPrint('🔴 [LOGIN] Network error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<List<Order>> getOrders() async {
    final url = Uri.parse('$baseUrl/orders');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ordersJson = data['orders'];

        // Parse all orders
        final orders = ordersJson.map((json) => Order.fromJson(json)).toList();

        // Get today's date (only year, month, day to avoid time mismatch)
        final today = DateTime.now();
        final todayOnlyDate = DateTime(today.year, today.month, today.day);

        // Filter orders where deliveryDate matches today's date
        final todayOrders = orders.where((order) {
          if (order.deliveryDate == null) return false;
          try {
            final orderDate = DateTime.parse(order.deliveryDate!);
            final orderOnlyDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
            return orderOnlyDate == todayOnlyDate;
          } catch (e) {
            // لو الـ date مش صالح نتجاهل الطلب
            return false;
          }
        }).toList();

        return todayOrders;
      } else {
        throw Exception('فشل تحميل الطلبات');
      }
    } catch (e) {
      throw Exception('خطأ في الشبكة: $e');
    }
  }

  static Future<List<OrderDetail>> getOrderDetails(int orderId) async {
    final url = Uri.parse('$baseUrl/orders/details?order_id=$orderId');
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}