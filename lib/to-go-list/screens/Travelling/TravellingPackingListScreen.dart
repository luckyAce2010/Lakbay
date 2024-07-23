// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class TravellingPackingListScreen extends StatefulWidget {
  const TravellingPackingListScreen({super.key, required String travelPlanId});

  @override
  _TravellingPackingListScreenState createState() =>
      _TravellingPackingListScreenState();
}

class _TravellingPackingListScreenState
    extends State<TravellingPackingListScreen> {
  List<Map<String, List<PackingItem>>> packingLists = [];

  TextEditingController categoryController = TextEditingController();
  TextEditingController itemController = TextEditingController();

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
                const SizedBox(height: 8.0),
                TextField(
                  controller: itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
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
      appBar: AppBar(title: const Text('Packing List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                categoryController.text = '';
                itemController.text = '';
                _showAddItemDialog(context, '');
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

                  Color listColor = Colors
                      .primaries[index % Colors.primaries.length]
                      .withOpacity(0.3);

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
                                    Text('- ${item.name}'),
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
                        _showAddItemDialog(context, category);
                      },
                      onLongPress: () {
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

    if (itemName.isNotEmpty) {
      setState(() {
        var existingCategoryIndex =
            packingLists.indexWhere((list) => list.keys.first == category);

        if (existingCategoryIndex != -1) {
          packingLists[existingCategoryIndex][category]!
              .add(PackingItem(name: itemName));
        } else {
          packingLists.add({
            category: [PackingItem(name: itemName)]
          });
        }
      });

      itemController.clear();
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
  bool isChecked;

  PackingItem({required this.name, this.isChecked = false});
}
