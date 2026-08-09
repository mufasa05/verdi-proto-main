class DashboardInsight {
  final String title;
  final String subtitle;
  final String actionLabel;
  final int colorIndex;

  const DashboardInsight({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.colorIndex,
  });
}

class ListingItem {
  final String product;
  final String quantity;
  final String price;
  final int views;
  final int inquiries;
  final String status;

  const ListingItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.views,
    required this.inquiries,
    required this.status,
  });
}

class OrderItem {
  final String orderId;
  final String name;
  final String product;
  final String status;
  final String delivery;

  const OrderItem({
    required this.orderId,
    required this.name,
    required this.product,
    required this.status,
    required this.delivery,
  });
}

class MarketplaceProduct {
  final String name;
  final String category;
  final String description;
  final String price;
  final String seller;
  final String location;
  final String quantity;
  final String distance;
  final String imageUrl;
  /// The user ID of the person who posted this listing.
  /// Null for seeded/demo products that belong to nobody.
  final String? sellerId;

  const MarketplaceProduct({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.seller,
    required this.location,
    required this.quantity,
    required this.distance,
    required this.imageUrl,
    this.sellerId,
  });
}

class MockAppData {
  static const farmerName = 'sir Mufasa';
  static const location = 'Chiredzi, Zimbabwe';
  static const dateTimeLabel = 'Friday, 16 May 2026 • 07:40 AM';

  static const insights = [
    DashboardInsight(
      title: '3 buyers in Chiredzi are looking for tomatoes',
      subtitle: 'Strong demand near your farm this morning.',
      actionLabel: 'View Buyers',
      colorIndex: 0,
    ),
    DashboardInsight(
      title: 'Tomato demand increased by 12% this week',
      subtitle: 'Price momentum is rising across nearby markets.',
      actionLabel: 'See Market Trends',
      colorIndex: 1,
    ),
    DashboardInsight(
      title: 'Rain expected tomorrow - Consider delaying delivery',
      subtitle: 'Weather risk may affect harvest transport.',
      actionLabel: 'View Forecast',
      colorIndex: 2,
    ),
    DashboardInsight(
      title: 'Eastern Field showing possible crop stress',
      subtitle: 'Crop health scan recommends closer monitoring.',
      actionLabel: 'Check Field',
      colorIndex: 3,
    ),
  ];

  static const topListings = [
    ListingItem(
      product: 'Tomatoes',
      quantity: '120 kg',
      price: '\$0.40/kg',
      views: 92,
      inquiries: 11,
      status: 'Active',
    ),
    ListingItem(
      product: 'Maize',
      quantity: '430 kg',
      price: '\$0.30/kg',
      views: 71,
      inquiries: 5,
      status: 'Active',
    ),
    ListingItem(
      product: 'Potatoes',
      quantity: '95 kg',
      price: '\$0.50/kg',
      views: 54,
      inquiries: 8,
      status: 'Draft',
    ),
    ListingItem(
      product: 'Onions',
      quantity: '75 kg',
      price: '\$0.20/kg',
      views: 40,
      inquiries: 3,
      status: 'Active',
    ),
  ];

  static const recentOrders = [
    OrderItem(
      orderId: '#ORD-104',
      name: 'Tendai M.',
      product: 'Tomatoes',
      status: 'Paid',
      delivery: 'Today',
    ),
    OrderItem(
      orderId: '#ORD-105',
      name: 'Nyasha K.',
      product: 'Maize',
      status: 'Pending',
      delivery: 'Tomorrow',
    ),
    OrderItem(
      orderId: '#ORD-106',
      name: 'J. Sibanda',
      product: 'Potatoes',
      status: 'Confirmed',
      delivery: 'Friday',
    ),
  ];

