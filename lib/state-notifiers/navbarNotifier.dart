// ignore: file_names
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navbarStateNotifierProvider =
    StateNotifierProvider<NavbarStateNotifier, int>((ref) {
  return NavbarStateNotifier();
});

class NavbarStateNotifier extends StateNotifier<int> {
  NavbarStateNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}
