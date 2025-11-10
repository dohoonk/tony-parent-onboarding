'use client';

import React from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Clock, RefreshCw } from 'lucide-react';

interface ResumeOnboardingDialogProps {
  open: boolean;
  onResume: () => void;
  onStartFresh: () => void;
  lastSaveDate?: Date;
  completedSteps?: number;
  totalSteps?: number;
}

export const ResumeOnboardingDialog: React.FC<ResumeOnboardingDialogProps> = ({
  open,
  onResume,
  onStartFresh,
  lastSaveDate,
  completedSteps = 0,
  totalSteps = 8
}) => {
  const formatDate = (date: Date): string => {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 60) {
      return `${diffMins} minute${diffMins !== 1 ? 's' : ''} ago`;
    } else if (diffHours < 24) {
      return `${diffHours} hour${diffHours !== 1 ? 's' : ''} ago`;
    } else {
      return `${diffDays} day${diffDays !== 1 ? 's' : ''} ago`;
    }
  };

  const percentage = Math.round((completedSteps / totalSteps) * 100);

  return (
    <Dialog open={open}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Welcome Back!</DialogTitle>
          <DialogDescription>
            We found your previous onboarding session. Would you like to continue where you left off?
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          <div className="flex items-center gap-3 rounded-md border bg-muted/50 p-4">
            <Clock className="h-5 w-5 text-muted-foreground" />
            <div>
              <p className="text-sm font-medium">Last saved</p>
              <p className="text-xs text-muted-foreground">
                {lastSaveDate ? formatDate(lastSaveDate) : 'Unknown'}
              </p>
            </div>
          </div>

          <div className="rounded-md border bg-muted/50 p-4">
            <div className="mb-2 flex items-center justify-between text-sm">
              <span className="font-medium">Progress</span>
              <span className="text-muted-foreground">{percentage}% complete</span>
            </div>
            <div className="h-2 overflow-hidden rounded-full bg-muted">
              <div
                className="h-full bg-primary transition-all"
                style={{ width: `${percentage}%` }}
              />
            </div>
            <p className="mt-2 text-xs text-muted-foreground">
              {completedSteps} of {totalSteps} steps completed
            </p>
          </div>
        </div>

        <DialogFooter className="flex-col gap-2 sm:flex-row">
          <Button variant="outline" onClick={onStartFresh} className="w-full sm:w-auto">
            <RefreshCw className="mr-2 h-4 w-4" />
            Start Fresh
          </Button>
          <Button onClick={onResume} className="w-full sm:w-auto">
            Continue
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

