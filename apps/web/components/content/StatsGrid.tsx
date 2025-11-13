import { cn } from "@/lib/utils";

export interface StatsGridProps {
  children: React.ReactNode;
  /** Number of columns on desktop (defaults to 3) */
  columns?: 2 | 3 | 4;
  className?: string;
}

export function StatsGrid({ children, columns = 3, className }: StatsGridProps) {
  return (
    <div
      className={cn(
        "grid gap-6 md:gap-8",
        {
          "grid-cols-1 md:grid-cols-2": columns === 2,
          "grid-cols-1 md:grid-cols-2 lg:grid-cols-3": columns === 3,
          "grid-cols-1 md:grid-cols-2 lg:grid-cols-4": columns === 4,
        },
        className
      )}
    >
      {children}
    </div>
  );
}



