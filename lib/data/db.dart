

import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

Future<BoxCollection> initCollections() async {
  final collection = await BoxCollection.open(
    'gists', // Name of your database
    {'gists', 'config'}, // Names of your boxes
    // path: './', // Path where to store your boxes (Only used in Flutter / Dart IO)
  );
  return collection;
}

// final collectionProvider =
// Provider<BoxCollection>((ref) => throw UnimplementedError());
//
// final gistsBoxProvider =
// Provider<CollectionBox>((ref) => throw UnimplementedError());