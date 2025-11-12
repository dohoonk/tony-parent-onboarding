"use client";

import { cn } from "@/lib/utils";

export interface ChapterProgress {
  id: string;
  label: string;
  completedQuestions: number;
  totalQuestions: number;
}

interface SegmentedProgressProps {
  chapters: ChapterProgress[];
  activeChapterId: string;
  onStepSelect?: (stepId: string) => void;
}

export const STEP_GROUPS = [
  { id: "you", label: "You", chapters: ["you"] },
  { id: "child", label: "Your Child", chapters: ["student"] },
  { id: "assessment", label: "Assessment", chapters: ["intake", "screeners"] },
  { id: "insurance", label: "Insurance", chapters: ["insurance"] },
  { id: "schedule", label: "Schedule", chapters: ["scheduling", "finish"] },
];

export function SegmentedProgress({ chapters, activeChapterId, onStepSelect }: SegmentedProgressProps) {
  const stepSummaries = STEP_GROUPS.map((step) => {
    const stepChapters = chapters.filter((chapter) => step.chapters.includes(chapter.id));
    const stepTotal = stepChapters.reduce((sum, chapter) => sum + chapter.totalQuestions, 0);
    const stepCompleted = stepChapters.reduce(
      (sum, chapter) => sum + Math.min(chapter.completedQuestions, chapter.totalQuestions),
      0,
    );
    const percent = stepTotal === 0 ? 0 : Math.round((stepCompleted / stepTotal) * 100);
    const isActive = step.chapters.includes(activeChapterId);
    const isComplete = percent >= 100 && !isActive;

    return {
      ...step,
      percent,
      isActive,
      isComplete,
    };
  });

  const activeStepIndex = Math.max(
    stepSummaries.findIndex((step) => step.isActive),
    0,
  );

  const currentStep = activeStepIndex + 1;
  const totalSteps = stepSummaries.length;
  const overallPercent = Math.min((currentStep - 1) * 20, 100);

  return (
    <div className="flex w-full flex-col items-center gap-4">
      <div className="flex items-center gap-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        <span>
          Step {currentStep} of {totalSteps}
        </span>
        <span className="text-muted-foreground/40">•</span>
        <span>{overallPercent}% complete</span>
      </div>
      <div className="flex w-full justify-center">
        <div className="flex w-full max-w-3xl items-center justify-between gap-4 border-b border-muted-foreground/20 pb-2">
          {stepSummaries.map((step) => {
            const clickable = typeof onStepSelect === "function";
            return (
              <button
                key={step.id}
                type="button"
                onClick={clickable ? () => onStepSelect?.(step.id) : undefined}
                className={cn(
                  "flex flex-1 flex-col items-center gap-2 bg-transparent p-0 text-center transition focus:outline-none",
                  clickable ? "cursor-pointer hover:opacity-90" : "cursor-default",
                )}
              >
                <span
                  className={cn(
                    "text-[13px] font-semibold uppercase tracking-wide text-muted-foreground transition-colors",
                    step.isActive && "text-primary",
                    step.isComplete && !step.isActive && "text-muted-foreground/60",
                  )}
                >
                  {step.label}
                </span>
                <div
                  className={cn(
                    "h-1 w-full max-w-[72px] rounded-full bg-transparent transition-all duration-300",
                    step.isActive && "bg-gradient-to-r from-primary to-primary/70 shadow-[0_3px_12px_rgba(31,142,241,0.25)]",
                    !step.isActive && step.isComplete && "bg-primary/15",
                    !step.isActive && !step.isComplete && "bg-muted-foreground/10",
                  )}
                />
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}


