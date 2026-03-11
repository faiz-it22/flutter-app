import 'package:hive/hive.dart';

part 'user_schema.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;
  
  @HiveField(3)
  DateTime? lastLogin;
}
