class StudentModel {
  final String id;
  final String fullKhName;
  final String fullEnName;
  StudentModel(
      {required this.id, required this.fullKhName, required this.fullEnName});
  factory StudentModel.fromJson(json) {
    return StudentModel(
        id: json['_id'],
        fullKhName: "${json["khFirstName"]} ${json["khLastName"]}",
        fullEnName: "${json["enFirstName"]} ${json["enLastName"]}");
  }
}
