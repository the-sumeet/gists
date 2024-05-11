import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gists/constants.dart';
import 'package:gists/data/gist_file.dart';
import 'package:gists/data/gists.dart';
import 'package:gists/data/gist.dart';
import 'package:gists/extentions.dart';
import 'package:gists/widget/async_value_widget.dart';
import 'package:github/github.dart';

import '../../../data/github.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newGistNameController = TextEditingController();
  final TextEditingController newGistFileController = TextEditingController();
  final TextEditingController newGistDescriptionController = TextEditingController();
  bool loadingNewGist = false;
  bool newGistPublic = false;

  int selectedTile = -1;

  @override
  Widget build(BuildContext context) {
    debugPrint("Building home screen");
    var gists = ref.watch(gistsProvider);
    var selectedGist = ref.watch(gist_Provider);
    var selectedGistFile = ref.watch(gistFile_Provider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Text('Gists'),
        actions: [
          AsyncValueWidget(
            value: gists,
            data: (Map<String, Gist> gists) {
              return IconButton(
                  onPressed: () => _dialogBuilder(context, gists),
                  icon: Icon(Icons.add));
            },
          ),
          IconButton(onPressed: () {
            ref.read(gistsProvider.notifier).refresh();
          }, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Row(
        children: [
          AsyncValueWidget(
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
              }),
          Expanded(
              child: AsyncValueWidget(
            value: selectedGistFile,
            data: (GistFile? gf) {

              if (gf != null) {
                codeController.text = gf.content ?? "";
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: codeController,
                  expands: true,
                  maxLines: null,
                ),
              );
            },
          ))
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, Map<String, Gist> gists) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('Add New Gist'),
                content: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownMenu<String>(
                          controller: newGistNameController,
                          initialSelection: 'New Gist',
                          requestFocusOnTap: true,
                          onSelected: (String? color) {
                            setState(() {
                              print(color);
                            });
                          },
                          dropdownMenuEntries: gists.entries
                              .map<DropdownMenuEntry<String>>((MapEntry gist) {
                            return DropdownMenuEntry<String>(
                              value: gist.value.id,
                              label: (gist.value as Gist).name(),
                              style: MenuItemButton.styleFrom(),
                            );
                          }).toList(),
                        ),
                        TextField(
                          controller: newGistFileController,
                            decoration: InputDecoration(
                                labelText: "File Name"
                            )
                        ),
                        TextField(
                          controller: newGistDescriptionController,
                          decoration: InputDecoration(
                            labelText: "Description"
                          ),
                        ),
                        kHeight8,
                        Row(
                          children: [
                            Text("Public"),
                            Switch(value: newGistPublic, onChanged: (val){
                              setState((){
                                newGistPublic=val;
                              });
                            }),
                          ],
                        )
                      ],
                    ),
                    if (loadingNewGist == true)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed:loadingNewGist == false ? (){
                      Navigator.of(context).pop();
                    } : null,
                  ),
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: loadingNewGist == false ? () async {
                      setState(() {
                        loadingNewGist = true;
                      });
                      GitHub client = ref.read(githubProvider);
                      await client.gists.createGist(
                          {'newGistNameController.text':"dd"},
                        description: newGistDescriptionController.text,
                        public: true
                      );
                      print('DONE');
                      setState(() {
                        loadingNewGist = false;
                      });
                      Navigator.of(context).pop();
                    } : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
