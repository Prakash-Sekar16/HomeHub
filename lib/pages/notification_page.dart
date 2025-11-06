import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../pages/ProductScreen/product_details.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, String>> notifications = [];
  Timer? refreshTimer;
  bool hasNewNotification = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    refreshTimer = Timer.periodic(Duration(seconds: 5), (_) => loadNotifications());
  }
  
  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    final stored = await NotificationService.getNotifications();
    final newList = stored.reversed.toList();

    if (newList.length != notifications.length && newList.isNotEmpty) {
      setState(() {
        hasNewNotification = true;
        notifications = newList;
      });
    } else {
      setState(() {
        hasNewNotification = false;
        notifications = newList;
      });
    }
  }

  Future<void> clearNotifications() async {
    await NotificationService.clearAllNotifications();
    setState(() {
      notifications.clear();
      hasNewNotification = false;
    });
  }

  void onNotificationTap(String productId) async {
    print("Tapped productId: $productId"); // Debug log

    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product ID is missing!")),
      );
      return;
    }

    try {
      var productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data()!;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productData: productData,
              addToCart: (Map<String, dynamic> product) {
                // Implement your addToCart logic here
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product not found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading product: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          if (hasNewNotification)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(Icons.fiber_new, color: Colors.red),
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: clearNotifications,
              tooltip: 'Clear all',
            )
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text("No notifications yet."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isNew = index == 0 && hasNewNotification;

                return Card(
                  color: isNew ? Colors.blue.shade50 : null,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.notifications_active, color: Colors.blue),
                    title: Text(
                      notif['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isNew ? Colors.blueAccent : null,
                      ),
                    ),
                    subtitle: Text(notif['body'] ?? ''),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      final productId = notif['productId'] ?? '';
                      if (productId.isNotEmpty) {
                        onNotificationTap(productId);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("This notification has no product ID.")),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/notification_service.dart';
// import '../pages/ProductScreen/product_details.dart';

// class NotificationPage extends StatefulWidget {
//   final Function(bool hasNotifications) onViewed;

//   NotificationPage({required this.onViewed});

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   List<Map<String, String>> notifications = [];
//   Timer? refreshTimer;
//   bool hasNewNotification = false;

//   @override
//   void initState() {
//     super.initState();
//     loadNotifications();
//     refreshTimer = Timer.periodic(Duration(seconds: 5), (_) => loadNotifications());
//   }

//   @override
//   void dispose() {
//     refreshTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> loadNotifications() async {
//     final stored = await NotificationService.getNotifications();
//     final newList = stored.reversed.toList();

//     final isNew = newList.length != notifications.length;

//     setState(() {
//       notifications = newList;
//       hasNewNotification = isNew;
//     });

//     // After viewing notifications, we hide the red dot
//     widget.onViewed(false);
//   }

//   Future<void> clearNotifications() async {
//     await NotificationService.clearAllNotifications();
//     setState(() {
//       notifications.clear();
//       hasNewNotification = false;
//     });

//     // Notify parent there are no notifications left
//     widget.onViewed(false);
//   }

//   void onNotificationTap(String productId) async {
//     if (productId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Product ID is missing!")),
//       );
//       return;
//     }

//     try {
//       var productSnapshot = await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .get();

//       if (productSnapshot.exists) {
//         Map<String, dynamic> productData = productSnapshot.data()!;

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailsPage(
//               productData: productData,
//               addToCart: (Map<String, dynamic> product) {
//                 // Your add-to-cart logic
//               },
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Product not found!")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error loading product: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//         actions: [
//           if (hasNewNotification)
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0),
//               child: Icon(Icons.fiber_new, color: Colors.red),
//             ),
//           if (notifications.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.delete_forever),
//               onPressed: clearNotifications,
//               tooltip: 'Clear all',
//             ),
//         ],
//       ),
//       body: notifications.isEmpty
//           ? Center(child: Text("No notifications yet."))
//           : ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notif = notifications[index];
//                 final isNew = index == 0 && hasNewNotification;

//                 return Card(
//                   color: isNew ? Colors.blue.shade50 : null,
//                   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   child: ListTile(
//                     leading: Icon(Icons.notifications_active, color: Colors.blue),
//                     title: Text(
//                       notif['title'] ?? '',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: isNew ? Colors.blueAccent : null,
//                       ),
//                     ),
//                     subtitle: Text(notif['body'] ?? ''),
//                     trailing: Icon(Icons.arrow_forward_ios, size: 14),
//                     onTap: () {
//                       final productId = notif['productId'] ?? '';
//                       onNotificationTap(productId);
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
