'use client';

import React, { useEffect, useState, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { OnboardingProvider, useOnboarding } from '@/contexts/OnboardingContext';
import { MagicLinkRequest } from '@/components/onboarding/MagicLinkRequest';
import { ResumeOnboardingDialog } from '@/components/onboarding/ResumeOnboardingDialog';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { AlertCircle } from 'lucide-react';

const ResumeContent: React.FC = () => {
  const searchParams = useSearchParams();
  const router = useRouter();
  const token = searchParams.get('token');
  const { loadProgress, hasSavedProgress, currentStep, data, clearProgress } = useOnboarding();
  const [isLoading, setIsLoading] = useState(!!token);
  const [error, setError] = useState<string | null>(null);
  const [showResumeDialog, setShowResumeDialog] = useState(false);
  const [lastSaveDate, setLastSaveDate] = useState<Date | null>(null);

  // Handle magic link token
  useEffect(() => {
    if (!token) return;

    const verifyAndResume = async () => {
      try {
        setIsLoading(true);
        // TODO: Verify magic link token with backend
        // const result = await verifyMagicLinkToken({ token });
        
        // Simulate API call
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        // Load saved progress
        await loadProgress();
        
        // Get last save date from localStorage
        const stored = localStorage.getItem('daybreak-onboarding-progress');
        if (stored) {
          const parsed = JSON.parse(stored);
          if (parsed.timestamp) {
            setLastSaveDate(new Date(parsed.timestamp));
          }
        }
        
        setShowResumeDialog(true);
      } catch (err) {
        setError('Invalid or expired link. Please request a new magic link.');
        console.error('Magic link verification failed:', err);
      } finally {
        setIsLoading(false);
      }
    };

    verifyAndResume();
  }, [token, loadProgress]);

  // Check for existing saved progress on mount
  useEffect(() => {
    if (!token && hasSavedProgress()) {
      const stored = localStorage.getItem('daybreak-onboarding-progress');
      if (stored) {
        const parsed = JSON.parse(stored);
        if (parsed.timestamp) {
          setLastSaveDate(new Date(parsed.timestamp));
        }
        setShowResumeDialog(true);
      }
    }
  }, [token, hasSavedProgress]);

  const handleResume = () => {
    setShowResumeDialog(false);
    router.push('/onboarding');
  };

  const handleStartFresh = () => {
    clearProgress();
    setShowResumeDialog(false);
    router.push('/onboarding');
  };

  const handleLinkSent = (method: 'email' | 'sms', identifier: string) => {
    // Link sent successfully, user will receive it
    console.log(`Magic link sent via ${method} to ${identifier}`);
  };

  if (isLoading) {
    return (
      <div className="container mx-auto flex min-h-screen items-center justify-center">
        <Card className="w-full max-w-md">
          <CardContent className="p-6 text-center">
            <div className="mb-4 inline-block h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            <p className="text-muted-foreground">Verifying your link...</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto flex min-h-screen items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-destructive">
              <AlertCircle className="h-5 w-5" />
              Unable to Resume
            </CardTitle>
            <CardDescription>{error}</CardDescription>
          </CardHeader>
          <CardContent>
            <MagicLinkRequest onLinkSent={handleLinkSent} />
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="container mx-auto flex min-h-screen items-center justify-center p-4">
      <div className="w-full max-w-md space-y-4">
        {showResumeDialog && (
          <ResumeOnboardingDialog
            open={showResumeDialog}
            onResume={handleResume}
            onStartFresh={handleStartFresh}
            lastSaveDate={lastSaveDate || undefined}
            completedSteps={currentStep - 1}
            totalSteps={8}
          />
        )}
        
        {!showResumeDialog && (
          <>
            <Card>
              <CardHeader>
                <CardTitle>Resume Your Onboarding</CardTitle>
                <CardDescription>
                  Enter your email or phone number to receive a secure link to continue where you left off
                </CardDescription>
              </CardHeader>
            </Card>
            <MagicLinkRequest onLinkSent={handleLinkSent} />
          </>
        )}
      </div>
    </div>
  );
};

export default function ResumePage() {
  return (
    <OnboardingProvider>
      <Suspense fallback={
        <div className="container mx-auto flex min-h-screen items-center justify-center">
          <Card className="w-full max-w-md">
            <CardContent className="p-6 text-center">
              <div className="mb-4 inline-block h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
              <p className="text-muted-foreground">Loading...</p>
            </CardContent>
          </Card>
        </div>
      }>
        <ResumeContent />
      </Suspense>
    </OnboardingProvider>
  );
}

