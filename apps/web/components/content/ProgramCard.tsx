import Link from "next/link";
import { LucideIcon } from "lucide-react";
import { Card, CardHeader, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export interface ProgramCardProps {
  /** Icon component to display at the top */
  icon: LucideIcon;
  /** Program or service title */
  title: string;
  /** Brief description of the program (2-3 lines) */
  description: string;
  /** CTA button text (defaults to "Learn More") */
  ctaText?: string;
  /** Link URL for the CTA button */
  ctaHref: string;
  /** Optional icon color class (defaults to text-primary) */
  iconClassName?: string;
  /** Additional CSS classes */
  className?: string;
}

export function ProgramCard({
  icon: Icon,
  title,
  description,
  ctaText = "Learn More",
  ctaHref,
  iconClassName,
  className,
}: ProgramCardProps) {
  return (
    <Card
      className={cn(
        "flex h-full flex-col rounded-lg p-6 shadow-md transition-all hover:shadow-lg hover:-translate-y-1",
        className
      )}
    >
      <CardHeader className="p-0">
        {/* Icon */}
        <div className="mb-4 flex items-center justify-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
            <Icon className={cn("h-8 w-8 text-primary", iconClassName)} />
          </div>
        </div>

        {/* Title */}
        <h3 className="text-h3-mobile font-semibold text-foreground md:text-h3">
          {title}
        </h3>
      </CardHeader>

      <CardContent className="flex-1 p-0 pt-4">
        {/* Description */}
        <p className="text-body text-muted-foreground">
          {description}
        </p>
      </CardContent>

      <CardFooter className="p-0 pt-6">
        {/* CTA Button */}
        <Button asChild variant="outline" className="w-full">
          <Link href={ctaHref}>{ctaText}</Link>
        </Button>
      </CardFooter>
    </Card>
  );
}



