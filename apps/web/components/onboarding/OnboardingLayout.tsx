'use client';

import React from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Stepper, Step } from './Stepper';
import { ProgressBar } from './ProgressBar';
import { ETADisplay } from './ETADisplay';
import { cn } from '@/lib/utils';

interface OnboardingLayoutProps {
  children: React.ReactNode;
  currentStep: number;
  totalSteps: number;
  steps: Step[];
  estimatedSeconds?: number;
  title?: string;
  description?: string;
  className?: string;
}

export const OnboardingLayout: React.FC<OnboardingLayoutProps> = ({
  children,
  currentStep,
  totalSteps,
  steps,
  estimatedSeconds,
  title,
  description,
  className
}) => {
  return (
    <div className={cn('container mx-auto max-w-4xl py-8', className)}>
      {/* Header with Progress */}
      <div className="mb-8 space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">
              {title || 'Parent Onboarding'}
            </h1>
            {description && (
              <p className="text-muted-foreground">{description}</p>
            )}
          </div>
          {estimatedSeconds && estimatedSeconds > 0 && (
            <ETADisplay estimatedSeconds={estimatedSeconds} />
          )}
        </div>

        {/* Progress Bar */}
        <ProgressBar current={currentStep} total={totalSteps} />

        {/* Stepper */}
        <div className="hidden md:block">
          <Stepper steps={steps} currentStep={currentStep} orientation="horizontal" />
        </div>
        <div className="md:hidden">
          <Stepper steps={steps} currentStep={currentStep} orientation="vertical" />
        </div>
      </div>

      {/* Main Content */}
      <Card>
        <CardHeader>
          <CardTitle>{steps[currentStep - 1]?.title}</CardTitle>
          {steps[currentStep - 1]?.description && (
            <CardDescription>{steps[currentStep - 1].description}</CardDescription>
          )}
        </CardHeader>
        <CardContent>{children}</CardContent>
      </Card>
    </div>
  );
};

