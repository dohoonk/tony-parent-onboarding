import Link from "next/link";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export interface HeroProps {
  title: string;
  subtitle?: string;
  primaryCta?: {
    text: string;
    href: string;
  };
  secondaryCta?: {
    text: string;
    href: string;
  };
  className?: string;
}

export function Hero({
  title,
  subtitle,
  primaryCta,
  secondaryCta,
  className,
}: HeroProps) {
  return (
    <section
      className={cn(
        "relative w-full bg-background py-20 md:py-28 lg:py-32",
        className
      )}
    >
      <div className="container mx-auto max-w-7xl px-4">
        <div className="flex flex-col items-center text-center">
          {/* Headline */}
          <h1 className="text-display-mobile font-bold tracking-tight text-foreground md:text-display">
            {title}
          </h1>

          {/* Subheading */}
          {subtitle && (
            <p className="mt-6 max-w-3xl text-body-large text-muted-foreground">
              {subtitle}
            </p>
          )}

          {/* CTA Buttons */}
          {(primaryCta || secondaryCta) && (
            <div className="mt-10 flex flex-col gap-4 sm:flex-row sm:gap-6">
              {primaryCta && (
                <Button asChild size="lg" className="touch-target">
                  <Link href={primaryCta.href}>{primaryCta.text}</Link>
                </Button>
              )}
              {secondaryCta && (
                <Button
                  asChild
                  size="lg"
                  variant="outline"
                  className="touch-target"
                >
                  <Link href={secondaryCta.href}>{secondaryCta.text}</Link>
                </Button>
              )}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}

