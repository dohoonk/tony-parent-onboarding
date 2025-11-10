'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { MessageCircle, X, Send, Loader2, User, Bot } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ChatMessage {
  id: string;
  role: 'user' | 'assistant' | 'staff';
  content: string;
  timestamp: Date;
  escalated?: boolean;
}

interface SupportChatProps {
  sessionId?: string;
}

export const SupportChat: React.FC<SupportChatProps> = ({ sessionId }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isEscalated, setIsEscalated] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

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
    setError(null);

    try {
      // TODO: Call GraphQL mutation to send message and get AI response
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      // Check if escalation is needed (mock logic)
      const needsEscalation = input.toLowerCase().includes('urgent') || 
                            input.toLowerCase().includes('emergency') ||
                            input.toLowerCase().includes('help me');

      if (needsEscalation && !isEscalated) {
        setIsEscalated(true);
        const escalationMessage: ChatMessage = {
          id: (Date.now() + 1).toString(),
          role: 'staff',
          content: "I've escalated your question to our support team. Someone will respond shortly. In the meantime, is there anything else I can help with?",
          timestamp: new Date(),
          escalated: true
        };
        setMessages((prev) => [...prev, escalationMessage]);
      } else {
        // AI response
        const aiMessage: ChatMessage = {
          id: (Date.now() + 1).toString(),
          role: 'assistant',
          content: "Thank you for your question! I'm here to help. Based on your question, here's some information that might be useful...",
          timestamp: new Date()
        };
        setMessages((prev) => [...prev, aiMessage]);
      }
    } catch (err) {
      setError('Failed to send message. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) {
    return (
      <Button
        variant="default"
        size="lg"
        onClick={() => setIsOpen(true)}
        className="fixed bottom-6 right-6 z-50 rounded-full shadow-lg h-14 w-14 p-0"
        aria-label="Open support chat"
      >
        <MessageCircle className="h-6 w-6" />
      </Button>
    );
  }

  return (
    <Card className="fixed bottom-6 right-6 z-50 w-96 h-[500px] shadow-xl flex flex-col">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">Need Help?</CardTitle>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsOpen(false)}
            className="h-6 w-6"
            aria-label="Close chat"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
        {isEscalated && (
          <p className="text-xs text-muted-foreground mt-1">
            Escalated to support team
          </p>
        )}
      </CardHeader>
      <CardContent className="flex-1 flex flex-col p-0">
        {/* Messages Area */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4" role="log" aria-live="polite">
          {messages.length === 0 && (
            <div className="text-center text-sm text-muted-foreground py-8">
              <MessageCircle className="h-8 w-8 mx-auto mb-2 opacity-50" />
              <p>How can we help you today?</p>
            </div>
          )}
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
                  'max-w-[80%] rounded-lg px-3 py-2 text-sm',
                  message.role === 'user'
                    ? 'bg-primary text-primary-foreground'
                    : message.role === 'staff'
                      ? 'bg-green-100 text-green-900 border border-green-200'
                      : 'bg-muted text-foreground'
                )}
              >
                <div className="flex items-start gap-2">
                  {message.role === 'assistant' && <Bot className="h-4 w-4 mt-0.5 shrink-0" />}
                  {message.role === 'staff' && <User className="h-4 w-4 mt-0.5 shrink-0" />}
                  <p className="whitespace-pre-wrap">{message.content}</p>
                </div>
                {message.escalated && (
                  <p className="text-xs mt-1 opacity-75">
                    Escalated to human support
                  </p>
                )}
              </div>
            </div>
          ))}
          {isLoading && (
            <div className="flex justify-start">
              <div className="bg-muted rounded-lg px-3 py-2">
                <Loader2 className="h-4 w-4 animate-spin" />
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input Area */}
        <div className="border-t p-4">
          <form onSubmit={handleSend} className="flex gap-2">
            <Input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Type your message..."
              disabled={isLoading || isEscalated}
              className="flex-1 text-sm"
              aria-label="Chat input"
            />
            <Button
              type="submit"
              disabled={!input.trim() || isLoading || isEscalated}
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
          {error && (
            <p className="text-xs text-destructive mt-2" role="alert">
              {error}
            </p>
          )}
        </div>
      </CardContent>
    </Card>
  );
};

