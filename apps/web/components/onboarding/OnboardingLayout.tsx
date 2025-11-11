'use client';

import React, { useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Stepper, Step } from './Stepper';
import { ProgressBar } from './ProgressBar';
import { ReassuranceBanner } from './ReassuranceBanner';
import { useReassurance } from '@/hooks/useReassurance';
import { cn } from '@/lib/utils';
import { Clock } from 'lucide-react';
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area';

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
  const progressPercent = Math.round((currentStep / totalSteps) * 100);
  const currentStepData = steps.find((s) => s.id === currentStep);
  
  const { reassuranceMessage, generateReassurance, clearReassurance } = useReassurance({
    context: {
      stepName: currentStepData?.title,
      progressPercent,
      timeSpent: estimatedSeconds ? `${Math.floor(estimatedSeconds / 60)} min` : undefined
    },
    triggerPoints: ['starting_onboarding', 'completing_forms', 'insurance_verification', 'scheduling', 'almost_done']
  });

  // Trigger reassurance at stress points
  useEffect(() => {
    if (currentStep === 1) {
      generateReassurance('starting_onboarding');
    } else if (currentStep === 2 || currentStep === 3) {
      generateReassurance('completing_forms');
    } else if (currentStep === 7) {
      generateReassurance('insurance_verification');
    } else if (currentStep === 8) {
      generateReassurance('scheduling');
    } else if (currentStep === totalSteps - 1) {
      generateReassurance('almost_done');
    }
  }, [currentStep, totalSteps, generateReassurance]);

  return (
    <div className={cn('container mx-auto max-w-4xl px-4 py-4 sm:py-6 md:py-8', className)}>
      {/* Reassurance Banner */}
      {reassuranceMessage && (
        <ReassuranceBanner
          message={reassuranceMessage}
          onDismiss={clearReassurance}
          autoHide={false}
        />
      )}

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
          {currentStep === 1 && (
            <div className="flex items-center gap-2 rounded-md bg-muted px-3 py-2 text-sm">
              <Clock className="h-4 w-4 text-muted-foreground" aria-hidden="true" />
              <span className="font-medium">Estimated time:</span>
              <span className="text-muted-foreground">
                About 15 minutes to complete
              </span>
            </div>
          )}
        </div>

        {/* Progress Bar */}
        <ProgressBar current={currentStep} total={totalSteps} />

        {/* Stepper */}
        <div className="hidden md:block">
          <ScrollArea orientation="horizontal" className="w-full pb-2">
            <div className="min-w-max pr-6">
              <Stepper
                steps={steps}
                currentStep={currentStep}
                orientation="horizontal"
                className="pr-8"
              />
            </div>
            <ScrollBar orientation="horizontal" />
          </ScrollArea>
        </div>
        <div className="md:hidden space-y-3">
          <div className="flex items-center justify-between text-sm text-muted-foreground">
            <span>
              Step {currentStep} of {totalSteps}
            </span>
            <span>{progressPercent}% complete</span>
          </div>
          <div className="flex overflow-x-auto gap-3 pb-2">
            {steps.map((step) => {
              const isCurrent = step.id === currentStep;
              const isComplete = step.id < currentStep;

              return (
                <div
                  key={step.id}
                  className={cn(
                    'min-w-[130px] rounded-md border px-3 py-2 text-xs',
                    isCurrent && 'border-primary bg-primary/10 text-primary',
                    isComplete && 'border-primary/60 bg-primary/5 text-primary/80'
                  )}
                >
                  <div className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                    Step {step.id}
                  </div>
                  <div className="mt-1 font-medium text-foreground">{step.title}</div>
                  {step.description && (
                    <div className="mt-1 text-[11px] text-muted-foreground line-clamp-2">
                      {step.description}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
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

