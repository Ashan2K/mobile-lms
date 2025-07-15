class RecordingModel {
  final String? id;
  final String name;
  final String description;
  final String visibility;
  final String? thumbnailUrl;
  final String videoUrl;
  final String? batchId;
  final DateTime uploadDate;

  RecordingModel({
    this.id,
    required this.name,
    required this.description,
    required this.visibility,
    this.thumbnailUrl,
    required this.videoUrl,
    this.batchId,
    required this.uploadDate,
  });

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      visibility: json['visibility'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String,
      batchId: json['batchId'] as String?,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'visibility': visibility,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      if (batchId != null) 'batchId': batchId,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }
}
