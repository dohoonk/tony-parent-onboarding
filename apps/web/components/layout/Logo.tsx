import Link from "next/link";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const logoVariants = cva(
  "inline-flex items-center font-bold text-primary transition-opacity hover:opacity-80",
  {
    variants: {
      size: {
        sm: "text-xl gap-2",
        md: "text-2xl gap-2.5",
        lg: "text-3xl gap-3",
      },
    },
    defaultVariants: {
      size: "md",
    },
  }
);

export interface LogoProps
  extends React.AnchorHTMLAttributes<HTMLAnchorElement>,
    VariantProps<typeof logoVariants> {
  href?: string;
}

export function Logo({ size, className, href = "/", ...props }: LogoProps) {
  return (
    <Link
      href={href}
      className={cn(logoVariants({ size }), className)}
      aria-label="Daybreak Health - Home"
      {...props}
    >
      {/* Icon/Logo Mark - Using a sunrise/daybreak symbol */}
      <svg
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className={cn(
          size === "sm" && "h-6 w-6",
          size === "md" && "h-8 w-8",
          size === "lg" && "h-10 w-10"
        )}
        aria-hidden="true"
      >
        {/* Sunrise/Daybreak Icon */}
        <circle
          cx="12"
          cy="12"
          r="4"
          fill="currentColor"
          className="text-primary"
        />
        <path
          d="M12 2v3M12 19v3M22 12h-3M5 12H2M19.07 4.93l-2.12 2.12M7.05 16.95l-2.12 2.12M19.07 19.07l-2.12-2.12M7.05 7.05L4.93 4.93"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          className="text-primary"
        />
      </svg>

      {/* Wordmark */}
      <span className="tracking-tight">
        Daybreak <span className="font-normal text-foreground">Health</span>
      </span>
    </Link>
  );
}

