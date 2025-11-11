import { Play } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export interface TestimonialCardProps {
  /** Quote text from the testimonial */
  quote: string;
  /** Name of the person giving the testimonial */
  name: string;
  /** Role or description of the person (e.g., "Parent", "School Counselor") */
  role: string;
  /** Optional avatar image URL */
  avatarUrl?: string;
  /** Optional video URL to play when clicked */
  videoUrl?: string;
  /** Optional click handler for video playback */
  onVideoClick?: () => void;
  /** Additional CSS classes */
  className?: string;
}

export function TestimonialCard({
  quote,
  name,
  role,
  avatarUrl,
  videoUrl,
  onVideoClick,
  className,
}: TestimonialCardProps) {
  const initials = name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  return (
    <Card
      className={cn(
        "relative p-6 shadow-md transition-shadow hover:shadow-lg",
        className
      )}
    >
      {/* Video Play Button Overlay */}
      {videoUrl && (
        <div className="absolute right-4 top-4">
          <Button
            variant="outline"
            size="icon"
            className="h-10 w-10 rounded-full"
            onClick={onVideoClick}
            aria-label="Play video testimonial"
          >
            <Play className="h-5 w-5 fill-current" />
          </Button>
        </div>
      )}

      {/* Quote */}
      <blockquote className="mb-6 text-body-large italic text-foreground">
        &ldquo;{quote}&rdquo;
      </blockquote>

      {/* Attribution */}
      <div className="flex items-center gap-4">
        <Avatar className="h-12 w-12">
          <AvatarImage src={avatarUrl} alt={name} />
          <AvatarFallback>{initials}</AvatarFallback>
        </Avatar>
        <div>
          <div className="font-semibold text-foreground">{name}</div>
          <div className="text-sm text-muted-foreground">{role}</div>
        </div>
      </div>
    </Card>
  );
}

