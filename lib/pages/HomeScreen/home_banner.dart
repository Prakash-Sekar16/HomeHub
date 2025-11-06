import 'package:flutter/material.dart';
import '../ProductScreen/product_display.dart';

class HomeBanner extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;
  final String selectedCategory;
  final Function(Map<String, dynamic>) addToCart;
  final int limit;  // Fix: Pass addToCart

  const HomeBanner({
    super.key,
    required this.scrollController,
    required this.searchController,
    required this.selectedCategory,
    required this.addToCart, 
    required this.limit, // Fix: Mark addToCart as required
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Explore our\nfuriniz\nmerchandise",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Furiniz shop offers all kinds of home living products for your comfortable living.",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDisplayPage(
                          selectedCategory: "All",
                          searchController: searchController,
                          scrollController: ScrollController(),
                          addToCart: addToCart,
                          limit: 50,  // Fix: Pass addToCart
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  child: const Text("Shop Now",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: const DecorationImage(
                image: AssetImage("images/homebanner.jpg"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
