import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Auth Screen
      'admin_login': 'Admin Login',
      'email_or_phone': 'Email or Phone',
      'password': 'Password',
      'please_enter_email': 'Please enter email or phone',
      'please_enter_password': 'Please enter password',
      'signing_in': 'Signing in...',
      'sign_in': 'Sign In',
      'admin_access_only': 'Admin access only',
      'push_notifications_enabled': 'Push notifications enabled',
      'login_failed': 'Login failed',

      // Orders Screen
      'orders_management': 'Orders Management',
      'error_loading_orders': 'Error loading orders',
      'retry': 'Retry',
      'no_orders_found': 'No orders found',
      'order': 'Order',
      'order_hash': 'Order #@id', // Added this line
      'amount': 'Amount',
      'items': 'Items',
      'view_details': 'View Details',

      // Order Details Screen
      'order_status': 'Order Status',
      'payment': 'Payment',
      'customer_information': 'Customer Information',
      'delivery_information': 'Delivery Information',
      'order_items': 'Order Items',
      'no_items_found': 'No items found',
      'error_loading_items': 'Error loading items',
      'order_summary': 'Order Summary',
      'subtotal': 'Subtotal',
      'delivery_charge': 'Delivery Charge',
      'total_amount': 'Total Amount',
      'payment_method': 'Payment Method',
      'order_note': 'Order Note',
      'no_description': 'No description',
      'qty': 'Qty',
      'change_language': 'Change Language',

      // Filter options
      'filter_orders': 'Filter Orders',
      'all_orders': 'All Orders',
      'filtered_by': 'Filtered by',
      'no_orders_with_filter': 'No orders found with current filter',
      'clear_filter': 'Clear Filter',

      // Order Status
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'out_for_delivery': 'Out for Delivery',
      'delivered': 'Delivered',
      'canceled': 'Canceled',
      'paid': 'Paid',
      'unpaid': 'Unpaid',

      // Payment Methods
      'cash_on_delivery': 'Cash on Delivery',
      'digital_payment': 'Digital Payment',
      'card_payment': 'Card Payment',
    },
    'ar': {
      // Auth Screen
      'admin_login': 'تسجيل دخول المشرف',
      'email_or_phone': 'البريد الإلكتروني أو الهاتف',
      'password': 'كلمة المرور',
      'please_enter_email': 'يرجى إدخال البريد الإلكتروني أو الهاتف',
      'please_enter_password': 'يرجى إدخال كلمة المرور',
      'signing_in': 'جاري تسجيل الدخول...',
      'sign_in': 'تسجيل الدخول',
      'admin_access_only': 'وصول المشرفين فقط',
      'push_notifications_enabled': 'الإشعارات الفورية مفعلة',
      'login_failed': 'فشل تسجيل الدخول',

      // Orders Screen
      'orders_management': 'إدارة الطلبات',
      'error_loading_orders': 'خطأ في تحميل الطلبات',
      'retry': 'إعادة المحاولة',
      'no_orders_found': 'لا توجد طلبات',
      'order': 'طلب',
      'order_hash': 'طلب #@id', // Added this line
      'amount': 'المبلغ',
      'items': 'العناصر',
      'view_details': 'عرض التفاصيل',

      // Order Details Screen
      'order_status': 'حالة الطلب',
      'payment': 'الدفع',
      'customer_information': 'معلومات العميل',
      'delivery_information': 'معلومات التسليم',
      'order_items': 'عناصر الطلب',
      'no_items_found': 'لم يتم العثور على عناصر',
      'error_loading_items': 'خطأ في تحميل العناصر',
      'order_summary': 'ملخص الطلب',
      'subtotal': 'المجموع الفرعي',
      'delivery_charge': 'رسوم التوصيل',
      'total_amount': 'المبلغ الإجمالي',
      'payment_method': 'طريقة الدفع',
      'order_note': 'ملاحظة الطلب',
      'no_description': 'لا يوجد وصف',
      'qty': 'الكمية',
      'change_language': 'تغيير اللغة',

      // Filter options
      'filter_orders': 'تصفية الطلبات',
      'all_orders': 'جميع الطلبات',
      'filtered_by': 'مصفى بواسطة',
      'no_orders_with_filter': 'لا توجد طلبات بالفلتر الحالي',
      'clear_filter': 'مسح الفلتر',

      // Order Status
      'pending': 'قيد الانتظار',
      'confirmed': 'مؤكد',
      'out_for_delivery': 'خارج للتوصيل',
      'delivered': 'تم التسليم',
      'canceled': 'ملغي',
      'paid': 'مدفوع',
      'unpaid': 'غير مدفوع',

      // Payment Methods
      'cash_on_delivery': 'الدفع عند الاستلام',
      'digital_payment': 'الدفع الرقمي',
      'card_payment': 'دفع بالبطاقة',
    },
  };
}

// File: lib/controllers/language_controller.dart


class LanguageController extends GetxController {
  static const String LANGUAGE_KEY = 'selected_language';

  // Observable locale
  Rx<Locale> locale = Locale('ar', 'SA').obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  // Load saved language from shared preferences
  void _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(LANGUAGE_KEY);

    if (languageCode != null) {
      locale.value = Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US');
    } else {
      // Default to Arabic
      locale.value = Locale('ar', 'SA');
    }

    // Update GetX locale
    Get.updateLocale(locale.value);
  }

  // Change language
  void changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_KEY, languageCode);

    locale.value = Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US');
    Get.updateLocale(locale.value);
  }

  // Toggle between Arabic and English
  void toggleLanguage() {
    String newLanguageCode = locale.value.languageCode == 'ar' ? 'en' : 'ar';
    changeLanguage(newLanguageCode);
  }

  // Check if current language is Arabic
  bool get isArabic => locale.value.languageCode == 'ar';

  // Check if current language is English
  bool get isEnglish => locale.value.languageCode == 'en';
}

