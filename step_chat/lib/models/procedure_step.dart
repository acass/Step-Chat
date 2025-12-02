class ProcedureStep {
  final int stepNumber;
  final String text;
  final String? imagePath;

  ProcedureStep({
    required this.stepNumber,
    required this.text,
    this.imagePath,
  });

  factory ProcedureStep.fromJson(Map<String, dynamic> json) {
    return ProcedureStep(
      stepNumber: json['step_number'] as int,
      text: json['text'] as String,
      imagePath: json['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'text': text,
      'image_path': imagePath,
    };
  }
}
