// ignore: file_names
// ignore_for_file: empty_catches, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/to-go-list/screens/BudgetList/LocationPrice.dart';

class BudgetListScreen extends StatefulWidget {
  final String travelPlanId;
  const BudgetListScreen({super.key, required this.travelPlanId});

  @override
  State<BudgetListScreen> createState() =>
      _BudgetListScreenState(travelPlanId: travelPlanId);
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  final String travelPlanId;

  late String userId;

  List<Category> categories = [];

  _BudgetListScreenState({required this.travelPlanId});

  @override
  void initState() {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        userId = currentUser.uid;
      }
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
            LocationPrice(travelPlanId: travelPlanId),
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
                        () => _addItem(
                            context, categories[index], userId, travelPlanId)),
                    const SizedBox(height: 15.0), // Adjust the height as needed
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
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory(
      BuildContext context, String userId, String travelPlanId) async {
    String categoryName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            onChanged: (value) {
              categoryName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter category name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (categoryName.isNotEmpty) {
                  Navigator.pop(context, categoryName);
                  Category newCategory =
                      Category(name: categoryName, items: []);
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
    String itemValue = '';

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
              TextField(
                onChanged: (value) => itemValue = value,
                decoration: const InputDecoration(hintText: 'Enter item value'),
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
                if (itemName.isNotEmpty && itemValue.isNotEmpty) {
                  Navigator.pop(context);
                  Item newItem = Item(
                    name: itemName,
                    value: itemValue,
                    categoryId: category.id.toString() ??
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
  final String value;
  final String categoryId;

  Item({required this.name, required this.value, required this.categoryId});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
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
                        BoldNormalText(
                            'P${item.value}', AppColors.accentBlackColor),
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
      .collection('budget-planner')
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
            value: itemData['value'],
            categoryId: doc.id,
          );
        }).toList(),
      );
    }).toList();
  }
}
