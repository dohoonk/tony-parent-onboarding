'use client';

import React, { useState, useEffect } from 'react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Info, Heart, ShieldCheck, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface ReassuranceBannerProps {
  message: string;
  /** Icon variant: info, heart, or shield */
  variant?: 'info' | 'heart' | 'shield';
  onDismiss?: () => void;
  autoHide?: boolean;
  hideAfter?: number; // milliseconds
  className?: string;
}

export const ReassuranceBanner: React.FC<ReassuranceBannerProps> = ({
  message,
  variant = 'info',
  onDismiss,
  autoHide = true,
  hideAfter = 5000,
  className
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [isAnimating, setIsAnimating] = useState(false);

  // Fade in on mount
  useEffect(() => {
    const timer = setTimeout(() => {
      setIsVisible(true);
      setIsAnimating(true);
    }, 100);
    return () => clearTimeout(timer);
  }, []);

  // Auto-hide functionality
  useEffect(() => {
    if (autoHide && isVisible) {
      const timer = setTimeout(() => {
        setIsAnimating(false);
        setTimeout(() => {
          setIsVisible(false);
          onDismiss?.();
        }, 300); // Wait for fade-out animation
      }, hideAfter);

      return () => clearTimeout(timer);
    }
  }, [autoHide, hideAfter, isVisible, onDismiss]);

  const handleDismiss = () => {
    setIsAnimating(false);
    setTimeout(() => {
      setIsVisible(false);
      onDismiss?.();
    }, 300); // Wait for fade-out animation
  };

  const IconComponent = {
    info: Info,
    heart: Heart,
    shield: ShieldCheck,
  }[variant];

  if (!isVisible) return null;

  return (
    <Alert
      className={cn(
        'mb-4 border-info/20 bg-info/5 transition-all duration-300 ease-in-out',
        isAnimating ? 'animate-in fade-in slide-in-from-top-2' : 'animate-out fade-out slide-out-to-top-2',
        className
      )}
    >
      <IconComponent className="h-4 w-4 text-info" />
      <AlertDescription className="flex items-center justify-between gap-3">
        <span className="text-body-small text-foreground">
          {message}
        </span>
        {onDismiss && (
          <Button
            variant="ghost"
            size="icon"
            onClick={handleDismiss}
            className="h-6 w-6 shrink-0 text-foreground hover:text-foreground/80"
            aria-label="Dismiss reassurance message"
          >
            <X className="h-3 w-3" />
          </Button>
        )}
      </AlertDescription>
    </Alert>
  );
};

