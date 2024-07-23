// ignore_for_file: empty_catches, unused_local_variable

import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/PlaceLister/PlaceCard.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClickableCardsScreen extends StatefulWidget {
  const ClickableCardsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClickableCardsScreenState createState() => _ClickableCardsScreenState();
}

class _ClickableCardsScreenState extends State<ClickableCardsScreen> {
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _cardData;
  int _currentPage = 1;
  final int _itemsPerPage = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cardData = [];

    // Initial data load
    _loadCardData(_currentPage);

    // Listen to the scroll controller for scroll events
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadCardData(int page) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch new data and update the state
      final List<Map<String, dynamic>> newData =
          await loadCardData(page, _itemsPerPage);

      setState(() {
        _cardData.addAll(newData);
        _currentPage = page;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.0) {
      // Load more data when reaching the end with a threshold of 200.0 pixels
      _loadCardData(_currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 25.0, left: 20.0, right: 20.0),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true, // Keeps the header pinned at the top
                delegate: SearchBar(
                  minExtent: 60.0,
                  maxExtent: 60.0,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderText('Recommendation'),
                        SizedBox(height: 15.0),
                      ],
                    );
                  },
                  childCount: 1,
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _cardData.length) {
                      return _buildLoadingIndicator();
                    } else {
                      return PlaceCard(
                        cardData: _cardData[index],
                        index: index,
                        context: context,
                      );
                    }
                  },
                  childCount:
                      _cardData.length + 1, // +1 for the loading indicator
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<List<Map<String, dynamic>>> loadCardData(
      int page, int itemsPerPage) async {
    // Declare an array to store preferences values
    List<String> preferencesArray = [];

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Get the user's details document reference
        DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('user-details')
            .doc(currentUser.uid);

        // Get the user's details document snapshot
        DocumentSnapshot userDocSnapshot = await userDocRef.get();

        if (userDocSnapshot.exists) {
          // Document exists, retrieve data
          Map<String, dynamic>? userData =
              userDocSnapshot.data() as Map<String, dynamic>?;

          if (userData != null && userData.containsKey('preferences')) {
            // Get the 'preferences' array as List<String>
            List<String> preferences =
                List<String>.from(userData['preferences']);

            // Process the preferences array
            for (var preference in preferences) {
              // Your logic to handle each preference

              // Store preference in the array
              preferencesArray.add(preference);
            }

            // Now preferencesArray contains all preferences values
          }
        } else {}
      }
    } catch (error) {}

    final String jsonString =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    // Shuffle the jsonList for each set of preferences
    jsonList.shuffle();

    // Initialize the list to store the final result
    List<Map<String, dynamic>> resultList = [];

    // Loop through each preference and get 5 items for each
    for (String preference in preferencesArray) {
      // Filter jsonList based on the current preference
      List<Map<String, dynamic>> filteredList = jsonList
          .where((item) =>
              item.containsKey('preferences') &&
              item['preferences'] == preference)
          .cast<Map<String, dynamic>>()
          .toList();

      // Shuffle the filteredList for each set of preferences
      filteredList.shuffle();

      // Calculate the starting index and ending index based on the page number and items per page
      int startIndex = (page - 1) * itemsPerPage;
      int endIndex = startIndex + itemsPerPage;

      // Take the items within the specified range
      List<Map<String, dynamic>> limitedList =
          filteredList.skip(startIndex).take(itemsPerPage).toList();

      // Add the limitedList to the final result
      resultList.addAll(limitedList);
      resultList.shuffle();
    }

    return resultList;
  }
}

class SearchBar extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;

  SearchBar({
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 60,
      color: AppColors.accentWhiteColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.accentWhiteColor,
          border: Border.all(
            color: AppColors.accentDarkGreenColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                child:
                    const BoldNormalText("Search", AppColors.accentBlackColor),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.accentDarkGreenColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: const Center(
                  child: Icon(
                    Icons.search,
                    color: AppColors.accentWhiteColor,
                    size: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
