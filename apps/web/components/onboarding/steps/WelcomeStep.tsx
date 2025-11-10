'use client';

import React from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Heart, Shield, Clock } from 'lucide-react';

interface WelcomeStepProps {
  onNext: () => void;
}

export const WelcomeStep: React.FC<WelcomeStepProps> = ({ onNext }) => {
  return (
    <div className="space-y-6">
      <div className="text-center">
        <h2 className="text-2xl font-bold">Welcome to Daybreak Health</h2>
        <p className="mt-2 text-muted-foreground">
          We're here to support your child's mental health journey.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col items-center text-center">
              <Heart className="mb-4 h-12 w-12 text-primary" />
              <h3 className="font-semibold">Compassionate Care</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Licensed therapists who specialize in working with children and teens
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col items-center text-center">
              <Shield className="mb-4 h-12 w-12 text-primary" />
              <h3 className="font-semibold">HIPAA Secure</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Your family's privacy and data security are our top priorities
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col items-center text-center">
              <Clock className="mb-4 h-12 w-12 text-primary" />
              <h3 className="font-semibold">Quick & Easy</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Complete onboarding in about 10 minutes at your own pace
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="rounded-md bg-muted p-4">
        <h4 className="font-semibold">What to expect:</h4>
        <ul className="mt-2 space-y-1 text-sm text-muted-foreground">
          <li>• Share basic information about you and your child</li>
          <li>• Tell us about your child's needs through a guided conversation</li>
          <li>• Complete a brief assessment to help match with the right therapist</li>
          <li>• Provide insurance information (if applicable)</li>
          <li>• Schedule your first session</li>
        </ul>
      </div>

      <Button onClick={onNext} className="w-full" size="lg">
        Get Started
      </Button>
    </div>
  );
};

