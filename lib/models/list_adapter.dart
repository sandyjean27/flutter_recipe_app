import 'package:hive/hive.dart';

class ListAdapter extends TypeAdapter<List> {
  @override
  final typeId = 1;

  @override
  List read(BinaryReader reader) {
    final length = reader.readByte();
    return List.generate(length, (index) => reader.read());
  }

  @override
  void write(BinaryWriter writer, List obj) {
    writer.writeByte(obj.length);
    obj.forEach((element) => writer.write(element));
  }
} 