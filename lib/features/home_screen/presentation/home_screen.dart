import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gists/constants.dart';
import 'package:gists/data/gist_file.dart';
import 'package:gists/data/gists.dart';
import 'package:gists/data/gist.dart';
import 'package:gists/extentions.dart';
import 'package:gists/features/home_screen/presentation/sidemenu.dart';
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
  // For new gist
  final TextEditingController newGistNameController = TextEditingController();
  // For new gist file
  final TextEditingController newGistFileNameController =
      TextEditingController();
  final TextEditingController newGistFileContentController =
      TextEditingController();
  final TextEditingController newGistDescriptionController =
      TextEditingController();

  bool loadingNewGist = false;
  bool newGistPublic = false;
  Gist? newGist = null;

  @override
  void initState() {
    if (newGist != null) {
      newGistDescriptionController.text = newGist!.description ?? "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building home screen");
    var gists = ref.watch(gistsProvider);
    var selectedGist = ref.watch(gist_Provider);
    var selectedGistFile = ref.watch(gistFile_Provider);

    if (newGist != null) {
      print(newGist!.description);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Text('Gists'),
        actions: [
          AsyncValueWidget(
            value: gists,
            data: (Map<String, Gist> gists) {
              return IconButton(
                onPressed: () {},
                icon: Icon(Icons.add),
              );
            },
          ),
          AsyncValueWidget(
            value: selectedGist,
            data: (Gist? gist) {
              if (gist != null) {
                return IconButton(
                  onPressed: () => _newGistFileDialog(context, gist),
                  icon: Icon(Icons.note_add),
                );
              }

              return Container();
            },
          ),
          IconButton(
            onPressed: () {
              ref.read(gistsProvider.notifier).refresh();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Row(
        children: [
          SidebarMenu(),
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

  Future<void> _newGistFileDialog(BuildContext context, Gist? gist) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('New Gist File'),
                content: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: newGistFileNameController,
                          decoration: InputDecoration(labelText: "File Name"),
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                        Container(
                          constraints: BoxConstraints(
                              // maxWidth: 1024,
                              maxHeight: 256),
                          child: TextField(
                            controller: newGistFileContentController,
                            decoration:
                                InputDecoration(labelText: "File Content"),
                            expands: true,
                            maxLines: null,
                            onChanged: (val) {
                              setState(() {});
                            },
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Text("Public"),
                        //     Switch(
                        //         value: newGist != null
                        //             ? (newGist!.public ?? newGistPublic)
                        //             : newGistPublic,
                        //         onChanged: (val) {
                        //           setState(() {
                        //             newGistPublic = val;
                        //           });
                        //         }),
                        //   ],
                        // )
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
                    onPressed: loadingNewGist == false
                        ? () {
                            Navigator.of(context).pop();
                          }
                        : null,
                  ),
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: (loadingNewGist == false &&
                            newGistFileNameController.text != "" &&
                            newGistFileContentController.text != "")
                        ? () async {
                            setState(() {
                              loadingNewGist = true;
                            });
                            GitHub client = ref.read(githubProvider);
                            var res = await client.gists.editGist(gist!.id!,
                                files: {
                                  newGistFileNameController.text:
                                      newGistFileContentController.text
                                });

                            ref.read(gistsProvider.notifier).refresh();
                            ref.read(gist_Provider.notifier).set(gist.id!);
                            // ref.read(gistFile_Provider.notifier).set(newGistFileNameController.text);
                            setState(() {
                              loadingNewGist = false;
                            });
                            Navigator.of(context).pop();
                          }
                        : null,
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
