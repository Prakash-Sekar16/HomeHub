// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';


// class CartPage extends StatefulWidget {
//   final List<Map<String, dynamic>> cartItems;
//   final Function(int) removeFromCart;
//   final Function(int, int) updateQuantity;
//   final VoidCallback clearCart;

//   const CartPage({
//     super.key,
//     required this.cartItems,
//     required this.removeFromCart,
//     required this.updateQuantity,
//     required this.clearCart,
//   });

//   @override
//   _CartPageState createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   double taxRate = 0.10; // 10% tax

//   // order will be store in dataset
//   Future<void> placeOrder() async {
//   final user = FirebaseAuth.instance.currentUser;

//   if (user == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please log in to place an order")),
//     );
//     return;
//   }

//   double totalBeforeTax = widget.cartItems.fold(
//       0, (sum, item) => sum + (item["price"] * item["quantity"]));
//   double estimatedTax = totalBeforeTax * taxRate;
//   double orderTotal = totalBeforeTax + estimatedTax;

//   try {
//     // Generate a unique order ID
//     DocumentReference orderRef =
//         FirebaseFirestore.instance.collection('orders').doc();

//     await orderRef.set({
//       'orderId': orderRef.id, // Store generated ID
//       'userId': user.uid,  // ✅ Ensure userId is included
//       'items': widget.cartItems,
//       'totalAmount': orderTotal,
//       'orderDate': DateTime.now().toIso8601String(),
//       'status': 'Processing',
//     });

//     setState(() {
//       widget.clearCart();
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Order placed successfully!")),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Failed to place order: $e")),
//     );
//   }
// }



//   @override
//   Widget build(BuildContext context) {
//     double totalBeforeTax = widget.cartItems
//         .fold(0, (sum, item) => sum + (item["price"] * item["quantity"]));
//     double estimatedTax = totalBeforeTax * taxRate;
//     double orderTotal = totalBeforeTax + estimatedTax;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Review Your Order"),
//         backgroundColor: Colors.white,
//         elevation: 1,
//       ),
//       body: widget.cartItems.isEmpty
//           ? const Center(
//               child: Text(
//                 "Your cart is empty!",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             )
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: widget.cartItems.length,
//                     itemBuilder: (context, index) {
//                       var item = widget.cartItems[index];

//                       return Card(
//                         elevation: 2,
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Product Image
//                               item["image"] != null && item["image"].isNotEmpty
//                                   ? Image.network(
//                                       item["image"],
//                                       width: 80,
//                                       height: 80,
//                                       fit: BoxFit.fill,
//                                       errorBuilder: (context, error,
//                                               stackTrace) =>
//                                           const Icon(Icons.image_not_supported,
//                                               size: 80, color: Colors.grey),
//                                     )
//                                   : const Icon(Icons.image_not_supported,
//                                       size: 80, color: Colors.grey),
//                               const SizedBox(width: 12),
//                               // Product Details
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item["name"]?.toString() ??
//                                           "Unknown Item",
//                                       style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       "\$${item["price"].toStringAsFixed(2)}",
//                                       style: const TextStyle(
//                                           fontSize: 16, color: Colors.red),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         // Quantity Controls
//                                         IconButton(
//                                           icon: const Icon(Icons.remove_circle,
//                                               color: Colors.red),
//                                           onPressed: () {
//                                             if (item["quantity"] > 1) {
//                                               setState(() {
//                                                 widget.updateQuantity(index,
//                                                     item["quantity"] - 1);
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 widget.removeFromCart(index);
//                                               });
//                                             }
//                                           },
//                                         ),
//                                         Text(
//                                           item["quantity"].toString(),
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.add_circle,
//                                               color: Colors.green),
//                                           onPressed: () {
//                                             setState(() {
//                                               widget.updateQuantity(
//                                                   index, item["quantity"] + 1);
//                                             });
//                                           },
//                                         ),
//                                         const Spacer(),
//                                         IconButton(
//                                           icon: const Icon(Icons.delete,
//                                               color: Colors.black45),
//                                           onPressed: () {
//                                             setState(() {
//                                               widget.removeFromCart(index);
//                                             });
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 // Order Summary
//                 Card(
//                   elevation: 2,
//                   margin: const EdgeInsets.all(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("Order Summary",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         const Divider(),
//                         summaryRow("Items (${widget.cartItems.length}):",
//                             "\$${totalBeforeTax.toStringAsFixed(2)}"),
//                         summaryRow("Total before tax:",
//                             "\$${totalBeforeTax.toStringAsFixed(2)}"),
//                         summaryRow("Estimated tax (10%):",
//                             "\$${estimatedTax.toStringAsFixed(2)}"),
//                         const Divider(),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text("Order total:",
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red)),
//                               Text("\$${orderTotal.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.red)),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.amber,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                             ),
//                             onPressed: () async {
//                               await placeOrder();
//                             },

//                             child: const Text("Place your order",
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   // Helper function to create summary rows
//   Widget summaryRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 16)),
//           Text(value,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:intl/intl.dart';


class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int) removeFromCart;
  final Function(int, int) updateQuantity;
  final VoidCallback clearCart;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.removeFromCart,
    required this.updateQuantity,
    required this.clearCart,
  });

  @override
  _CartPageState createState() => _CartPageState();
}
  
class _CartPageState extends State<CartPage> {
  double taxRate = 0.10; // 10% tax

