// lib/Riverpod/LandingpageProvider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deliveryItemsProvider = StateNotifierProvider<DeliveryItemsNotifier, List<Map>>((ref) {
  return DeliveryItemsNotifier();
});

class DeliveryItemsNotifier extends StateNotifier<List<Map>> {
  DeliveryItemsNotifier() : super([]);

  void setItems(List<Map> items) {
    state = items;
  }

  void clearItems() {
    state = [];
  }
}
