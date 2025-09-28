import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'api.dart';
import 'models.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<OrderDetail> orderDetails = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final details = await ApiService.getOrderDetails(widget.order.id);
      setState(() {
        orderDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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

  String _getLocalizedPaymentStatus(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return 'paid'.tr;
      case 'unpaid':
        return 'unpaid'.tr;
      default:
        return paymentStatus;
    }
  }

  String _getLocalizedPaymentMethod(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash_on_delivery':
        return 'cash_on_delivery'.tr;
      case 'digital_payment':
        return 'digital_payment'.tr;
      case 'card_payment':
        return 'card_payment'.tr;
      default:
        return paymentMethod.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${'order'.tr} #${widget.order.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.order.orderStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'order_status'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _getLocalizedStatus(widget.order.orderStatus),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(widget.order.orderStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'payment'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _getLocalizedPaymentStatus(widget.order.paymentStatus),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.order.paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Customer Information
            if (widget.order.customer != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'customer_information'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            '${widget.order.customer!.firstName} ${widget.order.customer!.lastName}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(widget.order.customer!.email),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(widget.order.customer!.phone),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Delivery Information
            if (widget.order.deliveryAddress != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'delivery_information'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.order.deliveryAddress!.address,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_pin, color: Colors.green),
                          SizedBox(width: 8),
                          Text(widget.order.deliveryAddress!.contactPersonName),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(widget.order.deliveryAddress!.contactPersonNumber),
                        ],
                      ),
                      if (widget.order.deliveryDate != null && widget.order.deliveryTime != null) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('${widget.order.deliveryDate} at ${widget.order.deliveryTime}'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Order Items
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'order_items'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    if (isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (errorMessage != null)
                      Center(
                        child: Column(
                          children: [
                            Text('${'error_loading_items'.tr}: $errorMessage'),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadOrderDetails,
                              child: Text('retry'.tr),
                            ),
                          ],
                        ),
                      )
                    else if (orderDetails.isEmpty)
                        Center(child: Text('no_items_found'.tr))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: orderDetails.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final item = orderDetails[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: item.productDetails.image.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://admin-mamamona.atwdemo.com/storage/app/public/product/${item.productDetails.image}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.image_not_supported, color: Colors.grey);
                                    },
                                  ),
                                )
                                    : Icon(Icons.fastfood, color: Colors.grey),
                              ),
                              title: Text(
                                item.productDetails.name,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                item.productDetails.description.isNotEmpty
                                    ? item.productDetails.description
                                    : 'no_description'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${'qty'.tr}: ${item.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Order Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'order_summary'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'subtotal'.tr}:'),
                        Text('\$${(widget.order.orderAmount - widget.order.deliveryCharge).toStringAsFixed(2)}'),
                      ],
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'delivery_charge'.tr}:'),
                        Text('\$${widget.order.deliveryCharge.toStringAsFixed(2)}'),
                      ],
                    ),

                    Divider(thickness: 1),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'total_amount'.tr}:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${widget.order.orderAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'payment_method'.tr}:'),
                        Text(
                          _getLocalizedPaymentMethod(widget.order.paymentMethod),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    if (widget.order.orderNote != null && widget.order.orderNote!.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        '${'order_note'.tr}:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(widget.order.orderNote!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}