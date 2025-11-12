"use client";

import { ChangeEvent, useEffect, useState } from "react";
import { QuestionConfig, QuestionOption } from "@/flows/onboarding/chapters";
import { QuestionFrame } from "./QuestionFrame";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Checkbox } from "@/components/ui/checkbox";
import { cn } from "@/lib/utils";
import { AIIntakeStep } from "@/components/onboarding/lemonade/chat/AIIntakeStep";
import { TherapistMatchQuestion } from "@/components/onboarding/lemonade/TherapistMatchQuestion";
import { AccountCheckQuestion } from "@/components/onboarding/lemonade/AccountCheckQuestion";

interface QuestionRendererProps {
  question: QuestionConfig;
  value?: any;
  onChange: (value: any) => void;
  onNext: () => Promise<void> | void;
  onSkip?: () => Promise<void> | void;
  isSubmitting?: boolean;
  errorMessage?: string | null;
  answers: Record<string, any>;
  sessionId?: string | null;
}
function ChoiceList({
  options,
  value,
  onSelect,
  disabled,
}: {
  options: QuestionOption[];
  value?: string;
  onSelect: (value: string) => void;
  disabled?: boolean;
}) {
  const handleSelect = (next: string) => {
    if (disabled) return;
    onSelect(next);
  };

  return (
    <RadioGroup value={value} onValueChange={handleSelect} className="grid gap-3">
      {options.map((option) => (
        <Label
          key={option.id}
          htmlFor={option.id}
          className={cn(
            "flex cursor-pointer items-center justify-between rounded-2xl border border-muted px-4 py-4 text-left shadow-sm transition hover:border-primary/50 hover:shadow-md",
            disabled && "cursor-not-allowed opacity-60",
          )}
        >
          <div className="flex flex-1 items-center gap-4">
            <RadioGroupItem
              id={option.id}
              value={option.id}
              className="h-5 w-5 border-2"
              disabled={disabled}
            />
            <div>
              <p className="text-base font-medium text-foreground">{option.label}</p>
              {option.description && (
                <p className="mt-1 text-sm text-muted-foreground">{option.description}</p>
              )}
            </div>
          </div>
        </Label>
      ))}
    </RadioGroup>
  );
}

const runAsync = async (fn?: () => Promise<void> | void) => {
  if (!fn) return;
  await Promise.resolve(fn());
};

