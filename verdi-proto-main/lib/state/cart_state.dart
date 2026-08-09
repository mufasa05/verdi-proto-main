import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final int quantity;
  final String imageUrl;
  final String supplier;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.supplier,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? price,
    int? quantity,
    String? imageUrl,
    String? supplier,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      supplier: supplier ?? this.supplier,
    );
  }
}

class CartState {
  final List<CartItem> items;

  const CartState({required this.items});

  const CartState.empty() : items = const [];

  double get total {
    return items.fold(0, (sum, item) {
      final priceValue = double.tryParse(
            item.price.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0;
      return sum + (priceValue * item.quantity);
    });
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState.empty());

  void addItem(CartItem item) {
    final index = state.items.indexWhere((e) => e.id == item.id);

    if (index == -1) {
      state = state.copyWith(items: [...state.items, item]);
      return;
    }

    final updated = [...state.items];
    updated[index] = updated[index].copyWith(
      quantity: updated[index].quantity + item.quantity,
    );
    state = state.copyWith(items: updated);
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  void increment(String id) {
    final updated = state.items.map((item) {
      if (item.id != id) return item;
      return item.copyWith(quantity: item.quantity + 1);
    }).toList();

    state = state.copyWith(items: updated);
  }

  void decrement(String id) {
    final updated = state.items.map((item) {
      if (item.id != id) return item;
      final nextQty = item.quantity - 1;
      return item.copyWith(quantity: nextQty < 1 ? 1 : nextQty);
    }).toList();

    state = state.copyWith(items: updated);
  }

  void clear() {
    state = const CartState.empty();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});