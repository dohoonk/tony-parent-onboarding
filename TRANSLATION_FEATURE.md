# Voice Input Translation Feature

## Overview
This feature enables users to speak in Korean (or other languages) and have their speech automatically transcribed and translated to English using OpenAI's GPT models.

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

