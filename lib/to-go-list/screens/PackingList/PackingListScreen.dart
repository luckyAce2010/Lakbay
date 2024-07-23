import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/to-go-list/screens/PackingList/SuggestionList.dart';

class PackingListScreen extends StatefulWidget {
  final String travelPlanId;

  const PackingListScreen({super.key, required this.travelPlanId});

  @override
  // ignore: library_private_types_in_public_api
  _PackingListScreenState createState() =>
      _PackingListScreenState(travelPlanId: travelPlanId);
}

class _PackingListScreenState extends State<PackingListScreen> {
  final String travelPlanId;

  late String userId;

  List<Category> categories = [];

  _PackingListScreenState({required this.travelPlanId});

  @override
  void initState() {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        userId = currentUser.uid;
      }
      // ignore: empty_catches
    } catch (error) {}

    _loadData();

    super.initState();
  }

  Future<void> _loadData() async {
    List<Category> loadedCategories =
        await FirestoreService(userId: userId, travelPlanId: travelPlanId)
            .getCategories();

    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SuggestionList(travelPlanId: travelPlanId),
                const SizedBox(
                  height: 15.0,
                ),
                Column(
                  children: List.generate(
                    categories.length,
                    (index) => Column(
                      children: [
                        CategoryWidget(
                            categories[index],
                            () => _addItem(context, categories[index], userId,
                                travelPlanId)),
                        const SizedBox(
                            height: 15.0), // Adjust the height as needed
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextButton(
                          onPressed: () =>
                              _addCategory(context, userId, travelPlanId),
                          child: const Text(
                            'Add a Category',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF929292),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  String categoryName = '';
  String selectedCategory = 'Transportation'; // Set a default value
  void _addCategory(
      BuildContext context, String userId, String travelPlanId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add a dropdown for category selection
              DropdownButton<String>(
                hint: const Text('Select category'),
                value: selectedCategory,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                      categoryName =
                          value; // Set category name based on selection
                      print(categoryName);
                    });

                    // Close the current dialog
                    Navigator.of(context).pop();

                    // Open the dialog again
                    _addCategory(context, userId, travelPlanId);
                  }
                },
                items: ['Transportation', 'Food', 'Accommodation']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16), // Add some spacing
              // Add a text field for entering custom category name
              TextField(
                onChanged: (value) {
                  categoryName = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter custom category name (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (categoryName.isNotEmpty || selectedCategory.isNotEmpty) {
                  Navigator.pop(
                      context,
                      categoryName.isNotEmpty
                          ? categoryName
                          : selectedCategory);
                  Category newCategory = Category(
                      name: categoryName.isNotEmpty
                          ? categoryName
                          : selectedCategory,
                      items: []);
                  DocumentReference categoryRef = await FirestoreService(
                          userId: userId, travelPlanId: travelPlanId)
                      .addCategory(newCategory);

                  setState(() {
                    newCategory.id = categoryRef.id;
                    categories.add(newCategory);
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addItem(BuildContext context, Category category, String userId,
      String travelPlanId) async {
    String itemName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Item to ${category.name}'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) => itemName = value,
                decoration: const InputDecoration(hintText: 'Enter item name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (itemName.isNotEmpty) {
                  Navigator.pop(context);
                  Item newItem = Item(
                    name: itemName,
                    categoryId: category.id ??
                        '', // Use empty string if category.id is null
                  );
                  setState(() {
                    category.items.add(newItem);
                  });
                  await FirestoreService(
                          userId: userId, travelPlanId: travelPlanId)
                      .addItem(category, newItem);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Category {
  String? id; // Change to String?

  final String name;
  final List<Item> items;

  Category({this.id, required this.name, required this.items});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class Item {
  final String name;
  final String categoryId;

  Item({required this.name, required this.categoryId});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
    };
  }
}

class CategoryWidget extends StatelessWidget {
  final Category category;
  final VoidCallback onAddItem;

  const CategoryWidget(this.category, this.onAddItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 25.0,
      ),
      decoration: BoxDecoration(
          color: AppColors.accentSmokeGreenColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: AppColors.accentLightGreenColor,
            width: 2.0,
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColumnsTitleText(category.name, AppColors.accentBlackColor),
          const SizedBox(
            height: 10.0,
          ),
          if (category.items.isNotEmpty)
            Column(
              children: category.items.map((item) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BoldNormalText(item.name, AppColors.accentBlackColor),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                  ],
                );
              }).toList(),
            ),
          Center(
            child: TextButton(
              onPressed: onAddItem,
              child: const Text('Add an Item',
                  style: TextStyle(
                    color: AppColors.accentBlackColor,
                    decoration: TextDecoration.underline,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class FirestoreService {
  final String userId;
  final String travelPlanId;

  FirestoreService({required this.userId, required this.travelPlanId});

  CollectionReference get categoriesCollection => FirebaseFirestore.instance
      .collection('packing-list')
      .doc(userId)
      .collection(travelPlanId);

  Future<DocumentReference> addCategory(Category category) {
    return categoriesCollection.add(category.toMap()).then((documentRef) {
      documentRef.update({'id': documentRef.id});
      return documentRef;
    });
  }

  Future<void> addItem(Category category, Item item) {
    return categoriesCollection.doc(category.id).update({
      'items': FieldValue.arrayUnion([item.toMap()])
    });
  }

  Future<List<Category>> getCategories() async {
    QuerySnapshot querySnapshot = await categoriesCollection.get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Category(
        id: doc.id,
        name: data['name'],
        items: (data['items'] as List<dynamic>).map((itemData) {
          return Item(
            name: itemData['name'],
            categoryId: doc.id,
          );
        }).toList(),
      );
    }).toList();
  }
}
