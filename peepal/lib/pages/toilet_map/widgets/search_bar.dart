import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_image_widget.dart';
import 'package:peepal/pages/toilet_map/bloc/toilet_map_bloc.dart';

class ToiletSearchBar extends StatefulWidget {
  const ToiletSearchBar({super.key});

  @override
  State<ToiletSearchBar> createState() => _ToiletSearchBarState();
}

class _ToiletSearchBarState extends State<ToiletSearchBar> {
  late final LocationCubit locationCubit;
  late final ToiletsBloc toiletsBloc;
  late final ToiletMapCubit toiletMapCubit;

  late final SearchController searchController;

  @override
  void initState() {
    locationCubit = context.read<LocationCubit>();
    toiletsBloc = context.read<ToiletsBloc>();
    toiletMapCubit = context.read<ToiletMapCubit>();
    searchController = SearchController();

    searchController.addListener(_handleSearch);

    super.initState();
  }

  void _handleSearch() {
    final location = locationCubit.state.location;
    final query = searchController.value.text.trim();

    if (query.isNotEmpty) {
      toiletsBloc.add(ToiletEventSearch(query: query, location: location));
    } else {
      toiletsBloc.add(const ToiletEventClearSearch());
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_handleSearch);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: SearchAnchor(
          isFullScreen: false,
          viewConstraints: const BoxConstraints(maxHeight: 300),
          searchController: searchController,
          builder: (context, controller) => SearchBar(
            onTap: () => controller.openView(),
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(1),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            leading: const Icon(Icons.search),
            hintText: 'Search toilets',
          ),
          viewBackgroundColor: Colors.white,
          suggestionsBuilder: (context, controller) async {
            final ToiletsState state = await toiletsBloc.stream.first;

            return state.searchResults.map((toilet) => ListTile(
                  leading: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: PPImageWidget(image: toilet.image),
                    ),
                  ),
                  title: Text(
                    toilet.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    toilet.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    controller.closeView(toilet.name);
                    controller.clear();
                    toiletsBloc.add(const ToiletEventClearSearch());
                    toiletMapCubit.selectToilet(toilet);
                  },
                ));
          },
        ),
      ),
    );
  }
}
