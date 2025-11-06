import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderManager {
  static Future<void> saveOrder(List<String> productIds) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ Error: No authenticated user");
        return;
      }

      if (productIds.isEmpty) {
        print("❌ Error: Empty product list");
        return;
      }

      DocumentReference userRef = FirebaseFirestore.instance.collection("user_interactions").doc(user.uid);

      await userRef.set({
        "purchased_products": FieldValue.arrayUnion(productIds),
        "last_updated": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Order saved successfully: $productIds");
    } catch (e) {
      print("❌ Error saving order: $e");
    }
  }
}



