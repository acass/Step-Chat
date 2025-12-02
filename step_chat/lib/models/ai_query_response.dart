class AIQueryResponse {
  final String searchTerms;
  final String? documentId;

  AIQueryResponse({
    required this.searchTerms,
    this.documentId,
  });

  factory AIQueryResponse.fromJson(Map<String, dynamic> json) {
    return AIQueryResponse(
      searchTerms: json['search_terms'] as String,
      documentId: json['document_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search_terms': searchTerms,
      'document_id': documentId,
    };
  }
}
