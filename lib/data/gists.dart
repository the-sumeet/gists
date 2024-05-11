import 'package:gists/data/github.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github/github.dart';

part 'gists.g.dart';


@riverpod
class Gists extends _$Gists {
  @override
  Future<Map<String, Gist>> build() async {
    var client = ref.watch(githubProvider);
    List<Gist> gists = await client.gists.listCurrentUserGists().toList();
    return { for (Gist g in gists) g.id!: g };
  }

  void updateGist(Gist gist) async {
    var newMap = state.value;
    if (newMap != null) {
      newMap[gist.id!] = gist;
    }
    state=AsyncValue.data(newMap!);
  }

  void refresh() async{
    state = AsyncLoading();
    var client = ref.watch(githubProvider);
    List<Gist> res = await client.gists.listCurrentUserGists().toList();
    state = AsyncValue.data({ for (Gist g in res) g.id!: g });
  }
}