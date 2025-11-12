"use client";

import { ReactNode } from "react";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export const LEMONADE_PRIMARY_BUTTON_CLASSES =
  "min-w-[160px] rounded-full bg-primary px-10 py-5 text-base font-semibold text-primary-foreground shadow-lg shadow-primary/30 transition-transform duration-150 ease-out hover:-translate-y-0.5 hover:shadow-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/70 focus-visible:ring-offset-2 disabled:translate-y-0 disabled:shadow-none";

export const LEMONADE_SECONDARY_BUTTON_CLASSES =
  "rounded-full border border-transparent px-8 py-4 text-base font-medium text-primary transition-colors duration-150 hover:bg-primary/10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/40 focus-visible:ring-offset-2";

interface QuestionFrameProps {
  eyebrow?: string;
  title: string;
  description?: string;
  errorMessage?: string | null;
  primaryAction?: {
    label: string;
    onClick: () => void;
    disabled?: boolean;
    loading?: boolean;
  };
  secondaryAction?: {
    label: string;
    onClick: () => void;
    variant?: "ghost" | "link";
  };
  children?: ReactNode;
  className?: string;
}

export function QuestionFrame({
  eyebrow,
  title,
  description,
  errorMessage,
  children,
  primaryAction,
  secondaryAction,
  className,
}: QuestionFrameProps) {
  return (
    <div className={cn("flex flex-col gap-10", className)}>
      <header className="space-y-4 text-center">
        {eyebrow && (
          <p className="text-xs font-semibold uppercase tracking-widest text-primary/80">{eyebrow}</p>
        )}
        <h1 className="text-3xl font-semibold leading-tight text-foreground sm:text-[2.5rem]">
          {title}
        </h1>
        {description && <p className="mx-auto max-w-xl text-base text-muted-foreground">{description}</p>}
      </header>
      {children && <div className="mx-auto flex w-full max-w-xl flex-col gap-6">{children}</div>}
      {errorMessage && (
        <div className="mx-auto w-full max-w-xl rounded-2xl border border-destructive/20 bg-destructive/10 px-4 py-3 text-sm text-destructive shadow-sm">
          {errorMessage}
        </div>
      )}
      {(primaryAction || secondaryAction) && (
        <footer className="flex flex-col items-center justify-center gap-3 sm:flex-row">
          {primaryAction && (
            <Button
              size="lg"
              className={LEMONADE_PRIMARY_BUTTON_CLASSES}
              onClick={primaryAction.onClick}
              disabled={primaryAction.disabled || primaryAction.loading}
            >
              {primaryAction.loading && (
                <Loader2 className="mr-2 h-5 w-5 animate-spin text-primary-foreground" />
              )}
              {primaryAction.label}
            </Button>
          )}
          {secondaryAction && (
            <Button
              variant={secondaryAction.variant ?? "ghost"}
              size="lg"
              onClick={secondaryAction.onClick}
              className={cn(
                LEMONADE_SECONDARY_BUTTON_CLASSES,
                secondaryAction.variant === "link" && "bg-transparent px-0 py-0 text-base font-semibold text-muted-foreground hover:text-foreground hover:bg-transparent",
              )}
            >
              {secondaryAction.label}
            </Button>
          )}
        </footer>
      )}
    </div>
  );
}


