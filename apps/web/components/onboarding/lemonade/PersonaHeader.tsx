"use client";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { cn } from "@/lib/utils";

interface PersonaHeaderProps {
  personaName?: string;
  personaTitle?: string;
  imageSrc?: string;
  className?: string;
}

const DEFAULT_NAME = "Daybreak Coach";
const DEFAULT_AVATAR_URL = "/avatars/daybreak-coach.png";

export function PersonaHeader({
  personaName = DEFAULT_NAME,
  personaTitle = "Here to walk you through this",
  imageSrc,
  className,
}: PersonaHeaderProps) {
  const initials = personaName
    .split(" ")
    .map((part) => part.charAt(0))
    .join("")
    .slice(0, 2)
    .toUpperCase();

  const resolvedImage = imageSrc ?? DEFAULT_AVATAR_URL;

  return (
    <div
      className={cn(
        "relative mx-auto flex w-full max-w-xl flex-col items-center gap-3 text-center",
        className,
      )}
    >
      <div className="relative">
        <div className="absolute inset-0 rounded-full bg-primary/30 blur-2xl" aria-hidden="true" />
        <Avatar className="relative h-16 w-16 overflow-hidden border-4 border-white shadow-lg ring-4 ring-primary/30">
          <AvatarImage src={resolvedImage} alt={`${personaName} avatar`} />
          <AvatarFallback className="bg-primary text-lg font-semibold text-primary-foreground">
            {initials || "DB"}
          </AvatarFallback>
        </Avatar>
      </div>
      <div className="space-y-1">
        <p className="text-sm font-medium uppercase tracking-wide text-primary">{personaName}</p>
        <p className="text-xs text-muted-foreground">{personaTitle}</p>
      </div>
    </div>
  );
}


