import {
  TrendingUp,
  Users,
  Heart,
  Clock,
  Video,
  PhoneCall,
  UsersRound,
  MessageCircle,
  HeartHandshake,
} from "lucide-react";
import { Header } from "@/components/layout/Header";
import { Hero } from "@/components/layout/Hero";
import { Section } from "@/components/layout/Section";
import {
  StatsGrid,
  StatCard,
  TrustSection,
  ProgramCard,
  TestimonialCard,
} from "@/components/content";

// Mock partner logos - replace with real logos
const partners = [
  { name: "Partner 1", logoUrl: "/placeholder-logo.svg", alt: "Partner Logo 1" },
  { name: "Partner 2", logoUrl: "/placeholder-logo.svg", alt: "Partner Logo 2" },
  { name: "Partner 3", logoUrl: "/placeholder-logo.svg", alt: "Partner Logo 3" },
  { name: "Partner 4", logoUrl: "/placeholder-logo.svg", alt: "Partner Logo 4" },
  { name: "Partner 5", logoUrl: "/placeholder-logo.svg", alt: "Partner Logo 5" },
  { name: "Partner 6", logoUrl: "/placeholder-logo.svg", alt: "Partner Logo 6" },
];

export default function Home() {
  return (
    <>
      <Header />
      <main id="main-content" className="min-h-screen">
        <Hero
          title="Mental health support for every student"
          subtitle="Daybreak Health provides accessible, evidence-based mental health care for students ages 5-19. Connect with licensed therapists through secure teletherapy, available when your family needs it most."
          primaryCta={{
            text: "Schools - Book a Demo",
            href: "/schools",
          }}
          secondaryCta={{
            text: "Families - Sign Up",
            href: "/onboarding",
          }}
        />

        {/* Statistics Section */}
        <Section variant="accent" padding="xl" showSeparator>
          <div className="text-center mb-12">
            <h2 className="text-h2-mobile font-bold text-foreground md:text-h2">
              Making a Difference in Student Mental Health
            </h2>
            <p className="mt-4 text-body-large text-muted-foreground max-w-2xl mx-auto">
              Trusted by schools nationwide to provide quality mental health care
            </p>
          </div>
          <StatsGrid columns={4}>
            <StatCard
              icon={TrendingUp}
              value="80%"
              label="School staff report improvements in student wellbeing"
            />
            <StatCard
              icon={Users}
              value="50K+"
              label="Students supported across the United States"
            />
            <StatCard
              icon={Heart}
              value="95%"
              label="Parent satisfaction with care quality"
            />
            <StatCard
              icon={Clock}
              value="24/7"
              label="Crisis support available anytime"
            />
          </StatsGrid>
        </Section>

        {/* Trust Indicators Section */}
        <Section padding="xl" showSeparator>
          <TrustSection
            heading="Trusted by leading school districts and accepted by major insurances"
            partners={partners}
          />
        </Section>

        {/* Programs/Services Section */}
        <Section variant="accent" padding="xl" showSeparator>
          <div className="text-center mb-12">
            <h2 className="text-h2-mobile font-bold text-foreground md:text-h2">
              Our Programs
            </h2>
            <p className="mt-4 text-body-large text-muted-foreground max-w-2xl mx-auto">
              Comprehensive mental health support tailored to your family's needs
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <ProgramCard
              icon={Video}
              title="Teletherapy for ages 5-19"
              description="Connect with licensed therapists through secure video sessions. Available during and after school hours."
              ctaHref="/programs/teletherapy"
            />
            <ProgramCard
              icon={PhoneCall}
              title="Crisis Support 24/7"
              description="Immediate support when you need it most. Our crisis team is available around the clock."
              ctaHref="/programs/crisis"
            />
            <ProgramCard
              icon={UsersRound}
              title="Family Therapy Sessions"
              description="Strengthen family bonds and improve communication with guided family therapy."
              ctaHref="/programs/family-therapy"
            />
            <ProgramCard
              icon={MessageCircle}
              title="Group Sessions"
              description="Peer support groups for students dealing with similar challenges in a safe environment."
              ctaHref="/programs/groups"
            />
            <ProgramCard
              icon={HeartHandshake}
              title="Parent Support"
              description="Resources and guidance for parents navigating their child's mental health journey."
              ctaHref="/programs/parent-support"
            />
            <ProgramCard
              icon={Heart}
              title="Wellness Programs"
              description="Proactive mental health education and wellness activities for students."
              ctaHref="/programs/wellness"
            />
          </div>
        </Section>

        {/* Testimonials Section */}
        <Section padding="xl" showSeparator>
          <div className="text-center mb-12">
            <h2 className="text-h2-mobile font-bold text-foreground md:text-h2">
              Families Love Daybreak
            </h2>
            <p className="mt-4 text-body-large text-muted-foreground max-w-2xl mx-auto">
              Real stories from families who have found support through Daybreak Health
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <TestimonialCard
              quote="Daybreak saved my son's life. The therapists are compassionate, professional, and truly care about their students."
              name="Sarah M."
              role="Parent"
            />
            <TestimonialCard
              quote="Finally, mental health support that fits our busy schedule. The teletherapy option has been a game-changer for our family."
              name="Michael Chen"
              role="Parent"
            />
            <TestimonialCard
              quote="As a school counselor, I've seen incredible progress in students who work with Daybreak. Their approach is evidence-based and effective."
              name="Dr. Jennifer Lopez"
              role="School Counselor"
            />
          </div>
        </Section>
      </main>
    </>
  );
}

