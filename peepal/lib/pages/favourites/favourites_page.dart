import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/favorites/model/favorite.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';
import 'package:peepal/pages/favourites/widget/favorites_card.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesState();
}

class _FavouritesState extends State<FavouritesPage> {
  @override
  void initState() {
    context.read<FavoritesCubit>().loadFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Toilets'),
      ),
      body: SafeArea(child: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesStateLoading ||
              state is FavoritesStateInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is FavoritesStateError) {
            return const Center(
              child: Text(
                "Error fetching saved toilets",
              ),
            );
          }

          final List<PPFavorite> favorites =
              (state as FavoritesStateLoaded).favorites;
          favorites.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return ToiletCard(toilet: favorites[index].toilet);
            },
          );
        },
      )),
    );
  }
}
