

import 'package:github/github.dart';

extension Display on Gist {
  String name() {
    if (files !=  null && files!.entries.length > 0) {
      return files!.entries.first.key;
    }
    return "NA";
  }
}