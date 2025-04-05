import 'package:flutter/material.dart';
import 'package:peepal/features/favourites/repository/favourites_repository.dart';
import 'package:peepal/shared/toilet/model/toilet.dart';
import 'package:peepal/features/favourites/widget/toilet_card.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesState();
}

class _FavouritesState extends State<FavouritesPage> {
  final FavouritesRespository _repository = MockFavouritesRepository(); // Use the concrete implementation
  late Future<List<PPToilet>> _favouriteToilets;

  @override
  void initState() {
    super.initState();
    _favouriteToilets = _fetchFavourites();
  }

  Future<List<PPToilet>> _fetchFavourites() async {
    final collection = await _repository.getFavourites();
    return collection.toilets; // Assuming `PPToiletCollection` has a `toilets` property
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Favorites"),
      ),
      body: FutureBuilder<List<PPToilet>>(
        future: _favouriteToilets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching saved toilets"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No saved toilets found"));
          }

          final toilets = snapshot.data!;
          return ListView.builder(
            itemCount: toilets.length,
            itemBuilder: (context, index) {
              return ToiletCard(toilet: toilets[index]);
            },
          );
        },
      ),
    );
  }
}

