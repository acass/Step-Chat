# Step Chat - AI-Powered Procedure Retrieval App

An AI-powered Flutter mobile application that enables users to ask about procedures using speech and retrieve structured, step-by-step instructions from Firebase Firestore with Pinecone RAG (Retrieval-Augmented Generation).

## Features

- **Speech-to-Text**: Voice input for natural language queries
- **AI-Powered Search**: Pinecone RAG for intelligent procedure retrieval
- **Firebase Integration**: Firestore database and Storage for procedures and images
- **Clean UI**: Minimalist, readable interface with step-by-step instructions
- **Image Support**: Display images inline with procedure steps

## Architecture

### Services
- **SpeechService**: Handles speech-to-text conversion using device microphone
- **PineconeRAGService**: AI interpretation and semantic search using Pinecone and OpenAI
- **FirestoreService**: Manages procedure data retrieval from Firestore
- **StorageService**: Fetches images from Firebase Storage

### Screens
- **HomeScreen**: Main interface with microphone button for voice input
- **LoadingScreen**: Shows processing status while retrieving procedures
- **ProcedureDetailScreen**: Displays procedure steps with images

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.9.2 or later)
- Firebase account
- Pinecone account
- OpenAI API key

### 2. Install Dependencies

```bash
cd step_chat
flutter pub get
```

### 3. Configure Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will create `firebase_options.dart` with your Firebase configuration.

### 4. Update API Keys

Edit `lib/config/app_config.dart` and replace the placeholder values:

```dart
class AppConfig {
  // Pinecone Configuration
  static const String pineconeApiKey = 'YOUR_ACTUAL_PINECONE_API_KEY';
  static const String pineconeEnvironment = 'YOUR_PINECONE_ENVIRONMENT'; // e.g., 'us-east-1-aws'
  static const String pineconeIndexName = 'YOUR_PINECONE_INDEX_NAME';

  // OpenAI Configuration
  static const String openAiApiKey = 'YOUR_ACTUAL_OPENAI_API_KEY';
}
```

### 5. Set Up Firestore Database

Create a Firestore collection named `procedures` with documents in this format:

```json
{
  "id": "unique_id",
  "title": "Procedure Name",
  "keywords": ["keyword1", "keyword2"],
  "steps": [
    {
      "step_number": 1,
      "text": "Step description",
      "image_path": "gs://bucket/path/image1.png"
    }
  ]
}
```

### 6. Set Up Pinecone Index

1. Create a Pinecone index with dimensions matching your embedding model (e.g., 1536 for text-embedding-3-small)
2. Populate the index with procedure embeddings
3. Ensure document IDs in Pinecone match Firestore document IDs

### 7. Configure Permissions

#### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MICROPHONE"/>
```

#### iOS (ios/Runner/Info.plist)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to process voice commands</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to understand your questions</string>
```

## Running the App

```bash
# Run on connected device or emulator
flutter run

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

## Usage

1. Launch the app
2. Tap the microphone button
3. Speak your question (e.g., "How do I lubricate the main gear?")
4. Wait for the AI to process and retrieve the procedure
5. View step-by-step instructions with images

## Data Flow

1. **User speaks** → Speech-to-Text conversion
2. **AI interpretation** → OpenAI processes query and extracts search terms
3. **Semantic search** → Pinecone finds similar procedures
4. **Data retrieval** → Firestore fetches procedure details
5. **Image loading** → Firebase Storage provides image URLs
6. **Display** → Structured UI renders steps and images

## Dependencies

- `firebase_core`: Firebase initialization
- `cloud_firestore`: Firestore database
- `firebase_storage`: Firebase Storage
- `speech_to_text`: Speech recognition
- `permission_handler`: Microphone permissions
- `http`: API calls to Pinecone and OpenAI
- `cached_network_image`: Image caching
- `provider`: State management

## Security Notes

⚠️ **Important**: Never commit API keys to version control!

- Add `lib/config/app_config.dart` to `.gitignore` if it contains real keys
- Use environment variables or secure secret management in production
- Consider using Firebase Functions to keep API keys server-side

## Troubleshooting

### Firebase not initialized
- Run `flutterfire configure` to set up Firebase
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in the correct locations

### Speech recognition not working
- Check microphone permissions are granted
- Verify device has speech recognition capability
- Test with a physical device (emulators may have limited support)

### Pinecone errors
- Verify API key and environment are correct
- Ensure index exists and has correct dimensions
- Check network connectivity

### Images not loading
- Verify Firebase Storage rules allow read access
- Check image paths in Firestore use correct format (gs:// URLs)
- Ensure Storage bucket name matches your Firebase project

## Future Enhancements

- Offline speech recognition
- Procedure bookmarks
- Voice-guided navigation
- PDF export
- Multi-language support
- Procedure history

## License

This project is created for educational and demonstration purposes.
