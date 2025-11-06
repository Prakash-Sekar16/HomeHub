
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ar/ar_viewpage.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> productData;
  final Function(Map<String, dynamic>) addToCart;

  const ProductDetailsPage({
    super.key,
    required this.productData,
    required this.addToCart,
  });

  // Save recently viewed product
  Future<void> _saveRecentlyViewed() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || productData["id"] == null) return;

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("recently_viewed")
        .doc(productData["id"]);

    await docRef.set({
      ...productData,
      "viewedAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure saveRecentlyViewed runs only once on build using Future.microtask
    Future.microtask(() => _saveRecentlyViewed());

    final double price = (productData["price"] ?? 0.0).toDouble();
    final double discountValue = (productData["discount"] ?? 0.0).toDouble();
    final int discount = (discountValue * 100).ceil();
    final double oldPrice = (discount > 0) ? price / (1 - discount / 100) : price;

    final String productName = productData["product_name"] ?? "Unknown Product";
    final String imageUrl = productData["image_url"] ?? "https://via.placeholder.com/150";
    final String description = productData["description"] ?? " ";
    final String modelUrl = productData["model_url"] ?? "";

    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Image.network(
                imageUrl,
                height: 280,
                width: 300,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 16),
            // Product Name
            Text(
              productName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Price and Discount Information
            Row(
              children: [
                Text(
                  "\$${price.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                if (discount > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    "\$${oldPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$discount% OFF",
                    style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Product Description
            Text(description, style: const TextStyle(fontSize: 10)),
            const Spacer(),
            // Add to Cart & 3D View buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      addToCart({
                        "name": productName,
                        "price": price,
                        "image": imageUrl,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$productName added to Cart")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (modelUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ARViewer(modelUrl: modelUrl),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("3D model not available for this product")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("3D View", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
