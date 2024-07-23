// ignore: file_names
import 'package:flutter/material.dart';
import 'package:lakbay/api/getters.dart';

class TravelBudgetListScreen extends StatefulWidget {
  final String travelPlanId;
  const TravelBudgetListScreen({super.key, required this.travelPlanId});

  @override
  // ignore: library_private_types_in_public_api
  _TravelBudgetListScreenState createState() => _TravelBudgetListScreenState();
}

class _TravelBudgetListScreenState extends State<TravelBudgetListScreen> {
  late String travelPlanId; // Declare with 'late'

  List<Map<String, List<PackingItem>>> packingLists = [];
  TextEditingController categoryController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    print("budget-list ${widget.travelPlanId}"); // Print the travel plan ID
    travelPlanId = widget.travelPlanId;
    super.initState();
  }

  void _showAddItemDialog(BuildContext context, String defaultCategory) {
    String enteredCategory = defaultCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'List Name',
                  ),
                  onChanged: (value) {
                    enteredCategory = value;
                  },
                ),
                const SizedBox(height: 8.0), // Adjusted spacing
                TextField(
                  controller: itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                  ),
                ),
                const SizedBox(height: 8.0), // Adjusted spacing
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0), // Adjusted padding
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addToPackingList(enteredCategory);
                Navigator.of(context).pop();
              },
              child: const Text('Add to List'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveListDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove List'),
          content:
              Text('Are you sure you want to remove the list "$category"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                removePackingList(category);
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveItemDialog(
      BuildContext context, String category, PackingItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text(
              'Are you sure you want to remove the item "${item.name}" from the list "$category"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                removePackingItem(category, item);
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Generate a unique identifier for the "General" list
                categoryController.text = '';
                itemController.text = '';
                priceController.text = '';

                _showAddItemDialog(context, categoryController.text);
              },
              child: const Text('Add List'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: packingLists.length,
                itemBuilder: (context, index) {
                  var packingList = packingLists[index];

                  var category = packingList.keys.first;
                  var items = packingList[category];

                  // Generate a lighter color based on the category
                  Color listColor = Colors
                      .primaries[index % Colors.primaries.length]
                      .withOpacity(0.3); // Adjust opacity as needed

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      tileColor: listColor,
                      title: Text(category),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items!
                            .map((item) => Row(
                                  children: [
                                    Checkbox(
                                      value: item.isChecked,
                                      onChanged: (value) {
                                        setState(() {
                                          item.isChecked = value!;
                                        });
                                      },
                                    ),
                                    Text(
                                        '- ${item.name} (${item.priceString} \$)'),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_forever_sharp),
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red)),
                                      onPressed: () {
                                        _showRemoveItemDialog(
                                            context, category, item);
                                      },
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                      onTap: () {
                        // When a list is tapped, show a dialog to add items to it
                        _showAddItemDialog(context, category);
                      },
                      onLongPress: () {
                        // When a list is long-pressed, show a dialog to remove it
                        _showRemoveListDialog(context, category);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showRemoveListDialog(context, category);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addToPackingList(String category) {
    String itemName = itemController.text;
    double itemPrice = double.tryParse(priceController.text) ?? 0.0;

    if (itemName.isNotEmpty) {
      setState(() {
        // Find the index of the selected category
        var existingCategoryIndex =
            packingLists.indexWhere((list) => list.keys.first == category);

        if (existingCategoryIndex != -1) {
          // If category exists, add the item to the existing category
          packingLists[existingCategoryIndex][category]!.add(PackingItem(
              name: itemName,
              price: itemPrice,
              priceString: itemPrice.toString()));
        } else {
          // If category does not exist, create a new category
          packingLists.add({
            category: [
              PackingItem(
                  name: itemName,
                  price: itemPrice,
                  priceString: itemPrice.toString())
            ]
          });
        }
      });

      // Clear text fields after adding to the list
      itemController.clear();
      priceController.clear();
    }
  }

  Future<void> initializePackingLists(travelPlanId) async {
    Getters databaseService = Getters();
    print('Initializing packing list...');
    print('Travel plan ID: $travelPlanId');

    try {
      // Fetch budget data
      Map<String, dynamic> budgetData =
          await databaseService.getBudgetData(travelPlanId);

      if (budgetData.containsKey('selectedPlaces')) {
        List<String> selectedPlaces =
            List<String>.from(budgetData['selectedPlaces']);

        // Create a list to hold items for the single category
        List<PackingItem> items = [];

        // Add items for each selected place with default values
        for (String place in selectedPlaces) {
          items.add(PackingItem(
            name: place,
            price: 0,
            isChecked: false,
            priceString: 'Medium', // Use 'Medium' as the default value
          ));
        }

        // Set the single category with items using setState
        setState(() {
          packingLists = [
            {'Place Budget': items}
          ];
        });

        print(packingLists);
      }
    } catch (error) {
      print('Error initializing packing list: $error');
    }
  }

  void removePackingList(String category) {
    setState(() {
      packingLists.removeWhere((list) => list.keys.first == category);
    });
  }

  void removePackingItem(String category, PackingItem item) {
    setState(() {
      for (var list in packingLists) {
        if (list.keys.first == category) {
          list[category]?.remove(item);
        }
      }
    });
  }
}

class PackingItem {
  final String name;
  final double price; // Keep the double representation
  final String priceString; // Keep the string representation
  bool isChecked;

  PackingItem({
    required this.name,
    required this.price,
    required this.priceString,
    this.isChecked = false,
  });
}
