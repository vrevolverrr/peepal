import 'package:flutter/material.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

class ToiletSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(PPToilet)? onLocationSelected;

  const ToiletSearchBar({
    Key? key,
    this.onSearch,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<ToiletSearchBar> createState() => _ToiletSearchBarState();
}

class _ToiletSearchBarState extends State<ToiletSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<PPToilet> _filteredLocations = [];
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLocations = [];
        _showResults = false;
      });
      return;
    }

    final filtered = _filteredLocations.where((location) {
      final name = location.name.toLowerCase();
      final address = location.address.toLowerCase();
      return name.contains(query) || address.contains(query);
    }).toList();

    setState(() {
      _filteredLocations = filtered;
      _showResults = true;
    });

    if (widget.onSearch != null) {
      widget.onSearch!(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SearchBar(
                controller: _searchController,
                backgroundColor: const MaterialStatePropertyAll(Colors.white),
                padding: const MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20.0)),
                leading: const SizedBox(width: 12.0, child: Icon(Icons.search)),
                hintText: "Search for toilets",
                hintStyle: const MaterialStatePropertyAll(
                    TextStyle(fontSize: 16.0, color: Color(0xFF5C5C5C))),
                onChanged: _filterLocations,
              ),
            ),
          ),
          if (_showResults && _filteredLocations.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxHeight: 200, // Limit the height of the dropdown
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredLocations.length,
                itemBuilder: (context, index) {
                  final location = _filteredLocations[index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.address),
                    dense: true,
                    trailing: location.rating != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text('${location.rating}'),
                            ],
                          )
                        : null,
                    onTap: () {
                      // Clear search and hide results
                      _searchController.clear();
                      setState(() {
                        _showResults = false;
                      });

                      // Notify parent about selection
                      if (widget.onLocationSelected != null) {
                        widget.onLocationSelected!(location);
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
