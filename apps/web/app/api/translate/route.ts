import { NextRequest, NextResponse } from "next/server";
import OpenAI from "openai";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

interface TranslateRequest {
  text: string;
  sourceLanguage?: string;
  targetLanguage?: string;
}

export async function POST(request: NextRequest) {
  try {
    const body: TranslateRequest = await request.json();
    const { text, sourceLanguage = "auto", targetLanguage = "en" } = body;

    if (!text || !text.trim()) {
      return NextResponse.json(
        { error: "Text is required" },
        { status: 400 }
      );
    }

    if (!process.env.OPENAI_API_KEY) {
      return NextResponse.json(
        { error: "OpenAI API key not configured" },
        { status: 500 }
      );
    }

    // Build the translation prompt
    let systemPrompt = "";
    let userPrompt = "";

    if (sourceLanguage === "auto") {
      // Auto-detect and translate
      systemPrompt = `You are a professional translator. Detect the language of the input text and translate it to ${getLanguageName(targetLanguage)}. Return ONLY the translated text, nothing else. If the text is already in ${getLanguageName(targetLanguage)}, return it as-is.`;
      userPrompt = text;
    } else {
      // Specific language translation
      systemPrompt = `You are a professional translator. Translate the following ${getLanguageName(sourceLanguage)} text to ${getLanguageName(targetLanguage)}. Return ONLY the translated text, nothing else. Preserve the meaning and tone accurately.`;
      userPrompt = text;
    }

    // Call OpenAI for translation
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini", // Fast and cost-effective for translation
      messages: [
        {
          role: "system",
          content: systemPrompt,
        },
        {
          role: "user",
          content: userPrompt,
        },
      ],
      temperature: 0.3, // Lower temperature for more consistent translations
      max_tokens: 1000,
    });

    const translatedText = completion.choices[0]?.message?.content?.trim() || text;

    // Detect if translation actually occurred (simple heuristic)
    const wasTranslated = translatedText !== text;

    return NextResponse.json({
      translatedText,
      originalText: text,
      sourceLanguage: sourceLanguage === "auto" ? "detected" : sourceLanguage,
      targetLanguage,
      wasTranslated,
    });
  } catch (error: any) {
    console.error("Translation API error:", error);
    
    // Handle specific OpenAI errors
    if (error.status === 401) {
      return NextResponse.json(
        { error: "Invalid OpenAI API key" },
        { status: 401 }
      );
    }
    
    if (error.status === 429) {
      return NextResponse.json(
        { error: "Rate limit exceeded. Please try again later." },
        { status: 429 }
      );
    }

    return NextResponse.json(
      { error: error.message || "Translation failed" },
      { status: 500 }
    );
  }
}

/**
 * Helper to get language names
 */
function getLanguageName(code: string): string {
  const names: Record<string, string> = {
    en: "English",
    ko: "Korean",
    zh: "Chinese",
    es: "Spanish",
    ja: "Japanese",
    fr: "French",
    vi: "Vietnamese",
    auto: "the detected language",
  };
  return names[code] || code;
}