export function QuestionRenderer({
  question,
  value,
  onChange,
  onNext,
  onSkip,
  isSubmitting,
  errorMessage,
  answers,
  sessionId,
}: QuestionRendererProps) {
  const [internalValue, setInternalValue] = useState<any>(value ?? "");

  useEffect(() => {
    if (question.type === "checkbox") {
      setInternalValue(value ?? false);
    } else if (question.type === "therapist-match") {
      setInternalValue(value ?? null);
    } else if (question.type === "account-check") {
      setInternalValue(
        value ?? {
          hasAccount: null,
          authenticated: false,
        },
      );
    } else {
      setInternalValue(value ?? "");
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value, question.id]);

  const syncValue = (newValue: any) => {
    setInternalValue(newValue);
    onChange(newValue);
  };

  const handleInputChange = (event: ChangeEvent<HTMLInputElement>) => {
    syncValue(event.target.value);
  };

  const handleContinue = async () => {
    if (!question.optional && (internalValue === undefined || internalValue === "")) {
      return;
    }
    await runAsync(onNext);
  };

  switch (question.type) {
    case "intro":
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void runAsync(onNext),
            loading: isSubmitting,
            disabled: isSubmitting,
          }}
        />
      );

    case "therapist-match":
      return (
        <TherapistMatchQuestion
          question={question}
          value={value}
          onChange={syncValue}
          onContinue={() => runAsync(onNext)}
          onSkip={onSkip}
          isSubmitting={isSubmitting}
          errorMessage={errorMessage}
          sessionId={sessionId}
          preferredDate={answers["schedule-date"]}
          preferredWindow={answers["schedule-time-window"]}
          preference={answers["schedule-therapist-preference"]}
        />
      );

    case "account-check":
      return (
        <AccountCheckQuestion
          question={question}
          value={internalValue}
          onChange={(val) => syncValue(val)}
          onContinue={() => runAsync(onNext)}
          isSubmitting={isSubmitting}
          externalError={errorMessage}
        />
      );

    case "email":
    case "text":
    case "phone":
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void handleContinue(),
            disabled: (!question.optional && !internalValue) || !!isSubmitting,
            loading: isSubmitting,
          }}
          secondaryAction={
            question.optional && question.secondaryLabel && onSkip
              ? {
                  label: question.secondaryLabel,
                  onClick: () => void runAsync(onSkip),
                  variant: "link",
                }
              : undefined
          }
        >
          <div className="flex flex-col gap-2">
            <Label className="text-sm text-muted-foreground">
              {question.type === "email"
                ? "Email address"
                : question.type === "phone"
                ? "Phone number"
                : "Response"}
            </Label>
            <Input
              type={question.type === "email" ? "email" : question.type === "phone" ? "tel" : "text"}
              value={internalValue}
              placeholder={
                question.type === "email"
                  ? "you@example.com"
                  : question.type === "phone"
                  ? "(555) 555-5555"
                  : ""
              }
              onChange={handleInputChange}
              disabled={!!isSubmitting}
              className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
            />
          </div>
        </QuestionFrame>
      );

    case "date":
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void handleContinue(),
            disabled: !internalValue || !!isSubmitting,
            loading: isSubmitting,
          }}
        >
          <div className="flex flex-col gap-2">
            <Label className="text-sm text-muted-foreground">Select a date</Label>
            <Input
              type="date"
              value={internalValue ?? ""}
              onChange={(event) => syncValue(event.target.value)}
              disabled={!!isSubmitting}
              className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
            />
          </div>
        </QuestionFrame>
      );

    case "choice":
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void handleContinue(),
            disabled: (!internalValue && !question.optional) || !!isSubmitting,
            loading: isSubmitting,
          }}
          secondaryAction={
            question.optional && question.secondaryLabel && onSkip
              ? {
                  label: question.secondaryLabel,
                  onClick: () => void runAsync(onSkip),
                  variant: "link",
                }
              : undefined
          }
        >
          <ChoiceList
            options={question.options ?? []}
            value={internalValue}
            onSelect={(selected) => syncValue(selected)}
            disabled={!!isSubmitting}
          />
        </QuestionFrame>
      );

    case "checkbox":
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void handleContinue(),
            disabled: (!internalValue && !question.optional) || !!isSubmitting,
            loading: isSubmitting,
          }}
        >
          <Label
            htmlFor={question.id}
            className={cn(
              "flex cursor-pointer items-start gap-4 rounded-2xl border border-muted px-5 py-4 text-left shadow-sm transition hover:border-primary/50 hover:shadow-md",
              isSubmitting && "cursor-not-allowed opacity-60",
            )}
          >
            <Checkbox
              id={question.id}
              checked={!!internalValue}
              onCheckedChange={(checked) => syncValue(checked === true)}
              disabled={!!isSubmitting}
              className="mt-1 h-5 w-5 border-2"
            />
            <div>
              <p className="text-base font-medium text-foreground">
                I agree to the terms of service and privacy policy.
              </p>
            </div>
          </Label>
        </QuestionFrame>
      );

    case "address":
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void handleContinue(),
            disabled:
              !internalValue ||
              !internalValue.street ||
              !internalValue.city ||
              !internalValue.state ||
              !internalValue.postalCode ||
              !!isSubmitting,
            loading: isSubmitting,
          }}
        >
          <div className="flex flex-col gap-4">
            <div className="flex flex-col gap-2">
              <Label className="text-sm text-muted-foreground">Street address</Label>
              <Input
                value={internalValue?.street ?? ""}
                placeholder="123 Main St"
                onChange={(event) =>
                  syncValue({
                    ...(internalValue ?? {}),
                    street: event.target.value,
                  })
                }
                disabled={!!isSubmitting}
                className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
              />
            </div>
            <div className="grid gap-3 sm:grid-cols-2">
              <div className="flex flex-col gap-2">
                <Label className="text-sm text-muted-foreground">City</Label>
                <Input
                  value={internalValue?.city ?? ""}
                  placeholder="City"
                  onChange={(event) =>
                    syncValue({
                      ...(internalValue ?? {}),
                      city: event.target.value,
                    })
                  }
                  disabled={!!isSubmitting}
                  className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label className="text-sm text-muted-foreground">State</Label>
                <Input
                  value={internalValue?.state ?? ""}
                  placeholder="CA"
                  onChange={(event) =>
                    syncValue({
                      ...(internalValue ?? {}),
                      state: event.target.value,
                    })
                  }
                  disabled={!!isSubmitting}
                  className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
                />
              </div>
            </div>
            <div className="flex flex-col gap-2 sm:w-1/2">
              <Label className="text-sm text-muted-foreground">ZIP / Postal code</Label>
              <Input
                value={internalValue?.postalCode ?? ""}
                placeholder="12345"
                onChange={(event) =>
                  syncValue({
                    ...(internalValue ?? {}),
                    postalCode: event.target.value,
                  })
                }
                disabled={!!isSubmitting}
                className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
              />
            </div>
          </div>
        </QuestionFrame>
      );

    case "upload":
      const fileLabel =
        internalValue instanceof File
          ? internalValue.name
          : typeof internalValue === "object" && internalValue !== null
          ? internalValue.name ?? ""
          : "";
      return (
        <QuestionFrame
          title={question.prompt}
          description={question.helperText}
          errorMessage={errorMessage}
          primaryAction={{
            label: question.ctaLabel ?? "Continue",
            onClick: () => void handleContinue(),
            disabled: (!internalValue || internalValue === "") || !!isSubmitting,
            loading: isSubmitting,
          }}
          secondaryAction={
            question.optional && question.secondaryLabel && onSkip
              ? {
                  label: question.secondaryLabel,
                  onClick: () => void runAsync(onSkip),
                  variant: "link",
                }
              : undefined
          }
        >
          <div className="flex flex-col gap-3">
            <Label className="text-sm text-muted-foreground">Upload image</Label>
            <Input
              type="file"
              accept="image/*"
              onChange={(event) => {
                const file = event.target.files?.[0];
                if (file) {
                  syncValue(file);
                }
              }}
              disabled={!!isSubmitting}
              className="h-auto rounded-2xl border-2 border-dashed border-muted bg-white py-6 text-base"
            />
            {internalValue instanceof File && (
              <p className="text-sm text-muted-foreground">
                Selected: <span className="font-medium text-foreground">{internalValue.name}</span>
              </p>
            )}
            {! (internalValue instanceof File) && fileLabel && (
              <p className="text-sm text-muted-foreground">
                Selected: <span className="font-medium text-foreground">{fileLabel}</span>
              </p>
            )}
          </div>
        </QuestionFrame>
      );

    case "chat":
      return (
        <AIIntakeStep
          onComplete={async (summary) => {
            onChange(summary);
            await runAsync(onNext);
          }}
          onExit={async () => {
            await runAsync(onNext);
          }}
        />
      );

    default:
      return (
        <QuestionFrame
          title="This question type is not implemented yet."
          description="Please check back soon."
          errorMessage={errorMessage}
          primaryAction={{
            label: "Continue",
            onClick: () => void runAsync(onNext),
            loading: isSubmitting,
            disabled: isSubmitting,
          }}
        />
      );
  }
}

