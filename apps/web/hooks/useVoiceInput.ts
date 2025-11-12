"use client";

import { useEffect, useRef, useState, useCallback } from "react";

interface UseVoiceInputOptions {
  onResult?: (transcript: string) => void;
  onError?: (error: string) => void;
  continuous?: boolean;
  interimResults?: boolean;
  language?: string;
  autoTranslate?: boolean;
  targetLanguage?: string;
}

interface UseVoiceInputReturn {
  isListening: boolean;
  isSupported: boolean;
  transcript: string;
  isTranslating: boolean;
  startListening: () => void;
  stopListening: () => void;
  toggleListening: () => void;
  resetTranscript: () => void;
}

export function useVoiceInput({
  onResult,
  onError,
  continuous = false,
  interimResults = true,
  language = "en-US",
  autoTranslate = false,
  targetLanguage = "en",
}: UseVoiceInputOptions = {}): UseVoiceInputReturn {
  const [isListening, setIsListening] = useState(false);
  const [isSupported, setIsSupported] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [isTranslating, setIsTranslating] = useState(false);
  const recognitionRef = useRef<SpeechRecognition | null>(null);

  useEffect(() => {
    if (typeof window === "undefined") return;

    // Check for Speech Recognition support
    const SpeechRecognition = window.SpeechRecognition || (window as any).webkitSpeechRecognition;

    if (!SpeechRecognition) {
      setIsSupported(false);
      return;
    }

    setIsSupported(true);

    // Initialize Speech Recognition
    const recognition = new SpeechRecognition();
    recognition.continuous = continuous;
    recognition.interimResults = interimResults;
    recognition.lang = language;
    recognition.maxAlternatives = 1;

    recognition.onstart = () => {
      setIsListening(true);
    };

    recognition.onresult = async (event: SpeechRecognitionEvent) => {
      let finalTranscript = "";
      let interimTranscript = "";

      for (let i = event.resultIndex; i < event.results.length; i++) {
        const transcriptPiece = event.results[i][0].transcript;
        if (event.results[i].isFinal) {
          finalTranscript += transcriptPiece + " ";
        } else {
          interimTranscript += transcriptPiece;
        }
      }

      const currentTranscript = finalTranscript || interimTranscript;
      setTranscript(currentTranscript.trim());

      // Handle final transcript with optional translation
      if (finalTranscript && onResult) {
        const trimmedTranscript = finalTranscript.trim();
        
        // If auto-translate is enabled and not already in target language
        if (autoTranslate && language !== `${targetLanguage}-US` && language !== targetLanguage) {
          setIsTranslating(true);
          try {
            // Extract language code from full locale (e.g., "ko-KR" -> "ko")
            const sourceLang = language.split("-")[0];
            
            const response = await fetch("/api/translate", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                text: trimmedTranscript,
                sourceLanguage: sourceLang,
                targetLanguage: targetLanguage,
              }),
            });

            if (!response.ok) {
              throw new Error("Translation failed");
            }

            const result = await response.json();
            onResult(result.translatedText);
          } catch (error: any) {
            console.error("Translation error:", error);
            // Fall back to original transcript if translation fails
            onResult(trimmedTranscript);
            if (onError) {
              onError("Translation failed. Using original text.");
            }
          } finally {
            setIsTranslating(false);
          }
        } else {
          // No translation needed
          onResult(trimmedTranscript);
        }
      }
    };

    recognition.onerror = (event: SpeechRecognitionErrorEvent) => {
      console.error("Speech recognition error:", event.error);
      setIsListening(false);

      let errorMessage = "Voice input error occurred.";
      switch (event.error) {
        case "no-speech":
          errorMessage = "No speech detected. Please try again.";
          break;
        case "audio-capture":
          errorMessage = "Microphone not available. Please check your device settings.";
          break;
        case "not-allowed":
          errorMessage = "Microphone access denied. Please allow microphone permissions.";
          break;
        case "network":
          errorMessage = "Network error. Please check your connection.";
          break;
        case "aborted":
          // Silent error - user cancelled
          return;
        default:
          errorMessage = `Voice input error: ${event.error}`;
      }

      if (onError) {
        onError(errorMessage);
      }
    };

    recognition.onend = () => {
      setIsListening(false);
    };

    recognitionRef.current = recognition;

    return () => {
      if (recognitionRef.current) {
        recognitionRef.current.stop();
        recognitionRef.current = null;
      }
    };
  }, [continuous, interimResults, language, onResult, onError]);

  const startListening = useCallback(() => {
    if (!recognitionRef.current || isListening) return;

    try {
      setTranscript("");
      recognitionRef.current.start();
    } catch (error) {
      console.error("Error starting speech recognition:", error);
      if (onError) {
        onError("Failed to start voice input. Please try again.");
      }
    }
  }, [isListening, onError]);

  const stopListening = useCallback(() => {
    if (!recognitionRef.current || !isListening) return;

    try {
      recognitionRef.current.stop();
    } catch (error) {
      console.error("Error stopping speech recognition:", error);
    }
  }, [isListening]);

  const toggleListening = useCallback(() => {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  }, [isListening, startListening, stopListening]);

  const resetTranscript = useCallback(() => {
    setTranscript("");
  }, []);

  return {
    isListening,
    isSupported,
    transcript,
    isTranslating,
    startListening,
    stopListening,
    toggleListening,
    resetTranscript,
  };
}

