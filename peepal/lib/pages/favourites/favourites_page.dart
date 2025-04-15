import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';
import 'package:peepal/pages/favourites/widget/favorite_card.dart';
import 'package:peepal/pages/toilet_details/toilet_details_page.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesState();
}

class _FavouritesState extends State<FavouritesPage> {
  @override
  void initState() {
    context.read<FavoritesBloc>().add(FavoritesEventLoad());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Toilets'),
      ),
      body: SafeArea(child: BlocBuilder<FavoritesBloc, FavoritesState>(
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

          return BlocBuilder<ToiletsBloc, ToiletsState>(
            buildWhen: (previous, current) =>
                current.toilets != previous.toilets,
            builder: (context, toiletState) {
              // Filter toilets to show only favorites
              // Note: Some toilets might be temporarily missing while the ToiletsBloc updates
              final List<PPToilet> toilets = toiletState.toilets
                  .where((t) => state.favoriteIds.contains(t.id))
                  .toList();

              if (toilets.isEmpty && state.favoriteIds.isNotEmpty) {
                // Only show loading if we have favorites but none are loaded yet
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final ToiletsBloc toiletsBloc = context.read<ToiletsBloc>();
              final FavoritesBloc favoritesBloc = context.read<FavoritesBloc>();

              return ListView.builder(
                itemCount: toilets.length,
                itemBuilder: (context, index) {
                  return FavoriteCard(
                      isFavorite: state.favoriteIds.contains(toilets[index].id),
                      toilet: toilets[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: toiletsBloc),
                                BlocProvider.value(value: favoritesBloc),
                              ],
                              child: ToiletDetailsPage(toilet: toilets[index]),
                            ),
                          ),
                        );
                      },
                      onFavouriteTap: () {
                        final toilet = toilets[index];
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        // Clear any existing snackbars
                        scaffoldMessenger.clearSnackBars();

                        context
                            .read<FavoritesBloc>()
                            .add(FavoritesEventToggle(toilet));

                        // Only show undo option when removing
                        if (state.favoriteIds.contains(toilet.id)) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Removed from favorites',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Colors.white,
                                onPressed: () {
                                  context
                                      .read<FavoritesBloc>()
                                      .add(FavoritesEventToggle(toilet));
                                },
                              ),
                            ),
                          );
                        }
                      });
                },
              );
            },
          );
        },
      )),
    );
  }
}
