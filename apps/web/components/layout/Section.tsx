import { cva, type VariantProps } from "class-variance-authority";
import { Separator } from "@/components/ui/separator";
import { cn } from "@/lib/utils";

const sectionVariants = cva(
  "w-full",
  {
    variants: {
      variant: {
        default: "bg-background",
        accent: "bg-accent",
        muted: "bg-muted",
      },
      padding: {
        default: "py-12 md:py-16",
        lg: "py-16 md:py-20 lg:py-24",
        xl: "py-20 md:py-24 lg:py-32",
        none: "",
      },
    },
    defaultVariants: {
      variant: "default",
      padding: "default",
    },
  }
);

export interface SectionProps
  extends React.HTMLAttributes<HTMLElement>,
    VariantProps<typeof sectionVariants> {
  children: React.ReactNode;
  /** Show a separator line at the top of the section */
  showSeparator?: boolean;
  /** Custom container max-width class */
  containerClassName?: string;
}

export function Section({
  children,
  variant,
  padding,
  showSeparator = false,
  containerClassName,
  className,
  ...props
}: SectionProps) {
  return (
    <section
      className={cn(sectionVariants({ variant, padding }), className)}
      {...props}
    >
      {showSeparator && <Separator className="mb-0" />}
      <div
        className={cn(
          "container mx-auto max-w-7xl px-4",
          containerClassName
        )}
      >
        {children}
      </div>
    </section>
  );
}

