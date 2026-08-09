# Live AI Integration Guide

## Current State
The app now has a production-ready SSE (Server-Sent Events) streaming client that can connect to a real backend.

### What's Implemented
- **SseStreamService**: Production implementation using HTTP/SSE
- **MockLiveAiStreamService**: Mock implementation for testing/demo
- **LiveAiProvider**: Manages streaming state and event handling
- **LiveAiPanel**: UI component that displays live events and streamed responses

## To Use Production SSE

### 1. Update `lib/main.dart`

Replace the mock service with the SSE service:

```dart
ChangeNotifierProvider(
  create: (_) => LiveAiProvider(
    service: SseStreamService(
      baseUrl: 'https://your-backend.com',  // Your backend URL
      authToken: 'your-bearer-token',        // Optional: API key or JWT
    ),
  )..connect(),
),
```

### 2. Backend Contract

Your backend must emit SSE events matching this format:

```
Content-Type: text/event-stream

data: {"eventId":"evt_1","type":"thinking","severity":"low","conversationId":"conv_123","sourceModule":"assistant","timestamp":"2026-07-12T10:35:00Z","data":{"message":"Analyzing..."}}

data: {"eventId":"evt_2","type":"token","severity":"low","conversationId":"conv_123","sourceModule":"assistant","timestamp":"2026-07-12T10:35:01Z","data":{"text":"I found "}}

data: {"eventId":"evt_3","type":"token","severity":"low","conversationId":"conv_123","sourceModule":"assistant","timestamp":"2026-07-12T10:35:01Z","data":{"text":"3 alerts."}}

data: [DONE]
```

### 3. Event Types Supported

- `token` - Streamed assistant text
- `thinking` - AI reasoning progress
- `summary` - Live digest updates
- `alert` - Urgent platform events
- `insight` - AI findings
- `action` - Suggested next steps
- `tool_use` - Backend tool calls
- `error` - Failures

### 4. Event Structure

Every event must include:
- `eventId` - Unique identifier
- `type` - Event type (see above)
- `severity` - `low`, `medium`, `high`, or `critical`
- `conversationId` - Links to conversation
- `sourceModule` - Where the event came from (e.g., `crop_health`, `orders`)
- `timestamp` - ISO 8601 timestamp
- `data` - Event payload

For `token` events, `data.text` contains the streamed text.
For other events, `data` may contain `title`, `message`, `actionLabel`, `actionRoute`.

### 5. Backend Endpoint

POST `/v1/assistant/stream`

**Request:**
```json
{
  "conversationId": "conv_123",
  "prompt": "What is happening?"
}
```

**Response:** SSE stream with events (see format above)

### 6. Example: Python Backend (Flask)

```python
from flask import Flask, response, jsonify
import json
from datetime import datetime

app = Flask(__name__)

@app.route('/v1/assistant/stream', methods=['POST'])
def stream_assistant():
    def generate():
        # Send thinking event
        event = {
            "eventId": "evt_1",
            "type": "thinking",
            "severity": "low",
            "conversationId": "conv_123",
            "sourceModule": "assistant",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "data": {"message": "Analyzing platform state..."}
        }
        yield f"data: {json.dumps(event)}\n\n"

        # Send token events
        tokens = ["I", "found", "3", "urgent", "alerts"]
        for i, token in enumerate(tokens):
            event = {
                "eventId": f"evt_{i+2}",
                "type": "token",
                "severity": "low",
                "conversationId": "conv_123",
                "sourceModule": "assistant",
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "data": {"text": token + " "}
            }
            yield f"data: {json.dumps(event)}\n\n"

        # Send summary event
        summary = {
            "eventId": "evt_10",
            "type": "summary",
            "severity": "medium",
            "conversationId": "conv_123",
            "sourceModule": "notifications",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "data": {
                "title": "Platform Summary",
                "message": "3 crop alerts, 2 delayed orders, 1 payment overdue"
            }
        }
        yield f"data: {json.dumps(summary)}\n\n"

        # End stream
        yield "data: [DONE]\n\n"

    return response(generate(), mimetype='text/event-stream')

if __name__ == '__main__':
    app.run(debug=True)
```

## Testing

With `MockLiveAiStreamService`, the app emits mock events and streams fake assistant replies every 10 seconds.

To verify the SSE client works:
1. Start your backend at the configured URL
2. Update `main.dart` to use `SseStreamService`
3. Run `flutter run`
4. Open AI assistant and send a prompt
5. Watch the streamed tokens and platform events appear in real-time

## Next Steps

- Implement your backend SSE route
- Connect a real AI model (OpenAI, Anthropic, local LLM, etc.)
- Wire platform events into the stream (from notifications, crop health, orders, etc.)
- Add authentication (JWT, API key, etc.)
- Add error recovery and reconnection logic
