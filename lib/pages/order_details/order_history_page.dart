
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.blue,
      ),
      body: user == null
          ? const Center(child: Text("Please log in to see your order history."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user!.uid)
                  // .orderBy('orderDate', descending: true) // Uncomment if orderDate exists
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No orders found."));
                }

                var orders = snapshot.data!.docs;
                print("Fetched orders: ${orders.map((e) => e.data()).toList()}");

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    var orderData = order.data() as Map<String, dynamic>;
                    
                    // Ensure items list is properly extracted
                    var items = orderData['items'] != null 
                      ? List<Map<String, dynamic>>.from(orderData['items']) 
                      : [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order ID: ${orderData['orderId'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Date: ${orderData['orderDate'] ?? 'Unknown'}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Divider(),
                            Column(
                              children: items.map((item) {
                                return ListTile(
                                  leading: item["image"] != null
                                      ? Image.network(
                                          item["image"],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                        )
                                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  title: Text(item["name"] ?? "Unknown Item"),
                                  subtitle: Text("Quantity: ${item["quantity"] ?? 'N/A'}"),
                                  trailing: Text("\$${(item["price"] ?? 0 * (item["quantity"] ?? 1)).toStringAsFixed(2)}"),
                                );
                              }).toList(),
                            ),
                            const Divider(),
                            Text(
                              "Total: \$${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            Text(
                              "Status: ${orderData['status'] ?? 'Unknown'}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: orderData['status'] == 'Processing' ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
