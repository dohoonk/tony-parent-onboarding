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
import { SummaryStep } from '@/components/onboarding/steps/SummaryStep';

const OnboardingContent: React.FC = () => {
  const {
    currentStep,
    totalSteps,
    steps,
    data,
    estimatedSecondsRemaining,
    nextStep,
    prevStep,
    updateData,
    sessionId,
    createSession
  } = useOnboarding();

  const renderStep = () => {
    switch (currentStep) {
      case 1:
        return (
          <WelcomeStep
            onNext={nextStep}
            onAuthSuccess={({ firstName, lastName, email }) => {
              updateData({
                parentInfo: {
                  ...(data.parentInfo || {}),
                  firstName,
                  lastName,
                  email,
                  phone: data.parentInfo?.phone || '',
                  street: data.parentInfo?.street || '',
                  city: data.parentInfo?.city || '',
                  state: data.parentInfo?.state || '',
                  postalCode: data.parentInfo?.postalCode || ''
                }
              });
            }}
          />
        );
      
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
            onNext={async (studentInfo) => {
              // Create session after we have both parent and student info
              await createSession(studentInfo);
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
            sessionId={sessionId || undefined}
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
            sessionId={sessionId || undefined}
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
            sessionId={sessionId || undefined}
          />
        );
      
      case 8:
        return (
          <SchedulingStep
            onNext={() => {
              updateData({ schedulingComplete: true });
              nextStep();
            }}
            onPrev={prevStep}
            sessionId={sessionId || undefined}
          />
        );
      
      case 9:
        return (
          <SummaryStep
            onComplete={() => {
              updateData({ onboardingComplete: true });
              // TODO: Redirect to completion page or dashboard
            }}
            sessionId={sessionId || undefined}
          />
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

