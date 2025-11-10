'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import { Send, Loader2 } from 'lucide-react';
import { ChatMessage } from './AIIntakeChat';
import { AIChatPanel } from './AIChatPanel';

interface AIIntakeStepProps {
  onNext: () => void;
  onPrev: () => void;
  sessionId?: string;
}

export const AIIntakeStep: React.FC<AIIntakeStepProps> = ({
  onNext,
  onPrev,
  sessionId
}) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isStreaming, setIsStreaming] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Initialize with welcome message
  useEffect(() => {
    if (messages.length === 0) {
      setMessages([
        {
          id: '1',
          role: 'assistant',
          content: "Hi! I&apos;m here to help you share information about your child&apos;s mental health needs. This conversation is completely confidential and will help us match your child with the right therapist. What brings you here today?",
          timestamp: new Date()
        }
      ]);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: input.trim(),
      timestamp: new Date()
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);
    setIsStreaming(true);
    setError(null);

    try {
      // TODO: Call GraphQL mutation to send message first
      // For now, we'll use a temporary ID and call streaming
      const tempMessageId = userMessage.id;
      
      // Start streaming response
      await handleStreamingResponse(tempMessageId);
    } catch (err) {
      setError('Failed to send message. Please try again.');
      console.error('Chat error:', err);
      setIsLoading(false);
      setIsStreaming(false);
    }
  };

  const handleStreamingResponse = async (userMessageId: string) => {
    if (!sessionId) {
      setError('Session ID is required');
      return;
    }

    // TODO: Get auth token from context/store
    const token = localStorage.getItem('auth_token') || '';
    
    // Import streaming client dynamically
    const { StreamingClient } = await import('@/lib/streaming-client');
    
    const streamClient = new StreamingClient(
      // onChunk
      (chunk: string) => {
        setMessages((prev) => {
          const lastMessage = prev[prev.length - 1];
          if (lastMessage?.role === 'assistant' && lastMessage.id === 'streaming') {
            return [...prev.slice(0, -1), { ...lastMessage, content: lastMessage.content + chunk }];
          } else {
            return [...prev, {
              id: 'streaming',
              role: 'assistant',
              content: chunk,
              timestamp: new Date()
            }];
          }
        });
      },
      // onComplete
      (messageId: string) => {
        setMessages((prev) => {
          const lastMessage = prev[prev.length - 1];
          if (lastMessage?.id === 'streaming') {
            return [...prev.slice(0, -1), { ...lastMessage, id: messageId }];
          }
          return prev;
        });
        setIsStreaming(false);
      },
      // onError
      (error: string) => {
        setError(error);
        setIsStreaming(false);
        // Remove streaming message on error
        setMessages((prev) => prev.filter(msg => msg.id !== 'streaming'));
      }
    );

    streamClient.start(sessionId, userMessageId, token);
  };

  const handleContinue = () => {
    // TODO: Extract summary before continuing
    onNext();
  };

  return (
    <div className="space-y-4">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">AI-Powered Intake Conversation</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Have a natural conversation with our AI assistant. Share what&apos;s on your mind about your child&apos;s mental health needs.
        </p>
      </div>

      <AIChatPanel
        messages={messages}
        isLoading={isLoading}
        isStreaming={isStreaming}
        error={error}
        onSend={handleSend}
        input={input}
        setInput={setInput}
      />

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
        <Button
          onClick={handleContinue}
          disabled={messages.length < 2}
          className="w-full sm:w-auto"
        >
          Continue to Next Step
        </Button>
      </div>
    </div>
  );
};

