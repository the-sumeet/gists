
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gists/extentions.dart';
import 'package:github/github.dart';

import '../../../data/gist.dart';
import '../../../data/gist_file.dart';
import '../../../data/gists.dart';
import '../../../widget/async_value_widget.dart';

class SidebarMenu extends ConsumerStatefulWidget {
  const SidebarMenu({super.key});

  @override
  ConsumerState<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends ConsumerState<SidebarMenu> {



  int selectedTile = -1;

  @override
  Widget build(BuildContext context) {

    var gists = ref.watch(gistsProvider);
    var selectedGist = ref.watch(gist_Provider);
    var selectedGistFile = ref.watch(gistFile_Provider);


    return AsyncValueWidget(
        value: gists,
        data: (Map<String, Gist> gists) {
          return Drawer(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
            child: AsyncValueWidget(
              value: selectedGist,
              data: (Gist? selectedGist) {
                var gistList = gists.entries.toList();
                return ListView.builder(
                  key: Key(selectedTile.toString()),
                  itemCount: gists.length,
                  itemBuilder: (BuildContext context, int i) {
                    return ExpansionTile(
                      initiallyExpanded: i == selectedTile,
                      onExpansionChanged: (state) {
                        if (state) {
                          setState(() {
                            selectedTile = i;
                          });
                          ref
                              .read(gist_Provider.notifier)
                              .set(gistList[i].value.id);
                        } else {
                          setState(() {
                            selectedTile = -1;
                          });
                        }
                      },
                      // shape: const Border(),
                      title: Text(gistList[i].value.name()),
                      subtitle: Row(
                        children: [
                          if (gistList[i].value.public != null &&
                              gistList[i].value.public!)
                            Icon(
                              Icons.public,
                              size: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .fontSize!,
                            )
                        ],
                      ),
                      children:
                      gistList[i].value.files!.entries.map((gf) {
                        return InkWell(
                          onTap: () {
                            ref
                                .read(gistFile_Provider.notifier)
                                .set(gf.key);
                          },
                          child: ListTile(
                            tileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            title: Text(gf.key),
                            subtitle: gf.value.language != null
                                ? Text(gf.value.language!)
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          );
        });
  }
}
