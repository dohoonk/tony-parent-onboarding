"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useMutation } from "@apollo/client";
import { QuestionConfig } from "@/flows/onboarding/chapters";
import { MATCH_THERAPISTS, CREATE_AVAILABILITY_WINDOW } from "@/lib/graphql/mutations";
import { QuestionFrame } from "./QuestionFrame";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Loader2, RefreshCcw, Check, Award } from "lucide-react";
import { cn } from "@/lib/utils";

const USER_TIMEZONE = "America/Los_Angeles";

const TIME_WINDOW_MAP: Record<string, { start: string; end: string }> = {
  morning: { start: "09:00", end: "11:00" },
  afternoon: { start: "13:00", end: "15:00" },
  evening: { start: "17:00", end: "19:00" },
  weekend: { start: "10:00", end: "12:00" },
};

interface TherapistMatch {
  id: string;
  name: string;
  languages: string[];
  specialties: string[];
  modalities: string[];
  bio: string | null;
  capacityAvailable?: number;
  capacityUtilization?: number;
  matchScore: number;
  matchRationale: string;
  matchDetails?: Record<string, any> | null;
}

interface TherapistMatchQuestionProps {
  question: QuestionConfig;
  value: any;
  onChange: (value: any) => void;
  onContinue: () => Promise<void> | void;
  onSkip?: () => Promise<void> | void;
  isSubmitting?: boolean;
  errorMessage?: string | null;
  sessionId?: string | null;
  preferredDate?: string;
  preferredWindow?: string;
  preference?: string;
}

const resolveTimeWindow = (windowKey?: string) => {
  if (!windowKey) return TIME_WINDOW_MAP.afternoon;
  return TIME_WINDOW_MAP[windowKey] ?? TIME_WINDOW_MAP.afternoon;
};

const formatDayName = (date: string) => {
  try {
    return new Intl.DateTimeFormat("en-US", { weekday: "long" }).format(new Date(`${date}T00:00:00`));
  } catch {
    return "Monday";
  }
};

const buildAvatarUrl = (seed: string) =>
  `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(seed)}&top=longHairStraight&hairColor=BrownDark&accessoriesChance=0&clothes=BlazerSweater&clotheColor=PastelOrange&skin=Light`;

const ensureString = (value: unknown): string | null => {
  if (typeof value === "string") {
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }
  return null;
};

const extractCredential = (details?: Record<string, any> | null): string | null => {
  if (!details) return null;
  const profile =
    (typeof details === "object" && details !== null && "therapist_profile" in details
      ? (details as Record<string, any>).therapist_profile
      : null) || null;

  const candidates: unknown[] = [
    details.credential,
    details.credentials,
    details.license,
    details.license_type,
    details.primary_license,
    details.license_abbreviation,
    profile?.credential,
    profile?.credentials,
    profile?.license,
    profile?.primary_license,
    profile?.license_type,
    profile?.license_abbreviation,
  ];

  for (const candidate of candidates) {
    if (Array.isArray(candidate) && candidate.length > 0) {
      const fromArray = ensureString(candidate[0]);
      if (fromArray) return fromArray;
    }
    const normalized = ensureString(candidate);
    if (normalized) {
      return normalized;
    }
  }

  return null;
};

const formatExperience = (details?: Record<string, any> | null): string | null => {
  if (!details) return null;
  const profile =
    (typeof details === "object" && details !== null && "therapist_profile" in details
      ? (details as Record<string, any>).therapist_profile
      : null) || null;

  const candidates: unknown[] = [
    details.years_experience,
    details.experience_years,
    details.experienceYears,
    details.yearsExperience,
    details.experience,
    details.therapist_experience,
    profile?.years_experience,
    profile?.experience_years,
    profile?.experienceYears,
    profile?.yearsExperience,
    profile?.experience,
  ];

  for (const candidate of candidates) {
    if (typeof candidate === "number" && Number.isFinite(candidate) && candidate > 0) {
      return `${candidate}+ years experience`;
    }
    if (typeof candidate === "string") {
      const trimmed = candidate.trim();
      if (trimmed.length === 0) continue;
      if (/\byear/.test(trimmed.toLowerCase())) {
        return trimmed;
      }
      return `${trimmed} experience`;
    }
  }

  return null;
};

