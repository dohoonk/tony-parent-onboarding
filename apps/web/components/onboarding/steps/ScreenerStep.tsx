'use client';

import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import { Loader2, CheckCircle2 } from 'lucide-react';

interface ScreenerItem {
  id: string;
  text: string;
  options: Array<{ value: number; label: string }>;
}

interface Screener {
  id: string;
  key: string;
  title: string;
  description?: string;
  items: ScreenerItem[];
}

interface ScreenerStepProps {
  onNext: () => void;
  onPrev: () => void;
  sessionId?: string;
}

export const ScreenerStep: React.FC<ScreenerStepProps> = ({
  onNext,
  onPrev,
  sessionId
}) => {
  const [screener, setScreener] = useState<Screener | null>(null);
  const [answers, setAnswers] = useState<Record<string, number>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [interpretation, setInterpretation] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Load screener on mount
  useEffect(() => {
    loadScreener();
  }, []);

  const loadScreener = async () => {
    try {
      setIsLoading(true);
      // TODO: Fetch screener from GraphQL API
      // For now, use a sample PHQ-9 screener
      const sampleScreener: Screener = {
        id: '1',
        key: 'phq9',
        title: 'PHQ-9 Depression Screening',
        description: 'This brief questionnaire helps us understand how you\'ve been feeling. There are no right or wrong answers.',
        items: [
          {
            id: '1',
            text: 'Over the last 2 weeks, how often have you been bothered by little interest or pleasure in doing things?',
            options: [
              { value: 0, label: 'Not at all' },
              { value: 1, label: 'Several days' },
              { value: 2, label: 'More than half the days' },
              { value: 3, label: 'Nearly every day' }
            ]
          },
          {
            id: '2',
            text: 'Over the last 2 weeks, how often have you been bothered by feeling down, depressed, or hopeless?',
            options: [
              { value: 0, label: 'Not at all' },
              { value: 1, label: 'Several days' },
              { value: 2, label: 'More than half the days' },
              { value: 3, label: 'Nearly every day' }
            ]
          },
          {
            id: '3',
            text: 'Over the last 2 weeks, how often have you been bothered by trouble falling or staying asleep, or sleeping too much?',
            options: [
              { value: 0, label: 'Not at all' },
              { value: 1, label: 'Several days' },
              { value: 2, label: 'More than half the days' },
              { value: 3, label: 'Nearly every day' }
            ]
          }
        ]
      };
      setScreener(sampleScreener);
    } catch (err) {
      setError('Failed to load screener');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleAnswerChange = (itemId: string, value: number) => {
    setAnswers((prev) => ({ ...prev, [itemId]: value }));
  };

  const calculateScore = (): number => {
    return Object.values(answers).reduce((sum, value) => sum + value, 0);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!screener) return;

    const unanswered = screener.items.filter((item) => !(item.id in answers));
    if (unanswered.length > 0) {
      setError('Please answer all questions');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      // TODO: Call GraphQL mutation to submit screener
      const score = calculateScore();
      
      // Simulate AI interpretation
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      // TODO: Get actual interpretation from API
      const mockInterpretation = `Thank you for completing this assessment. Your responses help us understand how you've been feeling. Based on your answers, we'll work together to find the right support for you.`;
      
      setInterpretation(mockInterpretation);
    } catch (err) {
      setError('Failed to submit screener. Please try again.');
      console.error(err);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (!screener) {
    return (
      <div className="rounded-md border border-destructive bg-destructive/10 p-4">
        <p className="text-destructive">Failed to load screener</p>
      </div>
    );
  }

  if (interpretation) {
    return (
      <div className="space-y-6">
        <Card className="border-green-200 bg-green-50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-5 w-5 text-green-600" />
              <CardTitle>Assessment Complete</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">{interpretation}</p>
            <Button onClick={onNext} className="w-full sm:w-auto">
              Continue
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">{screener.title}</h3>
        {screener.description && (
          <p className="mt-2 text-sm text-muted-foreground">{screener.description}</p>
        )}
      </div>

      <div className="space-y-6">
        {screener.items.map((item, index) => (
          <Card key={item.id}>
            <CardContent className="pt-6">
              <div className="space-y-4">
                <Label className="text-base font-medium">
                  {index + 1}. {item.text}
                </Label>
                <RadioGroup
                  value={answers[item.id]?.toString()}
                  onValueChange={(value) => handleAnswerChange(item.id, parseInt(value))}
                  className="space-y-2"
                >
                  {item.options.map((option) => (
                    <div key={option.value} className="flex items-center space-x-2">
                      <RadioGroupItem
                        value={option.value.toString()}
                        id={`${item.id}-${option.value}`}
                      />
                      <Label
                        htmlFor={`${item.id}-${option.value}`}
                        className="font-normal cursor-pointer"
                      >
                        {option.label}
                      </Label>
                    </div>
                  ))}
                </RadioGroup>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {error && (
        <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive" role="alert">
          {error}
        </div>
      )}

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
        <Button type="submit" disabled={isSubmitting} className="w-full sm:w-auto">
          {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
          Submit Assessment
        </Button>
      </div>
    </form>
  );
};

