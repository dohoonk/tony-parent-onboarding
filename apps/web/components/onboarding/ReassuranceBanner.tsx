'use client';

import React, { useState, useEffect } from 'react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Heart, X } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface ReassuranceBannerProps {
  message: string;
  onDismiss?: () => void;
  autoHide?: boolean;
  hideAfter?: number; // milliseconds
}

export const ReassuranceBanner: React.FC<ReassuranceBannerProps> = ({
  message,
  onDismiss,
  autoHide = true,
  hideAfter = 5000
}) => {
  const [isVisible, setIsVisible] = useState(true);

  useEffect(() => {
    if (autoHide && isVisible) {
      const timer = setTimeout(() => {
        setIsVisible(false);
        onDismiss?.();
      }, hideAfter);

      return () => clearTimeout(timer);
    }
  }, [autoHide, hideAfter, isVisible, onDismiss]);

  if (!isVisible) return null;

  return (
    <Alert className="mb-4 border-blue-200 bg-blue-50">
      <Heart className="h-4 w-4 text-blue-600" />
      <AlertDescription className="flex items-center justify-between">
        <span className="text-sm text-blue-900">{message}</span>
        {onDismiss && (
          <Button
            variant="ghost"
            size="icon"
            onClick={() => {
              setIsVisible(false);
              onDismiss();
            }}
            className="h-6 w-6 text-blue-600 hover:text-blue-800"
            aria-label="Dismiss"
          >
            <X className="h-3 w-3" />
          </Button>
        )}
      </AlertDescription>
    </Alert>
  );
};

