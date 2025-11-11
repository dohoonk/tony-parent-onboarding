'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useMutation } from '@apollo/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Loader2, Calendar, User, CheckCircle2, Award } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
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

const USER_TIMEZONE = 'America/Los_Angeles';

const toISOStringInUserTimezone = (dateString: string, timeString: string) => {
  const localDate = new Date(`${dateString}T${timeString}:00`);

  const demoTimezoneDate = new Date(
    localDate.toLocaleString('en-US', { timeZone: USER_TIMEZONE })
  );

  const offset = localDate.getTime() - demoTimezoneDate.getTime();
  const targetDate = new Date(localDate.getTime() + offset);

  return targetDate.toISOString();
};

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
      const timezone = USER_TIMEZONE;
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
      const { data, errors } = await bookAppointment({
        variables: {
          input: {
            sessionId,
            therapistId: selectedTherapist,
            scheduledAt: toISOStringInUserTimezone(selectedDate, startTime),
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
                    className={`transition-all duration-200 hover:shadow-md ${
                      selectedTherapist === therapist.id ? 'border-primary border-2' : ''
                    }`}
                  >
                    <CardContent className="pt-6">
                      <div className="space-y-4">
                        {/* Header with Avatar */}
                        <div className="flex items-start gap-4">
                          <Avatar className="h-16 w-16 border-2 border-border">
                            <AvatarImage 
                              src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${therapist.id}`} 
                              alt={therapist.name}
                            />
                            <AvatarFallback className="bg-primary/10 text-primary font-semibold">
                              {therapist.name.split(' ').map(n => n[0]).join('')}
                            </AvatarFallback>
                          </Avatar>
                          
                          <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between gap-2">
                              <div>
                                <h4 className="font-semibold text-lg">{therapist.name}</h4>
                                <div className="flex items-center gap-2 mt-1">
                                  <Badge variant="secondary" className="text-xs">
                                    <Award className="h-3 w-3 mr-1" />
                                    LCSW
                                  </Badge>
                                  <span className="text-xs text-muted-foreground">8+ years</span>
                                </div>
                              </div>
                              <Badge variant="default" className="shrink-0">
                                {therapist.matchScore}% match
                              </Badge>
                            </div>
                            
                            {therapist.bio && (
                              <p className="text-sm text-muted-foreground mt-2 line-clamp-2">
                                {therapist.bio}
                              </p>
                            )}
                          </div>
                        </div>
                        
                        {/* Specialties */}
                        <div className="flex flex-wrap gap-2">
                          {therapist.specialties.map((specialty) => (
                            <Badge key={specialty} variant="outline" className="text-xs">
                              {specialty}
                            </Badge>
                          ))}
                        </div>

                        {/* Languages */}
                        {therapist.languages.length > 0 && (
                          <div className="flex items-center flex-wrap gap-2">
                            <span className="text-xs font-medium text-muted-foreground">Languages:</span>
                            {therapist.languages.map((lang) => (
                              <Badge key={lang} variant="secondary" className="text-xs">
                                {lang}
                              </Badge>
                            ))}
                          </div>
                        )}

                        {/* Match Rationale */}
                        <div className="rounded-md bg-muted/50 p-3">
                          <p className="text-xs text-muted-foreground">
                            <strong className="text-foreground">Why this match:</strong> {therapist.matchRationale}
                          </p>
                        </div>

                        {/* Availability */}
                        {therapist.capacityAvailable > 0 && (
                          <div className="flex items-center gap-2 text-sm text-success">
                            <CheckCircle2 className="h-4 w-4" />
                            <span>{therapist.capacityAvailable} spots available</span>
                          </div>
                        )}

                        {/* Selection Radio */}
                        <RadioGroup value={selectedTherapist} onValueChange={setSelectedTherapist}>
                          <div className="flex items-center space-x-2 rounded-md border border-input p-3 hover:bg-accent/50 transition-colors">
                            <RadioGroupItem value={therapist.id} id={`therapist-${therapist.id}`} />
                            <Label 
                              htmlFor={`therapist-${therapist.id}`} 
                              className="flex-1 font-medium cursor-pointer"
                            >
                              Select {therapist.name.split(' ')[0]} as my therapist
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

