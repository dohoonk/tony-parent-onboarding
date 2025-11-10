'use client';

import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import { Loader2, Calendar, User, CheckCircle2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

interface TherapistMatch {
  id: string;
  name: string;
  languages: string[];
  specialties: string[];
  bio: string;
  match_score: number;
  match_rationale: string;
}

interface SchedulingStepProps {
  onNext: () => void;
  onPrev: () => void;
  sessionId?: string;
}

export const SchedulingStep: React.FC<SchedulingStepProps> = ({
  onNext,
  onPrev,
  sessionId
}) => {
  const [selectedTime, setSelectedTime] = useState<string>('');
  const [therapistMatches, setTherapistMatches] = useState<TherapistMatch[]>([]);
  const [selectedTherapist, setSelectedTherapist] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);
  const [isBooking, setIsBooking] = useState(false);
  const [isBooked, setIsBooked] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const timeSlots = [
    { id: 'morning', label: 'Morning (9 AM - 12 PM)', value: 'morning' },
    { id: 'afternoon', label: 'Afternoon (12 PM - 5 PM)', value: 'afternoon' },
    { id: 'evening', label: 'Evening (5 PM - 8 PM)', value: 'evening' }
  ];

  useEffect(() => {
    if (selectedTime) {
      loadTherapistMatches();
    }
  }, [selectedTime]);

  const loadTherapistMatches = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // TODO: Call GraphQL mutation to get therapist matches
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      // Mock matches
      setTherapistMatches([
        {
          id: '1',
          name: 'Dr. Sarah Johnson',
          languages: ['English', 'Spanish'],
          specialties: ['Anxiety', 'Depression'],
          bio: 'Experienced child therapist specializing in anxiety and depression. Over 10 years of experience working with children and adolescents.',
          match_score: 95,
          match_rationale: 'Language match: English; Age-appropriate: Grade 6 within range; Available during requested time'
        },
        {
          id: '2',
          name: 'Dr. Michael Chen',
          languages: ['English', 'Mandarin'],
          specialties: ['Anxiety', 'Trauma'],
          bio: 'Bilingual therapist with expertise in trauma-informed care. Specializes in working with diverse populations.',
          match_score: 85,
          match_rationale: 'Language match: English; Age range: Close match; Available during requested time'
        }
      ]);
    } catch (err) {
      setError('Failed to load therapist matches');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleBook = async () => {
    if (!selectedTherapist || !selectedTime) {
      setError('Please select a therapist and time slot');
      return;
    }

    setIsBooking(true);
    setError(null);

    try {
      // TODO: Call GraphQL mutation to book appointment
      await new Promise((resolve) => setTimeout(resolve, 2000));
      setIsBooked(true);
    } catch (err) {
      setError('Failed to book appointment. Please try again.');
      console.error(err);
    } finally {
      setIsBooking(false);
    }
  };

  if (isBooked) {
    return (
      <div className="space-y-6">
        <Card className="border-green-200 bg-green-50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-5 w-5 text-green-600" />
              <CardTitle>Appointment Booked!</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">
              Your appointment has been successfully booked. You&apos;ll receive a confirmation email and SMS shortly.
            </p>
            <Button 
              type="button"
              onClick={(e) => {
                e.preventDefault();
                onNext();
              }} 
              className="w-full sm:w-auto"
            >
              Continue
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">Schedule Your First Session</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Select your preferred time and we&apos;ll match you with available therapists.
        </p>
      </div>

      {/* Time Selection */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Calendar className="h-5 w-5 text-primary" />
            <CardTitle>Select Preferred Time</CardTitle>
          </div>
          <CardDescription>When would you prefer to have sessions?</CardDescription>
        </CardHeader>
        <CardContent>
          <RadioGroup value={selectedTime} onValueChange={setSelectedTime}>
            {timeSlots.map((slot) => (
              <div key={slot.id} className="flex items-center space-x-2">
                <RadioGroupItem value={slot.value} id={slot.id} />
                <Label htmlFor={slot.id} className="font-normal cursor-pointer">
                  {slot.label}
                </Label>
              </div>
            ))}
          </RadioGroup>
        </CardContent>
      </Card>

      {/* Therapist Matches */}
      {selectedTime && (
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <User className="h-5 w-5 text-primary" />
              <CardTitle>Recommended Therapists</CardTitle>
            </div>
            <CardDescription>
              We&apos;ve matched you with therapists based on your needs and availability
            </CardDescription>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
              </div>
            ) : therapistMatches.length > 0 ? (
              <div className="space-y-4">
                {therapistMatches.map((therapist) => (
                  <Card
                    key={therapist.id}
                    className={selectedTherapist === therapist.id ? 'border-primary' : ''}
                  >
                    <CardContent className="pt-6">
                      <div className="space-y-3">
                        <div className="flex items-start justify-between">
                          <div>
                            <h4 className="font-semibold">{therapist.name}</h4>
                            <p className="text-sm text-muted-foreground mt-1">
                              {therapist.bio}
                            </p>
                          </div>
                          <Badge variant="secondary">
                            {therapist.match_score}% match
                          </Badge>
                        </div>
                        
                        <div className="flex flex-wrap gap-2">
                          {therapist.specialties.map((specialty) => (
                            <Badge key={specialty} variant="outline">
                              {specialty}
                            </Badge>
                          ))}
                        </div>

                        <div className="text-xs text-muted-foreground">
                          <strong>Why this match:</strong> {therapist.match_rationale}
                        </div>

                        <RadioGroup value={selectedTherapist} onValueChange={setSelectedTherapist}>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value={therapist.id} id={`therapist-${therapist.id}`} />
                            <Label htmlFor={`therapist-${therapist.id}`} className="font-normal cursor-pointer">
                              Select this therapist
                            </Label>
                          </div>
                        </RadioGroup>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            ) : (
              <p className="text-sm text-muted-foreground text-center py-4">
                No matches found. Please try a different time slot.
              </p>
            )}
          </CardContent>
        </Card>
      )}

      {error && (
        <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive" role="alert">
          {error}
        </div>
      )}

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
        <Button
          onClick={handleBook}
          disabled={!selectedTherapist || !selectedTime || isBooking}
          className="w-full sm:w-auto"
        >
          {isBooking ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Booking...
            </>
          ) : (
            'Book Appointment'
          )}
        </Button>
      </div>
    </div>
  );
};

