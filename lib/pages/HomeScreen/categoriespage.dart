import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ProductScreen/product_display.dart';

class CategoriesPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) addToCart;

  const CategoriesPage({
    super.key,
    required this.cartItems,
    required this.addToCart,
  });

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> subcategories = [];
  String selectedSubcategory = "All";
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSubcategories();
  }

  /// Fetch unique subcategories from Firestore
  Future<void> fetchSubcategories() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection("products").get();

    Set<String> subcategorySet = {"All"};

    for (var doc in querySnapshot.docs) {
      String? subcategory = doc.data()["subcategory"];
      if (subcategory != null && subcategory.isNotEmpty) {
        subcategorySet.add(subcategory);
      }
    }

    setState(() {
      subcategories = subcategorySet.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                String category = subcategories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedSubcategory == category,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          selectedSubcategory = category;
                        });
                      }
                    },
                    selectedColor: Colors.blueAccent,
                    backgroundColor: Colors.grey[300],
                    labelStyle: TextStyle(
                      color: selectedSubcategory == category ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // Expanded widget ensures product list takes up remaining space
          Expanded(
            child: ProductDisplayPage(
              selectedCategory: selectedSubcategory,
              searchController: searchController,
              scrollController: scrollController,
              addToCart: widget.addToCart, // Use shared addToCart function
              limit: 0,
            ),
          ),
        ],
      ),
    );
  }
}
