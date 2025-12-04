class ProcedureStep {
  final String title;
  final String description;
  final String image;
  final String video;
  final String mediaType;
  final bool completed;

  ProcedureStep({
    required this.title,
    required this.description,
    required this.image,
    required this.video,
    required this.mediaType,
    required this.completed,
  });

  factory ProcedureStep.fromJson(Map<String, dynamic> json) {
    return ProcedureStep(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      video: json['video'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'video': video,
      'mediaType': mediaType,
      'completed': completed,
    };
  }
}
