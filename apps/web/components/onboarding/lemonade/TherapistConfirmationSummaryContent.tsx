"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { CheckCircle2, Calendar, Mail, Sparkles, User } from "lucide-react";
import { ReactNode } from "react";

type TherapistSelection = {
  therapistName?: string;
  scheduledDate?: string;
  timeWindow?: string;
  matchScore?: number;
  matchRationale?: string;
  languages?: string[];
  specialties?: string[];
};

interface TherapistConfirmationSummaryContentProps {
  therapistSelection?: TherapistSelection | null;
  contactName?: string;
  contactEmail?: string;
  studentName?: string;
  estimatedCost?: string | null;
}

const TIME_WINDOW_LABELS: Record<string, string> = {
  morning: "Morning (8am – 12pm)",
  afternoon: "Afternoon (12pm – 4pm)",
  evening: "Evening (4pm – 7pm)",
  weekend: "Weekend availability",
};

const NEXT_STEPS: Array<{ title: string; description: string }> = [
  {
    title: "You’ll get a confirmation email and text shortly",
    description: "We’ll include a secure link so you can reschedule or update preferences anytime.",
  },
  {
    title: "Your therapist will reach out before the first session",
    description: "Expect a short note with what to bring and how to prepare together.",
  },
  {
    title: "We’ll verify insurance + cost details",
    description: "Our team double-checks benefits so there are no surprises.",
  },
];

const TIMELINE: Array<{ label: string; detail: string }> = [
  {
    label: "Before first session",
    detail: "Therapist introduction, prep checklist, and family welcome packet.",
  },
  {
    label: "First session",
    detail: "50-minute visit focused on goals, routines, and building trust.",
  },
  {
    label: "Ongoing support",
    detail: "Progress check-ins every 4–6 weeks with clear next steps.",
  },
];

