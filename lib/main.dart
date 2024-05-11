import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'app.dart';
import 'data/db.dart';

void main() async {
  // await Hive.initFlutter();
  // BoxCollection collection = await initCollections();
  // CollectionBox gistsBox = await collection.openBox<Map>('gists');

  runApp(ProviderScope(
    overrides: [
      // collectionProvider.overrideWith((ref) => collection),
      // gistsBoxProvider.overrideWith((ref) => gistsBox),
    ],
    child: const App(),
  ));
}