const describeAvailability = (details?: Record<string, any> | null): string | null => {
  const availabilityDetails = details?.availability_match;
  if (!availabilityDetails) return null;
  const matches = availabilityDetails.matches;
  if (!Array.isArray(matches) || matches.length === 0) return null;
  const days = Array.from(new Set(matches.map((match) => match?.day).filter(Boolean)));
  if (days.length === 0) return null;
  const daySummary = days.join(", ");
  const count = availabilityDetails.match_count ?? matches.length;
  return `Open during your window on ${daySummary}${count > 1 ? ` (${count} slots)` : ""}`;
};

export function TherapistMatchQuestion({
  question,
  value,
  onChange,
  onContinue,
  onSkip,
  isSubmitting,
  errorMessage,
  sessionId,
  preferredDate,
  preferredWindow,
  preference,
}: TherapistMatchQuestionProps) {
  const [matches, setMatches] = useState<TherapistMatch[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [localError, setLocalError] = useState<string | null>(null);
  const [selectedId, setSelectedId] = useState<string | null>(value?.therapistId ?? null);
  const [availabilityWindowId, setAvailabilityWindowId] = useState<string | null>(value?.availabilityWindowId ?? null);
  const availabilityCacheRef = useRef<Record<string, string>>({});

  const [createAvailabilityWindow] = useMutation(CREATE_AVAILABILITY_WINDOW);
  const [matchTherapists] = useMutation(MATCH_THERAPISTS);

  useEffect(() => {
    if (value?.therapistId) {
      setSelectedId(value.therapistId);
      if (value.availabilityWindowId) {
        setAvailabilityWindowId(value.availabilityWindowId);
      }
    }
  }, [value?.therapistId, value?.availabilityWindowId]);

  const canFetch = Boolean(sessionId && preferredDate && preferredWindow);

  const loadMatches = useCallback(async () => {
    if (!sessionId) {
      setLocalError("We’re creating your secure profile. Please try again in a moment.");
      setMatches([]);
      return;
    }

    if (!preferredDate || !preferredWindow) {
      setLocalError("Choose a day and time first so we can match therapists.");
      setMatches([]);
      return;
    }

    const { start, end } = resolveTimeWindow(preferredWindow);
    const durationMinutes =
      Number.parseInt(end.split(":")[0]) * 60 +
      Number.parseInt(end.split(":")[1]) -
      (Number.parseInt(start.split(":")[0]) * 60 + Number.parseInt(start.split(":")[1]));

    if (durationMinutes <= 0 || Number.isNaN(durationMinutes)) {
      setLocalError("Pick a valid time window so we can match therapists.");
      setMatches([]);
      return;
    }

    setIsLoading(true);
    setLocalError(null);

    try {
      const cacheKey = `${preferredDate}|${start}-${end}|${USER_TIMEZONE}`;
      let windowId = availabilityCacheRef.current[cacheKey];

      if (!windowId) {
        const dayName = formatDayName(preferredDate);
        const availabilityJson = {
          days: [
            {
              day: dayName,
              time_blocks: [
                {
                  start,
                  duration: durationMinutes,
                },
              ],
            },
          ],
        };

        const { data: availabilityData, errors: availabilityErrors } = await createAvailabilityWindow({
          variables: {
            input: {
              startDate: preferredDate,
              endDate: preferredDate,
              timezone: USER_TIMEZONE,
              availabilityJson,
            },
          },
        });

        if (availabilityErrors && availabilityErrors.length > 0) {
          throw new Error(availabilityErrors[0].message);
        }

        const availabilityPayload = availabilityData?.createAvailabilityWindow;
        if (availabilityPayload?.errors && availabilityPayload.errors.length > 0) {
          throw new Error(availabilityPayload.errors[0]);
        }

        windowId = availabilityPayload?.availabilityWindow?.id ?? null;
        if (!windowId) {
          throw new Error("We couldn’t create an availability window. Please try again.");
        }

        availabilityCacheRef.current[cacheKey] = windowId;
      }

      setAvailabilityWindowId(windowId);

      const { data, errors } = await matchTherapists({
        variables: {
          sessionId,
          availabilityWindowId: windowId,
          insurancePolicyId: null,
          preference: preference && preference !== "no-preference" ? preference : null,
        },
      });

      if (errors && errors.length > 0) {
        throw new Error(errors[0].message);
      }

      const matchErrors = data?.matchTherapists?.errors ?? [];
      if (matchErrors.length > 0) {
        const errorMessage = matchErrors[0] ?? "We couldn’t load therapist matches. Please try again.";
        setLocalError(
          errorMessage === "Session not found"
            ? "We’re still setting up your secure session. Please wait a moment and refresh matches."
            : errorMessage,
        );
        setMatches([]);
        return;
      }

      const rawMatches = data?.matchTherapists?.matches ?? [];
      const transformed: TherapistMatch[] = rawMatches.map((match: any) => ({
        id: match.id,
        name: match.name,
        languages: match.languages ?? [],
        specialties: match.specialties ?? [],
        modalities: match.modalities ?? [],
        bio: match.bio,
        capacityAvailable: match.capacityAvailable ?? match.matchDetails?.capacity_available ?? null,
        capacityUtilization: match.capacityUtilization ?? null,
        matchScore: match.matchScore ?? 0,
        matchRationale: match.matchRationale ?? "",
        matchDetails: match.matchDetails ?? null,
      }));

      setMatches(transformed);

      if (transformed.length === 0) {
        setLocalError("We didn’t find an immediate match. Try a different time window.");
      } else if (selectedId && !transformed.some((match) => match.id === selectedId)) {
        setSelectedId(null);
      }
    } catch (err: any) {
      console.error("Failed to load therapist matches:", err);
      setLocalError(err.message ?? "We couldn’t load therapist matches. Please try again.");
      setMatches([]);
    } finally {
      setIsLoading(false);
    }
  }, [
    createAvailabilityWindow,
    matchTherapists,
    preferredDate,
    preferredWindow,
    preference,
    selectedId,
    sessionId,
  ]);

  useEffect(() => {
    if (canFetch) {
      void loadMatches();
    }
  }, [canFetch, loadMatches]);

  const handleSelect = (match: TherapistMatch) => {
    if (!availabilityWindowId) {
      return;
    }
    setSelectedId(match.id);
    onChange({
      therapistId: match.id,
      therapistName: match.name,
      availabilityWindowId,
      timezone: USER_TIMEZONE,
      scheduledDate: preferredDate,
      timeWindow: preferredWindow,
      languages: match.languages,
      specialties: match.specialties,
      modalities: match.modalities,
      matchScore: match.matchScore,
      matchRationale: match.matchRationale,
      matchDetails: match.matchDetails ?? undefined,
      credentials: extractCredential(match.matchDetails) ?? undefined,
      experience: formatExperience(match.matchDetails) ?? undefined,
      capacityAvailable: match.capacityAvailable,
    });
  };

  const handleContinue = async () => {
    if (!selectedId) {
      setLocalError("Select a therapist to continue.");
      return;
    }
    await onContinue();
  };

  const displayError = errorMessage ?? localError;

  return (
    <QuestionFrame
      title={question.prompt}
      description={question.helperText}
      errorMessage={displayError ?? undefined}
      primaryAction={{
        label: question.ctaLabel ?? "Continue",
        onClick: handleContinue,
        disabled: !selectedId || isLoading || matches.length === 0,
        loading: isSubmitting,
      }}
      secondaryAction={
        onSkip
          ? {
              label: question.secondaryLabel ?? "Skip",
              onClick: onSkip,
              variant: "link",
            }
          : undefined
      }
    >
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between rounded-2xl border border-dashed border-muted px-4 py-3 text-sm text-muted-foreground">
          <div className="flex flex-col gap-1 text-left">
            <span className="font-medium text-foreground">
              {preferredDate
                ? new Date(`${preferredDate}T00:00:00`).toLocaleDateString(undefined, {
                    weekday: "short",
                    month: "short",
                    day: "numeric",
                  })
                : "Pick a day"}
            </span>
            <span>
              {preferredWindow ? preferredWindow.replace("-", " ") : "Pick a time window"} • {USER_TIMEZONE}
            </span>
          </div>
          <Button
            type="button"
            size="sm"
            variant="outline"
            onClick={() => loadMatches()}
            disabled={!canFetch || isLoading}
          >
            {isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCcw className="h-4 w-4" />}
            <span className="ml-2">Refresh</span>
          </Button>
        </div>

        {isLoading ? (
          <div className="flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed border-muted px-6 py-10 text-center">
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
            <p className="text-sm text-muted-foreground">Finding the best therapists for your family…</p>
          </div>
        ) : matches.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-muted px-6 py-10 text-center text-sm text-muted-foreground">
            {displayError ?? "No matches yet. Try adjusting your time or refreshing."}
          </div>
        ) : (
          <>
            <div className="grid gap-4 sm:grid-cols-1">
            {matches.map((match) => {
              const isSelected = selectedId === match.id;
              const preferenceDetails = match.matchDetails?.preference_match;
              const languageDetails = match.matchDetails?.language_match;
              const credentialBadge = extractCredential(match.matchDetails) ?? "Licensed Therapist";
              const experienceCopy = formatExperience(match.matchDetails);
              const availabilitySummary = describeAvailability(match.matchDetails);
              const capacityAvailable =
                match.capacityAvailable ?? match.matchDetails?.capacity_available ?? null;
              return (
                <button
                  key={match.id}
                  type="button"
                  onClick={() => handleSelect(match)}
                  className={cn(
                    "text-left transition-transform",
                    isSelected ? "translate-y-[-2px]" : "hover:translate-y-[-1px]",
                  )}
                  aria-pressed={isSelected}
                >
                  <Card
                    className={cn(
                      "h-full border-2 transition-colors",
                      isSelected ? "border-primary shadow-lg shadow-primary/20" : "border-transparent",
                    )}
                  >
                    <CardHeader className="flex flex-row items-start gap-4 space-y-0 pb-[30px]">
                      <Avatar className="h-16 w-16 border-2 border-muted">
                        <AvatarImage src={buildAvatarUrl(match.id)} alt={match.name} />
                        <AvatarFallback>{match.name.slice(0, 2).toUpperCase()}</AvatarFallback>
                      </Avatar>
                      <div className="flex-1 space-y-3">
                        <div className="flex flex-wrap items-start justify-between gap-3">
                          <div className="space-y-1">
                            <CardTitle className="text-lg font-semibold">{match.name}</CardTitle>
                            {(credentialBadge || experienceCopy) && (
                              <div className="flex flex-wrap items-center gap-2 text-xs">
                                {credentialBadge && (
                                  <Badge variant="secondary" className="flex items-center gap-1">
                                    <Award className="h-3 w-3" />
                                    {credentialBadge}
                                  </Badge>
                                )}
                                {experienceCopy && (
                                  <span className="text-muted-foreground">{experienceCopy}</span>
                                )}
                              </div>
                            )}
                          </div>
                          <Badge
                            variant={isSelected ? "default" : "outline"}
                            className="flex items-center gap-1"
                          >
                            <Check className={cn("h-3 w-3", !isSelected && "hidden")} />
                            {Math.round(match.matchScore)}% match
                          </Badge>
                        </div>
                        {match.bio && (
                          <p className="mb-4 text-sm leading-relaxed text-muted-foreground">{match.bio}</p>
                        )}
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-3">
                      {match.specialties.length > 0 && (
                        <div className="flex flex-wrap gap-2">
                          {match.specialties.slice(0, 3).map((specialty) => (
                            <Badge key={specialty} variant="outline" className="text-xs font-medium">
                              {specialty}
                            </Badge>
                          ))}
                        </div>
                      )}
                      {match.languages.length > 0 && (
                        <p className="text-xs text-muted-foreground">
                          Languages: {match.languages.join(", ")}
                        </p>
                      )}
                      {match.modalities.length > 0 && (
                        <p className="text-xs text-muted-foreground">
                          Approaches: {match.modalities.slice(0, 3).join(", ")}
                          {match.modalities.length > 3 ? "…" : ""}
                        </p>
                      )}
                      {preferenceDetails?.applied && (
                        <p
                          className={cn(
                            "text-xs font-medium",
                            preferenceDetails.matched ? "text-emerald-600" : "text-amber-600",
                          )}
                        >
                          Preference:&nbsp;
                          {preferenceDetails.matched
                            ? `Matches ${preferenceDetails.requested?.toString().replace("-", " ")}`
                            : `Does not match ${preferenceDetails.requested?.toString().replace("-", " ")}`}
                        </p>
                      )}
                      {languageDetails && preference === "language" && (
                        <p
                          className={cn(
                            "text-xs",
                            languageDetails.matched ? "text-emerald-600 font-medium" : "text-amber-600 font-medium",
                          )}
                        >
                          Language preference:&nbsp;
                          {languageDetails.matched
                            ? `Speaks ${String(languageDetails.requested || "requested language")}`
                            : "Requested language unavailable"}
                        </p>
                      )}
                      {availabilitySummary && (
                        <p className="text-xs text-muted-foreground">{availabilitySummary}</p>
                      )}
                      {capacityAvailable !== null &&
                        typeof capacityAvailable === "number" &&
                        capacityAvailable > 0 && (
                          <p className="text-xs text-emerald-600">{capacityAvailable} openings this month</p>
                        )}
                    </CardContent>
                  </Card>
                </button>
              );
            })}
            </div>
          </>
        )}
      </div>
    </QuestionFrame>
  );
}


