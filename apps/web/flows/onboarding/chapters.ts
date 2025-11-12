"use client";

export type QuestionType =
  | "intro"
  | "text"
  | "email"
  | "date"
  | "phone"
  | "password"
  | "address"
  | "choice"
  | "toggle"
  | "checkbox"
  | "upload"
  | "chat"
  | "therapist-match"
  | "review"
  | "summary"
  | "account-check";

type MapSection =
  | "parent"
  | "student"
  | "consent"
  | "intake"
  | "screeners"
  | "insurance"
  | "scheduling";

export interface QuestionOption {
  id: string;
  label: string;
  description?: string;
  value?: string;
}

export interface QuestionConfig {
  id: string;
  type: QuestionType;
  prompt: string;
  helperText?: string;
  eyebrow?: string;
  ctaLabel?: string;
  secondaryLabel?: string;
  optional?: boolean;
  options?: QuestionOption[];
  nextQuestionId?: string;
  mapTo?: {
    section: MapSection;
    field: string;
  };
}

export interface ChapterConfig {
  id: string;
  label: string;
  personaTitle?: string;
  questions: QuestionConfig[];
}

export interface OnboardingFormData {
  parent: Record<string, any>;
  student: Record<string, any>;
  consent: Record<string, any>;
  intake: Record<string, any>;
  insurance: Record<string, any>;
  scheduling: Record<string, any>;
}

