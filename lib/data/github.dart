import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github/github.dart';
part 'github.g.dart';

@riverpod
GitHub github(GithubRef ref) {
  GitHub github = GitHub(auth: const Authentication.withToken(''));
  return github;
}