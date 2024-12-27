// lib/Functions/Order_assign.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DeliveryHandler {
  static Future<void> assignOrderToDelivery(
      BuildContext context, String deliveryBoyId, Map item) async {
    DatabaseReference orderRef =
        FirebaseDatabase.instance.ref('orders/${item['orderId']}');
    DatabaseReference deliveryUserRef =
        FirebaseDatabase.instance.ref('DeliveryUsers/$deliveryBoyId/assignedOrders');

    try {
      // Update the order's assignedTo and status
      await orderRef.update({
        'assignedTo': deliveryBoyId,
        'status': 'assigned',
      });

      // Save order details under the delivery boy's assigned orders
      await deliveryUserRef.child(item['orderId']).set({
        'orderDetails': item,
        'status': 'assigned',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order assigned to Delivery Boy: $deliveryBoyId')),
      );
    } catch (e) {
      print("Error assigning order: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to assign order')));
    }
  }

  static void showDeliveryBoyAlert(
      BuildContext context, String deliveryBoyId, Map item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign Delivery'),
          content: const Text('Are you sure you want to assign this order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                assignOrderToDelivery(context, deliveryBoyId, item);
                Navigator.of(context).pop();
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }
}
