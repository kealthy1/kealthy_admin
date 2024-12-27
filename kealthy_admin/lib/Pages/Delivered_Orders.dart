import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

// State notifier for delivered items
final deliveredItemsProvider =
    StateNotifierProvider<DeliveredItemsNotifier, List<Map<dynamic, dynamic>>>(
        (ref) {
  return DeliveredItemsNotifier();
});

// Notifier class for managing delivered items
class DeliveredItemsNotifier
    extends StateNotifier<List<Map<dynamic, dynamic>>> {
  DeliveredItemsNotifier() : super([]);

  void setItems(List<Map<dynamic, dynamic>> items) {
    state = items;
  }
}

// Main Delivered Orders Page
class DeliveredOrdersPage extends ConsumerStatefulWidget {
  const DeliveredOrdersPage({super.key});

  @override
  _DeliveredOrdersPageState createState() => _DeliveredOrdersPageState();
}

class _DeliveredOrdersPageState extends ConsumerState<DeliveredOrdersPage> {
  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );

  late DatabaseReference _deliveryRef;

  @override
  void initState() {
    super.initState();
    _deliveryRef = database1.ref('orders');
    _fetchDeliveredItems();
  }

  Future<void> _fetchDeliveredItems() async {
    _deliveryRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null) {
        final Map<dynamic, dynamic> dataMap = data as Map<dynamic, dynamic>;
        List<Map<dynamic, dynamic>> deliveredItems = dataMap.entries
            .map((e) => Map<String, dynamic>.from(e.value))
            .where(
                (item) => item['status'] == 'Delivered')
            .toList();

        ref.read(deliveredItemsProvider.notifier).setItems(deliveredItems);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveredItems = ref.watch(deliveredItemsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: deliveredItems.isEmpty
          ? const Center(child: Text('No delivered items available.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: deliveredItems.map((item) {
                      return SizedBox(
                        width: 350,
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RoundedBackgroundText(
                                  backgroundColor: Colors.green,
                                  item['orderId'] != null
                                      ? item['orderId']
                                          .toString()
                                          .substring(item['orderId'].length - 9)
                                      : 'No ID',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                    formatDate(item['createdAt'] ?? 'Unknown')),
                              ],
                            ),
                            subtitle: Text(
                              'Customer: ${item['selectedHouseNo'] ?? 'Unknown'}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Phone: ${item['phoneNumber'] ?? 'Unknown'}'),
                                    Text(
                                        'Address: ${item['selectedRoad'] ?? 'Unknown'}'),
                                    Text(
                                        'Instructions: ${item['selectedDirections'] ?? 'Unknown'}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${item['status'] ?? 'Unknown'}'),
                                        Text(
                                            '₹${item['totalAmountToPay'] ?? 'Unknown'}'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (item['orderItems'] != null)
                                      ...List.generate(
                                        item['orderItems'].length,
                                        (index) {
                                          final orderItem =
                                              item['orderItems'][index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Text(
                                              '${orderItem['item_quantity']} x ${orderItem['item_name']} - ₹${orderItem['item_price']}',
                                            ),
                                          );
                                        },
                                      ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
    );
  }
}

Future<List<String>> fetchDeliveryBoyIds() async {
  final deliveryUsersCollection =
      FirebaseFirestore.instance.collection('DeliveryUsers');
  final snapshot = await deliveryUsersCollection.get();
  return snapshot.docs.map((doc) => doc.id).toList();
}

String formatDate(String dateString) {
  if (dateString != 'Unknown' && dateString.isNotEmpty) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd-MM-yy').format(dateTime);
  } else {
    return 'Unknown';
  }
}
