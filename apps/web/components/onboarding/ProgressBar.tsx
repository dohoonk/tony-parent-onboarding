'use client';

import React from 'react';
import { Progress } from '@/components/ui/progress';
import { cn } from '@/lib/utils';

interface ProgressBarProps {
  current: number;
  total: number;
  className?: string;
  showLabel?: boolean;
}

export const ProgressBar: React.FC<ProgressBarProps> = ({
  current,
  total,
  className,
  showLabel = true
}) => {
  const percentage = Math.round((current / total) * 100);

  return (
    <div className={cn('w-full', className)}>
      {showLabel && (
        <div className="mb-3 flex justify-between text-body-small">
          <span className="font-semibold text-foreground">
            Step {current} of {total}
          </span>
          <span className="font-medium text-muted-foreground">{percentage}% complete</span>
        </div>
      )}
      <Progress 
        value={percentage} 
        className="h-2.5"
        aria-label={`Onboarding progress: ${percentage}% complete, step ${current} of ${total}`}
      />
    </div>
  );
};

