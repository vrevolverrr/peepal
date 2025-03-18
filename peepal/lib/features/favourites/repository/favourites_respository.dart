import 'package:peepal/shared/toilet/model/toilet_collection.dart';

abstract interface class FavouritesRespository {
  Future<PPToiletCollection> getFavourites();
  Future<void> addFavourite(String toiletId);
  Future<void> removeFavourite(String toiletId);
  Future<bool> isFavourite(String toiletId);
}
