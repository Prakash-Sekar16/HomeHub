
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homehub/pages/ProductScreen/cache_network_images.dart';
import 'product_details.dart';

class ProductDisplayPage extends StatefulWidget {
  final String selectedCategory;
  final TextEditingController searchController;
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) addToCart;
  final int limit;

  const ProductDisplayPage({
    super.key,
    required this.selectedCategory,
    required this.searchController,
    required this.scrollController,
    required this.addToCart,
    required this.limit,
  });

  @override
  _ProductDisplayPageState createState() => _ProductDisplayPageState();
}

class _ProductDisplayPageState extends State<ProductDisplayPage> {
  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {}); // Ensure widget is mounted before rebuilding UI
    }
  }

  // ✅ Optimized Firestore Query
  Stream<QuerySnapshot<Map<String, dynamic>>> getProductsStream() {
    Query<Map<String, dynamic>> productsQuery =
        FirebaseFirestore.instance.collection("products");

    if (widget.selectedCategory != "All") {
      debugPrint("Applying filter: ${widget.selectedCategory}");
      productsQuery =
          productsQuery.where("subcategory", isEqualTo: widget.selectedCategory);
    }

    if (widget.limit > 0) {
      productsQuery = productsQuery.limit(widget.limit);
    }

    return productsQuery.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    print("Selected Category: ${widget.selectedCategory}");

    return Scaffold(
      appBar: (ModalRoute.of(context)?.canPop == true && widget.limit > 0)
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text("Products"),
            )
          : null,
      body: ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.searchController,
        builder: (context, value, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: getProductsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var products = snapshot.data!.docs.where((doc) {
                Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

                bool matchesSearch = value.text.isEmpty ||
                    (data?["product_name"]?.toString().toLowerCase() ?? "")
                        .contains(value.text.toLowerCase());

                return matchesSearch;
              }).toList();

              return products.isEmpty
                  ? const Center(child: Text("No products available"))
                  : GridView.builder(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        Map<String, dynamic>? productData =
                            product.data() as Map<String, dynamic>?;

                        String imageUrl = productData?["image_url"] ??
                            "https://via.placeholder.com/150";
                        String productName =
                            productData?["product_name"] ?? "Unknown Product";
                        double price =
                            (productData?["price"] ?? 0.0).toDouble();
                        double discountValue =
                            (productData?["discount"] ?? 0).toDouble();
                        int discount = discountValue < 1
                            ? (discountValue * 100).round()
                            : discountValue.round();

                        double oldPrice = (discount > 0)
                            ? price / (1 - (discount / 100))
                            : price;

                        return GestureDetector(
                         onTap: () {
                            final fullData = {
                              ...productData!,
                              "id": product.id, // <-- Add this
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsPage(
                                  productData: fullData,
                                  addToCart: widget.addToCart,
                                ),
                              ),
                            );
                          },

                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: ProductImage(imageUrl: imageUrl),
                                ),
                                Expanded( 
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              "\$${price.toStringAsFixed(1)}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "\$${oldPrice.toStringAsFixed(1)}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "${discount.toString()}% off",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Spacer(), // ✅ Pushes button to the bottom
                                        SizedBox(
                                          width: double.infinity,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              widget.addToCart({
                                                "name": productName,
                                                "price": price,
                                                "image": imageUrl,
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text("Add to Cart",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            },
          );
        },
      ),
    );
  }
}
