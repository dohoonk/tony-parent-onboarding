'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useMutation } from '@apollo/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Loader2, Calendar, User, CheckCircle2 } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MATCH_THERAPISTS, BOOK_APPOINTMENT, CREATE_AVAILABILITY_WINDOW } from '@/lib/graphql/mutations';

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
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [startTime, setStartTime] = useState<string>('');
  const [endTime, setEndTime] = useState<string>('');
  const [therapistMatches, setTherapistMatches] = useState<TherapistMatch[]>([]);
  const [selectedTherapist, setSelectedTherapist] = useState<string>('');
  const [availabilityWindowId, setAvailabilityWindowId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isBooking, setIsBooking] = useState(false);
  const [isBooked, setIsBooked] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const availabilityWindowCacheRef = useRef<Record<string, string>>({});

  const [matchTherapists] = useMutation(MATCH_THERAPISTS);
  const [createAvailabilityWindow] = useMutation(CREATE_AVAILABILITY_WINDOW);
  const [bookAppointment] = useMutation(BOOK_APPOINTMENT);

  useEffect(() => {
    if (selectedDate && startTime && endTime && sessionId) {
      loadTherapistMatches();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedDate, startTime, endTime, sessionId]);

  const buildAvailabilityJson = () => {
    if (!selectedDate || !startTime || !endTime) {
      throw new Error('Please choose a date and time range');
    }

    const [startHour, startMinute] = startTime.split(':').map(Number);
    const [endHour, endMinute] = endTime.split(':').map(Number);

    const startInMinutes = startHour * 60 + startMinute;
    const endInMinutes = endHour * 60 + endMinute;

    if (Number.isNaN(startInMinutes) || Number.isNaN(endInMinutes)) {
      throw new Error('Invalid time selection');
    }

    const durationMinutes = endInMinutes - startInMinutes;

    if (durationMinutes <= 0) {
      throw new Error('End time must be after start time');
    }

    const dateObj = new Date(`${selectedDate}T00:00:00`);
    const dayFormatter = new Intl.DateTimeFormat('en-US', { weekday: 'long' });
    const dayName = dayFormatter.format(dateObj);

    return {
      days: [
        {
          day: dayName,
          time_blocks: [
            {
              start: `${startTime}`,
              duration: durationMinutes
            }
          ]
        }
      ]
    };
  };

  const loadTherapistMatches = async () => {
    if (!sessionId) {
      setError('Session ID is required');
      return;
    }

    if (!selectedDate || !startTime || !endTime) {
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      const timezone =
        (typeof Intl !== 'undefined' && Intl.DateTimeFormat().resolvedOptions().timeZone) ||
        'America/Los_Angeles';
      const cacheKey = `${selectedDate}|${startTime}-${endTime}|${timezone}`;
      let windowId = availabilityWindowCacheRef.current[cacheKey];

      if (!windowId) {
        const availabilityJson = buildAvailabilityJson();
        const startDate = selectedDate;

        const { data: availabilityData, errors: availabilityErrors } = await createAvailabilityWindow({
          variables: {
            input: {
              startDate,
              endDate: startDate,
              timezone,
              availabilityJson
            }
          }
        });

        if (availabilityErrors && availabilityErrors.length > 0) {
          throw new Error(availabilityErrors[0].message);
        }

        const availabilityPayload = availabilityData?.createAvailabilityWindow;

        if (availabilityPayload?.errors && availabilityPayload.errors.length > 0) {
          throw new Error(availabilityPayload.errors[0]);
        }

        windowId = availabilityPayload?.availabilityWindow?.id;

        if (!windowId) {
          throw new Error('Failed to create availability window');
        }

        availabilityWindowCacheRef.current[cacheKey] = windowId;
      }

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
    if (!selectedTherapist || !selectedDate || !startTime || !endTime || !sessionId) {
      setError('Please select a therapist, date, and time range');
      return;
    }

    setIsBooking(true);
    setError(null);

    try {
      const [startHour, startMinute] = startTime.split(':').map(Number);
      const scheduledDate = new Date(`${selectedDate}T00:00:00`);
      scheduledDate.setHours(startHour || 0, startMinute || 0, 0, 0);

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

      {/* Availability Selection */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Calendar className="h-5 w-5 text-primary" />
            <CardTitle>Select Preferred Date & Time</CardTitle>
          </div>
          <CardDescription>Choose the day and time range that works best for your family.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="availability-date">Preferred date</Label>
              <Input
                id="availability-date"
                type="date"
                value={selectedDate}
                min={new Date().toISOString().split('T')[0]}
                onChange={(event) => {
                  setSelectedDate(event.target.value);
                  setSelectedTherapist('');
                  setTherapistMatches([]);
                  setAvailabilityWindowId(null);
                  setError(null);
                }}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="start-time">Start time</Label>
              <Input
                id="start-time"
                type="time"
                value={startTime}
                onChange={(event) => {
                  setStartTime(event.target.value);
                  setSelectedTherapist('');
                  setTherapistMatches([]);
                  setAvailabilityWindowId(null);
                  setError(null);
                }}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="end-time">End time</Label>
              <Input
                id="end-time"
                type="time"
                value={endTime}
                min={startTime}
                onChange={(event) => {
                  setEndTime(event.target.value);
                  setSelectedTherapist('');
                  setTherapistMatches([]);
                  setAvailabilityWindowId(null);
                  setError(null);
                }}
              />
            </div>
          </div>
          <p className="mt-3 text-xs text-muted-foreground">
            We&apos;ll match you with therapists who have openings during this exact window.
          </p>
        </CardContent>
      </Card>

      {/* Therapist Matches */}
      {selectedDate && startTime && endTime && (
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
          disabled={!selectedTherapist || !selectedDate || !startTime || !endTime || isBooking}
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

