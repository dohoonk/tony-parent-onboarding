'use client';

import React, { useState, useEffect } from 'react';
import { useMutation } from '@apollo/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import { Loader2, Calendar, User, CheckCircle2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MATCH_THERAPISTS, BOOK_APPOINTMENT } from '@/lib/graphql/mutations';

interface TherapistMatch {
  id: string;
  name: string;
  languages: string[];
  specialties: string[];
  modalities: string[];
  bio: string | null;
  capacityAvailable: number;
  capacityUtilization: number;
  matchScore: number;
  matchRationale: string;
  matchDetails?: any;
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
  const [availabilityWindowId, setAvailabilityWindowId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isBooking, setIsBooking] = useState(false);
  const [isBooked, setIsBooked] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [matchTherapists] = useMutation(MATCH_THERAPISTS);
  const [bookAppointment] = useMutation(BOOK_APPOINTMENT);

  const timeSlots = [
    { id: 'morning', label: 'Morning (9 AM - 12 PM)', value: 'morning', timeRange: { start: 9, end: 12 } },
    { id: 'afternoon', label: 'Afternoon (12 PM - 5 PM)', value: 'afternoon', timeRange: { start: 12, end: 17 } },
    { id: 'evening', label: 'Evening (5 PM - 8 PM)', value: 'evening', timeRange: { start: 17, end: 20 } }
  ];

  useEffect(() => {
    if (selectedTime && sessionId) {
      loadTherapistMatches();
    }
  }, [selectedTime, sessionId]);

  // Helper to create a temporary availability window ID based on time slot
  // In production, this should create an actual availability window or use an existing one
  const getAvailabilityWindowId = (timeSlot: string): string => {
    // For now, we'll use a placeholder approach
    // In production, you'd either:
    // 1. Query existing availability windows for the parent/student
    // 2. Create a new availability window via mutation
    // 3. Use a default availability window ID
    // This is a temporary solution - the backend should handle this better
    return `temp-${timeSlot}-${sessionId}`;
  };

  const loadTherapistMatches = async () => {
    if (!sessionId) {
      setError('Session ID is required');
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      // Create a temporary availability window ID based on the time slot
      // Note: In production, this should be a real availability window ID
      const windowId = getAvailabilityWindowId(selectedTime);
      setAvailabilityWindowId(windowId);

      const { data, errors } = await matchTherapists({
        variables: {
          sessionId,
          availabilityWindowId: windowId,
          insurancePolicyId: null // TODO: Get from insurance step
        }
      });

      if (errors && errors.length > 0) {
        throw new Error(errors[0].message);
      }

      if (data?.matchTherapists?.errors && data.matchTherapists.errors.length > 0) {
        throw new Error(data.matchTherapists.errors[0]);
      }

      // Transform GraphQL response to component format
      const matches: TherapistMatch[] = (data?.matchTherapists?.matches || []).map((match: any) => ({
        id: match.id,
        name: match.name,
        languages: match.languages || [],
        specialties: match.specialties || [],
        modalities: match.modalities || [],
        bio: match.bio,
        capacityAvailable: match.capacityAvailable || 0,
        capacityUtilization: match.capacityUtilization || 0,
        matchScore: match.matchScore || 0,
        matchRationale: match.matchRationale || '',
        matchDetails: match.matchDetails
      }));

      setTherapistMatches(matches);
    } catch (err: any) {
      setError(err.message || 'Failed to load therapist matches');
      console.error('Error loading therapist matches:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleBook = async () => {
    if (!selectedTherapist || !selectedTime || !sessionId) {
      setError('Please select a therapist and time slot');
      return;
    }

    setIsBooking(true);
    setError(null);

    try {
      // Calculate scheduled_at based on selected time slot
      // For now, schedule for next week at the start of the selected time range
      const timeSlot = timeSlots.find(slot => slot.value === selectedTime);
      const scheduledDate = new Date();
      scheduledDate.setDate(scheduledDate.getDate() + 7); // Next week
      scheduledDate.setHours(timeSlot?.timeRange.start || 14, 0, 0, 0); // Start of time range

      const { data, errors } = await bookAppointment({
        variables: {
          input: {
            sessionId,
            therapistId: selectedTherapist,
            scheduledAt: scheduledDate.toISOString(),
            durationMinutes: 50
          }
        }
      });

      if (errors && errors.length > 0) {
        throw new Error(errors[0].message);
      }

      if (data?.bookAppointment?.errors && data.bookAppointment.errors.length > 0) {
        throw new Error(data.bookAppointment.errors[0]);
      }

      setIsBooked(true);
    } catch (err: any) {
      setError(err.message || 'Failed to book appointment. Please try again.');
      console.error('Error booking appointment:', err);
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
                e.stopPropagation();
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
                            {therapist.bio && (
                              <p className="text-sm text-muted-foreground mt-1">
                                {therapist.bio}
                              </p>
                            )}
                          </div>
                          <Badge variant="secondary">
                            {therapist.matchScore}% match
                          </Badge>
                        </div>
                        
                        <div className="flex flex-wrap gap-2">
                          {therapist.specialties.map((specialty) => (
                            <Badge key={specialty} variant="outline">
                              {specialty}
                            </Badge>
                          ))}
                        </div>

                        {therapist.languages.length > 0 && (
                          <div className="flex flex-wrap gap-2">
                            <span className="text-xs text-muted-foreground">Languages:</span>
                            {therapist.languages.map((lang) => (
                              <Badge key={lang} variant="outline" className="text-xs">
                                {lang}
                              </Badge>
                            ))}
                          </div>
                        )}

                        <div className="text-xs text-muted-foreground">
                          <strong>Why this match:</strong> {therapist.matchRationale}
                        </div>

                        {therapist.capacityAvailable > 0 && (
                          <div className="text-xs text-muted-foreground">
                            <strong>Availability:</strong> {therapist.capacityAvailable} spots available
                          </div>
                        )}

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

