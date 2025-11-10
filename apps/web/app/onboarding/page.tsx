'use client';

import React from 'react';
import { OnboardingProvider, useOnboarding } from '@/contexts/OnboardingContext';
import { OnboardingLayout } from '@/components/onboarding/OnboardingLayout';
import { WelcomeStep } from '@/components/onboarding/steps/WelcomeStep';
import { ParentInfoStep } from '@/components/onboarding/steps/ParentInfoStep';
import { StudentInfoStep } from '@/components/onboarding/steps/StudentInfoStep';
import { ConsentStep } from '@/components/onboarding/steps/ConsentStep';
import { AIIntakeStep } from '@/components/onboarding/steps/AIIntakeStep';
import { ScreenerStep } from '@/components/onboarding/steps/ScreenerStep';
import { InsuranceStep } from '@/components/onboarding/steps/InsuranceStep';
import { SchedulingStep } from '@/components/onboarding/steps/SchedulingStep';

const OnboardingContent: React.FC = () => {
  const {
    currentStep,
    totalSteps,
    steps,
    data,
    estimatedSecondsRemaining,
    nextStep,
    prevStep,
    updateData
  } = useOnboarding();

  const renderStep = () => {
    switch (currentStep) {
      case 1:
        return <WelcomeStep onNext={nextStep} />;
      
      case 2:
        return (
          <ParentInfoStep
            onNext={(parentInfo) => {
              updateData({ parentInfo });
              nextStep();
            }}
            onPrev={prevStep}
            initialData={data.parentInfo}
          />
        );
      
      case 3:
        return (
          <StudentInfoStep
            onNext={(studentInfo) => {
              updateData({ studentInfo });
              nextStep();
            }}
            onPrev={prevStep}
            initialData={data.studentInfo}
          />
        );
      
      case 4:
        return (
          <ConsentStep
            onNext={() => {
              updateData({ consentsAccepted: true });
              nextStep();
            }}
            onPrev={prevStep}
          />
        );
      
      case 5:
        return (
          <AIIntakeStep
            onNext={() => {
              updateData({ aiIntakeComplete: true });
              nextStep();
            }}
            onPrev={prevStep}
            sessionId={session?.id?.toString()}
          />
        );
      
      case 6:
        return (
          <ScreenerStep
            onNext={() => {
              updateData({ screenersComplete: true });
              nextStep();
            }}
            onPrev={prevStep}
            sessionId={session?.id?.toString()}
          />
        );
      
      case 7:
        return (
          <InsuranceStep
            onNext={() => {
              updateData({ insuranceComplete: true });
              nextStep();
            }}
            onPrev={prevStep}
            sessionId={session?.id?.toString()}
          />
        );
      
      case 8:
        return (
          <div className="text-center">
            <h3 className="text-lg font-semibold">Scheduling Step</h3>
            <p className="mt-2 text-muted-foreground">
              This step will allow booking the first therapy session.
            </p>
            <div className="mt-6 flex justify-between">
              <button onClick={prevStep} className="rounded-md bg-muted px-4 py-2">
                Back
              </button>
              <button
                onClick={() => {
                  updateData({ schedulingComplete: true });
                  alert('Onboarding complete!');
                }}
                className="rounded-md bg-primary px-4 py-2 text-primary-foreground"
              >
                Complete
              </button>
            </div>
          </div>
        );
      
      default:
        return <div>Unknown step</div>;
    }
  };

  return (
    <OnboardingLayout
      currentStep={currentStep}
      totalSteps={totalSteps}
      steps={steps}
      estimatedSeconds={estimatedSecondsRemaining}
    >
      {renderStep()}
    </OnboardingLayout>
  );
};

export default function OnboardingPage() {
  return (
    <OnboardingProvider>
      <OnboardingContent />
    </OnboardingProvider>
  );
}

