import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'api.dart';
import 'auth_screen.dart';
import 'details_screen.dart';
import 'language.dart';
import 'models.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'api.dart';
import 'auth_screen.dart';
import 'details_screen.dart';
import 'language.dart';
import 'models.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedFilter; // null means "All"

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _logCurrentFCMToken();
  }

  void _changeLanguage() {
    final LanguageController languageController = Get.find<LanguageController>();

    // Show language selection dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('change_language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text('English'),
                onTap: () {
                  languageController.changeLanguage('en');
                  Navigator.of(context).pop();
                },
                trailing: languageController.isEnglish
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
              ListTile(
                leading: Text('🇸🇦', style: TextStyle(fontSize: 24)),
                title: Text('العربية'),
                onTap: () {
                  languageController.changeLanguage('ar');
                  Navigator.of(context).pop();
                },
                trailing: languageController.isArabic
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('filter_orders'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.all_inclusive),
                title: Text('all_orders'.tr),
                onTap: () {
                  _applyFilter(null);
                  Navigator.of(context).pop();
                },
                trailing: selectedFilter == null
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
              ListTile(
                leading: Icon(Icons.access_time, color: Colors.orange),
                title: Text('pending'.tr),
                onTap: () {
                  _applyFilter('pending');
                  Navigator.of(context).pop();
                },
                trailing: selectedFilter == 'pending'
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('confirmed'.tr),
                onTap: () {
                  _applyFilter('confirmed');
                  Navigator.of(context).pop();
                },
                trailing: selectedFilter == 'confirmed'
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
              ListTile(
                leading: Icon(Icons.local_shipping, color: Colors.blue),
                title: Text('out_for_delivery'.tr),
                onTap: () {
                  _applyFilter('out_for_delivery');
                  Navigator.of(context).pop();
                },
                trailing: selectedFilter == 'out_for_delivery'
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
              ListTile(
                leading: Icon(Icons.done_all, color: Colors.green[700]),
                title: Text('delivered'.tr),
                onTap: () {
                  _applyFilter('delivered');
                  Navigator.of(context).pop();
                },
                trailing: selectedFilter == 'delivered'
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text('canceled'.tr),
                onTap: () {
                  _applyFilter('canceled');
                  Navigator.of(context).pop();
                },
                trailing: selectedFilter == 'canceled'
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilter(String? filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == null) {
        filteredOrders = List.from(orders);
      } else {
        filteredOrders = orders
            .where((order) => order.orderStatus.toLowerCase() == filter.toLowerCase())
            .toList();
      }
    });
  }

  void _logCurrentFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint("🔑 Current FCM Token: $token");
    } catch (e) {
      debugPrint("❌ Error fetching FCM token: $e");
    }
  }

  void _loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedOrders = await ApiService.getOrders();
      setState(() {
        orders = loadedOrders;
        filteredOrders = List.from(loadedOrders); // Initialize filtered list
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _logout() async {
    await ApiService.logout();
    Get.offAll(() => LoginScreen());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'out_for_delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.green[700]!;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'out_for_delivery':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'canceled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getLocalizedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending'.tr;
      case 'confirmed':
        return 'confirmed'.tr;
      case 'out_for_delivery':
        return 'out_for_delivery'.tr;
      case 'delivered':
        return 'delivered'.tr;
      case 'canceled':
        return 'canceled'.tr;
      default:
        return status;
    }
  }

  String _getLocalizedPaymentMethod(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash_on_delivery':
        return 'cash_on_delivery'.tr;
      default:
        return paymentMethod.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('orders_management'.tr),
            if (selectedFilter != null)
              Text(
                '${'filtered_by'.tr}: ${_getLocalizedStatus(selectedFilter!)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Filter Button
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (selectedFilter != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'filter_orders'.tr,
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.language),
            tooltip: 'change_language'.tr,
            onPressed: _changeLanguage,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'retry'.tr,
            onPressed: _loadOrders,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'error_loading_orders'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: Text('retry'.tr),
            ),
          ],
        ),
      )
          : filteredOrders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedFilter != null ? Icons.filter_list_off : Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              selectedFilter != null
                  ? 'no_orders_with_filter'.tr
                  : 'no_orders_found'.tr,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (selectedFilter != null) ...[
              SizedBox(height: 8),
              TextButton(
                onPressed: () => _applyFilter(null),
                child: Text('clear_filter'.tr),
              ),
            ],
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          _loadOrders();
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => OrderDetailsScreen(order: order));
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'order'.tr} #${order.id}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(order.orderStatus),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(order.orderStatus),
                                  size: 16,
                                  color: _getStatusColor(order.orderStatus),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _getLocalizedStatus(order.orderStatus),
                                  style: TextStyle(
                                    color: _getStatusColor(order.orderStatus),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Customer Info
                      if (order.customer != null) ...[
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              '${order.customer!.firstName} ${order.customer!.lastName}',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              order.customer!.phone,
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],

                      // Order Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${'amount'.tr}: \$${order.orderAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                              Text(
                                '${'items'.tr}: ${order.totalQuantity}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getLocalizedPaymentMethod(order.paymentMethod),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: order.paymentStatus == 'paid'
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                ),
                              ),
                              if (order.deliveryDate != null)
                                Text(
                                  order.deliveryDate!,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ],
                      ),

                      if (order.deliveryAddress != null) ...[
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.deliveryAddress!.address,
                                style: TextStyle(color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 8),

                      // View Details Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Get.to(() => OrderDetailsScreen(order: order));
                          },
                          icon: Icon(Icons.arrow_forward, size: 16),
                          label: Text('view_details'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}