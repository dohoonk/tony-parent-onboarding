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
          content: "Hi! I'm here to help you share information about your child's mental health needs. This conversation is completely confidential and will help us match your child with the right therapist. What brings you here today?",
          timestamp: new Date()
        }
      ]);
    }
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
      // TODO: Call GraphQL mutation to send message and stream response
      // For now, simulate streaming
      await simulateStreamingResponse(userMessage.content);
    } catch (err) {
      setError('Failed to send message. Please try again.');
      console.error('Chat error:', err);
    } finally {
      setIsLoading(false);
      setIsStreaming(false);
    }
  };

  const simulateStreamingResponse = async (userInput: string) => {
    // Simulate streaming response
    const responseText = "Thank you for sharing that. Can you tell me more about how long this has been going on?";
    const words = responseText.split(' ');
    let currentText = '';

    for (let i = 0; i < words.length; i++) {
      await new Promise((resolve) => setTimeout(resolve, 50));
      currentText += (i > 0 ? ' ' : '') + words[i];
      
      setMessages((prev) => {
        const lastMessage = prev[prev.length - 1];
        if (lastMessage?.role === 'assistant' && lastMessage.id === 'streaming') {
          return [...prev.slice(0, -1), { ...lastMessage, content: currentText }];
        } else {
          return [...prev, {
            id: 'streaming',
            role: 'assistant',
            content: currentText,
            timestamp: new Date()
          }];
        }
      });
    }

    // Finalize message
    setMessages((prev) => {
      const lastMessage = prev[prev.length - 1];
      if (lastMessage?.id === 'streaming') {
        return [...prev.slice(0, -1), { ...lastMessage, id: Date.now().toString() }];
      }
      return prev;
    });
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
          Have a natural conversation with our AI assistant. Share what's on your mind about your child's mental health needs.
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