export const CHAPTERS: ChapterConfig[] = [
  {
    id: "you",
    label: "You",
    personaTitle: "I’ll guide you through each step.",
    questions: [
      {
        id: "account-check",
        type: "account-check",
        prompt: "Do you already have a Daybreak account?",
        helperText: "If you do, we’ll sign you in first so we can pick up right where you left off.",
        ctaLabel: "Continue",
      },
      {
        id: "welcome-intro",
        type: "intro",
        prompt: "I’ll get you an awesome bundle price in minutes. Ready to go?",
        ctaLabel: "Let’s start",
      },
      {
        id: "parent-first-name",
        type: "text",
        prompt: "What’s your first name?",
        helperText: "We’ll use this to personalize your experience.",
        ctaLabel: "Continue",
        mapTo: { section: "parent", field: "firstName" },
      },
      {
        id: "parent-last-name",
        type: "text",
        prompt: "And your last name?",
        ctaLabel: "Continue",
        mapTo: { section: "parent", field: "lastName" },
      },
      {
        id: "parent-email",
        type: "email",
        prompt: "Great to meet you! What’s the best email for updates?",
        helperText: "We use this to send important onboarding updates. No spam, promise.",
        ctaLabel: "Continue",
        mapTo: { section: "parent", field: "email" },
      },
      {
        id: "parent-password",
        type: "password",
        prompt: "Create a password you’ll remember.",
        helperText: "You’ll use this to sign back in and manage your child’s care.",
        ctaLabel: "Continue",
      },
      {
        id: "parent-dob",
        type: "date",
        prompt: "When were you born?",
        helperText: "This helps us personalize support and verify eligibility.",
        ctaLabel: "Continue",
        mapTo: { section: "parent", field: "dateOfBirth" },
      },
      {
        id: "parent-relationship",
        type: "choice",
        prompt: "How are you connected to your child?",
        helperText: "We’ll use this to tailor updates and resources.",
        ctaLabel: "Continue",
        options: [
          { id: "mother", label: "Mother" },
          { id: "father", label: "Father" },
          { id: "guardian", label: "Guardian / Caregiver" },
        ],
        mapTo: { section: "parent", field: "relationship" },
      },
      {
        id: "parent-phone",
        type: "phone",
        prompt: "What number should we text if we need to reach you?",
        helperText: "We’ll only text important updates about your child’s care.",
        optional: true,
        ctaLabel: "Continue",
        secondaryLabel: "Skip for now",
        mapTo: { section: "parent", field: "phone" },
      },
      {
        id: "parent-address",
        type: "address",
        prompt: "Where do you call home?",
        helperText: "We’ll match support in your area.",
        ctaLabel: "Looks good",
        mapTo: { section: "parent", field: "address" },
      },
      {
        id: "parent-consent",
        type: "checkbox",
        prompt: "Mind giving us the okay to get started?",
        helperText: "By continuing you agree to our terms of service and privacy policy.",
        ctaLabel: "I agree",
        mapTo: { section: "consent", field: "termsAccepted" },
      },
    ],
  },
  {
    id: "student",
    label: "Student",
    personaTitle: "Let’s make sure we understand your child.",
    questions: [
      {
        id: "student-intro",
        type: "intro",
        prompt: "Let’s get to know your child.",
        ctaLabel: "Sounds good",
      },
      {
        id: "student-first-name",
        type: "text",
        prompt: "What’s your child’s first name?",
        ctaLabel: "Continue",
        mapTo: { section: "student", field: "firstName" },
      },
      {
        id: "student-last-name",
        type: "text",
        prompt: "And their last name?",
        ctaLabel: "Continue",
        mapTo: { section: "student", field: "lastName" },
      },
      {
        id: "student-pronouns",
        type: "choice",
        prompt: "How do they like to be referred to?",
        optional: true,
        ctaLabel: "Continue",
        options: [
          { id: "he", label: "He / Him" },
          { id: "she", label: "She / Her" },
          { id: "they", label: "They / Them" },
          { id: "neutral", label: "Prefer not to say" },
        ],
        mapTo: { section: "student", field: "pronouns" },
      },
      {
        id: "student-dob",
        type: "date",
        prompt: "When is their birthday?",
        ctaLabel: "Continue",
        mapTo: { section: "student", field: "dateOfBirth" },
      },
      {
        id: "student-grade",
        type: "choice",
        prompt: "Which grade are they in?",
        ctaLabel: "Continue",
        options: [
          { id: "K", label: "Kindergarten" },
          { id: "1", label: "Grade 1" },
          { id: "2", label: "Grade 2" },
          { id: "3", label: "Grade 3" },
          { id: "4", label: "Grade 4" },
          { id: "5", label: "Grade 5" },
          { id: "6", label: "Grade 6" },
          { id: "7", label: "Grade 7" },
          { id: "8", label: "Grade 8" },
          { id: "9", label: "Grade 9" },
          { id: "10", label: "Grade 10" },
          { id: "11", label: "Grade 11" },
          { id: "12", label: "Grade 12" },
        ],
        mapTo: { section: "student", field: "grade" },
      },
      {
        id: "student-school",
        type: "text",
        prompt: "Where do they go to school?",
        helperText: "Optional, but it helps us coordinate with school teams.",
        optional: true,
        ctaLabel: "Continue",
        mapTo: { section: "student", field: "school" },
      },
      {
        id: "student-language",
        type: "choice",
        prompt: "What language do they feel most comfortable using?",
        ctaLabel: "Continue",
        options: [
          { id: "english", label: "English" },
          { id: "spanish", label: "Spanish" },
          { id: "mandarin", label: "Mandarin" },
          { id: "korean", label: "Korean" },
          { id: "other", label: "Something else" },
        ],
        mapTo: { section: "student", field: "language" },
      },
      {
        id: "goals",
        type: "choice",
        prompt: "What’s the biggest support you’re hoping for?",
        ctaLabel: "Continue",
        options: [
          { id: "anxiety", label: "Managing anxiety" },
          { id: "mood", label: "Mood support" },
          { id: "academics", label: "School performance" },
          { id: "social", label: "Friendships & social skills" },
          { id: "other", label: "Something else" },
        ],
        mapTo: { section: "student", field: "primaryGoal" },
      },
    ],
  },
  {
    id: "intake",
    label: "Intake",
    personaTitle: "Thanks for opening up – I’m right here with you.",
    questions: [
      {
        id: "intake-intro",
        type: "intro",
        prompt: "We’ll start with a quick check-in conversation.",
        helperText: "It’s supportive and private, and only takes a few minutes.",
        ctaLabel: "Sounds good",
      },
      {
        id: "intake-reassurance",
        type: "intro",
        prompt: "Everything you share stays between us.",
        helperText: "Sharing how things feel helps us match the right support.",
        ctaLabel: "Continue",
      },
      {
        id: "intake-chat",
        type: "chat",
        prompt: "Ready to start the check-in?",
        helperText: "You’ll chat with our AI coach, and you can pause anytime.",
        ctaLabel: "Let’s begin",
        mapTo: { section: "intake", field: "conversationSummary" },
      },
    ],
  },
  {
    id: "screeners",
    label: "Check-In",
    personaTitle: "Let’s do a quick wellbeing check.",
    questions: [
      {
        id: "screener-intro",
        type: "intro",
        prompt: "A few quick questions help us understand how things feel lately.",
        helperText: "This won’t affect eligibility—it just guides our support.",
        ctaLabel: "Begin",
      },
      {
        id: "screener-energy",
        type: "choice",
        prompt: "How has your child’s energy been this past week?",
        options: [
          { id: "high", label: "High energy most days" },
          { id: "steady", label: "Steady, about the same" },
          { id: "low", label: "Lower than usual" },
          { id: "very-low", label: "Very low or tired" },
        ],
        ctaLabel: "Continue",
        mapTo: { section: "screeners", field: "energy" },
      },
      {
        id: "screener-focus",
        type: "choice",
        prompt: "How easy is it for them to focus on schoolwork or activities?",
        options: [
          { id: "great", label: "They focus really well" },
          { id: "manageable", label: "Mostly manageable" },
          { id: "tough", label: "Pretty tough lately" },
          { id: "unsure", label: "I’m not sure" },
        ],
        ctaLabel: "Continue",
        mapTo: { section: "screeners", field: "focus" },
      },
      {
        id: "screener-wrap",
        type: "intro",
        prompt: "Thanks for sharing. Ready for the next part?",
        ctaLabel: "Continue",
      },
    ],
  },
  {
    id: "insurance",
    label: "Insurance",
    personaTitle: "Let’s see how we can use your coverage.",
    questions: [
      {
        id: "insurance-intro",
        type: "intro",
        prompt: "Grab your insurance card so we can verify coverage.",
        helperText: "It only takes a minute—and ensures accurate cost estimates.",
        ctaLabel: "Got it",
      },
      {
        id: "insurance-upload-front",
        type: "upload",
        prompt: "Snap a photo of the front of the card.",
        helperText: "Make sure the text is easy to read.",
        ctaLabel: "Uploaded",
        mapTo: { section: "insurance", field: "frontImage" },
      },
      {
        id: "insurance-upload-back",
        type: "upload",
        prompt: "Great! Now the back of the card.",
        helperText: "This helps us grab the right contact numbers.",
        ctaLabel: "Uploaded",
        optional: true,
        secondaryLabel: "Skip",
        mapTo: { section: "insurance", field: "backImage" },
      },
      {
        id: "insurance-provider",
        type: "text",
        prompt: "Which insurance carrier is on the card?",
        helperText: "We’ll use this to route claims correctly.",
        ctaLabel: "Continue",
        mapTo: { section: "insurance", field: "provider" },
      },
      {
        id: "insurance-policy-holder",
        type: "text",
        prompt: "Who is the policy holder on the card?",
        helperText: "Include full name as it appears on the card.",
        ctaLabel: "Continue",
        optional: true,
        secondaryLabel: "Skip",
        mapTo: { section: "insurance", field: "policyHolder" },
      },
      {
        id: "insurance-member-id",
        type: "text",
        prompt: "What’s the member ID?",
        helperText: "We need this for verification.",
        ctaLabel: "Continue",
        mapTo: { section: "insurance", field: "memberId" },
      },
      {
        id: "insurance-cost-preview",
        type: "intro",
        prompt: "Most families with your coverage pay between $20–$50 per session.",
        helperText: "We’ll verify details and confirm before appointments begin.",
        ctaLabel: "Continue",
      },
    ],
  },
  {
    id: "scheduling",
    label: "Scheduling",
    personaTitle: "Let’s find a time that fits your family.",
    questions: [
      {
        id: "schedule-intro",
        type: "intro",
        prompt: "We’ll match you with a clinician and set up your first session.",
        helperText: "Answer a few quick questions so we can hold a spot.",
        ctaLabel: "Continue",
      },
      {
        id: "schedule-contact-name",
        type: "text",
        prompt: "Who should we send scheduling updates to?",
        helperText: "Add their full name.",
        ctaLabel: "Continue",
        mapTo: { section: "scheduling", field: "contactName" },
      },
      {
        id: "schedule-contact-email",
        type: "email",
        prompt: "What’s the best email for scheduling updates?",
        ctaLabel: "Continue",
        mapTo: { section: "scheduling", field: "contactEmail" },
      },
      {
        id: "schedule-date",
        type: "date",
        prompt: "Pick a day that usually works for your family.",
        helperText: "We’ll aim for this day each week.",
        ctaLabel: "Continue",
        mapTo: { section: "scheduling", field: "preferredDate" },
      },
      {
        id: "schedule-time-window",
        type: "choice",
        prompt: "What time of day is usually best?",
        options: [
          { id: "morning", label: "Morning (8am – 12pm)" },
          { id: "afternoon", label: "Afternoon (12pm – 4pm)" },
          { id: "evening", label: "Evening (4pm – 7pm)" },
          { id: "weekend", label: "Weekends" },
        ],
        ctaLabel: "Continue",
        mapTo: { section: "scheduling", field: "preferredTime" },
      },
      {
        id: "schedule-therapist-preference",
        type: "choice",
        prompt: "Any therapist preferences?",
        helperText: "We’ll do our best to honor this.",
        options: [
          { id: "no-preference", label: "No preference" },
          { id: "female", label: "Prefer a female therapist" },
          { id: "male", label: "Prefer a male therapist" },
          { id: "language", label: "Needs a specific language" },
        ],
        optional: true,
        ctaLabel: "Continue",
        secondaryLabel: "Skip",
        mapTo: { section: "scheduling", field: "therapistPreference" },
      },
      {
        id: "schedule-therapist-match",
        type: "therapist-match",
        prompt: "Here are therapists who fit best right now.",
        helperText: "Pick who you’d like to meet first. You can always change later.",
        ctaLabel: "Continue",
        mapTo: { section: "scheduling", field: "therapistSelection" },
      },
      {
        id: "schedule-confirm",
        type: "summary",
        prompt: "You’re all set!",
        helperText: "We’ve held your spot and sent the confirmation details. Here’s what to expect next.",
        ctaLabel: "Continue",
      },
    ],
  },
  {
    id: "finish",
    label: "Finish",
    personaTitle: "We’re so glad you reached out.",
    questions: [
      {
        id: "finish-overview",
        type: "intro",
        prompt: "You’re all set! We’re lining up the right support.",
        helperText:
          "Expect a welcome message, therapist matches, and a full summary in your inbox soon.",
        ctaLabel: "Finish",
      },
    ],
  },
];


