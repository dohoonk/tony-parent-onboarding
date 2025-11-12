"use client";

import { PropsWithChildren } from "react";

import { PersonaHeader } from "./PersonaHeader";
import { SegmentedProgress, ChapterProgress } from "./SegmentedProgress";
import { cn } from "@/lib/utils";

interface LemonadeLayoutProps extends PropsWithChildren {
  personaName?: string;
  personaTitle?: string;
  avatarSrc?: string;
  chapters: ChapterProgress[];
  activeChapterId: string;
  activeQuestionId?: string;
  className?: string;
  onStepSelect?: (stepId: string) => void;
}

export function LemonadeLayout({
  personaName,
  personaTitle,
  avatarSrc,
  chapters,
  activeChapterId,
  activeQuestionId,
  children,
  className,
  onStepSelect,
}: LemonadeLayoutProps) {
  return (
    <div
      className={cn(
        "flex min-h-screen flex-col items-center bg-gradient-to-b from-white via-white to-primary/10 px-4 pb-16 pt-10",
        className,
      )}
    >
      <PersonaHeader personaName={personaName} personaTitle={personaTitle} imageSrc={avatarSrc} />
      <div className="mt-6 w-full max-w-3xl">
        <SegmentedProgress 
          chapters={chapters} 
          activeChapterId={activeChapterId} 
          activeQuestionId={activeQuestionId}
          onStepSelect={onStepSelect} 
        />
      </div>
      <section
        key={activeChapterId}
        className={cn(
          "relative mt-10 w-full max-w-3xl overflow-hidden rounded-3xl bg-white shadow-xl ring-1 ring-black/5",
          "transition-all duration-500 ease-out data-[state=enter]:translate-y-0 data-[state=enter]:opacity-100 data-[state=exit]:-translate-y-4 data-[state=exit]:opacity-0",
        )}
        data-state="enter"
      >
        <div className="absolute inset-x-0 -top-2 h-1 bg-gradient-to-r from-primary via-primary to-primary/60 opacity-80" />
        <div className="relative px-6 py-10 sm:px-12 sm:py-12">{children}</div>
      </section>
    </div>
  );
}


