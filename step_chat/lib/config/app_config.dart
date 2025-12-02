class AppConfig {
  // Pinecone Configuration
  static const String pineconeApiKey = 'YOUR_PINECONE_API_KEY';
  static const String pineconeEnvironment = 'YOUR_PINECONE_ENVIRONMENT';
  static const String pineconeIndexName = 'YOUR_PINECONE_INDEX_NAME';

  // OpenAI Configuration (for embeddings and AI interpretation)
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';

  // Firebase Configuration
  // Note: Firebase configuration should be added via Firebase CLI
  // Run: flutterfire configure

  // API Endpoints
  static const String pineconeApiUrl = 'https://api.pinecone.io';
  static const String openAiApiUrl = 'https://api.openai.com/v1';
}
