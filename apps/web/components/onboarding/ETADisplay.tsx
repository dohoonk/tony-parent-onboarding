'use client';

import React, { useEffect, useState } from 'react';
import { Clock } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ETADisplayProps {
  estimatedSeconds: number;
  className?: string;
}

export const ETADisplay: React.FC<ETADisplayProps> = ({
  estimatedSeconds,
  className
}) => {
  const [timeRemaining, setTimeRemaining] = useState(estimatedSeconds);

  useEffect(() => {
    setTimeRemaining(estimatedSeconds);
  }, [estimatedSeconds]);

  useEffect(() => {
    if (timeRemaining <= 0) return;

    const interval = setInterval(() => {
      setTimeRemaining((prev) => Math.max(0, prev - 1));
    }, 1000);

    return () => clearInterval(interval);
  }, [timeRemaining]);

  const formatTime = (seconds: number): string => {
    if (seconds < 60) {
      return `${seconds} sec`;
    }
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    if (minutes < 60) {
      return remainingSeconds > 0
        ? `${minutes} min ${remainingSeconds} sec`
        : `${minutes} min`;
    }
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    return `${hours}h ${remainingMinutes}m`;
  };

  return (
    <div
      className={cn(
        'flex items-center gap-2 rounded-md bg-muted px-3 py-2 text-sm',
        className
      )}
      role="timer"
      aria-live="polite"
    >
      <Clock className="h-4 w-4 text-muted-foreground" aria-hidden="true" />
      <span className="font-medium">Time remaining:</span>
      <span className="text-muted-foreground">{formatTime(timeRemaining)}</span>
    </div>
  );
};

