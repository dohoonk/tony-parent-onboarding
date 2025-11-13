"use client";

import { useState } from "react";
import Image from "next/image";
import { Play } from "lucide-react";
import { AspectRatio } from "@/components/ui/aspect-ratio";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export interface VideoCardProps {
  /** Thumbnail image URL */
  thumbnailUrl: string;
  /** Video embed URL (YouTube, Vimeo, etc.) */
  videoUrl: string;
  /** Video title for accessibility and dialog */
  title: string;
  /** Optional description to display below thumbnail */
  description?: string;
  /** Alt text for thumbnail image */
  alt?: string;
  /** Additional CSS classes */
  className?: string;
}

export function VideoCard({
  thumbnailUrl,
  videoUrl,
  title,
  description,
  alt,
  className,
}: VideoCardProps) {
  const [isOpen, setIsOpen] = useState(false);

  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      setIsOpen(true);
    }
  };

  // Extract video ID from YouTube/Vimeo URLs for embed
  const getEmbedUrl = (url: string) => {
    // YouTube
    if (url.includes("youtube.com") || url.includes("youtu.be")) {
      const videoId = url.includes("youtu.be")
        ? url.split("/").pop()?.split("?")[0]
        : new URL(url).searchParams.get("v");
      return `https://www.youtube.com/embed/${videoId}`;
    }
    // Vimeo
    if (url.includes("vimeo.com")) {
      const videoId = url.split("/").pop();
      return `https://player.vimeo.com/video/${videoId}`;
    }
    return url; // Assume it's already an embed URL
  };

  return (
    <>
      <div className={cn("group", className)}>
        {/* Video Thumbnail with Play Button */}
        <div
          className="relative cursor-pointer overflow-hidden rounded-lg transition-shadow hover:shadow-lg"
          onClick={() => setIsOpen(true)}
          onKeyDown={handleKeyDown}
          role="button"
          tabIndex={0}
          aria-label={`Play video: ${title}`}
        >
          <AspectRatio ratio={16 / 9}>
            <Image
              src={thumbnailUrl}
              alt={alt || title}
              fill
              className="object-cover transition-transform group-hover:scale-105"
              sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
            />
            {/* Play Button Overlay */}
            <div className="absolute inset-0 flex items-center justify-center bg-black/20 transition-all group-hover:bg-black/30">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/90 shadow-lg transition-all group-hover:scale-110 group-hover:bg-primary md:h-20 md:w-20">
                <Play className="ml-1 h-8 w-8 fill-primary-foreground text-primary-foreground md:h-10 md:w-10" />
              </div>
            </div>
          </AspectRatio>
        </div>

        {/* Optional Description */}
        {description && (
          <p className="mt-4 text-body text-muted-foreground">{description}</p>
        )}
      </div>

      {/* Video Modal Dialog */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-4xl">
          <DialogHeader>
            <DialogTitle>{title}</DialogTitle>
          </DialogHeader>
          <AspectRatio ratio={16 / 9} className="bg-muted">
            <iframe
              src={getEmbedUrl(videoUrl)}
              title={title}
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              className="h-full w-full rounded-md"
            />
          </AspectRatio>
        </DialogContent>
      </Dialog>
    </>
  );
}



