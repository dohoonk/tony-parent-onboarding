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
      setError('Session ID is required. Please go back and complete the previous steps.');
      setIsLoading(false);
      setIsStreaming(false);
      return;
    }

    // Check if this is a temporary session ID (development mode)
    const isTempSession = sessionId.startsWith('temp-session-');
    
    if (isTempSession) {
      // Development mode: Simulate AI response since we don't have a real backend session
      setIsStreaming(true);
      
      // Get the last user message to generate context-aware response
      const lastUserMessage = messages.findLast(msg => msg.role === 'user');
      const userInput = lastUserMessage?.content.toLowerCase() || '';
      
      // Count conversation turns to track progress
      const userMessageCount = messages.filter(msg => msg.role === 'user').length;
      
      // Generate context-aware response based on user input and conversation progress
      let simulatedResponse = '';
      
      if (userMessageCount === 1) {
        // First user response - acknowledge and ask about duration/impact
        if (userInput.includes('anxiety') || userInput.includes('worr') || userInput.includes('stress')) {
          simulatedResponse = "Thank you for sharing that. I understand that anxiety can be really challenging for children. Can you tell me a bit more about when you first noticed these concerns, and how it's been affecting your child's daily life?";
        } else if (userInput.includes('depress') || userInput.includes('sad') || userInput.includes('down')) {
          simulatedResponse = "I appreciate you sharing that with me. It takes courage to talk about these concerns. Can you help me understand when you first noticed these changes, and what impact they've had on your child's daily activities?";
        } else if (userInput.includes('behavior') || userInput.includes('act') || userInput.includes('tantrum')) {
          simulatedResponse = "Thank you for opening up about this. Behavioral changes can be concerning for parents. When did you first start noticing these behaviors, and how have they been affecting your child's relationships or school performance?";
        } else {
          simulatedResponse = "Thank you for sharing that. I'd like to understand more about your child's situation. Can you tell me when you first noticed these concerns, and how they've been impacting your child's daily life?";
        }
      } else if (userMessageCount === 2) {
        // Second user response - acknowledge timeline and ask about specific impacts
        if (userInput.includes('year') || userInput.includes('month') || userInput.includes('week') || userInput.includes('ago')) {
          simulatedResponse = "I see. That's helpful context. How has this been affecting your child's school performance, friendships, or family relationships?";
        } else if (userInput.includes('grade') || userInput.includes('school') || userInput.includes('academic')) {
          simulatedResponse = "Thank you for that detail. School can be a big source of stress. Besides academics, have you noticed changes in how your child interacts with friends or family members?";
        } else {
          simulatedResponse = "I appreciate you sharing more details. Can you help me understand what specific areas of your child's life have been most affected by these concerns?";
        }
      } else if (userMessageCount === 3) {
        // Third user response - acknowledge impacts and ask about goals
        simulatedResponse = "Thank you for providing that context. It sounds like this has been affecting multiple areas of your child's life. What are you hoping therapy might help your child achieve? What would success look like for your family?";
      } else {
        // Fourth+ response - acknowledge and ask about goals or wrap up
        if (userInput.includes('goal') || userInput.includes('hope') || userInput.includes('want') || userInput.includes('need')) {
          simulatedResponse = "That's really helpful to know. Thank you for sharing your hopes and goals. Is there anything else you'd like me to know about your child's situation before we move forward?";
        } else {
          simulatedResponse = "I appreciate you sharing that. You've given me a good understanding of your child's situation. Is there anything else you'd like to add, or are you ready to move on to the next step?";
        }
      }
      
      // Simulate chunked streaming
      const words = simulatedResponse.split(' ');
      let currentContent = '';
      
      for (let i = 0; i < words.length; i++) {
        await new Promise(resolve => setTimeout(resolve, 50)); // Simulate delay
        currentContent += (i > 0 ? ' ' : '') + words[i];
        
        setMessages((prev) => {
          const lastMessage = prev[prev.length - 1];
          if (lastMessage?.role === 'assistant' && lastMessage.id === 'streaming') {
            return [...prev.slice(0, -1), { ...lastMessage, content: currentContent }];
          } else {
            return [...prev, {
              id: 'streaming',
              role: 'assistant',
              content: currentContent,
              timestamp: new Date()
            }];
          }
        });
      }
      
      // Mark as complete
      setMessages((prev) => {
        const lastMessage = prev[prev.length - 1];
        if (lastMessage?.id === 'streaming') {
          return [...prev.slice(0, -1), { ...lastMessage, id: Date.now().toString() }];
        }
        return prev;
      });
      
      setIsStreaming(false);
      setIsLoading(false);
      return;
    }

    // Production mode: Use real streaming
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
        setIsLoading(false);
      },
      // onError
      (error: string) => {
        setError(error);
        setIsStreaming(false);
        setIsLoading(false);
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

