'use client';

import React, { useRef, useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Send, Loader2, AlertCircle, Mic, MicOff } from 'lucide-react';
import { ChatMessage } from './AIIntakeChat';
import { cn } from '@/lib/utils';
import { useVoiceInput } from '@/hooks/useVoiceInput';

interface AIChatPanelProps {
  messages: ChatMessage[];
  isLoading: boolean;
  isStreaming: boolean;
  error: string | null;
  onSend: (e: React.FormEvent) => void;
  input: string;
  setInput: (value: string) => void;
}

export const AIChatPanel: React.FC<AIChatPanelProps> = ({
  messages,
  isLoading,
  isStreaming,
  error,
  onSend,
  input,
  setInput
}) => {
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const [voiceError, setVoiceError] = useState<string | null>(null);

  // Voice input hook
  const {
    isListening,
    isSupported: isVoiceSupported,
    transcript,
    toggleListening,
    resetTranscript,
  } = useVoiceInput({
    onResult: (finalTranscript) => {
      // Append to existing input or replace if empty
      setInput((prev) => {
        const trimmedPrev = prev.trim();
        return trimmedPrev ? `${trimmedPrev} ${finalTranscript}` : finalTranscript;
      });
      resetTranscript();
    },
    onError: (errorMessage) => {
      setVoiceError(errorMessage);
      setTimeout(() => setVoiceError(null), 5000); // Clear after 5 seconds
    },
    continuous: false,
    interimResults: true,
  });

  // Update input with interim transcript while listening
  useEffect(() => {
    if (isListening && transcript) {
      const trimmedInput = input.trim();
      // Show interim transcript as placeholder/preview
      if (trimmedInput) {
        // Don't override typed text, just show we're listening
      } else {
        // Show interim transcript in input
        setInput(transcript);
      }
    }
  }, [transcript, isListening, input, setInput]);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isStreaming]);

  // Focus input on mount
  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return (
    <div className="flex h-[500px] flex-col rounded-lg border bg-background">
      {/* Messages Area */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4" role="log" aria-live="polite" aria-label="Chat messages">
        {messages.map((message) => (
          <div
            key={message.id}
            className={cn(
              'flex',
              message.role === 'user' ? 'justify-end' : 'justify-start'
            )}
          >
            <div
              className={cn(
                'max-w-[80%] rounded-lg px-4 py-2',
                message.role === 'user'
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted text-foreground'
              )}
            >
              <p className="text-sm whitespace-pre-wrap">{message.content}</p>
              {message.timestamp && (
                <p className={cn(
                  'mt-1 text-xs',
                  message.role === 'user' ? 'text-primary-foreground/70' : 'text-muted-foreground'
                )}>
                  {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </p>
              )}
            </div>
          </div>
        ))}

        {isStreaming && (
          <div className="flex justify-start">
            <div className="max-w-[80%] rounded-lg bg-muted px-4 py-2">
              <div className="flex items-center gap-2">
                <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                <span className="text-sm text-muted-foreground">AI is typing...</span>
              </div>
            </div>
          </div>
        )}

        {error && (
          <div className="flex justify-center">
            <div className="flex items-center gap-2 rounded-md bg-destructive/10 px-4 py-2 text-sm text-destructive" role="alert">
              <AlertCircle className="h-4 w-4" />
              {error}
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Input Area */}
      <div className="border-t p-4">
        <form onSubmit={onSend} className="flex gap-2">
          <Input
            ref={inputRef}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={isListening ? "Listening... Speak now" : "Type or speak your message..."}
            disabled={isLoading}
            className={cn(
              "flex-1",
              isListening && "ring-2 ring-primary ring-offset-2"
            )}
            aria-label="Chat input"
            aria-describedby={error || voiceError ? 'chat-error' : undefined}
          />
          {isVoiceSupported && (
            <Button
              type="button"
              onClick={toggleListening}
              disabled={isLoading}
              size="icon"
              variant={isListening ? "destructive" : "outline"}
              className="shrink-0"
              aria-label={isListening ? "Stop voice input" : "Start voice input"}
              title={isListening ? "Stop voice input" : "Start voice input"}
            >
              {isListening ? (
                <MicOff className="h-4 w-4 animate-pulse" />
              ) : (
                <Mic className="h-4 w-4" />
              )}
            </Button>
          )}
          <Button
            type="submit"
            disabled={!input.trim() || isLoading}
            size="icon"
            className="shrink-0"
            aria-label="Send message"
          >
            {isLoading ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Send className="h-4 w-4" />
            )}
          </Button>
        </form>
        {(error || voiceError) && (
          <p id="chat-error" className="mt-2 text-xs text-destructive" role="alert">
            {voiceError || error}
          </p>
        )}
        {isListening && !voiceError && (
          <p className="mt-2 text-xs text-primary" role="status">
            🎤 Listening... Speak clearly into your microphone
          </p>
        )}
      </div>
    </div>
  );
};

