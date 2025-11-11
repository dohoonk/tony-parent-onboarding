'use client';

import React from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { CheckCircle2, Edit2, AlertTriangle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

interface IntakeSummary {
  concerns: string[];
  goals: string[];
  risk_flags: string[];
  summary_text: string;
}

interface IntakeSummaryReviewProps {
  summary: IntakeSummary;
  onEdit: () => void;
  onContinue: () => void;
}

export const IntakeSummaryReview: React.FC<IntakeSummaryReviewProps> = ({
  summary,
  onEdit,
  onContinue
}) => {
  return (
    <div className="space-y-4">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">Review Your Intake Summary</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Please review the information we've gathered from our conversation. You can add more details or continue to the next step.
        </p>
      </div>

      {/* Summary Text */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Conversation Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">{summary.summary_text}</p>
        </CardContent>
      </Card>

      {/* Concerns */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Main Concerns</CardTitle>
          <CardDescription>Key challenges and concerns you've shared</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {summary.concerns.length > 0 ? (
              summary.concerns.map((concern, index) => (
                <Badge key={index} variant="secondary" className="text-sm">
                  {concern}
                </Badge>
              ))
            ) : (
              <p className="text-sm text-muted-foreground">No specific concerns identified</p>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Goals */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Therapy Goals</CardTitle>
          <CardDescription>What you hope to achieve through therapy</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {summary.goals.length > 0 ? (
              summary.goals.map((goal, index) => (
                <Badge key={index} variant="outline" className="text-sm">
                  {goal}
                </Badge>
              ))
            ) : (
              <p className="text-sm text-muted-foreground">No specific goals identified yet</p>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Risk Flags */}
      {summary.risk_flags && summary.risk_flags.length > 0 && (
        <Card className="border-yellow-200 bg-yellow-50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-yellow-600" />
              <CardTitle className="text-lg text-yellow-900">Important Notes</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <ul className="list-disc list-inside space-y-1 text-sm text-yellow-800">
              {summary.risk_flags.map((flag, index) => (
                <li key={index}>{flag}</li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}

      {/* Actions */}
      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button
          type="button"
          variant="outline"
          onClick={onEdit}
          className="w-full sm:w-auto"
        >
          <Edit2 className="h-4 w-4 mr-2" />
          Add More Details
        </Button>
        <Button
          onClick={onContinue}
          className="w-full sm:w-auto"
        >
          <CheckCircle2 className="h-4 w-4 mr-2" />
          Continue to Next Step
        </Button>
      </div>
    </div>
  );
};

