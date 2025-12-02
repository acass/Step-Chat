# Step Chat

An AI-powered voice-activated mobile application for retrieving and displaying maintenance procedures using natural language queries.

## Overview

Step Chat is a Flutter-based mobile application that allows users to ask questions about maintenance procedures using voice commands. The app leverages AI and semantic search to understand natural language queries and retrieve relevant step-by-step procedures with accompanying images.

## Features

- **Voice Input**: Hands-free operation using speech-to-text recognition
- **Natural Language Understanding**: AI-powered query interpretation using OpenAI GPT-4
- **Semantic Search**: Pinecone vector database with RAG (Retrieval-Augmented Generation) for intelligent procedure matching
- **Step-by-Step Guidance**: Clear, numbered procedure steps with visual aids
- **Image Support**: Cached network images for faster loading and offline viewing
- **Real-time Transcription**: Live speech-to-text feedback during voice input
- **Multi-Search Strategy**: Combines direct document lookup, keyword search, and semantic search for best results

## Technology Stack

### Frontend
- **Flutter** (SDK 3.9.2+) - Cross-platform mobile development framework
- **Material Design 3** - Modern UI components

### Backend Services
- **Firebase Core** - Firebase initialization and configuration
- **Cloud Firestore** - NoSQL database for storing procedures
- **Firebase Storage** - Cloud storage for procedure images

### AI & Search
- **OpenAI GPT-4** - Natural language query interpretation
- **OpenAI Embeddings** (text-embedding-3-small) - Text vectorization
- **Pinecone** - Vector database for semantic search and retrieval

### Additional Packages
- **speech_to_text** - Voice recognition and transcription
- **permission_handler** - Runtime permissions management
- **cached_network_image** - Efficient image loading and caching
- **http** - HTTP client for API requests
- **provider** - State management

## Architecture

The application follows a clean architecture pattern with separation of concerns:

### Services Layer (`lib/services/`)
- `speech_service.dart` - Handles speech recognition and transcription
- `pinecone_rag_service.dart` - AI query interpretation and semantic search
- `firestore_service.dart` - Database operations for procedures
- `storage_service.dart` - Image URL retrieval from Firebase Storage

### Models Layer (`lib/models/`)
- `procedure.dart` - Procedure data model
- `procedure_step.dart` - Individual step data model
- `ai_query_response.dart` - AI response parsing model

### Presentation Layer (`lib/screens/`)
- `home_screen.dart` - Main voice input interface
- `loading_screen.dart` - Query processing screen
- `procedure_detail_screen.dart` - Step-by-step procedure display

### Configuration
- `app_config.dart` - API keys and environment configuration

## How It Works

1. **Voice Input**: User taps the microphone button and speaks their query (e.g., "How do I lubricate the main gear?")
2. **Speech Recognition**: The app transcribes the speech to text in real-time
3. **AI Interpretation**: OpenAI GPT-4 interprets the query and extracts search terms or document IDs
4. **Multi-Stage Retrieval**:
   - First attempts direct document lookup if ID is provided
   - Falls back to keyword-based Firestore search
   - Uses Pinecone semantic search as final fallback
5. **Display**: Retrieved procedure is displayed with numbered steps and images

## Setup Instructions

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Firebase project with Firestore and Storage enabled
- OpenAI API key
- Pinecone account and index

### Installation

1. Clone the repository:
```bash
git clone https://github.com/acass/Step-Chat.git
cd Step-Chat/step_chat
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
```bash
flutterfire configure
```

4. Set up API keys in `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String pineconeApiKey = 'your-pinecone-api-key';
  static const String openAiApiKey = 'your-openai-api-key';
  static const String pineconeEnvironment = 'your-pinecone-environment';
  static const String pineconeIndexName = 'your-index-name';
  static const String openAiApiUrl = 'https://api.openai.com/v1';
}
```

5. Configure iOS permissions in `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice commands</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice commands</string>
```

6. Configure Android permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

7. Run the app:
```bash
flutter run
```

## CocoaPods Integration

This project uses CocoaPods for iOS dependency management. The Podfile is configured to support iOS 12.0+ with specific pod dependencies for Firebase and other native integrations.

## Project Structure

```
step_chat/
├── lib/
│   ├── config/
│   │   └── app_config.dart
│   ├── models/
│   │   ├── ai_query_response.dart
│   │   ├── procedure.dart
│   │   └── procedure_step.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── loading_screen.dart
│   │   └── procedure_detail_screen.dart
│   ├── services/
│   │   ├── firestore_service.dart
│   │   ├── pinecone_rag_service.dart
│   │   ├── speech_service.dart
│   │   └── storage_service.dart
│   └── main.dart
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

## Example Queries

- "How do I lubricate the main gear?"
- "What is the hydraulic system check procedure?"
- "How do I inspect the landing gear?"

## Future Enhancements

- Offline mode with local procedure caching
- Multi-language support
- Voice-guided step navigation
- Procedure history and favorites
- User annotations and notes
- Video support for complex procedures

## License

This project is private and not published to pub.dev.

## Contributing

For contributions and issues, please contact the repository maintainer.

## Version

Current version: 1.0.0+1
