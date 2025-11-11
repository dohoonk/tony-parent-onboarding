"use client";

import Image from "next/image";
import Autoplay from "embla-carousel-autoplay";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
} from "@/components/ui/carousel";
import { cn } from "@/lib/utils";

export interface Partner {
  name: string;
  /** Path to logo image or URL */
  logoUrl: string;
  /** Alt text for accessibility */
  alt: string;
}

export interface TrustSectionProps {
  /** Heading text (defaults to "Trusted by...") */
  heading?: string;
  /** Array of partner/insurance provider logos */
  partners: Partner[];
  /** Additional CSS classes */
  className?: string;
}

export function TrustSection({
  heading = "Trusted by top school districts and insurance providers",
  partners,
  className,
}: TrustSectionProps) {
  return (
    <div className={cn("w-full", className)}>
      {/* Heading */}
      <h2 className="mb-8 text-center text-h3-mobile font-semibold text-muted-foreground md:text-h3">
        {heading}
      </h2>

      {/* Logo Carousel */}
      <Carousel
        opts={{
          align: "start",
          loop: true,
        }}
        plugins={[
          Autoplay({
            delay: 3000,
            stopOnInteraction: true,
            stopOnMouseEnter: true,
          }),
        ]}
        className="w-full"
      >
        <CarouselContent className="-ml-4">
          {partners.map((partner, index) => (
            <CarouselItem
              key={`${partner.name}-${index}`}
              className="basis-1/2 pl-4 md:basis-1/3 lg:basis-1/4 xl:basis-1/5"
            >
              <div className="flex h-24 items-center justify-center p-4">
                <div className="relative h-12 w-full transition-all grayscale hover:grayscale-0 md:h-16">
                  <Image
                    src={partner.logoUrl}
                    alt={partner.alt}
                    fill
                    className="object-contain"
                    sizes="(max-width: 768px) 50vw, (max-width: 1024px) 33vw, (max-width: 1280px) 25vw, 20vw"
                  />
                </div>
              </div>
            </CarouselItem>
          ))}
        </CarouselContent>
      </Carousel>
    </div>
  );
}

