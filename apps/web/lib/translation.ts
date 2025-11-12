/**
 * Translation service using OpenAI
 */

interface TranslationOptions {
  text: string;
  sourceLanguage?: string;
  targetLanguage?: string;
}

interface TranslationResult {
  translatedText: string;
  originalText: string;
  sourceLanguage: string;
  targetLanguage: string;
  detectedLanguage?: string;
}

/**
 * Translate text using OpenAI's GPT model
 * @param options Translation options
 * @returns Translated text result
 */
export async function translateText({
  text,
  sourceLanguage = "auto",
  targetLanguage = "en",
}: TranslationOptions): Promise<TranslationResult> {
  if (!text.trim()) {
    throw new Error("Text to translate cannot be empty");
  }

  // If source is English and target is English, no translation needed
  if (sourceLanguage === "en" && targetLanguage === "en") {
    return {
      translatedText: text,
      originalText: text,
      sourceLanguage: "en",
      targetLanguage: "en",
    };
  }

  try {
    const response = await fetch("/api/translate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        text,
        sourceLanguage,
        targetLanguage,
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || "Translation failed");
    }

    const result = await response.json();
    return result;
  } catch (error: any) {
    console.error("Translation error:", error);
    throw new Error(error.message || "Failed to translate text");
  }
}

/**
 * Detect if text is likely non-English
 * Simple heuristic based on character ranges
 */
export function detectNonEnglish(text: string): boolean {
  // Korean characters (Hangul)
  const koreanRegex = /[\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F]/;
  
  // Chinese characters (Simplified & Traditional)
  const chineseRegex = /[\u4E00-\u9FFF\u3400-\u4DBF]/;
  
  // Japanese characters (Hiragana, Katakana, Kanji)
  const japaneseRegex = /[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]/;
  
  // Spanish/French special characters
  const latinExtRegex = /[àáâãäåèéêëìíîïòóôõöùúûüýÿñçÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝŸÑÇ]/;
  
  return (
    koreanRegex.test(text) ||
    chineseRegex.test(text) ||
    japaneseRegex.test(text) ||
    latinExtRegex.test(text)
  );
}

/**
 * Language code mappings
 */
export const LANGUAGE_NAMES: Record<string, string> = {
  "en": "English",
  "ko": "Korean",
  "zh": "Chinese",
  "es": "Spanish",
  "ja": "Japanese",
  "fr": "French",
  "vi": "Vietnamese",
  "auto": "Auto-detect",
};

/**
 * Get language name from code
 */
export function getLanguageName(code: string): string {
  return LANGUAGE_NAMES[code] || code;
}

