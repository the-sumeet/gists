//
//
// import 'package:github/github.dart';
// import 'package:hive/hive.dart';
//
// class GistAdapter extends TypeAdapter<Gist>{
//   @override
//   final typeId = 1;
//
//   @override
//   Gist read(BinaryReader reader) {
//     return Gist(
//         id: reader.read() as String?,
//         description: reader.read() as String?,
//         public: reader.read() as bool?,
//         owner: reader.read() as User,
//         files: reader.read() as bool?,
//       htmlUrl: reader.read() as bool?,
//       htmlUrl: reader.read() as bool?,
//       htmlUrl: reader.read() as bool?,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, ObjectFromLibrary obj) {
//     writer.write(obj.value);
//     writer.write(obj.status);
//   }
// }