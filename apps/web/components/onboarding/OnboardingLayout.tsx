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
    <div className={cn('container mx-auto max-w-4xl px-4 py-4 sm:py-6 md:py-8', className)}>
      {/* Header with Progress */}
      <div className="mb-4 space-y-4 sm:mb-6 md:mb-8">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold tracking-tight sm:text-3xl">
              {title || 'Parent Onboarding'}
            </h1>
            {description && (
              <p className="mt-1 text-sm text-muted-foreground sm:text-base">{description}</p>
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

