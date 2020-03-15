import 'dart:convert';

class OpenDiaryDatabase {
  List<Diary> diary;
  OpenDiaryDatabase({
    this.diary,
  });

  OpenDiaryDatabase copyWith({
    List<Diary> diary,
  }) {
    return OpenDiaryDatabase(
      diary: diary ?? this.diary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diary': List<dynamic>.from(diary.map((x) => x.toMap())),
    };
  }

  static OpenDiaryDatabase fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return OpenDiaryDatabase(
      diary: List<Diary>.from(map['diary']?.map((x) => Diary.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  static OpenDiaryDatabase fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'OpenDiaryDatabase(diary: $diary)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is OpenDiaryDatabase &&
      o.diary == diary;
  }

  @override
  int get hashCode => diary.hashCode;
}

class Diary {
  String title;
  String createdDateTime;
  String updatedDateTime;
  String filename;
  Diary({
    this.title,
    this.createdDateTime,
    this.updatedDateTime,
    this.filename,
  });

  Diary copyWith({
    String title,
    String createdDateTime,
    String updatedDateTime,
    String filename,
  }) {
    return Diary(
      title: title ?? this.title,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      updatedDateTime: updatedDateTime ?? this.updatedDateTime,
      filename: filename ?? this.filename,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdDateTime': createdDateTime,
      'updatedDateTime': updatedDateTime,
      'filename': filename,
    };
  }

  static Diary fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Diary(
      title: map['title'],
      createdDateTime: map['createdDateTime'],
      updatedDateTime: map['updatedDateTime'],
      filename: map['filename'],
    );
  }

  String toJson() => json.encode(toMap());

  static Diary fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Diary(title: $title, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, filename: $filename)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Diary &&
      o.title == title &&
      o.createdDateTime == createdDateTime &&
      o.updatedDateTime == updatedDateTime &&
      o.filename == filename;
  }

  @override
  int get hashCode {
    return title.hashCode ^
      createdDateTime.hashCode ^
      updatedDateTime.hashCode ^
      filename.hashCode;
  }
}
