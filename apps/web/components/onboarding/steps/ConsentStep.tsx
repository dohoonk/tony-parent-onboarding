'use client';

import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import { ScrollArea } from '@/components/ui/scroll-area';

interface ConsentStepProps {
  onNext: () => void;
  onPrev: () => void;
}

export const ConsentStep: React.FC<ConsentStepProps> = ({ onNext, onPrev }) => {
  const [consents, setConsents] = useState({
    treatmentConsent: false,
    privacyPolicy: false,
    termsOfService: false,
    communicationConsent: false
  });

  const [error, setError] = useState<string>('');

  const handleConsent = (key: keyof typeof consents, checked: boolean) => {
    setConsents((prev) => ({ ...prev, [key]: checked }));
    if (error) setError('');
  };

  const handleSubmit = () => {
    const required = ['treatmentConsent', 'privacyPolicy', 'termsOfService'] as const;
    const allRequired = required.every((key) => consents[key]);

    if (!allRequired) {
      setError('Please accept all required consents to continue');
      return;
    }

    onNext();
  };

  return (
    <div className="space-y-6">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">Important Information</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Please review and accept the following consents to proceed with onboarding.
        </p>
      </div>

      <div className="space-y-6">
        {/* Treatment Consent */}
        <div className="space-y-3">
          <div className="flex items-start space-x-3">
            <Checkbox
              id="treatmentConsent"
              checked={consents.treatmentConsent}
              onCheckedChange={(checked) => handleConsent('treatmentConsent', checked as boolean)}
              aria-required="true"
            />
            <div className="flex-1 space-y-1">
              <Label htmlFor="treatmentConsent" className="font-semibold">
                Treatment Consent <span className="text-destructive">*</span>
              </Label>
              <ScrollArea className="h-32 rounded border p-3">
                <p className="text-sm">
                  I consent to mental health treatment for my child through Daybreak Health. I understand
                  that treatment may include therapy sessions, assessments, and other clinically
                  appropriate interventions...
                </p>
              </ScrollArea>
            </div>
          </div>
        </div>

        {/* Privacy Policy */}
        <div className="space-y-3">
          <div className="flex items-start space-x-3">
            <Checkbox
              id="privacyPolicy"
              checked={consents.privacyPolicy}
              onCheckedChange={(checked) => handleConsent('privacyPolicy', checked as boolean)}
              aria-required="true"
            />
            <div className="flex-1 space-y-1">
              <Label htmlFor="privacyPolicy" className="font-semibold">
                Privacy Policy <span className="text-destructive">*</span>
              </Label>
              <p className="text-sm text-muted-foreground">
                I have read and agree to the{' '}
                <a href="/privacy" className="text-primary underline" target="_blank">
                  Privacy Policy
                </a>
                , including how my family&apos;s protected health information will be used and disclosed.
              </p>
            </div>
          </div>
        </div>

        {/* Terms of Service */}
        <div className="space-y-3">
          <div className="flex items-start space-x-3">
            <Checkbox
              id="termsOfService"
              checked={consents.termsOfService}
              onCheckedChange={(checked) => handleConsent('termsOfService', checked as boolean)}
              aria-required="true"
            />
            <div className="flex-1 space-y-1">
              <Label htmlFor="termsOfService" className="font-semibold">
                Terms of Service <span className="text-destructive">*</span>
              </Label>
              <p className="text-sm text-muted-foreground">
                I have read and agree to the{' '}
                <a href="/terms" className="text-primary underline" target="_blank">
                  Terms of Service
                </a>
                .
              </p>
            </div>
          </div>
        </div>

        {/* Communication Consent */}
        <div className="space-y-3">
          <div className="flex items-start space-x-3">
            <Checkbox
              id="communicationConsent"
              checked={consents.communicationConsent}
              onCheckedChange={(checked) => handleConsent('communicationConsent', checked as boolean)}
            />
            <div className="flex-1 space-y-1">
              <Label htmlFor="communicationConsent" className="font-semibold">
                Communication Preferences (Optional)
              </Label>
              <p className="text-sm text-muted-foreground">
                I would like to receive appointment reminders, educational resources, and updates via
                email and SMS.
              </p>
            </div>
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive" role="alert">
          {error}
        </div>
      )}

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
        <Button onClick={handleSubmit} className="w-full sm:w-auto">Continue</Button>
      </div>
    </div>
  );
};