const formatScheduledDate = (date?: string | null): string | null => {
  if (!date) return null;
  try {
    const formatter = new Intl.DateTimeFormat("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
    return formatter.format(new Date(`${date}T00:00:00`));
  } catch {
    return null;
  }
};

const SummaryLine = ({ label, value }: { label: string; value: ReactNode }) => (
  <div className="space-y-1">
    <p className="text-sm font-medium text-foreground">{label}</p>
    <p className="text-sm text-muted-foreground">{value}</p>
  </div>
);

export function TherapistConfirmationSummaryContent({
  therapistSelection,
  contactEmail,
  contactName,
  studentName,
  estimatedCost,
}: TherapistConfirmationSummaryContentProps) {
  const readableDate = formatScheduledDate(therapistSelection?.scheduledDate);
  const timeWindowLabel =
    (therapistSelection?.timeWindow && TIME_WINDOW_LABELS[therapistSelection.timeWindow]) ?? null;
  const introStudent = studentName ? `${studentName}’s` : "Your";
  const therapistName = therapistSelection?.therapistName ?? "Your matched therapist";
  const matchNote = therapistSelection?.matchRationale ?? "Great fit based on your family’s preferences.";
  const languages = therapistSelection?.languages?.length ? therapistSelection.languages.join(", ") : null;
  const specialties = therapistSelection?.specialties?.length
    ? therapistSelection.specialties.slice(0, 3).join(", ")
    : null;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col items-center gap-2 text-center">
        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-emerald-100">
          <CheckCircle2 className="h-6 w-6 text-emerald-700" />
        </div>
        <p className="text-sm font-medium uppercase tracking-wide text-emerald-700">You’re confirmed</p>
        <p className="max-w-xl text-base text-muted-foreground">
          We’ve held {introStudent.toLowerCase()} first session with <span className="font-semibold text-foreground">{therapistName}</span>.
          Check your inbox for scheduling controls and preparation resources.
        </p>
      </div>

      <Card>
        <CardHeader className="flex flex-col gap-1">
          <div className="flex items-center gap-2 text-primary">
            <Calendar className="h-4 w-4" />
            <CardTitle className="text-lg font-semibold text-foreground">First session snapshot</CardTitle>
          </div>
          <CardDescription>Everything you need to know is in your confirmation email.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <SummaryLine label="Therapist" value={therapistName} />
          {readableDate && (
            <SummaryLine label="Target day" value={readableDate} />
          )}
          {timeWindowLabel && (
            <SummaryLine label="Preferred time" value={timeWindowLabel} />
          )}
          {languages && <SummaryLine label="Languages" value={languages} />}
          {specialties && <SummaryLine label="Focus areas" value={specialties} />}
          {estimatedCost ? (
            <SummaryLine label="Estimated cost" value={estimatedCost} />
          ) : (
            <SummaryLine
              label="Cost status"
              value="We’re verifying your coverage and will confirm any copay before sessions begin."
            />
          )}
          <Card className="border border-primary/20 bg-primary/5">
            <CardContent className="flex flex-col gap-2 py-4">
              <p className="text-sm font-medium text-foreground">Why this match</p>
              <p className="text-sm text-muted-foreground">{matchNote}</p>
            </CardContent>
          </Card>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-foreground">What happens next</CardTitle>
          <CardDescription>We’ll keep you looped in at every step.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-5">
          <div className="space-y-3">
            {NEXT_STEPS.map((step) => (
              <div key={step.title} className="flex items-start gap-3 rounded-xl border border-muted/40 bg-muted/20 p-3">
                <Sparkles className="mt-1 h-4 w-4 text-primary" />
                <div>
                  <p className="text-sm font-semibold text-foreground">{step.title}</p>
                  <p className="text-sm text-muted-foreground">{step.description}</p>
                </div>
              </div>
            ))}
          </div>

          <div className="space-y-3 rounded-xl border border-dashed border-muted px-4 py-4">
            <p className="text-sm font-medium text-foreground">Timeline overview</p>
            <div className="space-y-3">
              {TIMELINE.map((item) => (
                <div key={item.label} className="flex gap-3">
                  <Badge variant="outline" className="shrink-0 text-xs font-semibold">
                    {item.label}
                  </Badge>
                  <p className="text-sm text-muted-foreground">{item.detail}</p>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="border border-emerald-200 bg-emerald-50/80">
        <CardContent className="flex flex-col gap-3 py-6">
          <div className="flex items-center gap-2 text-emerald-700">
            <Sparkles className="h-4 w-4" />
            <p className="text-sm font-semibold uppercase tracking-wide">Families like yours finish strong</p>
          </div>
          <p className="text-sm text-emerald-900/90">
            Parents who secure their therapist at this step complete onboarding with a{" "}
            <span className="font-semibold text-emerald-900">100% success rate</span>. You’re in the home stretch!
          </p>
          <div className="space-y-2 rounded-xl border border-white/60 bg-white/60 p-4">
            <div className="flex items-center justify-between text-sm font-medium text-emerald-800">
              <span>Completion rate</span>
              <span>100%</span>
            </div>
            <Progress value={100} aria-label="100 percent of parents finish onboarding after matching with a therapist" />
          </div>
          {(contactEmail || contactName) && (
            <div className="flex items-center gap-3 rounded-lg border border-emerald-200 bg-white px-4 py-3 text-sm text-emerald-800">
              <Mail className="h-4 w-4 shrink-0 text-emerald-600" />
              <div>
                <p className="font-medium">
                  Updates go to {contactName ? <span>{contactName}</span> : "your primary contact"}
                </p>
                {contactEmail && <p className="text-xs text-emerald-700">{contactEmail}</p>}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <div className="flex items-center gap-3 rounded-xl border border-muted/40 bg-muted/20 px-4 py-3 text-sm text-muted-foreground">
        <User className="h-4 w-4 text-muted-foreground" />
        <p>
          Need to change anything? Reply to your confirmation email and our care team will help within one business day.
        </p>
      </div>
    </div>
  );
}