  static const products = [
    MarketplaceProduct(
      name: 'Tomatoes',
      category: 'Vegetables',
      description: 'Fresh grade-A tomatoes from irrigated beds.',
      price: '\$0.40/kg',
      seller: 'Mufasa Farm',
      location: 'Chiredzi',
      quantity: '120 kg available',
      distance: '3.2 km',
      imageUrl: 'assets/images/tomato.jpg',
    ),
    MarketplaceProduct(
      name: 'Maize',
      category: 'Grains',
      description: 'Cleaned and dried maize for buyers and traders.',
      price: '\$0.30/kg',
      seller: 'Mambo Farm',
      location: 'Masvingo',
      quantity: '430 kg available',
      distance: '8.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1532336414038-cf19250c5757?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Potatoes',
      category: 'Vegetables',
      description: 'Sorted potatoes in retail-ready sacks.',
      price: '\$0.50/kg',
      seller: 'Eastern Fields',
      location: 'Mutare',
      quantity: '95 kg available',
      distance: '12.4 km',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Onions',
      category: 'Vegetables',
      description: 'High-quality onions with long shelf life.',
      price: '\$0.20/kg',
      seller: 'Green Valley',
      location: 'Chiredzi',
      quantity: '75 kg available',
      distance: '5.5 km',
      imageUrl: 'assets/images/onion.jpg',
    ),
    MarketplaceProduct(
      name: 'Mango',
      category: 'Fruits',
      description: 'Sweet ripe mangoes, hand-picked and packed fresh.',
      price: '\$1.10/kg',
      seller: 'Zambezi Orchards',
      location: 'Chiredzi',
      quantity: '88 kg available',
      distance: '4.1 km',
      imageUrl: 'https://images.unsplash.com/photo-1605027990121-cbae9e0642df?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Tractors',
      category: 'Equipment',
      description: 'Used farm tractors in good working condition.',
      price: '\$8,500',
      seller: 'AgriTech Zimbabwe',
      location: 'Harare',
      quantity: '2 units available',
      distance: '18.6 km',
      imageUrl: 'assets/images/tractor.jpg',
    ),
    MarketplaceProduct(
      name: 'Planter',
      category: 'Equipment',
      description: 'Precision planter for row crop operations.',
      price: '\$2,100',
      seller: 'Farm Tools Hub',
      location: 'Bulawayo',
      quantity: '1 unit available',
      distance: '24.3 km',
      imageUrl: 'assets/images/planter.jpg',
    ),
    MarketplaceProduct(
      name: 'Plough',
      category: 'Equipment',
      description: 'Durable plough for land preparation and tilling.',
      price: '\$680',
      seller: 'Farm Tools Hub',
      location: 'Masvingo',
      quantity: '4 units available',
      distance: '11.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Chilli',
      category: 'Processed product',
      description: 'Dry chilli packed for retail and food processors.',
      price: '\$2.40/kg',
      seller: 'Spice Garden',
      location: 'Mutare',
      quantity: '36 kg available',
      distance: '6.7 km',
      imageUrl: 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Compound D',
      category: 'Processed product',
      description: 'Compound D fertilizer for maize and garden crops.',
      price: '\$28/bag',
      seller: 'AgriSupply',
      location: 'Chiredzi',
      quantity: '28 bags available',
      distance: '7.5 km',
      imageUrl: 'assets/images/compound_d.jpg',
    ),
    MarketplaceProduct(
      name: 'Brahman',
      category: 'Livestock',
      description: 'Healthy Brahman cattle for breeding and fattening.',
      price: '\$900/head',
      seller: 'Mufasa Ranch',
      location: 'Gwanda',
      quantity: '6 heads available',
      distance: '29.4 km',
      imageUrl: 'https://images.unsplash.com/photo-1527153857715-3908f2bae5e8?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Broilers',
      category: 'Livestock',
      description: 'Fast-growing broiler chickens ready for market.',
      price: '\$6/chick',
      seller: 'Sunrise Poultry',
      location: 'Chiredzi',
      quantity: '180 chicks available',
      distance: '2.9 km',
      imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Eggs',
      category: 'Livestock',
      description: 'Fresh eggs packed in trays for wholesale buyers.',
      price: '\$4.50/tray',
      seller: 'Sunrise Poultry',
      location: 'Chiredzi',
      quantity: '52 trays available',
      distance: '3.5 km',
      imageUrl: 'https://images.unsplash.com/photo-1569288052389-dac9b01c5c0a?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Rape',
      category: 'Vegetables',
      description: 'Fresh rape leaves harvested for local markets.',
      price: '\$0.30/bunch',
      seller: 'Green Valley',
      location: 'Chiredzi',
      quantity: '140 bunches available',
      distance: '4.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Cabbages',
      category: 'Vegetables',
      description: 'Firm cabbages packed for bulk sale.',
      price: '\$0.60/kg',
      seller: 'Sunfield Market',
      location: 'Bulawayo',
      quantity: '84 heads available',
      distance: '21.7 km',
      imageUrl: 'https://images.unsplash.com/photo-1554348713-f5a6c3a7f1c1?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Drip Irrigation Kit',
      category: 'Equipment',
      description: 'Full drip irrigation kit covers 1 Hectare. Complete with valves and hoses.',
      price: '\$250.00',
      seller: 'AgriSupply',
      location: 'Harare',
      quantity: '5 units available',
      distance: '10 km',
      imageUrl: 'https://images.unsplash.com/photo-1463123081488-729f99c93b6e?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: '2,4-D Herbicide',
      category: 'Processed product',
      description: 'Selective herbicide for control of broadleaf weeds in maize and grain crops.',
      price: '\$15.00',
      seller: 'AgriSupply',
      location: 'Harare',
      quantity: '40 bottles available',
      distance: '10 km',
      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
    ),
  ];
}