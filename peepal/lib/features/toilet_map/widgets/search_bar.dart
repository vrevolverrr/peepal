import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToiletSearchBar extends StatefulWidget {
  const ToiletSearchBar({
    super.key,
  });

  @override
  State<ToiletSearchBar> createState() => _ToiletSearchBarState();
}

class _ToiletSearchBarState extends State<ToiletSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SearchBar(
              padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 15.0)),
              hintText: "Search Toilets",
              leading: Icon(Icons.search, size: 24.0),
              onChanged: (value) {},
            )));
  }
}
