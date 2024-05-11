import 'package:gists/data/gist_file.dart';
import 'package:gists/data/gists.dart';
import 'package:gists/data/github.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github/github.dart';
part 'gist.g.dart';


@riverpod
class Gist_ extends _$Gist_ {
  @override
  Future<Gist?> build() async {
    return null;
  }
  
  void set(String? id) async {

    if (id == null) {
      return;
    }


    Gist cachedGist = (await ref.read(gistsProvider.future))[id]!;

    // If gist file contents is there, don't fetch the gist.
    cachedGist.files!.forEach((key, value) async {
      if (value.content == null) {
        GitHub client = ref.read(githubProvider);
        Gist gist = await client.gists.getGist(id);
        ref.read(gistsProvider.notifier).updateGist(gist);
        state=AsyncValue.data(gist);
      }
    });
    state=AsyncValue.data(cachedGist);
  }
}