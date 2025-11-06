import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homehub/pages/HomeScreen/home_banner.dart';
import 'package:homehub/pages/Users/user_profile.dart';
import '../Cart/cart_page.dart';
import '../notification_page.dart';
import '../ProductScreen/product_display.dart';
import '../ProductScreen/product_details.dart';
import '../HomeScreen/categoriespage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode searchFocusNode = FocusNode();
  String selectedCategory = "All";
  bool isSearching = false;
  bool isFooterVisible = false;
  List<String> allSubcategories = [];
  List<String> filteredSubcategories = ["All"];
  List<Map<String, dynamic>> cartItems = [];
  bool showBanner = true;
  List<Map<String, dynamic>> recentlyViewed = [];
  List<Map<String, dynamic>> recommendedProducts = [];
  bool isLoadingRecommendations = true;
  bool hasNewNotification = true;

  @override
  void initState() {
    super.initState();
    fetchSubcategories();
    fetchRecentlyViewed();
    fetchRecommendedProducts();

    searchFocusNode.addListener(() {
      setState(() {
        isSearching = searchFocusNode.hasFocus;
      });
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 10) {
        if (!isFooterVisible) {
          setState(() {
            isFooterVisible = true;
          });
        }
      } else {
        if (isFooterVisible) {
          setState(() {
            isFooterVisible = false;
          });
        }
      }

      if (scrollController.position.pixels > 50) {
        if (showBanner) {
          setState(() {
            showBanner = false;
          });
        }
      } else {
        if (!showBanner) {
          setState(() {
            showBanner = true;
          });
        }
      }
    });
  }

  Future<void> fetchRecommendedProducts() async {
    try {
      setState(() => isLoadingRecommendations = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get recently viewed categories
      final recentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("recently_viewed")
          .orderBy("viewedAt", descending: true)
          .limit(10)
          .get();

      final recentCategories = recentSnapshot.docs
          .map((doc) => (doc.data()["subcategory"] ?? "").toString().trim())
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();

      print("Recent Categories: $recentCategories");

      if (recentCategories.isEmpty) {
        // If no recent views, use some default categories
        recentCategories.addAll(["chairs", "tables", "sofas"]);
      }

      // First try to get recommendations from the same categories
      QuerySnapshot recommendedSnapshot = await FirebaseFirestore.instance
          .collection("products")
          .where("subcategory", whereIn: recentCategories)
          .limit(10)
          .get();

      // If no results, try a broader search
      if (recommendedSnapshot.docs.isEmpty) {
        print(
            "No recommendations found in exact categories, trying broader search");
        recommendedSnapshot = await FirebaseFirestore.instance
            .collection("products")
            .limit(10)
            .get();
      }

      setState(() {
        recommendedProducts = recommendedSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'imageUrl': data['image_url'] ?? '',
            'name': data['product_name'] ?? 'No name',
            'price': data['price']?.toString() ?? '0',
            'id': doc.id,
            // Include any other fields needed for ProductDetailsPage
            ...data, // Spread the rest of the data
          };
        }).toList();
        isLoadingRecommendations = false;
      });

      print("Fetched ${recommendedProducts.length} recommendations");
    } catch (e) {
      print("Error fetching recommendations: $e");
      setState(() => isLoadingRecommendations = false);
    }
  }

  Future<void> fetchSubcategories() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection("products")
        .where("subcategory", isNotEqualTo: null)
        .get();

    Set<String> subcategories = {"All"};

    for (var doc in querySnapshot.docs) {
      String? subcategory = doc.data()["subcategory"];
      if (subcategory != null && subcategory.isNotEmpty) {
        subcategories.add(subcategory);
      }
    }

    setState(() {
      allSubcategories = subcategories.toList();
      filteredSubcategories = List.from(allSubcategories);
    });
  }

  Future<void> fetchRecentlyViewed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("recently_viewed")
        .orderBy("viewedAt", descending: true)
        .limit(5)
        .get();

    setState(() {
      recentlyViewed = snapshot.docs.map((doc) {
        final data = doc.data();
        data["docId"] = doc.id;
        return data;
      }).toList();
    });

    print("Recently Viewed Count: ${recentlyViewed.length}");
  }

  Future<void> removeRecentlyViewed(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("recently_viewed")
        .doc(docId)
        .delete();

    fetchRecentlyViewed();
  }

  void filterSubcategories(String query) {
    setState(() {
      filteredSubcategories = query.isEmpty
          ? List.from(allSubcategories)
          : allSubcategories
              .where((subcategory) =>
                  subcategory.toLowerCase().contains(query.toLowerCase()))
              .toList();

      selectedCategory = filteredSubcategories.isNotEmpty
          ? filteredSubcategories.first
          : "All";
    });
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      String uniqueId =
          "${item["id"]}_${DateTime.now().millisecondsSinceEpoch}";

      int existingIndex =
          cartItems.indexWhere((cartItem) => cartItem["uniqueId"] == uniqueId);

      if (existingIndex != -1) {
        cartItems[existingIndex]["quantity"] += 1;
      } else {
        cartItems.add({...item, "uniqueId": uniqueId, "quantity": 1});
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Item added to cart",
                style: TextStyle(color: Colors.white, fontSize: 14)),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      cartItems: cartItems,
                      removeFromCart: removeFromCart,
                      updateQuantity: updateQuantity,
                      clearCart: () {
                        setState(() {
                          cartItems.clear();
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                "GO TO CART",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void updateQuantity(int index, int newQuantity) {
    setState(() {
      cartItems[index]["quantity"] = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Furniture Hub",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey)),
        backgroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.blueGrey),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => CartPage(
                            cartItems: cartItems,
                            removeFromCart: removeFromCart,
                            updateQuantity: updateQuantity,
                            clearCart: () {
                              setState(() {
                                cartItems.clear();
                              });
                            },
                          ),
                        ),
                      )
                      .then((_) => setState(() {}));
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      cartItems.length.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.blueGrey),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationPage(
                      
                    )),
                  );
                  setState(() {
                    hasNewNotification = false; // Hide red dot after viewing
                  });
                },
              ),
              if (hasNewNotification)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blueGrey),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              decoration: InputDecoration(
                hintText: "Search for furniture...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            isSearching = false;
                            searchFocusNode.unfocus();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) => filterSubcategories(value),
            ),
          ),
          const SizedBox(height: 8),
          if (isSearching)
            Expanded(
              child: ProductDisplayPage(
                scrollController: scrollController,
                selectedCategory: selectedCategory,
                searchController: searchController,
                addToCart: addToCart,
                limit: 0,
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (showBanner)
                      SizedBox(
                        height: 200,
                        child: HomeBanner(
                          scrollController: scrollController,
                          searchController: searchController,
                          selectedCategory: selectedCategory,
                          addToCart: addToCart,
                          limit: 0,
                        ),
                      ),
                    if (recentlyViewed.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Recently Viewed",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentlyViewed.length,
                                itemBuilder: (context, index) {
                                  var product = recentlyViewed[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsPage(
                                            productData: product,
                                            addToCart: addToCart,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 120,
                                      child: Stack(
                                        children: [
                                          Card(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.network(
                                                  product["image_url"] ?? "",
                                                  width: 100,
                                                  height: 70,
                                                  fit: BoxFit.fill,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const Icon(
                                                          Icons.broken_image),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    product["product_name"] ??
                                                        "No name",
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  size: 18,
                                                  color: Colors.redAccent),
                                              onPressed: () {
                                                removeRecentlyViewed(
                                                    product["docId"]);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    if (isLoadingRecommendations)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      )
                    else if (recommendedProducts.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Recommended for You",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedProducts.length,
                              itemBuilder: (context, index) {
                                final product = recommendedProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailsPage(
                                          productData: product,
                                          addToCart: addToCart,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            product['imageUrl'] ?? '',
                                            height: 120,
                                            width: 160,
                                            fit: BoxFit.fill,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              height: 120,
                                              width: 100,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                  Icons.image_not_supported),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product['name'] ?? 'Unnamed Product',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          "\$${product['price']?.toString() ?? '0'}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "No recommendations available",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Browse more products to get personalized recommendations",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: "Categories"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    CategoriesPage(cartItems: cartItems, addToCart: addToCart),
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CartPage(
                  cartItems: cartItems,
                  removeFromCart: removeFromCart,
                  updateQuantity: updateQuantity,
                  clearCart: () {
                    setState(() {
                      cartItems.clear();
                    });
                  },
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserProfile()),
            );
          }
        },
      ),
    );
  }
}
