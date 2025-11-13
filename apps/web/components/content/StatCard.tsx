import { LucideIcon } from "lucide-react";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";

export interface StatCardProps {
  /** Large number or percentage to display */
  value: string;
  /** Descriptive label for the stat */
  label: string;
  /** Optional icon to display above the value */
  icon?: LucideIcon;
  /** Additional CSS classes */
  className?: string;
}

export function StatCard({ value, label, icon: Icon, className }: StatCardProps) {
  return (
    <Card className={cn("p-6 text-center transition-shadow hover:shadow-lg", className)}>
      {Icon && (
        <div className="mb-4 flex justify-center">
          <Icon className="h-8 w-8 text-primary" />
        </div>
      )}
      <div className="text-display-mobile font-bold text-primary md:text-h1">
        {value}
      </div>
      <p className="mt-2 text-body-small text-muted-foreground">
        {label}
      </p>
    </Card>
  );
}



