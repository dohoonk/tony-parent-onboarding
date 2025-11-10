'use client';

import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { CheckCircle2, Calendar, User, DollarSign, FileText, Loader2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

interface SummaryStepProps {
  onComplete: () => void;
  sessionId?: string;
}

export const SummaryStep: React.FC<SummaryStepProps> = ({
  onComplete,
  sessionId
}) => {
  const [summary, setSummary] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSending, setIsSending] = useState(false);

  useEffect(() => {
    loadSummary();
  }, [sessionId]);

  const loadSummary = async () => {
    setIsLoading(true);
    try {
      // TODO: Fetch summary from GraphQL API
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      // Mock summary data
      setSummary({
        parentName: 'John Doe',
        studentName: 'Jane Doe',
        appointmentDate: '2024-01-15',
        appointmentTime: '2:00 PM',
        therapistName: 'Dr. Sarah Johnson',
        estimatedCost: '$20 - $50 per session',
        nextSteps: [
          'You will receive a confirmation email and SMS shortly',
          'Your therapist will reach out before your first session',
          'Complete any remaining paperwork if needed',
          'Prepare for your first session by thinking about goals'
        ],
        timeline: {
          'Before first session': 'Therapist introduction and preparation materials',
          'First session': 'Initial assessment and goal setting',
          'Ongoing sessions': 'Regular therapy sessions as scheduled'
        }
      });
    } catch (err) {
      console.error('Failed to load summary:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSendNotifications = async () => {
    setIsSending(true);
    try {
      // TODO: Call GraphQL mutation to send notifications
      await new Promise((resolve) => setTimeout(resolve, 2000));
      // Notifications sent
    } catch (err) {
      console.error('Failed to send notifications:', err);
    } finally {
      setIsSending(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="text-center">
        <CheckCircle2 className="h-16 w-16 text-green-600 mx-auto mb-4" />
        <h2 className="text-3xl font-bold tracking-tight">You&apos;re All Set!</h2>
        <p className="mt-2 text-muted-foreground">
          Thank you for completing the onboarding process. Here&apos;s what happens next.
        </p>
      </div>

      {summary && (
        <>
          {/* Appointment Summary */}
          <Card>
            <CardHeader>
              <div className="flex items-center gap-2">
                <Calendar className="h-5 w-5 text-primary" />
                <CardTitle>Your Appointment</CardTitle>
              </div>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <p className="text-sm font-medium">Therapist</p>
                <p className="text-sm text-muted-foreground">{summary.therapistName}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Date & Time</p>
                <p className="text-sm text-muted-foreground">
                  {summary.appointmentDate} at {summary.appointmentTime}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium">Estimated Cost</p>
                <p className="text-sm text-muted-foreground">{summary.estimatedCost}</p>
              </div>
            </CardContent>
          </Card>

          {/* What Happens Next */}
          <Card>
            <CardHeader>
              <CardTitle>What Happens Next</CardTitle>
              <CardDescription>Here&apos;s your timeline and next steps</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <h4 className="font-semibold mb-2">Immediate Next Steps</h4>
                <ul className="space-y-2">
                  {summary.nextSteps.map((step: string, index: number) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <CheckCircle2 className="h-4 w-4 text-green-600 mt-0.5 shrink-0" />
                      <span>{step}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="border-t pt-4">
                <h4 className="font-semibold mb-3">Timeline</h4>
                <div className="space-y-3">
                  {Object.entries(summary.timeline).map(([key, value]) => (
                    <div key={key} className="flex items-start gap-3">
                      <Badge variant="outline" className="shrink-0">
                        {key}
                      </Badge>
                      <p className="text-sm text-muted-foreground flex-1">{value as string}</p>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Support Information */}
          <Card className="bg-muted/50">
            <CardHeader>
              <CardTitle className="text-lg">Need Help?</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground mb-4">
                If you have any questions or need to make changes to your appointment, 
                please reach out to our support team. We&apos;re here to help!
              </p>
              <div className="flex flex-col sm:flex-row gap-3">
                <Button variant="outline" className="flex-1">
                  Contact Support
                </Button>
                <Button variant="outline" className="flex-1">
                  View Appointment Details
                </Button>
              </div>
            </CardContent>
          </Card>
        </>
      )}

      <div className="flex justify-center">
        <Button
          onClick={() => {
            handleSendNotifications();
            onComplete();
          }}
          disabled={isSending}
          size="lg"
          className="w-full sm:w-auto"
        >
          {isSending ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Sending notifications...
            </>
          ) : (
            'Complete Onboarding'
          )}
        </Button>
      </div>
    </div>
  );
};

