'use client';

import React, { useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Loader2, HelpCircle, X, Send } from 'lucide-react';
import { cn } from '@/lib/utils';

interface InlineFAQProps {
  context?: {
    stepName?: string;
    progressPercent?: number;
    timeSpent?: string;
  };
  onAnswer?: (answer: string) => void;
}

export const InlineFAQ: React.FC<InlineFAQProps> = ({ context, onAnswer }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!question.trim() || isLoading) return;

    setIsLoading(true);
    setError(null);

    try {
      // TODO: Call GraphQL query to get FAQ answer
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      // Mock answer
      const mockAnswer = "Thank you for your question! Our team is here to help. You can reach out anytime if you need support during this process.";
      setAnswer(mockAnswer);
      onAnswer?.(mockAnswer);
    } catch (err) {
      setError('Failed to get answer. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) {
    return (
      <Button
        variant="outline"
        size="sm"
        onClick={() => setIsOpen(true)}
        className="fixed bottom-4 right-4 z-50 shadow-lg"
        aria-label="Open FAQ"
      >
        <HelpCircle className="mr-2 h-4 w-4" />
        Need help?
      </Button>
    );
  }

  return (
    <Card className="fixed bottom-4 right-4 z-50 w-80 shadow-lg">
      <CardContent className="p-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-semibold text-sm">Have a question?</h3>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => {
              setIsOpen(false);
              setQuestion('');
              setAnswer(null);
            }}
            className="h-6 w-6"
            aria-label="Close FAQ"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>

        {answer ? (
          <div className="space-y-3">
            <div className="rounded-md bg-muted p-3 text-sm">
              <p>{answer}</p>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                setAnswer(null);
                setQuestion('');
              }}
              className="w-full"
            >
              Ask Another Question
            </Button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-3">
            <Input
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              placeholder="Ask a question..."
              disabled={isLoading}
              className="text-sm"
            />
            {error && (
              <p className="text-xs text-destructive">{error}</p>
            )}
            <Button
              type="submit"
              disabled={!question.trim() || isLoading}
              size="sm"
              className="w-full"
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                  Getting answer...
                </>
              ) : (
                <>
                  <Send className="mr-2 h-3 w-3" />
                  Ask
                </>
              )}
            </Button>
          </form>
        )}
      </CardContent>
    </Card>
  );
};

