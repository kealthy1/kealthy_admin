import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import '../Riverpod/LandingpageProvider.dart';

class DeliveryPortal extends ConsumerStatefulWidget {
  const DeliveryPortal({super.key});

  @override
  _DeliveryPortalState createState() => _DeliveryPortalState();
}

class _DeliveryPortalState extends ConsumerState<DeliveryPortal> {
  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );

  late DatabaseReference _deliveryRef;

  @override
  void initState() {
    super.initState();
    _deliveryRef = database1.ref('orders');
    _fetchDeliveryItems();
  }

  Future<void> _fetchDeliveryItems() async {
    _deliveryRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null) {
        final Map<dynamic, dynamic> dataMap = data as Map<dynamic, dynamic>;
        List<Map<dynamic, dynamic>> deliveryItems = dataMap.entries
            .map((e) => Map<String, dynamic>.from(e.value))
            .where((item) => item['status'] != 'Delivered')
            .toList();

        ref.read(deliveryItemsProvider.notifier).setItems(deliveryItems);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryItems = ref.watch(deliveryItemsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: deliveryItems.isEmpty
          ? const Center(child: Text('No delivery items available.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: deliveryItems.map((item) {
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
                            title: RoundedBackgroundText(
                              backgroundColor: Colors.green,
                              item['orderId'] != null
                                  ? item['orderId']
                                      .toString()
                                      .substring(item['orderId'].length - 9)
                                  : 'No ID',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              'Customer: ${item['Name'] ?? 'Unknown'}',
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
                                    if (item['assignedto'] == 'NotAssigned')
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            onPressed: () async {
                                              List<String> deliveryBoyIds =
                                                  await fetchDeliveryBoyIds();

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Select Delivery Boy'),
                                                    content: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth:
                                                                  300), // Limit max width
                                                      child: SizedBox(
                                                        width: double.maxFinite,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              deliveryBoyIds
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            String
                                                                deliveryBoyId =
                                                                deliveryBoyIds[
                                                                    index];
                                                            return FutureBuilder<
                                                                String?>(
                                                              future: _fetchDeliveryPartnerName(
                                                                  deliveryBoyId),
                                                              builder: (context,
                                                                  snapshot) {
                                                                String
                                                                    deliveryBoyName =
                                                                    snapshot.data ??
                                                                        deliveryBoyId;
                                                                return ListTile(
                                                                  title: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          deliveryBoyName,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      Text(
                                                                          deliveryBoyId),
                                                                    ],
                                                                  ),
                                                                  onTap: () {
                                                                    assignDeliveryBoyToOrder(
                                                                        item[
                                                                            'orderId'],
                                                                        deliveryBoyId);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Assign',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    else
                                      Text(
                                        'Assigned to: ${item['assignedto']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
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

  Future<String?> _fetchDeliveryPartnerName(String assignedTo) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('DeliveryUsers')
          .doc(assignedTo)
          .get();

      if (snapshot.exists) {
        return snapshot.data()?['Name']; // Adjust field name as needed
      }
    } catch (e) {
      print('Error fetching delivery partner name: $e');
    }
    return null;
  }

  Future<void> assignDeliveryBoyToOrder(
      String orderId, String deliveryBoyId) async {
    final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
    );

    DatabaseReference orderRef = database1.ref('orders/$orderId');

    await orderRef.update({
      'assignedto': deliveryBoyId,
    });

    print('Assigned delivery boy $deliveryBoyId to order $orderId');
  }

  Future<List<String>> fetchDeliveryBoyIds() async {
    final deliveryUsersCollection =
        FirebaseFirestore.instance.collection('DeliveryUsers');
    final snapshot = await deliveryUsersCollection.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
