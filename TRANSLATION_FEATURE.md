# Voice Input Translation Feature

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [Success Metrics](#success-metrics)
3. [Solution Overview](#solution-overview)
4. [Architecture & Design](#architecture--design)
5. [AI Integration Strategy](#ai-integration-strategy)
6. [Data Flow](#data-flow)
7. [Implementation Details](#implementation-details)
8. [Setup & Configuration](#setup--configuration)
9. [Testing & Validation](#testing--validation)
10. [Performance & Cost](#performance--cost)
11. [Security & Privacy](#security--privacy)
12. [Future Enhancements](#future-enhancements)

---

## Problem Statement

### The Challenge
Parents seeking mental health services for their children often face language barriers during the onboarding process. Our AI-powered intake assessment requires parents to share sensitive, detailed information about their child's mental health—a task that becomes significantly more difficult when the parent's primary language differs from the system language.

### Pain Points Identified

1. **Language Barrier During Critical Assessment**
   - Parents struggle to articulate complex mental health concerns in English
   - Nuanced cultural contexts and emotional states are lost in translation
   - Typing in English creates friction and increases drop-off rates
   - Parents may provide incomplete information due to language constraints

2. **Accessibility Gap**
   - Non-English speaking parents are underserved
   - Korean-speaking families (significant demographic in our market) face barriers
   - Voice input exists but only in English, limiting utility

3. **User Experience Friction**
   - Switching between languages or using external translation tools breaks flow
   - Copy-pasting translations is cumbersome and error-prone
   - Parents may abandon onboarding due to language frustration

4. **Quality of Care Impact**
   - Incomplete or inaccurate information leads to poor therapist matching
   - Cultural nuances critical for mental health assessment are lost
   - Trust is diminished when parents can't express themselves naturally

### Target User Persona
**Korean-American Parent (Primary Persona)**
- Immigrated to the US, comfortable speaking Korean
- Seeks mental health services for their child
- Prefers to discuss sensitive topics in native language
- Tech-savvy enough to use voice input but not expert
- Values privacy and cultural sensitivity in healthcare

**Success Criteria for This Persona:**
- Can complete intake assessment entirely in Korean
- Feels comfortable expressing complex emotional states
- Experiences seamless translation without manual intervention
- Trusts that nuanced information is preserved

---

## Success Metrics

### Primary Metrics (Must Achieve)

1. **Completion Rate**
   - **Target**: ≥85% completion rate for Korean-speaking parents
   - **Baseline**: ~60% completion rate (estimated from partial data)
   - **Measurement**: Percentage who complete AI intake using Korean voice input

2. **Translation Accuracy**
   - **Target**: ≥95% semantic accuracy (human-evaluated)
   - **Measurement**: Monthly review of 50 random Korean→English translations
   - **Success**: Parent's intent and emotional context preserved

3. **Latency**
   - **Target**: <2 seconds from speech end to translated text appearing
   - **Breakdown**: Transcription (real-time) + Translation (<1s) + Network (<500ms)
   - **Measurement**: Client-side performance monitoring

4. **Adoption Rate**
   - **Target**: ≥40% of Korean-speaking users use voice input feature
   - **Measurement**: Voice input usage vs. text-only input among Korean locale users

### Secondary Metrics (Monitor & Optimize)

5. **Error Rate**
   - **Target**: <5% translation failures
   - **Includes**: API errors, network issues, timeout errors
   - **Action**: Automatic fallback to original transcript

6. **User Satisfaction**
   - **Target**: ≥4.5/5 rating on post-assessment survey
   - **Question**: "How easy was it to share information in your preferred language?"

7. **Cost Efficiency**
   - **Target**: <$0.02 per complete intake assessment
   - **Current**: ~$0.015 per assessment (10 translations avg @ $0.00015 each)

8. **Match Quality Improvement**
   - **Target**: 15% improvement in therapist match ratings
   - **Hypothesis**: Better information → better matches
   - **Measurement**: Post-match parent satisfaction scores

### Leading Indicators

- **Time to First Voice Input**: <30 seconds from seeing chat interface
- **Average Translations per Session**: 8-12 messages
- **Retry Rate**: <10% (users re-recording due to inaccuracy)
- **Feature Discovery Rate**: ≥70% of Korean-locale users notice microphone button

---

## Solution Overview

### Core Innovation
**Seamless, zero-friction voice input with automatic translation**: Parents speak naturally in Korean, and the system automatically transcribes and translates their speech to English, enabling full participation in the AI-powered intake assessment without language barriers.

### Key Features

1. **Browser-Based Voice Transcription**
   - Uses Web Speech API for real-time Korean speech recognition
   - No server-side audio processing (privacy + performance)
   - Works in Chrome, Edge, and modern browsers

2. **Intelligent Translation Layer**
   - OpenAI GPT-4o-mini for contextual translation
   - Preserves emotional tone and cultural nuances
   - Fast (<1s) and cost-effective ($0.00015 per translation)

3. **Transparent User Experience**
   - Single microphone button to activate
   - Real-time visual feedback (listening, translating)
   - Editable translated text before sending
   - No configuration required—works out of the box

4. **Graceful Degradation**
   - Falls back to original transcript if translation fails
   - User-friendly error messages
   - Doesn't break chat flow on failures

---

## Architecture & Design

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER'S BROWSER                          │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              AIChatPanel Component                         │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │  🎤 Microphone Button (Click to activate)          │  │ │
│  │  │  💬 Chat Input Field (Shows translated text)        │  │ │
│  │  │  📊 Status Indicators (Listening/Translating)       │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  │                          ↓                                 │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │         useVoiceInput Hook (Core Logic)             │  │ │
│  │  │  • Manages Web Speech API                           │  │ │
│  │  │  • Handles transcription state                      │  │ │
│  │  │  • Triggers translation when needed                 │  │ │
│  │  │  • Config: language="ko-KR", autoTranslate=true     │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              ↓                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │         Web Speech API (Browser Native)                   │ │
│  │  • SpeechRecognition / webkitSpeechRecognition           │ │
│  │  • language: "ko-KR" (Korean)                             │ │
│  │  • continuous: false (stop after speech)                  │ │
│  │  • interimResults: true (show real-time)                  │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              ↓                                  │
│                    Korean Text Transcribed                      │
│                   "안녕하세요, 도움이 필요합니다"                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    HTTP POST /api/translate
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    NEXT.JS SERVER (API ROUTE)                   │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │     apps/web/app/api/translate/route.ts                   │ │
│  │                                                            │ │
│  │  1. Validate request (text, sourceLanguage, targetLang)   │ │
│  │  2. Build translation prompt                              │ │
│  │  3. Call OpenAI API                                        │ │
│  │  4. Return translated text                                 │ │
│  │  5. Handle errors gracefully                               │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    POST to OpenAI API
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      OPENAI API (External)                      │
│                                                                 │
│  Model: gpt-4o-mini                                             │
│  System Prompt: "You are a professional translator..."         │
│  User Input: Korean text                                        │
│  Temperature: 0.3 (consistent translations)                     │
│  Max Tokens: 1000                                               │
│                                                                 │
│  Output: English translation                                    │
│  "Hello, I need help"                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    Response flows back
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                         USER'S BROWSER                          │
│                                                                 │
│  • English text appears in chat input                           │
│  • User can edit before sending                                 │
│  • User sends message to AI intake system                       │
│  • AI processes English text for assessment                     │
└─────────────────────────────────────────────────────────────────┘
```

### Component Architecture

```
src/
├── components/onboarding/steps/
│   └── AIChatPanel.tsx           # Main chat UI, integrates voice input
│       ├── Microphone button
│       ├── Status indicators
│       └── Uses useVoiceInput hook
│
├── hooks/
│   └── useVoiceInput.ts          # Core voice input + translation logic
│       ├── Web Speech API integration
│       ├── Translation trigger logic
│       ├── State management (listening, translating)
│       └── Error handling
│
├── lib/
│   └── translation.ts            # Translation utilities
│       ├── Language detection helpers
│       ├── Language code mappings
│       └── Client-side helper functions
│
└── app/api/translate/
    └── route.ts                  # Server-side translation endpoint
        ├── OpenAI API integration
        ├── Request validation
        ├── Error handling
        └── Rate limiting awareness
```

### Design Principles

1. **Separation of Concerns**
   - **UI Layer** (`AIChatPanel`): Handles user interaction, visual feedback
   - **Logic Layer** (`useVoiceInput`): Manages speech recognition and translation orchestration
   - **API Layer** (`/api/translate`): Securely handles OpenAI communication
   - **Utility Layer** (`translation.ts`): Provides reusable helper functions

2. **Progressive Enhancement**
   - Feature detection: Check if Web Speech API is supported
   - Graceful degradation: Hide microphone button if not supported
   - Fallback: Use original transcript if translation fails

3. **Single Responsibility**
   - Each component does one thing well
   - `useVoiceInput` handles voice, not UI
   - `AIChatPanel` handles UI, delegates voice logic to hook
   - API route handles translation, not transcription

4. **Privacy by Design**
   - Audio never leaves the browser
   - Only text is sent to server
   - API key secured server-side
   - No logging of sensitive parent information

5. **Performance First**
   - Browser handles transcription (no API latency)
   - Translation only triggered on final transcript (not interim)
   - Lightweight API route with minimal processing
   - Fast model choice (gpt-4o-mini)

---

## AI Integration Strategy

### Why OpenAI for Translation?

**Decision Matrix:**

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| **Google Translate API** | Fast, cheap, dedicated translation service | Less contextual, may miss nuances, separate service to manage | ❌ Rejected |
| **Browser Translation** | Free, instant, offline | Poor quality, not programmable, inconsistent | ❌ Rejected |
| **OpenAI GPT-4o-mini** | Contextual, preserves tone, already integrated, cost-effective | Slightly slower than dedicated APIs, requires OpenAI key | ✅ **Selected** |
| **Local Translation Model** | Private, no API costs, offline | Large bundle size, slower inference, limited language support | ❌ Rejected |

**Key Reasons for OpenAI:**

1. **Context Preservation**: GPT models understand context and preserve emotional tone
2. **Existing Integration**: Already using OpenAI for AI intake assessment
3. **Cost-Effective**: gpt-4o-mini is optimized for this use case
4. **Reliability**: High uptime, mature API, good error handling
5. **Flexibility**: Can tune prompts for better mental health context preservation

### Model Selection: GPT-4o-mini

**Why not GPT-4 or GPT-3.5-turbo?**

| Model | Cost (Input/Output) | Speed | Quality | Decision |
|-------|---------------------|-------|---------|----------|
| **gpt-4** | $30/$60 per 1M tokens | ~3-5s | Excellent | ❌ Overkill, too expensive |
| **gpt-3.5-turbo** | $0.50/$1.50 per 1M tokens | ~1-2s | Good | ⚠️ Good but newer models better |
| **gpt-4o-mini** | $0.15/$0.60 per 1M tokens | ~0.5-1s | Excellent for translation | ✅ **Selected** |
| **gpt-4o** | $2.50/$10 per 1M tokens | ~1-2s | Excellent | ❌ More expensive, speed similar |

**GPT-4o-mini is ideal because:**
- 3-10x cheaper than alternatives
- Specifically optimized for structured tasks like translation
- Fast enough for real-time UX (<1s responses)
- High quality for translation workloads
- Released in 2024, more capable than older models

### Prompt Engineering

**System Prompt:**
```
You are a professional translator. Detect the language of the input text 
and translate it to English. Return ONLY the translated text, nothing else. 
If the text is already in English, return it as-is.
```

**Design Choices:**
1. **Simple & Direct**: No verbose instructions → faster, cheaper responses
2. **Identity Only**: Return translation, no explanations or metadata
3. **Preserve Meaning**: Implicitly instructs to maintain tone and context
4. **Fallback Handling**: "If already English, return as-is" prevents unnecessary processing

**Temperature: 0.3**
- Low temperature = more deterministic, consistent translations
- Not 0.0 because we want slight flexibility for natural phrasing
- Not 1.0 because we don't want creative liberty in translation

**Max Tokens: 1000**
- Typical parent message: 50-200 tokens
- 1000 provides comfortable buffer
- Prevents runaway costs from edge cases

### AI Safety & Quality Controls

1. **Input Validation**
   - Max input length: ~500 characters (prevent abuse)
   - Reject empty strings
   - Sanitize special characters

2. **Output Validation**
   - Check response is non-empty
   - Fallback to original if translation seems failed
   - Log anomalies for review

3. **Rate Limiting**
   - Rely on Vercel's edge function limits
   - OpenAI has built-in rate limiting
   - Monitor for abuse patterns

4. **Quality Monitoring**
   - Sample 50 translations/month for human review
   - Track parent satisfaction scores
   - Flag translations with high edit rates (indicates poor quality)

---

## Data Flow

### Detailed Sequence Diagram

```
Parent                  Browser               Next.js Server          OpenAI API
  │                        │                        │                     │
  │  Click Microphone      │                        │                     │
  ├───────────────────────>│                        │                     │
  │                        │                        │                     │
  │  Speak in Korean       │                        │                     │
  │  "도움이 필요합니다"      │                        │                     │
  ├───────────────────────>│                        │                     │
  │                        │                        │                     │
  │                        │  Web Speech API        │                     │
  │                        │  (Browser Native)      │                     │
  │                        │  Transcribes audio     │                     │
  │                        │────┐                   │                     │
  │                        │    │ Real-time         │                     │
  │                        │    │ Korean→Text       │                     │
  │                        │<───┘                   │                     │
  │                        │                        │                     │
  │  Show: "🎤 Listening"  │                        │                     │
  │<───────────────────────┤                        │                     │
  │                        │                        │                     │
  │                        │  onresult event        │                     │
  │                        │  (final transcript)    │                     │
  │                        │────┐                   │                     │
  │                        │    │ isFinal=true      │                     │
  │                        │<───┘                   │                     │
  │                        │                        │                     │
  │                        │  Check: autoTranslate? │                     │
  │                        │  language !== "en"?    │                     │
  │                        │────┐                   │                     │
  │                        │    │ Yes, translate    │                     │
  │                        │<───┘                   │                     │
  │                        │                        │                     │
  │  Show: "🌐 Translating"│                        │                     │
  │<───────────────────────┤                        │                     │
  │                        │                        │                     │
  │                        │  POST /api/translate   │                     │
  │                        │  body: {               │                     │
  │                        │    text: "도움이...",   │                     │
  │                        │    sourceLang: "ko",   │                     │
  │                        │    targetLang: "en"    │                     │
  │                        │  }                     │                     │
  │                        ├───────────────────────>│                     │
  │                        │                        │                     │
  │                        │                        │  Validate request   │
  │                        │                        │  Build prompt       │
  │                        │                        │────┐                │
  │                        │                        │    │                │
  │                        │                        │<───┘                │
  │                        │                        │                     │
  │                        │                        │  POST /chat/completions
  │                        │                        │  {                  │
  │                        │                        │    model: "gpt-4o-mini"
  │                        │                        │    messages: [...]  │
  │                        │                        │    temperature: 0.3 │
  │                        │                        │  }                  │
  │                        │                        ├────────────────────>│
  │                        │                        │                     │
  │                        │                        │                     │ LLM Processing
  │                        │                        │                     │ (~500-1000ms)
  │                        │                        │                     │────┐
  │                        │                        │                     │    │
  │                        │                        │                     │<───┘
  │                        │                        │                     │
  │                        │                        │  {                  │
  │                        │                        │    translatedText:  │
  │                        │                        │    "I need help"    │
  │                        │                        │  }                  │
  │                        │                        │<────────────────────┤
  │                        │                        │                     │
  │                        │  {                     │                     │
  │                        │    translatedText:     │                     │
  │                        │    "I need help",      │                     │
  │                        │    originalText: "...", │                     │
  │                        │    wasTranslated: true │                     │
  │                        │  }                     │                     │
  │                        │<───────────────────────┤                     │
  │                        │                        │                     │
  │                        │  onResult callback     │                     │
  │                        │  setInput("I need help")│                     │
  │                        │────┐                   │                     │
  │                        │    │                   │                     │
  │                        │<───┘                   │                     │
  │                        │                        │                     │
  │  Input field shows:    │                        │                     │
  │  "I need help"         │                        │                     │
  │  (editable)            │                        │                     │
  │<───────────────────────┤                        │                     │
  │                        │                        │                     │
  │  Parent reviews        │                        │                     │
  │  Optionally edits      │                        │                     │
  │  Clicks Send           │                        │                     │
  ├───────────────────────>│                        │                     │
  │                        │                        │                     │
  │                        │  Send to AI Intake     │                     │
  │                        │  (separate flow)       │                     │
  │                        ├───────────────────────>│                     │
  │                        │                        │                     │
```

### State Management Flow

**React State Transitions:**

```typescript
// Initial State
{
  isListening: false,
  isTranslating: false,
  transcript: "",
  input: ""
}

// User clicks microphone
→ toggleListening() called
→ recognition.start()
→ isListening: true

// User speaks "도움이 필요합니다"
→ onresult fires (interim)
→ transcript: "도움이 필요" (partial)
→ Display in UI (optional preview)

// User finishes speaking
→ onresult fires (isFinal=true)
→ transcript: "도움이 필요합니다" (complete)
→ Check: autoTranslate && language !== "en"
→ isTranslating: true
→ POST /api/translate

// Translation returns
→ Receives: "I need help"
→ onResult("I need help")
→ setInput("I need help")
→ isTranslating: false
→ isListening: false
→ transcript: "" (cleared)

// Final State
{
  isListening: false,
  isTranslating: false,
  transcript: "",
  input: "I need help"
}
```

### Error Handling Flow

```
Error Occurs
     │
     ├──→ Translation API Error
     │    ├─→ Network timeout
     │    ├─→ OpenAI rate limit
     │    ├─→ Invalid API key
     │    └─→ Server error (500)
     │         │
     │         ├──→ Catch in useVoiceInput
     │         ├──→ Log error to console
     │         ├──→ Call onError callback
     │         ├──→ Fallback: use original transcript
     │         └──→ Show user-friendly message
     │
     ├──→ Web Speech API Error
     │    ├─→ no-speech (user silent)
     │    ├─→ audio-capture (no mic)
     │    ├─→ not-allowed (permissions)
     │    └─→ network (browser API issue)
     │         │
     │         ├──→ Catch in recognition.onerror
     │         ├──→ Map error code to message
     │         └──→ Display to user via onError
     │
     └──→ React/Component Error
          ├─→ State update after unmount
          ├─→ Cleanup issues
          └─→ Caught by error boundary
```

---

## Implementation Details

### File Structure

## How It Works

### 1. Voice Transcription (Browser)
- Uses Web Speech API to transcribe speech to text
- Supports multiple languages including Korean (`ko-KR`)
- Runs entirely in the browser (no API calls for transcription)

### 2. Automatic Translation (OpenAI)
- When `autoTranslate` is enabled, transcribed text is sent to OpenAI
- GPT-4o-mini model translates the text to English
- Fast and cost-effective translation
- Preserves meaning and tone

### 3. User Experience
- User clicks microphone button
- Speaks in Korean (or English)
- Browser transcribes speech to Korean text
- OpenAI translates Korean text to English
- English text appears in the chat input
- User can edit before sending

## Implementation Details

### Files Created/Modified

#### New Files:
1. **`apps/web/lib/translation.ts`**
   - Translation service using OpenAI API
   - Language detection utilities
   - Helper functions for language codes

2. **`apps/web/app/api/translate/route.ts`**
   - Next.js API route for translation
   - Handles OpenAI API calls server-side
   - Error handling and rate limiting

#### Modified Files:
1. **`apps/web/hooks/useVoiceInput.ts`**
   - Added `autoTranslate` and `targetLanguage` options
   - Added `isTranslating` state
   - Integrated translation logic into speech recognition flow

2. **`apps/web/components/onboarding/steps/AIChatPanel.tsx`**
   - Configured for Korean language (`ko-KR`)
   - Enabled auto-translation to English
   - Added translation status indicator

## Configuration

### Environment Variables
Ensure `OPENAI_API_KEY` is set in your environment:

```bash
# .env.local
OPENAI_API_KEY=sk-...
```

### Hook Usage

```typescript
const {
  isListening,
  isTranslating,
  transcript,
  toggleListening,
} = useVoiceInput({
  language: "ko-KR",        // Korean language
  autoTranslate: true,      // Enable translation
  targetLanguage: "en",     // Translate to English
  onResult: (translatedText) => {
    // translatedText is already in English
    console.log(translatedText);
  },
  onError: (error) => {
    console.error(error);
  },
});
```

## Supported Languages

### Transcription (Web Speech API)
The following languages are supported by most browsers:
- Korean: `ko-KR`
- English: `en-US`
- Spanish: `es-ES`, `es-MX`
- Chinese: `zh-CN`, `zh-TW`
- Japanese: `ja-JP`
- French: `fr-FR`
- Vietnamese: `vi-VN`

### Translation (OpenAI)
OpenAI supports translation between virtually all languages, including:
- Korean (ko)
- English (en)
- Spanish (es)
- Chinese (zh)
- Japanese (ja)
- French (fr)
- Vietnamese (vi)
- And many more...

## Cost Considerations

### Web Speech API (Free)
- Voice transcription is free
- Runs in the browser
- No API calls for transcription

### OpenAI Translation
- Uses GPT-4o-mini model (cost-effective)
- Approximate cost: $0.00015 per translation
- Example: 1000 translations ≈ $0.15

## Error Handling

The system gracefully handles errors:

1. **Translation Failure**: Falls back to original transcribed text
2. **Network Issues**: Shows user-friendly error message
3. **API Rate Limits**: Informs user to try again later
4. **Microphone Access**: Prompts user to enable permissions

## Privacy & Security

- Voice transcription happens in the browser (private)
- Only transcribed text is sent to OpenAI for translation
- No audio is recorded or stored
- All API calls are server-side (API key is secure)

## Testing

### Manual Testing Steps:
1. Navigate to the AI assessment chat
2. Click the microphone button
3. Speak in Korean: "안녕하세요, 저는 도움이 필요합니다"
4. Observe:
   - "🎤 Listening..." status appears
   - Korean text is transcribed
   - "🌐 Translating to English..." status appears
   - English translation appears in input: "Hello, I need help"
5. Send the message or edit before sending

### Expected Behavior:
- ✅ Korean speech is transcribed correctly
- ✅ Translation to English is accurate
- ✅ User can edit translated text before sending
- ✅ Error messages are user-friendly
- ✅ Works with both Korean and English speech

## Future Enhancements

### Potential Improvements:
1. **Language Selector**: Let users choose their language
2. **Bilingual Display**: Show both original and translated text
3. **Translation History**: Cache translations to reduce API calls
4. **Offline Mode**: Use local translation models
5. **Multiple Languages**: Support more language pairs
6. **Voice Output**: Text-to-speech in user's language

## Troubleshooting

### Common Issues:

**Issue**: Translation not working
- **Solution**: Check `OPENAI_API_KEY` is set correctly

**Issue**: Korean not transcribing
- **Solution**: Ensure browser supports Korean (Chrome/Edge recommended)

**Issue**: "Translation failed" error
- **Solution**: Check internet connection and OpenAI API status

**Issue**: Microphone not working
- **Solution**: Grant microphone permissions in browser settings

## Technical Architecture

```
User speaks Korean
       ↓
Web Speech API (Browser)
       ↓
Korean text transcribed
       ↓
POST /api/translate (Next.js)
       ↓
OpenAI GPT-4o-mini
       ↓
English translation
       ↓
Display in chat input
       ↓
User sends message
```

## Performance

- **Transcription**: Real-time (< 100ms)
- **Translation**: ~500-1000ms per request
- **Total Latency**: ~1 second from speech to translated text

## Browser Compatibility

| Browser | Transcription | Translation |
|---------|--------------|-------------|
| Chrome  | ✅ Full      | ✅ Full     |
| Edge    | ✅ Full      | ✅ Full     |
| Safari  | ⚠️ Limited   | ✅ Full     |
| Firefox | ❌ No        | ✅ Full     |

*Note: Safari has limited Web Speech API support. Firefox doesn't support Web Speech API.*

## Conclusion

This feature provides a seamless multilingual experience for users who prefer to speak in their native language while maintaining English as the system language for AI processing.

