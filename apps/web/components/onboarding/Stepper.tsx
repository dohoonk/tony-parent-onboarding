'use client';

import React from 'react';
import { Check } from 'lucide-react';
import { cn } from '@/lib/utils';

export interface Step {
  id: number;
  title: string;
  description?: string;
}

interface StepperProps {
  steps: Step[];
  currentStep: number;
  orientation?: 'horizontal' | 'vertical';
  className?: string;
}

export const Stepper: React.FC<StepperProps> = ({
  steps,
  currentStep,
  orientation = 'horizontal',
  className
}) => {
  const isStepComplete = (stepId: number) => stepId < currentStep;
  const isStepCurrent = (stepId: number) => stepId === currentStep;
  const isStepUpcoming = (stepId: number) => stepId > currentStep;

  return (
    <div
      className={cn(
        'flex',
        orientation === 'horizontal' ? 'flex-row items-center' : 'flex-col',
        className
      )}
      role="navigation"
      aria-label="Onboarding progress"
    >
      {steps.map((step, index) => {
        const isComplete = isStepComplete(step.id);
        const isCurrent = isStepCurrent(step.id);
        const isLast = index === steps.length - 1;

        return (
          <React.Fragment key={step.id}>
            <div
              className={cn(
                'flex items-center',
                orientation === 'horizontal' ? 'flex-row' : 'flex-col'
              )}
            >
              {/* Step Circle */}
              <div
                className={cn(
                  'flex h-10 w-10 shrink-0 items-center justify-center rounded-full border-2 transition-all',
                  isComplete && 'border-primary bg-primary text-primary-foreground',
                  isCurrent && 'border-primary bg-background text-primary',
                  isStepUpcoming(step.id) && 'border-muted bg-background text-muted-foreground'
                )}
                aria-current={isCurrent ? 'step' : undefined}
              >
                {isComplete ? (
                  <Check className="h-5 w-5" aria-hidden="true" />
                ) : (
                  <span className="text-sm font-semibold">{step.id}</span>
                )}
              </div>

              {/* Step Label */}
              <div
                className={cn(
                  'ml-3',
                  orientation === 'vertical' && 'mb-4 ml-0 mt-2'
                )}
              >
                <div
                  className={cn(
                    'text-sm font-medium',
                    isComplete && 'text-primary',
                    isCurrent && 'text-foreground',
                    isStepUpcoming(step.id) && 'text-muted-foreground'
                  )}
                >
                  {step.title}
                </div>
                {step.description && (
                  <div className="text-xs text-muted-foreground">
                    {step.description}
                  </div>
                )}
              </div>
            </div>

            {/* Connector Line */}
            {!isLast && (
              <div
                className={cn(
                  'bg-border',
                  orientation === 'horizontal'
                    ? 'mx-4 h-[2px] flex-1'
                    : 'ml-5 h-8 w-[2px]',
                  isComplete && 'bg-primary'
                )}
                aria-hidden="true"
              />
            )}
          </React.Fragment>
        );
      })}
    </div>
  );
};

