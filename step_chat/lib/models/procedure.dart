import 'procedure_step.dart';

class Procedure {
  final String id;
  final String title;
  final List<String> keywords;
  final List<ProcedureStep> steps;

  Procedure({
    required this.id,
    required this.title,
    required this.keywords,
    required this.steps,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      id: json['id'] as String,
      title: json['title'] as String,
      keywords: List<String>.from(json['keywords'] as List),
      steps: (json['steps'] as List)
          .map((step) => ProcedureStep.fromJson(step as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'keywords': keywords,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}
