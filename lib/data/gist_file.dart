import 'package:gists/data/gist.dart';
import 'package:gists/data/github.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github/github.dart';
part 'gist_file.g.dart';


@riverpod
class GistFile_ extends _$GistFile_ {
  @override
  Future<GistFile?> build() async {
    return null;
  }
  
  void set(String filename) async {
    state = AsyncLoading();

    Gist? currentGist = await ref.read(gist_Provider.future);
    if (currentGist == null || currentGist.files == null) {
      return;
    }

    var gf = currentGist.files![filename];

    if (gf == null) {
      return;
    }
    print(filename);
    state = AsyncValue.data(gf);
  }
}