  // order will be store in dataset
  Future<void> placeOrder() async {
  final user = FirebaseAuth.instance.currentUser;
  
  
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please log in to place an order")),
    );
    return;
  }

  String customerId = user.uid;
  double totalBeforeTax = widget.cartItems.fold(
      0, (sum, item) => sum + (item["price"] * item["quantity"]));
  double estimatedTax = totalBeforeTax * taxRate;
  double orderTotal = totalBeforeTax + estimatedTax;

  try {
    final now = DateTime.now();
    final dateFormatter = DateFormat("MM/dd/yyyy");
    final formattedDate = dateFormatter.format(now);

    // Create main order
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc();
    await orderRef.set({
      'orderId': orderRef.id,
      'userId': user.uid,
      'items': widget.cartItems,
      'totalAmount': orderTotal,
      'orderDate': now.toIso8601String(),
      'status': 'Processing',
    });

    // For each cart item: store a row in "sales_data"
    for (var item in widget.cartItems) {
      String productName = item['name'];
      int quantity = item['quantity'];
      double unitPrice = item['price'];

      // Fetch product details from "products" collection
      final productSnap = await FirebaseFirestore.instance
          .collection("products")
          .where("product_name", isEqualTo: productName)
          .limit(1)
          .get();

      if (productSnap.docs.isEmpty) continue;
      final productData = productSnap.docs.first.data();

      String productKey = productData["product_key"] ?? "UNKNOWN";
      String subcategoryName = productData["subcategory"] ?? "";
      String categoryName = productData["category_name"] ?? "Furniture";
      double discount = productData["discount"] ?? 0.0;

      double totalPrice = unitPrice * quantity;

      // Generate sales_order_number
      String salesOrderNumber = "MX-${now.year}-${Random().nextInt(999999)}";

      // Calculate sales in the last 7, 30, and 90 days
      Future<int> getSalesInLastDays(int days) async {
        final dateFrom = now.subtract(Duration(days: days));
        final salesSnap = await FirebaseFirestore.instance
            .collection("sales_data")
            .where("product_key", isEqualTo: productKey)
            .get();

        int total = 0;
        for (var doc in salesSnap.docs) {
          String dateStr = doc['order_date'] ?? '';
          try {
            DateTime saleDate = dateFormatter.parse(dateStr);
            if (saleDate.isAfter(dateFrom) && saleDate.isBefore(now)) {
              total += (doc['order_quantity'] ?? 0) as int;
            }
          } catch (_) {}
        }
        return total;
      }

      int salesWeek = await getSalesInLastDays(7);
      int salesMonth = await getSalesInLastDays(30);
      int sales3Months = await getSalesInLastDays(90);

      // Create unique customer key
      // int customerKey = Random().nextInt(99999) + 10000;
      
      // Store each product row in "sales_data"
      await FirebaseFirestore.instance.collection("sales_data").add({
        "category_name": categoryName,
        "customer_key": customerId,
        "discount_percentage": discount,
        "order_date": formattedDate,
        "order_quantity": quantity,
        "product_key": productKey,
        "product_name": productName,
        "sales_last_3_months": sales3Months,
        "sales_last_month": salesMonth,
        "sales_last_week": salesWeek,
        "sales_order_number": salesOrderNumber,
        "subcategory_name": subcategoryName,
        "total_price": totalPrice,
        "unit_price": unitPrice,
      });
    }

    for (var item in widget.cartItems) {
    final productName = item['name'];

    final productQuery = await FirebaseFirestore.instance
        .collection('products')
        .where('product_name', isEqualTo: productName)
        .limit(1)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productDoc = productQuery.docs.first;
      final productRef = productDoc.reference;

      final currentStock = productDoc['current_stock_level'] ?? 0;
      final orderedQty = item['quantity'];

      await productRef.update({
        'current_stock_level': (currentStock - orderedQty).clamp(0, currentStock),
      });
    }
  }

    setState(() {
      widget.clearCart();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to place order: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    double totalBeforeTax = widget.cartItems
        .fold(0, (sum, item) => sum + (item["price"] * item["quantity"]));
    double estimatedTax = totalBeforeTax * taxRate;
    double orderTotal = totalBeforeTax + estimatedTax;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Your Order"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              item["image"] != null && item["image"].isNotEmpty
                                  ? Image.network(
                                      item["image"],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.fitWidth,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 80, color: Colors.grey),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 80, color: Colors.grey),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"]?.toString() ??
                                          "Unknown Item",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "\$${item["price"].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.red),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Quantity Controls
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () {
                                            if (item["quantity"] > 1) {
                                              setState(() {
                                                widget.updateQuantity(index,
                                                    item["quantity"] - 1);
                                              });
                                            } else {
                                              setState(() {
                                                widget.removeFromCart(index);
                                              });
                                            }
                                          },
                                        ),
                                        Text(
                                          item["quantity"].toString(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green),
                                          onPressed: () {
                                            setState(() {
                                              widget.updateQuantity(
                                                  index, item["quantity"] + 1);
                                            });
                                          },
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.black45),
                                          onPressed: () {
                                            setState(() {
                                              widget.removeFromCart(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Order Summary
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order Summary",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        summaryRow("Items (${widget.cartItems.length}):",
                            "\$${totalBeforeTax.toStringAsFixed(2)}"),
                        summaryRow("Total before tax:",
                            "\$${totalBeforeTax.toStringAsFixed(2)}"),
                        summaryRow("Estimated tax (10%):",
                            "\$${estimatedTax.toStringAsFixed(2)}"),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Order total:",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              Text("\$${orderTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () async {
                              await placeOrder();
                            },

                            child: const Text("Place your order",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper function to create summary rows
  Widget summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
