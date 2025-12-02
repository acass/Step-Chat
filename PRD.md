Product Requirements Document (PRD)
Project: AI-Powered Procedure Retrieval App
Version: 1.0
1. Overview

This application enables users to ask about a procedure using speech, and retrieve structured, step-by-step instructions from a Firebase Firestore + Storage backend. An AI model interprets the user’s question, determines the right procedure to fetch, and optionally formats the response as JSON for consistent front-end rendering.

The app is built with Flutter and targets mobile devices.

2. Goals & Success Criteria
Primary Goals

Allow the user to speak a question about a procedure.

Convert speech to text reliably.

Use an AI model to interpret the user’s intent.

Retrieve the correct procedure from Firestore & Firebase Storage.

Display a clean, structured UI showing steps + images.

Success Criteria

95% accuracy in identifying the correct procedure when the Firestore data is well structured.

Speech-to-text accuracy sufficient for most common maintenance questions.

Response time from speech → displayed steps under 3 seconds (excluding network latency).

Structured JSON output from AI ensures consistency across platforms.

3. User Workflow

User speaks a question

User taps a microphone icon and speaks naturally.

Speech-to-text conversion

The app listens, transcribes, and produces text.

AI interpretation

The text is sent to an AI model.

AI extracts intent and produces:

Search keywords

Optional direct Firestore document path

Optional formatted JSON response template

Query Firestore & Firebase Storage

Firestore returns the procedure document:

Title

Keywords

List of steps

Image file paths

Firebase Storage URLs are retrieved for images.

AI optional post-processing

App may send the raw Firestore data to AI to:

Clean wording

Normalize formatting

Output strict JSON

UI display

User sees:

Procedure title

Steps

Images

Downloaded from Firebase Storage

4. Functional Requirements
4.1 Speech Input

The user can initiate recording.

Real-time or near-real-time transcription.

Error handling for no audio input or low confidence.

4.2 AI Query

Convert transcription into a Firestore query.

Output format must be valid JSON:

{
  "search_terms": "main gear lubrication",
  "document_id": null
}


If model is confident, it may also provide document_id to skip search.

AI must support optional re-formatting of Firestore results.

4.3 Firestore Integration

Firestore collection: procedures.

Each document includes:

{
  "id": "unique_id",
  "title": "Procedure Name",
  "keywords": ["gear", "lubrication"],
  "steps": [
    {
      "step_number": 1,
      "text": "Do X",
      "image_path": "gs://bucket/path/image1.png"
    }
  ]
}


Support filtering via:

arrayContains

text search (client-side fallback)

4.4 Firebase Storage Integration

Retrieve public URLs or authenticated URLs.

Display images inline with step content.

4.5 JSON Output Formatting (optional)

If enabled, AI returns:

{
  "procedure_title": "",
  "steps": [
    { "number": 1, "text": "", "image": "" }
  ]
}


Ensures strong consistency across the UI.

4.6 Front-End UI

Minimalist, readable layout.

Screens:

Home / Prompt Screen

Microphone button

Example questions

Loading Screen

Animated progress

Procedure Detail Screen

Title

Steps

Images

Scrollable content

4.7 Error Handling

No matching procedure found → AI suggests alternatives.

Speech failure → Prompt retry.

Firestore failure → Show graceful fallback message.

Slow AI / network → Throttle + retry messaging.

5. Non-Functional Requirements
5.1 Performance

Cold start under 2 seconds.

Speech-to-text latency under 200ms.

AI response under 1.5 seconds (model-dependent).

5.2 Reliability

App gracefully handles offline mode.

Cache last retrieved procedures locally.

5.3 Security

Firebase Authentication (optional for phase 1).

Firestore rules allow read-only for procedures collection.

No API keys stored in plaintext.

5.4 Scalability

Designed to handle thousands of procedure documents.

Image loading uses lazy loading.

6. Technical Architecture
6.1 Client (Flutter)

Speech-to-text module

AI request module

Firestore service

Storage service

JSON formatter

UI renderer

6.2 Backend

Firestore database

Firebase Storage

Optional:

Cloud Function to pre-clean or index data

Vector search engine for semantic matching

7. AI Prompt Specification
Routing Prompt
You are a maintenance procedure router.
Given a natural language question, return the best Firestore search terms or document ID.
Return JSON only:
{
  "search_terms": "",
  "document_id": null
}

Response Formatting Prompt
You are a formatter.
Given procedure data from Firebase, return a clean JSON object.
Do not invent steps.

8. Future Enhancements

Vector embeddings for better semantic search.

Offline speech recognition.

Downloadable PDF for procedures.

User bookmarks.

Step-by-step voice navigation (“next step”).

9. Acceptance Criteria

Asking “How do I lubricate the main gear?” successfully retrieves the correct procedure.

Images load from Firebase Storage.

JSON response is valid and renders correctly.

UI handles missing data gracefully.

Speech-to-text round trip feels natural.