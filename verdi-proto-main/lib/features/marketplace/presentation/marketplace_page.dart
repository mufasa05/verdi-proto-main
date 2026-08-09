import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/mock_app_data.dart';
import '../../../state/cart_state.dart';
import '../../../state/app_state.dart';
import '../../../state/chat_state.dart';
import '../../../widgets/cart_drawer.dart';
import '../../../widgets/nearby_transport_panel.dart';
import '../../../features/auth/state/auth_state.dart';
import 'package:verdi/core/services/verdi_api_service.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage>
    with SingleTickerProviderStateMixin {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const bgLight = Color(0xFFF8FAFC);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Maize',
    'Tomatoes',
    'Potatoes',
    'Onions',
    'Beans',
    'Vegetables',
    'Fruits',
    'More',
  ];

  String _selectedLocation = 'All regions';
  String _selectedCategoryFilter = 'All categories';
  String _selectedType = 'All types';
  String _selectedPriceRange = 'Any price';
  String _selectedSort = 'Recommended';
  String _currentViewMode = 'grid';
  int _visibleItemCount = 8;

  late List<MarketplaceProduct> _allProducts;

  final List<MarketplaceProduct> _defaultProducts = const [
    MarketplaceProduct(
      name: 'Tomatoes',
      category: 'Tomatoes',
      description: 'Red, fresh tomatoes',
      price: '\$0.40 / kg',
      seller: 'Chiredzi Fresh Farms',
      location: 'Chiredzi',
      quantity: '3,000 kg available',
      distance: '4.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Maize',
      category: 'Maize',
      description: 'White A-quality maize',
      price: '\$0.30 / kg',
      seller: 'Green Valley Farms',
      location: 'Chiredzi',
      quantity: '2,000 kg available',
      distance: '3.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Potatoes',
      category: 'Potatoes',
      description: 'Firm potatoes',
      price: '\$0.50 / kg',
      seller: 'Mutey Farm Produce',
      location: 'Chiredzi',
      quantity: '500 kg available',
      distance: '11 km',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Onions',
      category: 'Onions',
      description: 'Red onions',
      price: '\$0.20 / kg',
      seller: 'ZimbabweWest Co.',
      location: 'Chiredzi',
      quantity: '1,000 kg available',
      distance: '15 km',
      imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Green Beans',
      category: 'Beans',
      description: 'Fresh green beans',
      price: '\$0.50 / kg',
      seller: 'Yaram Gardens',
      location: 'Chiredzi',
      quantity: '300 kg available',
      distance: '12 km',
      imageUrl: 'https://images.unsplash.com/photo-1567375698348-5d9d5ae99de0?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Cabbage',
      category: 'Vegetables',
      description: 'Fresh green cabbage',
      price: '\$0.60 / kg',
      seller: 'Shawa Greens',
      location: 'Chiredzi',
      quantity: '400 kg available',
      distance: '13 km',
      imageUrl: 'https://images.unsplash.com/photo-1598170845058-12ef4a457939?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Avocados',
      category: 'Fruits',
      description: 'Hass avocados',
      price: '\$1.20 / kg',
      seller: 'Tropics Produce',
      location: 'Chiredzi',
      quantity: '200 kg available',
      distance: '20 km',
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Oranges',
      category: 'Fruits',
      description: 'Sweet oranges',
      price: '\$0.75 / kg',
      seller: 'Gutu Valley',
      location: 'Chiredzi',
      quantity: '300 kg available',
      distance: '22 km',
      imageUrl: 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Carrots',
      category: 'Vegetables',
      description: 'Crisp organic carrots',
      price: '\$0.70 / kg',
      seller: 'Mvurwi Organic Estates',
      location: 'Harare',
      quantity: '1,500 kg available',
      distance: '18 km',
      imageUrl: 'https://images.unsplash.com/photo-1598170845058-12ef4a457939?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Sweet Potatoes',
      category: 'Potatoes',
      description: 'Orange-fleshed sweet potatoes',
      price: '\$0.45 / kg',
      seller: 'Bindura Roots Co.',
      location: 'Bindura',
      quantity: '800 kg available',
      distance: '25 km',
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Watermelon',
      category: 'Fruits',
      description: 'Fresh juicy sweet watermelon',
      price: '\$1.50 / unit',
      seller: 'Middle Sabi Orchards',
      location: 'Chiredzi',
      quantity: '600 units available',
      distance: '28 km',
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Soybeans',
      category: 'Beans',
      description: 'Grade-1 golden soybeans',
      price: '\$0.55 / kg',
      seller: 'Mazowe Grains',
      location: 'Mazowe',
      quantity: '5,000 kg available',
      distance: '30 km',
      imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Wheat Grain',
      category: 'Maize',
      description: 'Premium milling wheat',
      price: '\$0.35 / kg',
      seller: 'Highveld Agro',
      location: 'Gweru',
      quantity: '10,000 kg available',
      distance: '35 km',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Garlic',
      category: 'Vegetables',
      description: 'Fresh purple garlic bulbs',
      price: '\$2.50 / kg',
      seller: 'Nyanga Highlands',
      location: 'Mutare',
      quantity: '250 kg available',
      distance: '40 km',
      imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Green Peppers',
      category: 'Vegetables',
      description: 'Crisp bell peppers',
      price: '\$0.80 / kg',
      seller: 'Save Valley Greens',
      location: 'Chiredzi',
      quantity: '450 kg available',
      distance: '14 km',
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=900&q=80',
    ),
    MarketplaceProduct(
      name: 'Groundnuts',
      category: 'Beans',
      description: 'Shelled raw groundnuts',
      price: '\$1.10 / kg',
      seller: 'Gutu Co-op',
      location: 'Masvingo',
      quantity: '1,200 kg available',
      distance: '32 km',
      imageUrl: 'https://images.unsplash.com/photo-1567375698348-5d9d5ae99de0?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _allProducts = List.from(_defaultProducts);
    _loadBackendListings();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _loadBackendListings() async {
    try {
      final backendData = await VerdiApiService.instance.getMarketplaceListings();
      if (backendData.isNotEmpty) {
        final fetched = backendData.map((map) {
          return MarketplaceProduct(
            name: map['name']?.toString() ?? 'Agri Product',
            category: map['category']?.toString() ?? 'Vegetables',
            description: map['description']?.toString() ?? '',
            price: map['price']?.toString() ?? '\$1.00',
            seller: map['seller']?.toString() ?? 'Verified Producer',
            location: map['location']?.toString() ?? 'Chiredzi',
            quantity: map['quantity']?.toString() ?? '100 kg available',
            distance: map['distance']?.toString() ?? '0.0 km',
            imageUrl: (map['imageUrl']?.toString() != null && map['imageUrl'].toString().isNotEmpty)
                ? map['imageUrl'].toString()
                : 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
          );
        }).toList();

        if (mounted) {
          setState(() {
            _allProducts = [...fetched, ..._allProducts];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading backend marketplace listings: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MarketplaceProduct> get _filteredProducts {
    final search = _searchController.text.trim().toLowerCase();
    final tab = _categories[_tabController.index];

    return _allProducts.where((p) {
      final matchesSearch = search.isEmpty ||
          p.name.toLowerCase().contains(search) ||
          p.description.toLowerCase().contains(search) ||
          p.seller.toLowerCase().contains(search) ||
          p.location.toLowerCase().contains(search);

      final matchesTab = tab == 'All' || tab == 'More' || p.category.toLowerCase().contains(tab.toLowerCase()) || p.name.toLowerCase().contains(tab.toLowerCase());
      final matchesLocation = _selectedLocation == 'All regions' || p.location == _selectedLocation;
      final matchesCat = _selectedCategoryFilter == 'All categories' || p.category == _selectedCategoryFilter;

      final priceValue = double.tryParse(p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      final matchesPrice = switch (_selectedPriceRange) {
        'Under \$0.50' => priceValue < 0.50,
        '\$0.50 - \$1.00' => priceValue >= 0.50 && priceValue <= 1.00,
        'Above \$1.00' => priceValue > 1.00,
        _ => true,
      };

      return matchesSearch && matchesTab && matchesLocation && matchesCat && matchesPrice;
    }).toList();
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    String selectedCategory = 'Tomatoes';
    String? pickedImageBase64;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('List New Produce', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Produce Name', hintText: 'e.g. Fresh Tomatoes'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const ['Tomatoes', 'Maize', 'Potatoes', 'Onions', 'Beans', 'Vegetables', 'Fruits']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedCategory = v);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price', hintText: 'e.g. 0.40 / kg'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity Available', hintText: 'e.g. 1,000 kg available'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                setDialogState(() {
                                  pickedImageBase64 = base64Str;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Gallery'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: green,
                              side: const BorderSide(color: green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                setDialogState(() {
                                  pickedImageBase64 = base64Str;
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: const Text('Camera'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: green,
                              side: const BorderSide(color: green),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (pickedImageBase64 != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(border: Border.all(color: green, width: 2)),
                          child: Image.memory(
                            base64Decode(pickedImageBase64!.split(',').last),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'Image Link (Optional)',
                          hintText: 'Paste image URL',
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = priceController.text.trim();
                    final qty = quantityController.text.trim();
                    final desc = descController.text.trim();
                    final customImg = imageController.text.trim();

                    if (name.isEmpty || price.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill Name and Price fields.')),
                      );
                      return;
                    }

                    final finalImageUrl = (pickedImageBase64 != null && pickedImageBase64!.isNotEmpty)
                        ? pickedImageBase64!
                        : (customImg.isNotEmpty
                            ? customImg
                            : 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80');

                    final user = ref.read(authStateProvider).user;
                    final newProduct = MarketplaceProduct(
                      name: name,
                      category: selectedCategory,
                      description: desc.isEmpty ? 'Fresh quality produce listed on Verdi.' : desc,
                      price: price.startsWith('\$') ? price : '\$$price',
                      seller: 'Chiredzi Produce',
                      location: 'Chiredzi',
                      quantity: qty.isEmpty ? '1,000 kg available' : qty,
                      distance: '1.5 km',
                      imageUrl: finalImageUrl,
                      sellerId: user?.id,
                    );

                    VerdiApiService.instance.createMarketplaceListing({
                      'name': name,
                      'category': selectedCategory,
                      'description': desc.isEmpty ? 'Fresh quality produce listed on Verdi.' : desc,
                      'price': price.startsWith('\$') ? price : '\$$price',
                      'seller': 'Chiredzi Produce',
                      'location': 'Chiredzi',
                      'quantity': qty.isEmpty ? '1,000 kg available' : qty,
                      'imageUrl': finalImageUrl,
                      'status': 'Active',
                    });

                    setState(() {
                      _allProducts.insert(0, newProduct);
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name listed successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Submit Listing'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNearbyTransportBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const NearbyTransportPanel(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _gridCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 850) return 3;
    return 2;
  }

  void _openCart() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showProductDetails(BuildContext context, MarketplaceProduct product, VoidCallback onAddToCart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: product.imageUrl.startsWith('data:image')
                      ? Image.memory(base64Decode(product.imageUrl.split(',').last), fit: BoxFit.cover)
                      : (product.imageUrl.startsWith('assets/')
                          ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                            )),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    product.distance,
                    style: const TextStyle(color: muted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.price,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: green,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black12),
              const SizedBox(height: 12),
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: dark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.description,
                style: GoogleFonts.inter(fontSize: 14, color: muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: muted),
                  const SizedBox(width: 8),
                  const Text('Seller: ', style: TextStyle(fontWeight: FontWeight.w600, color: dark)),
                  Text(product.seller, style: const TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 20, color: muted),
                  const SizedBox(width: 8),
                  const Text('Location: ', style: TextStyle(fontWeight: FontWeight.w600, color: dark)),
                  Text('${product.location} • ${product.quantity}', style: const TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(chatProvider.notifier).startOrGetThread(
                          product.seller,
                          'Inquiries about ${product.name}',
                          'Hello! I saw your listing for ${product.name} on the marketplace. Is it still available?',
                        );
                    ref.read(appStateProvider.notifier).setNavIndex(2);
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with Seller'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: green),
                        foregroundColor: green,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onAddToCart();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).itemCount;
    final allMatchingProducts = _filteredProducts;
    final displayedProducts = allMatchingProducts.take(_visibleItemCount).toList();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const CartDrawer(),
      backgroundColor: bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCart,
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: Badge(
          label: Text('$cartCount', style: const TextStyle(fontWeight: FontWeight.bold)),
          isLabelVisible: cartCount > 0,
          backgroundColor: Colors.red,
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        label: Text(
          cartCount > 0 ? 'Checkout ($cartCount)' : 'View Cart',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13.5),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth > 1100;
            final crossAxisCount = _gridCount(constraints.maxWidth);
            final isMobile = constraints.maxWidth < 700;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Top Header Bar Matching Reference Mockup (Profile Talent K. removed as requested)
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.fromLTRB(16, isMobile ? 12 : 16, 16, 12),
                          child: Column(
                            children: [
                              _buildTopHeaderRow(isMobile, cartCount),
                              const SizedBox(height: 14),
                              _buildCategoryBarRow(),
                              const SizedBox(height: 12),
                              _buildFilterBarRow(),
                            ],
                          ),
                        ),
                      ),

                      // Sticky Section Header for Listings (Fixed overflow pixel error)
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(
                          minHeight: 68,
                          maxHeight: 68,
                          child: Container(
                            color: bgLight,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: green.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.location_on_outlined, color: green, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Nearby Listings',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: dark,
                                              ),
                                            ),
                                            if (!isMobile)
                                              Text(
                                                'Showing produce ready to deliver within 50 km of Chiredzi',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(fontSize: 11.5, color: muted),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                   tooltip: 'List View',
                                   onPressed: () {
                                     setState(() {
                                       _currentViewMode = 'list';
                                     });
                                   },
                                   icon: Icon(
                                     Icons.reorder_rounded,
                                     size: 18,
                                     color: _currentViewMode == 'list' ? green : dark,
                                   ),
                                   style: IconButton.styleFrom(
                                     backgroundColor: _currentViewMode == 'list' ? green.withValues(alpha: 0.15) : Colors.white,
                                     side: BorderSide(color: _currentViewMode == 'list' ? green : Colors.black.withValues(alpha: 0.1)),
                                     padding: const EdgeInsets.all(8),
                                   ),
                                 ),
                                 const SizedBox(width: 6),
                                 IconButton(
                                   tooltip: 'Grid View',
                                   onPressed: () {
                                     setState(() {
                                       _currentViewMode = 'grid';
                                     });
                                   },
                                   icon: Icon(
                                     Icons.grid_view_rounded,
                                     size: 18,
                                     color: _currentViewMode == 'grid' ? green : dark,
                                   ),
                                   style: IconButton.styleFrom(
                                     backgroundColor: _currentViewMode == 'grid' ? green.withValues(alpha: 0.15) : Colors.white,
                                     side: BorderSide(color: _currentViewMode == 'grid' ? green : Colors.black.withValues(alpha: 0.1)),
                                     padding: const EdgeInsets.all(8),
                                   ),
                                 ),
                                 const SizedBox(width: 8),
                                 OutlinedButton.icon(
                                   onPressed: () {
                                     setState(() {
                                       _currentViewMode = 'map';
                                     });
                                   },
                                   icon: Icon(
                                     Icons.map_outlined,
                                     size: 16,
                                     color: _currentViewMode == 'map' ? green : dark,
                                   ),
                                   label: Text(
                                     isMobile ? 'Map' : 'Map View',
                                     style: TextStyle(
                                       color: _currentViewMode == 'map' ? green : dark,
                                       fontWeight: _currentViewMode == 'map' ? FontWeight.bold : FontWeight.normal,
                                     ),
                                   ),
                                   style: OutlinedButton.styleFrom(
                                     backgroundColor: _currentViewMode == 'map' ? green.withValues(alpha: 0.15) : Colors.white,
                                     foregroundColor: _currentViewMode == 'map' ? green : dark,
                                     side: BorderSide(color: _currentViewMode == 'map' ? green : Colors.black.withValues(alpha: 0.12)),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                   ),
                                 ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Produce View Section (Grid / List / Map Modes)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        sliver: displayedProducts.isEmpty
                            ? SliverToBoxAdapter(
                                child: Container(
                                  padding: const EdgeInsets.all(40),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      const Icon(Icons.search_off_rounded, size: 54, color: muted),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No matching produce found',
                                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: dark),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Try adjusting search keywords or category filters.',
                                        style: GoogleFonts.inter(fontSize: 13, color: muted),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _currentViewMode == 'map'
                                 ? SliverToBoxAdapter(
                                     child: _MarketplaceMapView(
                                       products: displayedProducts,
                                       onOpenTransport: _showNearbyTransportBottomSheet,
                                       onAddToCart: (p) {
                                         ref.read(cartProvider.notifier).addItem(
                                               CartItem(
                                                 id: '${p.name}-${p.seller}',
                                                 name: p.name,
                                                 price: p.price,
                                                 quantity: 1,
                                                 imageUrl: p.imageUrl,
                                                 supplier: p.seller,
                                               ),
                                             );
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           SnackBar(
                                             content: Text('${p.name} added to cart!'),
                                             action: SnackBarAction(
                                               label: 'Checkout',
                                               textColor: Colors.amber,
                                               onPressed: _openCart,
                                             ),
                                           ),
                                         );
                                       },
                                       onViewDetails: (p) => _showProductDetails(context, p, () {
                                         ref.read(cartProvider.notifier).addItem(
                                               CartItem(
                                                 id: '${p.name}-${p.seller}',
                                                 name: p.name,
                                                 price: p.price,
                                                 quantity: 1,
                                                 imageUrl: p.imageUrl,
                                                 supplier: p.seller,
                                               ),
                                             );
                                       }),
                                     ),
                                   )
                                 : _currentViewMode == 'list'
                                     ? SliverList(
                                         delegate: SliverChildBuilderDelegate(
                                           (context, index) {
                                             final p = displayedProducts[index];
                                             final currentUser = ref.watch(authStateProvider).user;
                                             final currentRole = ref.watch(appStateProvider).role;
                                             final bool canDelete;
                                             if (currentUser == null) {
                                               canDelete = false;
                                             } else if (currentRole == UserRole.admin) {
                                               canDelete = true;
                                             } else if (p.sellerId != null && p.sellerId!.isNotEmpty) {
                                               canDelete = p.sellerId == currentUser.id;
                                             } else {
                                               canDelete = false;
                                             }

                                             return _MarketplaceListTileCard(
                                               product: p,
                                               canDelete: canDelete,
                                               onDelete: () {
                                                 showDialog(
                                                   context: context,
                                                   builder: (context) => AlertDialog(
                                                     title: const Text('Delete Listing'),
                                                     content: Text('Are you sure you want to delete "${p.name}"?'),
                                                     actions: [
                                                       TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                       ElevatedButton(
                                                         onPressed: () {
                                                           setState(() {
                                                             _allProducts.remove(p);
                                                           });
                                                           Navigator.pop(context);
                                                         },
                                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                         child: const Text('Delete'),
                                                       ),
                                                     ],
                                                   ),
                                                 );
                                               },
                                               onAddToCart: () {
                                                 ref.read(cartProvider.notifier).addItem(
                                                       CartItem(
                                                         id: '${p.name}-${p.seller}',
                                                         name: p.name,
                                                         price: p.price,
                                                         quantity: 1,
                                                         imageUrl: p.imageUrl,
                                                         supplier: p.seller,
                                                       ),
                                                     );
                                                 ScaffoldMessenger.of(context).showSnackBar(
                                                   SnackBar(
                                                     content: Text('${p.name} added to cart!'),
                                                     action: SnackBarAction(
                                                       label: 'Checkout',
                                                       textColor: Colors.amber,
                                                       onPressed: _openCart,
                                                     ),
                                                   ),
                                                 );
                                               },
                                               onViewDetails: () {
                                                 _showProductDetails(context, p, () {
                                                   ref.read(cartProvider.notifier).addItem(
                                                         CartItem(
                                                           id: '${p.name}-${p.seller}',
                                                           name: p.name,
                                                           price: p.price,
                                                           quantity: 1,
                                                           imageUrl: p.imageUrl,
                                                           supplier: p.seller,
                                                         ),
                                                       );
                                                 });
                                               },
                                             );
                                           },
                                           childCount: displayedProducts.length,
                                         ),
                                       )
                                     : SliverGrid(
                                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                           crossAxisCount: crossAxisCount,
                                           crossAxisSpacing: 14,
                                           mainAxisSpacing: 14,
                                           mainAxisExtent: isMobile ? 410 : 360,
                                         ),
                                         delegate: SliverChildBuilderDelegate(
                                           (context, index) {
                                             final p = displayedProducts[index];
                                             final currentUser = ref.watch(authStateProvider).user;
                                             final currentRole = ref.watch(appStateProvider).role;
                                             final bool canDelete;
                                             if (currentUser == null) {
                                               canDelete = false;
                                             } else if (currentRole == UserRole.admin) {
                                               canDelete = true;
                                             } else if (p.sellerId != null && p.sellerId!.isNotEmpty) {
                                               canDelete = p.sellerId == currentUser.id;
                                             } else {
                                               canDelete = false;
                                             }

                                             return _MarketplaceProductCard(
                                               product: p,
                                               canDelete: canDelete,
                                               onDelete: () {
                                                 showDialog(
                                                   context: context,
                                                   builder: (context) => AlertDialog(
                                                     title: const Text('Delete Listing'),
                                                     content: Text('Are you sure you want to delete "${p.name}"?'),
                                                     actions: [
                                                       TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                       ElevatedButton(
                                                         onPressed: () {
                                                           setState(() {
                                                             _allProducts.remove(p);
                                                           });
                                                           Navigator.pop(context);
                                                           ScaffoldMessenger.of(context).showSnackBar(
                                                             SnackBar(content: Text('${p.name} deleted.')),
                                                           );
                                                         },
                                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                         child: const Text('Delete'),
                                                       ),
                                                     ],
                                                   ),
                                                 );
                                               },
                                               onAddToCart: () {
                                                 ref.read(cartProvider.notifier).addItem(
                                                       CartItem(
                                                         id: '${p.name}-${p.seller}',
                                                         name: p.name,
                                                         price: p.price,
                                                         quantity: 1,
                                                         imageUrl: p.imageUrl,
                                                         supplier: p.seller,
                                                       ),
                                                     );
                                                 ScaffoldMessenger.of(context).showSnackBar(
                                                   SnackBar(
                                                     content: Text('${p.name} added to cart!'),
                                                     action: SnackBarAction(
                                                       label: 'Checkout',
                                                       textColor: Colors.amber,
                                                       onPressed: _openCart,
                                                     ),
                                                     duration: const Duration(seconds: 3),
                                                   ),
                                                 );
                                               },
                                               onViewDetails: () {
                                                 _showProductDetails(context, p, () {
                                                   ref.read(cartProvider.notifier).addItem(
                                                         CartItem(
                                                           id: '${p.name}-${p.seller}',
                                                           name: p.name,
                                                           price: p.price,
                                                           quantity: 1,
                                                           imageUrl: p.imageUrl,
                                                           supplier: p.seller,
                                                         ),
                                                       );
                                                   ScaffoldMessenger.of(context).showSnackBar(
                                                     SnackBar(
                                                       content: Text('${p.name} added to cart!'),
                                                       action: SnackBarAction(
                                                         label: 'Checkout',
                                                         textColor: Colors.amber,
                                                         onPressed: _openCart,
                                                       ),
                                                       duration: const Duration(seconds: 3),
                                                     ),
                                                   );
                                                 });
                                               },
                                               isMobile: isMobile,
                                             );
                                           },
                                           childCount: displayedProducts.length,
                                         ),
                                       ),
                      ),

                      // Functional Load More Button
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (_visibleItemCount < allMatchingProducts.length) {
                                    _visibleItemCount += 8;
                                  } else {
                                    _visibleItemCount = 8;
                                  }
                                });
                              },
                              icon: Icon(
                                _visibleItemCount < allMatchingProducts.length
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                size: 18,
                              ),
                              label: Text(
                                _visibleItemCount < allMatchingProducts.length
                                    ? 'Load More Listings (${allMatchingProducts.length - _visibleItemCount} remaining)'
                                    : 'Show Less Listings',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: dark,
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Feature Highlights Cards (4 columns)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmall = constraints.maxWidth < 750;
                              if (isSmall) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFeatureHighlightCard(
                                            Icons.verified_user_outlined,
                                            'Verified Users',
                                            'All farmers and buyers verified',
                                            onTap: () => _showVerifiedUsersDialog(context),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildFeatureHighlightCard(
                                            Icons.lock_outline_rounded,
                                            'Secure Transactions',
                                            'Safe escrow & mobile payments',
                                            onTap: () => ref.read(appStateProvider.notifier).setNavIndex(6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFeatureHighlightCard(
                                            Icons.auto_awesome_outlined,
                                            'Smart Matching',
                                            'AI connects buyers & sellers',
                                            onTap: () => ref.read(appStateProvider.notifier).setNavIndex(2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildFeatureHighlightCard(
                                            Icons.local_shipping_outlined,
                                            'Fast Delivery',
                                            'Connected with transporters',
                                            onTap: () => ref.read(appStateProvider.notifier).setNavIndex(5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildFeatureHighlightCard(
                                      Icons.verified_user_outlined,
                                      'Verified Users',
                                      'All farmers & buyers verified',
                                      onTap: () => _showVerifiedUsersDialog(context),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildFeatureHighlightCard(
                                      Icons.lock_outline_rounded,
                                      'Secure Transactions',
                                      'Safe escrow protection',
                                      onTap: () => ref.read(appStateProvider.notifier).setNavIndex(6),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildFeatureHighlightCard(
                                      Icons.auto_awesome_outlined,
                                      'Smart Matching',
                                      'AI connects trade faster',
                                      onTap: () => ref.read(appStateProvider.notifier).setNavIndex(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildFeatureHighlightCard(
                                      Icons.local_shipping_outlined,
                                      'Fast Delivery',
                                      'Connected transporters',
                                      onTap: () => ref.read(appStateProvider.notifier).setNavIndex(5),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Desktop Sidebar Panel
                if (desktop)
                  SizedBox(
                    width: 360,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _ReferenceDesktopPanel(
                          onOpenTransport: _showNearbyTransportBottomSheet,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeaderRow(bool isMobile, int cartCount) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketplace',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: dark,
                      ),
                    ),
                    Text(
                      'Buy, sell and make produce across Zimbabwe.',
                      style: GoogleFonts.inter(fontSize: 11.5, color: muted),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: Text('Cart ($cartCount)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSearchBox()),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Edit Produce'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marketplace',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: dark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Buy, sell and make produce across Zimbabwe.',
              style: GoogleFonts.inter(fontSize: 12.5, color: muted),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(child: _buildSearchBox()),
        const SizedBox(width: 14),
        ElevatedButton.icon(
          onPressed: _showAddProductDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Edit Produce'),
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => ref.read(appStateProvider.notifier).setNavIndex(2),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: dark),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
            padding: const EdgeInsets.all(10),
          ),
        ),
        const SizedBox(width: 8),
        Badge(
          label: const Text('3'),
          backgroundColor: Colors.red,
          child: IconButton(
            onPressed: () => ref.read(appStateProvider.notifier).setNavIndex(7),
            icon: const Icon(Icons.notifications_none_rounded, size: 22, color: dark),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _openCart,
          icon: Badge(
            label: Text('$cartCount'),
            isLabelVisible: cartCount > 0,
            backgroundColor: Colors.white,
            textColor: green,
            child: const Icon(Icons.shopping_cart_outlined, size: 18),
          ),
          label: Text('Cart ($cartCount)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.inter(fontSize: 13.5, color: dark),
        decoration: InputDecoration(
          hintText: 'Search product, location or buyers...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: muted),
          prefixIcon: const Icon(Icons.search, color: muted, size: 20),
          suffixIcon: UnconstrainedBox(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '30K',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: muted),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildCategoryBarRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          final isSelected = _tabController.index == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _tabController.animateTo(index);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? green : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? green : Colors.black.withValues(alpha: 0.1),
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: green.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
                ),
                child: Row(
                  children: [
                    Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : dark,
                      ),
                    ),
                    if (cat == 'More') ...[
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isSelected ? Colors.white : dark),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterBarRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterDropdownPill('Location', _selectedLocation, ['All regions', 'Chiredzi', 'Masvingo', 'Mutare', 'Harare', 'Bulawayo'], (v) => setState(() => _selectedLocation = v)),
          const SizedBox(width: 8),
          _filterDropdownPill('Categories', _selectedCategoryFilter, ['All categories', 'Tomatoes', 'Maize', 'Potatoes', 'Onions', 'Beans', 'Vegetables', 'Fruits'], (v) => setState(() => _selectedCategoryFilter = v)),
          const SizedBox(width: 8),
          _filterDropdownPill('Type', _selectedType, ['All types', 'Fresh Produce', 'Organic', 'Processed'], (v) => setState(() => _selectedType = v)),
          const SizedBox(width: 8),
          _filterDropdownPill('Price range', _selectedPriceRange, ['Any price', 'Under \$0.50', '\$0.50 - \$1.00', 'Above \$1.00'], (v) => setState(() => _selectedPriceRange = v)),
          const SizedBox(width: 8),
          _filterDropdownPill('Sort by', _selectedSort, ['Recommended', 'Lowest Price', 'Highest Distance', 'Newest'], (v) => setState(() => _selectedSort = v)),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded, size: 16, color: dark),
            label: const Text('Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: dark,
              side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdownPill(String title, String value, List<String> options, ValueChanged<String> onChanged) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => options.map((opt) => PopupMenuItem(value: opt, child: Text(opt))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 10, color: muted)),
                Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: dark)),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
          ],
        ),
      ),
    );
  }

  void _showVerifiedUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.verified_user_rounded, color: green, size: 26),
            SizedBox(width: 10),
            Text('Verdi User Verification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'All farmers, buyers, and transporters on Verdi undergo 3-tier verification:',
              style: TextStyle(fontSize: 13.5, height: 1.4),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: green, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('National ID / Passport Verification', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: green, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Farm GPS Location Polygon Audit', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: green, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Protected Bank & Escrow Settlement KYC', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Understand & Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlightCard(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: green, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800, color: dark)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10.5, color: muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight;
  }
}

class _MarketplaceProductCard extends ConsumerStatefulWidget {
  final MarketplaceProduct product;
  final VoidCallback onAddToCart;
  final VoidCallback onViewDetails;
  final VoidCallback? onDelete;
  final bool canDelete;
  final bool isMobile;

  const _MarketplaceProductCard({
    required this.product,
    required this.onAddToCart,
    required this.onViewDetails,
    this.onDelete,
    required this.canDelete,
    required this.isMobile,
  });

  @override
  ConsumerState<_MarketplaceProductCard> createState() => _MarketplaceProductCardState();
}

class _MarketplaceProductCardState extends ConsumerState<_MarketplaceProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack Container with distance pill overlay & favorite button
            SizedBox(
              height: widget.isMobile ? 125 : 140,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: p.imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(p.imageUrl.split(',').last),
                            fit: BoxFit.cover,
                          )
                        : (p.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                p.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: p.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image_outlined),
                                ),
                              )),
                  ),

                  // Distance Tag Pill Overlay (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.distance,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Favorite Heart Button (Top Right)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? Colors.red : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  // Delete button for owners/admins
                  if (widget.canDelete && widget.onDelete != null)
                    Positioned(
                      top: 6,
                      left: 54,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _MarketplacePageState.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _MarketplacePageState.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.price,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _MarketplacePageState.green,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: _MarketplacePageState.green.withValues(alpha: 0.2),
                          child: Text(
                            p.seller.substring(0, 1),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _MarketplacePageState.green),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${p.seller} • ${p.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 11, color: _MarketplacePageState.dark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.quantity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 11, color: _MarketplacePageState.muted),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _MarketplacePageState.dark,
                              side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: widget.onAddToCart,
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: _MarketplacePageState.green),
                          style: IconButton.styleFrom(
                            backgroundColor: _MarketplacePageState.green.withValues(alpha: 0.12),
                            padding: const EdgeInsets.all(9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ReferenceDesktopPanel extends StatelessWidget {
  final VoidCallback onOpenTransport;

  const _ReferenceDesktopPanel({required this.onOpenTransport});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top High Demand Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Text('🌾', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High demand for maize',
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: _MarketplacePageState.dark),
                    ),
                    Text(
                      'Rise of 15% in a week',
                      style: GoogleFonts.inter(fontSize: 11.5, color: _MarketplacePageState.muted),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('See Trends', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Transport Assistance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Text('🚚', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transport assistance',
                      style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: _MarketplacePageState.dark),
                    ),
                    Text(
                      '5 transporters nearby',
                      style: GoogleFonts.inter(fontSize: 11.5, color: _MarketplacePageState.muted),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onOpenTransport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Book Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Market Demand Section Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Demand',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _MarketplacePageState.dark),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('View full report', style: GoogleFonts.inter(fontSize: 12, color: _MarketplacePageState.muted)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _demandRow('🍅', 'Tomatoes', 'High demand', '+12%', Colors.green),
              const SizedBox(height: 10),
              _demandRow('🌽', 'Maize', 'High demand', '+8%', Colors.green),
              const SizedBox(height: 10),
              _demandRow('🥔', 'Potatoes', 'Moderate demand', '+3%', Colors.orange),
              const SizedBox(height: 10),
              _demandRow('🧅', 'Others', 'Low demand', '-3%', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Transport Near You Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transport Near You',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _MarketplacePageState.dark),
                  ),
                  TextButton(
                    onPressed: onOpenTransport,
                    child: Text('View all', style: GoogleFonts.inter(fontSize: 12, color: _MarketplacePageState.muted)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _transportRow('Towarda Logistics', '4.8 • 2 km away', onOpenTransport),
              const SizedBox(height: 10),
              _transportRow('Speedy Movers', '4.8 • 5 km away', onOpenTransport),
              const SizedBox(height: 10),
              _transportRow('ZimFast Transport', '4.7 • 8 km away', onOpenTransport),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onOpenTransport,
                child: Text(
                  '+7 transport providers available >',
                  style: GoogleFonts.inter(fontSize: 12, color: _MarketplacePageState.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _demandRow(String emoji, String title, String tag, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _MarketplacePageState.bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: _MarketplacePageState.dark)),
                Text(tag, style: GoogleFonts.inter(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(change, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _transportRow(String name, String details, VoidCallback onBook) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_shipping_outlined, size: 16, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800, color: _MarketplacePageState.dark)),
              Text(details, style: GoogleFonts.inter(fontSize: 10.5, color: _MarketplacePageState.muted)),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onBook,
          style: OutlinedButton.styleFrom(
            foregroundColor: _MarketplacePageState.green,
            side: const BorderSide(color: _MarketplacePageState.green),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Book', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _MarketplaceListTileCard extends StatelessWidget {
  final MarketplaceProduct product;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onAddToCart;
  final VoidCallback onViewDetails;

  const _MarketplaceListTileCard({
    required this.product,
    required this.canDelete,
    required this.onDelete,
    required this.onAddToCart,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const dark = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.grass_rounded, color: green, size: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: green,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (canDelete)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 13, color: muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${product.seller} • ${product.distance}',
                            style: GoogleFonts.inter(fontSize: 12, color: muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.price,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: onAddToCart,
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketplaceMapView extends StatefulWidget {
  final List<MarketplaceProduct> products;
  final VoidCallback onOpenTransport;
  final Function(MarketplaceProduct) onAddToCart;
  final Function(MarketplaceProduct) onViewDetails;

  const _MarketplaceMapView({
    required this.products,
    required this.onOpenTransport,
    required this.onAddToCart,
    required this.onViewDetails,
  });

  @override
  State<_MarketplaceMapView> createState() => _MarketplaceMapViewState();
}

class _MarketplaceMapViewState extends State<_MarketplaceMapView> {
  MarketplaceProduct? _selectedProduct;
  bool _isSatellite = false;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const dark = Color(0xFF0F172A);

    final selected = _selectedProduct ?? (widget.products.isNotEmpty ? widget.products.first : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _isSatellite ? const Color(0xFF0B132B) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Map Header Controls Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.map_rounded, color: green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive Produce Location Map',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '50 km Radius • Chiredzi & Regional Hubs',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _isSatellite = !_isSatellite),
                  icon: Icon(_isSatellite ? Icons.map_outlined : Icons.satellite_alt_rounded, color: Colors.white70),
                  tooltip: _isSatellite ? 'Street Map View' : 'Satellite Imagery',
                ),
                ElevatedButton.icon(
                  onPressed: widget.onOpenTransport,
                  icon: const Icon(Icons.local_shipping_outlined, size: 14),
                  label: const Text('Logistics Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Map Canvas with Pinned Markers
          Container(
            height: 280,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _isSatellite ? const Color(0xFF1C2A3A) : const Color(0xFF1E293B),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                // Map Backdrop Pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: 0.35,
                      child: Image.network(
                        _isSatellite
                            ? 'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80'
                            : 'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?auto=format&fit=crop&w=1200&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.black26),
                      ),
                    ),
                  ),
                ),

                // Radius Circle Overlay Label
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: green.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.products.length} Pinned Sellers',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map Produce Pin Markers
                ...widget.products.take(6).toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  final isSelected = selected == p;

                  final topPos = 40.0 + (idx * 35.0) % 180.0;
                  final leftPos = 30.0 + (idx * 65.0) % 320.0;

                  return Positioned(
                    top: topPos,
                    left: leftPos,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedProduct = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? green.withValues(alpha: 0.4) : Colors.black26,
                              blurRadius: isSelected ? 12 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: isSelected ? Colors.white : green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${p.name} ${p.price.split(' ').first}',
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.white : dark,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Selected Product Quick Preview Card
          if (selected != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        selected.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${selected.seller} • ${selected.distance}',
                          style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selected.price,
                          style: GoogleFonts.inter(color: green, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => widget.onAddToCart(selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}