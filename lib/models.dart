class Order {
  final int id;
  final int userId;
  final double orderAmount;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final String? deliveryDate;
  final String? deliveryTime;
  final double deliveryCharge;
  final String? orderNote;
  final Customer? customer;
  final DeliveryAddress? deliveryAddress;
  final int totalQuantity;

  Order({
    required this.id,
    required this.userId,
    required this.orderAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    this.deliveryDate,
    this.deliveryTime,
    required this.deliveryCharge,
    this.orderNote,
    this.customer,
    this.deliveryAddress,
    required this.totalQuantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      orderAmount: double.parse(json['order_amount'].toString()),
      paymentStatus: json['payment_status'],
      orderStatus: json['order_status'],
      paymentMethod: json['payment_method'],
      deliveryDate: json['delivery_date'],
      deliveryTime: json['delivery_time'],
      deliveryCharge: double.parse(json['delivery_charge'].toString()),
      orderNote: json['order_note'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddress.fromJson(json['delivery_address']) : null,
      totalQuantity: int.parse(json['total_quantity'].toString()),
    );
  }
}

class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['f_name'],
      lastName: json['l_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class DeliveryAddress {
  final int id;
  final String addressType;
  final String contactPersonName;
  final String contactPersonNumber;
  final String address;

  DeliveryAddress({
    required this.id,
    required this.addressType,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.address,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'],
      addressType: json['address_type'],
      contactPersonName: json['contact_person_name'],
      contactPersonNumber: json['contact_person_number'],
      address: json['address'],
    );
  }
}

class OrderDetail {
  final int id;
  final int productId;
  final int orderId;
  final double price;
  final int quantity;
  final ProductDetails productDetails;

  OrderDetail({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.price,
    required this.quantity,
    required this.productDetails,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      productId: json['product_id'],
      orderId: json['order_id'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      productDetails: ProductDetails.fromJson(json['product_details']),
    );
  }
}

class ProductDetails {
  final int id;
  final String name;
  final String description;
  final String image;
  final double price;

  ProductDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      price: double.parse(json['price'].toString()),
    );
  }
}
