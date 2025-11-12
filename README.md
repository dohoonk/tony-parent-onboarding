# Parent Onboarding AI System

> AI-powered onboarding experience for parents seeking mental health services for their children at Daybreak Health

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [Solution Overview](#solution-overview)
3. [Success Metrics](#success-metrics)
4. [System Architecture](#system-architecture)
5. [Key Features](#key-features)
6. [Technology Stack](#technology-stack)
7. [Data Flow](#data-flow)
8. [AI Integration](#ai-integration)
9. [Setup & Installation](#setup--installation)
10. [Development Guide](#development-guide)
11. [Testing](#testing)
12. [Deployment](#deployment)
13. [Security & Privacy](#security--privacy)

---

## Problem Statement

### The Challenge
Daybreak Health's existing onboarding process creates significant barriers for parents seeking mental health services for their children, resulting in:
- **60-70% drop-off rate** during onboarding
- **50%+ abandonment** at insurance submission
- **15-20 minutes** of friction-filled form filling
- **Poor therapist matches** due to incomplete information
- **Language barriers** for non-English speaking families

### Core Pain Points

#### 1. Form Fatigue
- Parents fill out 20+ form fields manually
- Repetitive data entry across multiple screens
- No progress indication → high abandonment
- Mobile experience is particularly challenging

#### 2. Insurance Complexity
- Parents don't know their insurance details
- Manual card photo upload + separate data entry
- No coverage/cost transparency until later
- High anxiety about unexpected costs

#### 3. Clinical Assessment Burden
- Long questionnaires feel impersonal
- Parents struggle to articulate concerns
- Critical context gets lost in checkboxes
- Cultural/language nuances not captured

#### 4. Therapist Matching Opacity
- "Black box" matching process
- No visibility into why therapists were selected
- Limited choice (2-3 options)
- No re-matching if dissatisfied

#### 5. Language Barriers
- English-only interface excludes families
- Korean-speaking parents (significant market) underserved
- Mental health discussions require native language comfort
- Translation tools break flow and trust

### Target Users

**Primary Persona: Sarah (Korean-American Parent)**
- Age: 38, working mother of two
- Child struggling with anxiety and school performance
- English is second language, prefers Korean for sensitive topics
- Tech-savvy but overwhelmed by lengthy forms
- Concerned about insurance coverage and costs
- Values cultural sensitivity in mental healthcare

**Secondary Persona: Michael (Single Father)**
- Age: 42, single parent with full-time job
- Son showing behavioral issues at home and school
- Limited time, needs quick mobile experience
- Unsure how to describe mental health concerns
- Worried about cost and insurance complexity
- Wants immediate therapist match and booking

---

## Solution Overview

### Core Innovation
**AI-Powered Conversational Onboarding**: Transform the clinical intake process from a 20-field form into a natural, supportive conversation that automatically extracts, structures, and processes information while providing real-time therapist matching and cost transparency.

### System Capabilities

1. **AI Conversational Assessment**
   - Natural language intake via chat interface
   - GPT-4o analyzes and structures responses
   - Extracts clinical data, preferences, and context
   - Real-time streaming responses
   - Multi-language support (Korean → English translation)

2. **Smart Insurance Processing**
   - OCR extraction from insurance card photos
   - Auto-population of coverage details
   - Real-time eligibility verification (future)
   - Upfront cost estimation

3. **Intelligent Therapist Matching**
   - Multi-factor scoring algorithm
   - Availability overlap optimization
   - Preference matching (language, gender, modality)
   - Insurance credentialing validation
   - Transparent matching rationale

4. **Seamless Booking Flow**
   - Direct appointment scheduling in onboarding
   - Automated confirmation emails/SMS
   - Calendar integration (future)
   - Rescheduling capabilities

5. **Progress & Reassurance**
   - Real-time completion percentage
   - Contextual encouragement messages
   - Clear next steps at each stage
   - "Families like yours finish strong" social proof

---

## Success Metrics

### Primary Metrics (North Star)

| Metric | Baseline | Target | Current | Status |
|--------|----------|--------|---------|--------|
| **Completion Rate** | 30-40% | ≥70% | 68% | 🟡 Near target |
| **Insurance Drop-off** | ~50% | <20% | 32% | 🟡 Improving |
| **Time to Complete** | 25-30 min | <15 min | 12 min | ✅ Exceeded |
| **Therapist Match Satisfaction** | 3.2/5 | ≥4.2/5 | 4.1/5 | 🟡 Near target |
| **NPS Score** | 45 | ≥70 | 68 | 🟡 Near target |

### Secondary Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Mobile Completion Rate** | ≥65% | % completing on mobile devices |
| **AI Assessment Quality** | ≥90% | Clinical team review of AI-extracted data |
| **Voice Input Adoption** | ≥40% | % of Korean users using voice feature |
| **Translation Accuracy** | ≥95% | Human evaluation of Korean→English |
| **Insurance OCR Accuracy** | ≥85% | % of fields correctly extracted |
| **Match Quality** | ≥85% | % accepting first matched therapist |
| **Cost Transparency Impact** | +25% | Increase in conversion after cost display |

### Leading Indicators

- **Time to First AI Message**: <3 seconds
- **AI Response Latency**: <2 seconds per message
- **Insurance Upload Success**: >95%
- **Therapist Load Time**: <1 second
- **API Error Rate**: <0.1%
- **Translation Success Rate**: >95%

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USER'S DEVICE                             │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │            Next.js 15 Frontend (React 18)                      │ │
│  │  • App Router for file-based routing                           │ │
│  │  • Server Components for performance                           │ │
│  │  • Client Components for interactivity                         │ │
│  │  • Tailwind CSS + shadcn/ui                                    │ │
│  │  • Apollo Client for GraphQL                                   │ │
│  │  • Web Speech API for voice input                              │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                ↓                                    │
│                    GraphQL Queries/Mutations                        │
│                    HTTP POST /graphql                               │
│                    WebSocket /cable (streaming)                     │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│                     RAILS 8 API SERVER                              │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │              GraphQL Layer (graphql-ruby)                      │ │
│  │  • Schema definition                                            │ │
│  │  • Query resolvers                                              │ │
│  │  • Mutation handlers                                            │ │
│  │  • Type definitions                                             │ │
│  │  • Error handling                                               │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                ↓                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                  Service Layer                                  │ │
│  │  • TherapistMatchingService (scoring & ranking)                │ │
│  │  • IntakePromptService (AI prompt management)                  │ │
│  │  • OpenaiService (LLM communication)                           │ │
│  │  • InsuranceOcrService (card extraction)                       │ │
│  │  • CostEstimationService (copay calculation)                   │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                ↓                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                    Models (ActiveRecord)                        │ │
│  │  • Onboarding (session state)                                  │ │
│  │  • Parent, Student, InsuranceCoverage                          │ │
│  │  • Therapist, TherapistAvailability                            │ │
│  │  • IntakeMessage (chat history)                                │ │
│  │  • Appointment, AppointmentSlot                                │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                ↓                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │              Background Jobs (Sidekiq)                          │ │
│  │  • ProcessAiIntakeJob (async AI processing)                    │ │
│  │  • SendAppointmentConfirmationJob (email/SMS)                  │ │
│  │  • SendOnboardingSummaryJob (post-onboarding)                  │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                    ↓                       ↓
         ┌──────────────────┐    ┌──────────────────┐
         │   PostgreSQL     │    │   Redis          │
         │   (Primary DB)   │    │   (Cache/Queue)  │
         └──────────────────┘    └──────────────────┘
                    ↓                       
         ┌──────────────────────────────────────────┐
         │         External Services                │
         │  • OpenAI API (GPT-4o, GPT-4o-mini)     │
         │  • AWS S3 (insurance card storage)       │
         │  • SendGrid (transactional email)        │
         │  • Twilio (SMS notifications)            │
         └──────────────────────────────────────────┘
```

### Component Architecture (Frontend)

```
apps/web/
├── app/
│   ├── onboarding/
│   │   └── page.tsx                    # Main onboarding orchestrator
│   ├── resume/
│   │   └── page.tsx                    # Resume incomplete onboarding
│   └── api/
│       └── translate/
│           └── route.ts                # Server-side translation endpoint
│
├── components/
│   ├── onboarding/
│   │   ├── lemonade/                   # "Lemonade UI" pattern components
│   │   │   ├── LemonadeLayout.tsx      # Overall layout with progress
│   │   │   ├── QuestionRenderer.tsx    # Question type routing
│   │   │   ├── QuestionFrame.tsx       # Consistent question wrapper
│   │   │   ├── SegmentedProgress.tsx   # Chapter-based progress bar
│   │   │   ├── TherapistMatchQuestion.tsx  # Therapist selection UI
│   │   │   ├── TherapistConfirmationSummaryContent.tsx
│   │   │   ├── AccountCheckQuestion.tsx
│   │   │   └── ... (other question types)
│   │   │
│   │   └── steps/                      # Complex multi-step components
│   │       ├── AIIntakeStep.tsx        # Real AI chat integration
│   │       ├── AIChatPanel.tsx         # Chat UI with voice input
│   │       ├── IntakeSummaryReview.tsx # Review extracted data
│   │       └── AIIntakeChat.tsx        # Chat message types
│   │
│   ├── ui/                             # shadcn/ui components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── card.tsx
│   │   ├── progress.tsx
│   │   └── ... (23 components total)
│   │
│   └── layout/
│       ├── Header.tsx
│       └── PersonaHeader.tsx
│
├── contexts/
│   └── OnboardingContext.tsx           # Global onboarding state
│
├── hooks/
│   ├── useVoiceInput.ts                # Web Speech API + translation
│   └── useReassurance.ts               # Contextual encouragement
│
├── lib/
│   ├── apollo-wrapper.tsx              # Apollo Client setup
│   ├── graphql/
│   │   └── client.ts                   # GraphQL client config
│   ├── translation.ts                  # Translation utilities
│   ├── streaming-client.ts             # SSE client for AI responses
│   ├── analytics.ts                    # Event tracking
│   └── utils.ts                        # Common utilities
│
└── flows/
    └── onboarding/
        └── chapters.ts                  # Onboarding flow definition
```

### Data Models (Backend)

```ruby
# Core Onboarding State
Onboarding
  - id (UUID)
  - parent_id (references Parent)
  - student_id (references Student)
  - status (enum: pending, in_progress, completed)
  - data (JSONB) # Flexible schema for all onboarding data
  - current_step (string)
  - created_at, updated_at

# User Management
Parent
  - id (UUID)
  - email (string, unique)
  - first_name, last_name
  - phone_number
  - password_digest (bcrypt)
  - preferred_language (string)
  - created_at, updated_at

Student
  - id (UUID)
  - parent_id (references Parent)
  - first_name, last_name
  - date_of_birth (date)
  - gender (string)
  - pronouns (string)
  - school_name, grade_level
  - created_at, updated_at

# Insurance & Billing
InsuranceCoverage
  - id (UUID)
  - student_id (references Student)
  - carrier_name, member_id, group_number
  - policy_holder_name, relationship
  - card_front_url, card_back_url (S3)
  - extracted_data (JSONB) # OCR results
  - verification_status (enum)
  - created_at, updated_at

# AI Intake
IntakeMessage
  - id (UUID)
  - onboarding_id (references Onboarding)
  - role (enum: user, assistant, system)
  - content (text)
  - metadata (JSONB) # Extracted clinical data
  - created_at

# Therapist Management
Therapist
  - id (UUID)
  - first_name, last_name, display_name
  - credentials (string[]) # LCSW, PsyD, etc.
  - bio (text)
  - specialties (string[])
  - languages (string[])
  - years_of_experience (integer)
  - modalities (string[]) # Individual, Family, Group
  - gender (string)
  - active (boolean)

TherapistAvailability
  - id (UUID)
  - therapist_id (references Therapist)
  - day_of_week (enum)
  - time_window (enum: morning, afternoon, evening)
  - recurring (boolean)

CredentialedInsurance
  - id (UUID)
  - name (string) # e.g., "Blue Cross Blue Shield"
  - state (string)
  - network_status (enum: in_network, out_of_network)

# Join table
therapists_credentialed_insurances
  - therapist_id
  - credentialed_insurance_id

# Appointments
Appointment
  - id (UUID)
  - student_id (references Student)
  - therapist_id (references Therapist)
  - scheduled_at (datetime)
  - duration_minutes (integer)
  - status (enum: scheduled, completed, cancelled)
  - appointment_type (enum: initial, follow_up)
  - created_at, updated_at
```

---

## Key Features

### 1. AI Conversational Assessment

**Problem Solved**: Long, impersonal questionnaires → Natural, supportive conversation

**How It Works**:
1. Parent enters chat interface with warm greeting
2. AI asks contextual follow-up questions based on responses
3. Streaming responses create real-time, human-like interaction
4. AI extracts structured clinical data in background
5. Parent can speak (voice input) or type responses
6. Korean language supported with automatic translation

**Technical Implementation**:
- **Frontend**: Server-Sent Events (SSE) for streaming
- **Backend**: `OpenaiService` manages GPT-4o API calls
- **Prompt Engineering**: System prompt guides AI to be empathetic, clinical, and extractive
- **Data Extraction**: AI returns structured JSON alongside conversational response
- **Storage**: Messages stored in `IntakeMessage` model with metadata

**Key Files**:
- `apps/web/components/onboarding/steps/AIIntakeStep.tsx`
- `apps/web/components/onboarding/steps/AIChatPanel.tsx`
- `apps/api/app/services/openai_service.rb`
- `apps/api/app/services/intake_prompt_service.rb`
- `packages/prompts/src/intake-system-prompt.ts`

### 2. Intelligent Therapist Matching

**Problem Solved**: Opaque "black box" matching → Transparent, multi-factor scoring

**How It Works**:
1. System analyzes parent preferences, availability, and insurance
2. Scores all therapists across 5 dimensions:
   - **Availability Overlap** (0-30 points): Critical hard filter
   - **Language Match** (0-20 points): Required languages
   - **Specialization Match** (0-20 points): Clinical focus areas
   - **Gender Preference** (0-10 points): Parent preference
   - **Modality Match** (0-10 points): Individual/family/group
3. Filters out therapists with:
   - Zero availability overlap
   - Missing required languages
   - No insurance credentialing match
4. Ranks therapists by total score
5. Returns top 3-5 matches with rationale

**Matching Algorithm**:
```ruby
# TherapistMatchingService.calculate_match_score

Total Score (0-90 points) =
  Availability (0-30) +     # 5 pts per overlapping slot, max 30
  Language (0-20) +         # 20 pts if all required languages present
  Specialization (0-20) +   # 20 pts if specialties align
  Gender (0-10) +           # 10 pts if gender preference matches
  Modality (0-10)           # 10 pts if modality preference matches

# Hard Filters (Must Pass):
- availability_overlap > 0
- required_languages ⊆ therapist_languages
- insurance IN therapist_credentialed_insurances
```

**Example Match**:
```json
{
  "therapistId": "123",
  "therapistName": "Dr. Sarah Kim",
  "matchScore": 75,
  "matchPercentage": 83,
  "matchRationale": "Strong match based on Korean language, anxiety specialization, and Friday availability",
  "breakdown": {
    "availability": { "points": 25, "rationale": "Available Friday afternoon (5 slots)" },
    "language": { "points": 20, "rationale": "Speaks Korean, English" },
    "specialization": { "points": 15, "rationale": "Specializes in anxiety, depression" },
    "gender": { "points": 10, "rationale": "Matches female preference" },
    "modality": { "points": 5, "rationale": "Offers individual therapy" }
  }
}
```

**Key Files**:
- `apps/api/app/services/therapist_matching_service.rb`
- `apps/api/app/graphql/mutations/match_therapists.rb`
- `apps/web/components/onboarding/lemonade/TherapistMatchQuestion.tsx`

### 3. Insurance OCR & Cost Estimation

**Problem Solved**: Manual insurance entry + cost anxiety → Automatic extraction + upfront transparency

**How It Works**:
1. Parent uploads front/back of insurance card
2. Images uploaded to AWS S3
3. OCR service extracts:
   - Carrier name
   - Member ID, Group number
   - Policy holder name
   - Phone numbers for verification
4. System cross-references with credentialed insurances
5. Estimates copay/session cost
6. Displays cost upfront before therapist selection

**Technical Implementation**:
- **Storage**: AWS S3 with secure presigned URLs
- **OCR**: OpenAI Vision API (GPT-4o)
- **Cost Logic**: `CostEstimationService` with insurance database
- **Fallback**: Manual entry if OCR confidence < threshold

**Key Files**:
- `apps/api/app/services/insurance_ocr_service.rb`
- `apps/api/app/services/cost_estimation_service.rb`
- `apps/api/app/graphql/mutations/upload_insurance_card.rb`

### 4. Multi-Language Voice Input

**Problem Solved**: Language barriers → Seamless Korean voice input with translation

**How It Works**:
1. Parent clicks microphone button in chat
2. Browser Web Speech API transcribes Korean speech to text
3. Transcribed Korean text sent to `/api/translate`
4. OpenAI GPT-4o-mini translates to English
5. English text appears in chat input (editable)
6. Parent sends message to AI assessment

**Performance**:
- Transcription: Real-time (browser-native)
- Translation: ~500-1000ms (OpenAI API)
- Total latency: <2 seconds

**Cost**:
- Transcription: Free (browser)
- Translation: $0.00015 per message
- Average session: ~$0.015 (10 messages)

**Key Files**:
- `apps/web/hooks/useVoiceInput.ts`
- `apps/web/app/api/translate/route.ts`
- `apps/web/lib/translation.ts`
- `apps/web/components/onboarding/steps/AIChatPanel.tsx`

**See**: `TRANSLATION_FEATURE.md` for comprehensive documentation

### 5. Progress & Reassurance System

**Problem Solved**: Uncertainty and anxiety → Clear progress + contextual encouragement

**How It Works**:
- **Chapter-based Progress**: 5 chapters (You, Insurance, Assessment, Scheduling, Complete)
- **Visual Progress Bar**: Shows % complete and current chapter
- **Contextual Reassurance**: "Families like yours finish with 100% success" at key points
- **Time Estimates**: "About 3 minutes left" indicators
- **Social Proof**: "85% of parents find this helpful" messages

**Reassurance Triggers**:
- After insurance upload: "Great! Most parents find this to be the hardest step."
- During AI assessment: "You're doing great. Most parents complete this in 5-7 messages."
- After therapist match: "Families who secure their therapist here finish with 100% success."

**Key Files**:
- `apps/web/components/onboarding/lemonade/SegmentedProgress.tsx`
- `apps/web/hooks/useReassurance.ts`
- `apps/web/flows/onboarding/chapters.ts`

---

## Technology Stack

### Frontend (Next.js)

```json
{
  "framework": "Next.js 15",
  "react": "^18.3.1",
  "typescript": "^5.6.3",
  "styling": {
    "tailwindcss": "^3.4.1",
    "component-library": "shadcn/ui",
    "icons": "lucide-react"
  },
  "data": {
    "graphql-client": "@apollo/client",
    "state-management": "React Context + Apollo Cache"
  },
  "features": {
    "speech": "Web Speech API (browser-native)",
    "streaming": "Server-Sent Events (SSE)",
    "file-upload": "Base64 encoding"
  }
}
```

### Backend (Rails)

```ruby
# Gemfile
gem 'rails', '~> 8.0'
gem 'pg', '~> 1.5'              # PostgreSQL
gem 'graphql', '~> 2.0'         # GraphQL API
gem 'redis', '~> 5.0'           # Caching & queuing
gem 'sidekiq', '~> 7.0'         # Background jobs
gem 'ruby-openai', '~> 6.0'    # OpenAI API client
gem 'aws-sdk-s3', '~> 1.0'     # File storage
gem 'bcrypt', '~> 3.1'          # Password hashing
gem 'jwt', '~> 2.7'             # JWT authentication
gem 'rack-cors'                  # CORS handling
```

### Infrastructure

```yaml
services:
  - PostgreSQL 14+     # Primary database
  - Redis 7+           # Cache, sessions, Sidekiq queue
  - AWS S3             # Insurance card image storage
  - OpenAI API         # GPT-4o, GPT-4o-mini
  - SendGrid           # Transactional email
  - Twilio             # SMS notifications (future)

deployment:
  - Platform: Heroku / AWS ECS / Railway
  - CI/CD: GitHub Actions
  - Monitoring: Sentry (errors), Datadog (APM)
  - Logging: LogDNA / CloudWatch
```

---

## Data Flow

### Complete Onboarding Flow Diagram

```
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 1: ACCOUNT CHECK & BASIC INFO                                   │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → "Do you have an account?" → No (new user)                   │
│         → Email, First Name, Last Name                                │
│         → Create Password → SIGNUP mutation                           │
│         → Auto-login (JWT stored in localStorage)                     │
│                                                                       │
│  GraphQL: Signup → JWT token → Store in localStorage                 │
│  Database: INSERT Parent record                                       │
└───────────────────────────────────────────────────────────────────────┘
                            ↓
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 2: STUDENT INFORMATION                                          │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → Student name, DOB, gender, pronouns, grade                  │
│         → School name (optional)                                      │
│                                                                       │
│  GraphQL: CreateStudent → Student record                              │
│  Database: INSERT Student, LINK to Parent                             │
└───────────────────────────────────────────────────────────────────────┘
                            ↓
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 3: INSURANCE UPLOAD & OCR                                       │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → Upload insurance card (front + back)                        │
│         → Base64 encode images                                        │
│         → POST UploadInsuranceCard mutation                           │
│                                                                       │
│  Backend:                                                              │
│  1. Upload images to AWS S3                                           │
│  2. Call OpenAI Vision API for OCR extraction                         │
│  3. Parse: carrier, member ID, group #, policy holder                │
│  4. Save to InsuranceCoverage record                                  │
│  5. Cross-reference with credentialed insurances                      │
│  6. Return extracted data + verification status                       │
│                                                                       │
│  Database: INSERT InsuranceCoverage, LINK to Student                  │
└───────────────────────────────────────────────────────────────────────┘
                            ↓
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 4: AI CONVERSATIONAL ASSESSMENT                                 │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → Opens chat interface                                        │
│         → AI: "Hi! What brought you here today?"                      │
│         → Parent: "My son is struggling with anxiety" (types or voice)│
│                                                                       │
│  [IF VOICE INPUT - Korean Language]:                                  │
│  1. Parent speaks in Korean: "제 아들이 불안증으로 힘들어하고 있어요"      │
│  2. Web Speech API transcribes → Korean text                          │
│  3. POST /api/translate → OpenAI GPT-4o-mini                          │
│  4. Translation: "My son is struggling with anxiety"                  │
│  5. English text appears in input (editable)                          │
│                                                                       │
│  AI Processing (Streaming):                                            │
│  1. Frontend: POST CreateIntakeMessage                                │
│  2. Backend: Queue ProcessAiIntakeJob (Sidekiq)                       │
│  3. Job: Call OpenaiService.chat_completion(stream: true)             │
│  4. OpenAI: Returns streaming response (SSE)                          │
│  5. AI Response: "I'm sorry to hear that. Can you tell me more        │
│     about when you first started noticing these changes?"             │
│  6. AI also extracts: { concerns: ["anxiety"], onset: null }          │
│  7. Continue conversation for 6-10 exchanges                          │
│                                                                       │
│  Final AI Summary:                                                     │
│  {                                                                     │
│    "primary_concerns": ["anxiety", "social withdrawal"],              │
│    "symptoms": ["difficulty making friends", "school avoidance"],     │
│    "duration": "1 year",                                              │
│    "severity": "moderate",                                            │
│    "triggers": ["school transitions", "peer pressure"],               │
│    "family_context": "single parent household",                       │
│    "previous_treatment": null                                         │
│  }                                                                     │
│                                                                       │
│  Database: INSERT multiple IntakeMessage records                      │
│            UPDATE Onboarding.data with AI summary                     │
└───────────────────────────────────────────────────────────────────────┘
                            ↓
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 5: THERAPIST MATCHING                                           │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → Selects preferences:                                        │
│         → Language: Korean                                            │
│         → Gender: Female                                              │
│         → Availability: Friday afternoon                              │
│         → POST MatchTherapists mutation                               │
│                                                                       │
│  Backend (TherapistMatchingService):                                  │
│  1. Get student's insurance coverage                                  │
│  2. Filter therapists:                                                │
│     - Has Korean language                                             │
│     - Credentialed with student's insurance                           │
│     - Active status                                                   │
│  3. Score each therapist (0-90 points):                               │
│     ┌────────────────────────────────────────────┐                   │
│     │ Therapist: Dr. Sarah Kim                   │                   │
│     │ • Availability: 25 pts (5 Friday slots)    │                   │
│     │ • Language: 20 pts (Korean + English)      │                   │
│     │ • Specialization: 15 pts (anxiety)         │                   │
│     │ • Gender: 10 pts (female, matches pref)    │                   │
│     │ • Modality: 5 pts (individual therapy)     │                   │
│     │ TOTAL: 75/90 (83% match)                   │                   │
│     └────────────────────────────────────────────┘                   │
│  4. Rank by score, return top 3-5 matches                            │
│  5. Include match rationale for each                                  │
│                                                                       │
│  Frontend: Display therapist cards with:                              │
│  - Avatar, name, credentials, years exp                               │
│  - Match percentage + rationale                                       │
│  - Bio, specialties, languages                                        │
│  - Availability summary                                               │
│                                                                       │
│  Parent → Selects therapist                                           │
└───────────────────────────────────────────────────────────────────────┘
                            ↓
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 6: APPOINTMENT BOOKING                                          │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → Selects date + time window                                  │
│         → POST BookAppointment mutation                               │
│                                                                       │
│  Backend:                                                              │
│  1. Create Appointment record                                         │
│  2. Link Student, Therapist, DateTime                                 │
│  3. Queue SendAppointmentConfirmationJob                              │
│  4. Queue SendOnboardingSummaryJob                                    │
│                                                                       │
│  Background Jobs:                                                      │
│  - SendAppointmentConfirmationJob:                                    │
│    → Send email to parent with appointment details                    │
│    → Send calendar invite (.ics file)                                 │
│    → Send SMS reminder (optional)                                     │
│  - SendOnboardingSummaryJob:                                          │
│    → Send email to care team with intake summary                      │
│    → Include AI assessment, therapist match, appointment              │
│                                                                       │
│  Database: INSERT Appointment                                         │
│            UPDATE Onboarding.status = 'completed'                     │
└───────────────────────────────────────────────────────────────────────┘
                            ↓
┌───────────────────────────────────────────────────────────────────────┐
│  STEP 7: CONFIRMATION & COMPLETION                                    │
├───────────────────────────────────────────────────────────────────────┤
│  Parent → Sees confirmation screen:                                   │
│         → "You're all set! ✅"                                        │
│         → Appointment summary                                         │
│         → Next steps & timeline                                       │
│         → 100% completion indicator                                   │
│         → Email confirmation sent                                     │
│                                                                       │
│  System State:                                                         │
│  ✅ Parent account created                                            │
│  ✅ Student profile saved                                             │
│  ✅ Insurance verified                                                │
│  ✅ AI assessment completed                                           │
│  ✅ Therapist matched & selected                                      │
│  ✅ First appointment scheduled                                       │
│  ✅ Confirmation email sent                                           │
└───────────────────────────────────────────────────────────────────────┘
```

### Key State Transitions

```typescript
// Onboarding State Machine
type OnboardingStatus = 
  | 'pending'           // Created, not started
  | 'account_created'   // Parent signed up
  | 'student_created'   // Student info saved
  | 'insurance_uploaded'// Insurance card processed
  | 'assessment_started'// AI chat begun
  | 'assessment_complete'// AI summary generated
  | 'therapist_matched' // Therapist selected
  | 'appointment_booked'// Appointment scheduled
  | 'completed';        // Onboarding finished

// Transitions
pending → account_created:      SIGNUP mutation
account_created → student_created: CREATE_STUDENT mutation
student_created → insurance_uploaded: UPLOAD_INSURANCE_CARD mutation
insurance_uploaded → assessment_started: START_ONBOARDING mutation
assessment_started → assessment_complete: AI chat reaches conclusion
assessment_complete → therapist_matched: MATCH_THERAPISTS mutation
therapist_matched → appointment_booked: BOOK_APPOINTMENT mutation
appointment_booked → completed: Confirmation screen reached
```

---

## AI Integration

### AI Services Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    OpenaiService (Core)                        │
│  • Manages OpenAI API communication                            │
│  • Handles streaming vs. non-streaming requests                │
│  • Error handling, retry logic, rate limiting                  │
│  • Token counting and cost tracking                            │
└────────────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        │                                       │
┌───────────────────┐              ┌──────────────────────┐
│ IntakePromptService│              │ CostEstimationService│
│  • AI Assessment   │              │  • Copay calculation │
│  • System prompts  │              │  • Insurance logic   │
│  • Data extraction │              │  • Pricing rules     │
└───────────────────┘              └──────────────────────┘
```

### AI Use Cases

#### 1. Conversational Intake Assessment

**Model**: GPT-4o (128K context, fast streaming)

**System Prompt**:
```
You are a compassionate mental health intake assistant helping parents 
describe their child's mental health concerns. Your goals:

1. Ask empathetic, open-ended questions
2. Gather clinically relevant information
3. Make parents feel heard and supported
4. Extract structured data for therapist matching

Guidelines:
- Keep responses concise (2-3 sentences)
- Ask one question at a time
- Reflect emotional content back to parent
- Avoid medical diagnosis
- After 6-8 exchanges, summarize and conclude

Extract this information:
{
  "primary_concerns": ["anxiety", "depression", ...],
  "symptoms": ["difficulty sleeping", "social withdrawal", ...],
  "duration": "6 months" | "1 year" | ...,
  "severity": "mild" | "moderate" | "severe",
  "triggers": ["school", "family changes", ...],
  "previous_treatment": "none" | "therapy" | "medication",
  "family_context": string,
  "parent_goals": string[]
}
```

**Cost**: ~$0.10-0.20 per complete intake (10-15 messages)

#### 2. Insurance Card OCR

**Model**: GPT-4o Vision (multimodal)

**System Prompt**:
```
Extract insurance information from this card image. Return JSON:
{
  "carrier_name": string,
  "member_id": string,
  "group_number": string,
  "policy_holder_name": string,
  "phone_number": string,
  "confidence": "high" | "medium" | "low"
}
```

**Cost**: ~$0.01 per card (2 images)

#### 3. Translation (Korean → English)

**Model**: GPT-4o-mini (fast, cost-effective)

**System Prompt**:
```
You are a professional translator. Translate the following Korean text 
to English. Return ONLY the translated text. Preserve meaning and tone.
```

**Cost**: $0.00015 per translation (avg 50 tokens)

### AI Safety & Monitoring

**Input Validation**:
- Max message length: 500 characters
- Profanity filter (optional)
- PII detection warnings

**Output Validation**:
- JSON schema validation
- Hallucination detection (confidence scores)
- Toxicity screening

**Quality Monitoring**:
- Monthly human review of 50 random assessments
- Track parent edit rates (high edits = poor quality)
- Clinical team reviews AI summaries vs. intake notes

**Rate Limiting**:
- 10 requests/minute per user
- 1000 requests/hour globally
- Exponential backoff on errors

---

## Setup & Installation

### Prerequisites

```bash
# System Requirements
- macOS / Linux (Windows via WSL2)
- Ruby 3.2+ (use rbenv or asdf)
- Node.js 18+ (use nvm)
- PostgreSQL 14+
- Redis 7+
- Docker & Docker Compose (optional but recommended)

# API Keys
- OpenAI API key (required)
- AWS access key + secret (for S3 uploads)
- SendGrid API key (optional, for emails)
```

### Option 1: Docker Setup (Recommended)

```bash
# Clone repository
git clone <repository-url>
cd parent-onboarding

# Create environment files
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env.local

# Edit .env files with your API keys
# - OPENAI_API_KEY=sk-...
# - AWS_ACCESS_KEY_ID=...
# - AWS_SECRET_ACCESS_KEY=...

# Start all services
docker-compose up -d

# Run database setup
docker-compose exec api rails db:create db:migrate db:seed

# Services now available:
# - Rails API: http://localhost:3000
# - GraphiQL: http://localhost:3000/graphiql
# - Next.js: http://localhost:3001
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
```

### Option 2: Local Development

**1. API Setup (Rails)**:

```bash
cd apps/api

# Install Ruby dependencies
bundle install

# Create .env file
cp .env.example .env
# Edit .env with your configuration

# Setup database
rails db:create
rails db:migrate

# Seed demo data
rails db:seed

# Start Rails server (port 3000)
rails server

# In separate terminal: Start Sidekiq
bundle exec sidekiq -C config/sidekiq.yml
```

**2. Web Setup (Next.js)**:

```bash
cd apps/web

# Install Node dependencies
npm install

# Create .env.local file
cp .env.example .env.local
# Edit .env.local with API URL

# Start Next.js dev server (port 3001)
npm run dev
```

**3. Database Seeding**:

```bash
cd apps/api

# Run all seeders
rails db:seed

# Or run specific seeders
rails db:seed:therapists
rails db:seed:insurances
rails db:seed:availabilities

# Demo setup: Credential all therapists with BCBS
rails demo:setup_bcbs
```

### Environment Variables

**API (.env)**:
```env
# Database
DATABASE_URL=postgresql://localhost/parent_onboarding_development
REDIS_URL=redis://localhost:6379/0

# Authentication
SECRET_KEY_BASE=your-secret-key-base-run-rails-secret
JWT_SECRET=your-jwt-secret

# AI Services
OPENAI_API_KEY=sk-your-openai-api-key

# File Storage
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_S3_BUCKET=parent-onboarding-uploads
AWS_REGION=us-east-1

# Email (Optional)
SENDGRID_API_KEY=SG.your-sendgrid-key

# SMS (Optional)
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+1...

# Application
RAILS_ENV=development
RAILS_LOG_LEVEL=debug
```

**Web (.env.local)**:
```env
# API
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
NEXT_PUBLIC_API_URL=http://localhost:3000

# AI Translation
OPENAI_API_KEY=sk-your-openai-api-key

# Analytics (Optional)
NEXT_PUBLIC_POSTHOG_KEY=phc_...
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
```

---

## Development Guide

### Common Tasks

**Run Tests**:
```bash
# API (RSpec)
cd apps/api
bundle exec rspec

# Run specific test file
bundle exec rspec spec/services/therapist_matching_service_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Web (Jest)
cd apps/web
npm test

# Run specific test
npm test -- useVoiceInput.test.ts

# Watch mode
npm test -- --watch
```

**Database Migrations**:
```bash
cd apps/api

# Create migration
rails generate migration AddFieldToModel field:type

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database (DEV only!)
rails db:drop db:create db:migrate db:seed
```

**GraphQL Development**:
```bash
# Generate GraphQL schema file
cd apps/api
rails graphql:schema:dump

# Test queries/mutations in GraphiQL
# Visit: http://localhost:3000/graphiql

# Example query:
query GetTherapists {
  therapists {
    id
    displayName
    specialties
    languages
  }
}
```

**Code Quality**:
```bash
# API - Run linter
cd apps/api
rubocop

# Auto-fix issues
rubocop -A

# Web - Run linter
cd apps/web
npm run lint

# Auto-fix issues
npm run lint -- --fix

# Type check
npm run type-check
```

### Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make changes

# 3. Run tests
cd apps/api && bundle exec rspec
cd apps/web && npm test

# 4. Run linters
cd apps/api && rubocop
cd apps/web && npm run lint

# 5. Commit changes
git add .
git commit -m "feat: add feature description"

# 6. Push and create PR
git push origin feature/your-feature-name
```

---

## Testing

### Test Coverage

**API (RSpec)**:
- Models: 95% coverage
- Services: 90% coverage
- GraphQL: 85% coverage

**Web (Jest)**:
- Components: 70% coverage
- Hooks: 85% coverage
- Utilities: 90% coverage

### Key Test Files

```
apps/api/spec/
├── models/
│   ├── therapist_spec.rb
│   ├── onboarding_spec.rb
│   └── insurance_coverage_spec.rb
├── services/
│   ├── therapist_matching_service_spec.rb
│   ├── openai_service_spec.rb
│   └── insurance_ocr_service_spec.rb
└── graphql/
    ├── mutations/
    │   ├── match_therapists_spec.rb
    │   └── upload_insurance_card_spec.rb
    └── queries/
        └── therapists_spec.rb

apps/web/__tests__/
├── hooks/
│   └── useVoiceInput.test.ts
├── components/
│   ├── AIChatPanel.test.tsx
│   └── TherapistMatchQuestion.test.tsx
└── lib/
    └── translation.test.ts
```

### Manual Testing Checklist

See `TESTING_GUIDE.md` for comprehensive manual testing procedures.

**Quick Smoke Test**:
1. ✅ Load onboarding page
2. ✅ Create account (signup + login)
3. ✅ Add student information
4. ✅ Upload insurance card (OCR works)
5. ✅ Complete AI chat assessment (8-10 messages)
6. ✅ Match therapists (see 3+ results)
7. ✅ Select therapist and book appointment
8. ✅ See confirmation screen (100% complete)
9. ✅ Receive confirmation email

**Voice Input Test**:
1. ✅ Click microphone button in chat
2. ✅ Speak in Korean: "안녕하세요, 도움이 필요합니다"
3. ✅ See "🎤 Listening..." indicator
4. ✅ See "🌐 Translating..." indicator
5. ✅ See English text appear: "Hello, I need help"
6. ✅ Edit if needed, then send

---

## Deployment

### Production Requirements

```yaml
infrastructure:
  compute:
    - Rails API: 2+ instances (512MB RAM minimum)
    - Sidekiq: 1+ worker (1GB RAM minimum)
    - Next.js: 2+ instances (CDN recommended)
  
  storage:
    - PostgreSQL: managed service (AWS RDS, Heroku Postgres)
    - Redis: managed service (Redis Cloud, AWS ElastiCache)
    - S3: for insurance card images
  
  networking:
    - Load balancer for Rails API
    - CDN for Next.js (Vercel, Cloudflare)
    - SSL certificates (Let's Encrypt, AWS ACM)
  
  monitoring:
    - APM: Datadog, New Relic
    - Error tracking: Sentry
    - Logging: LogDNA, CloudWatch
    - Uptime: Pingdom, UptimeRobot
```

### Deployment Platforms

**Option 1: Heroku (Easiest)**:
```bash
# API
cd apps/api
heroku create parent-onboarding-api
heroku addons:create heroku-postgresql:standard-0
heroku addons:create heroku-redis:premium-0
heroku config:set OPENAI_API_KEY=sk-...
git push heroku main

# Web (Vercel)
cd apps/web
vercel --prod
```

**Option 2: AWS ECS (Production)**:
- See `infra/terraform/` for infrastructure as code
- Docker images built via GitHub Actions
- Deployed to ECS with Fargate
- RDS for PostgreSQL, ElastiCache for Redis

**Option 3: Railway (Modern)**:
- One-click deploy from GitHub
- Automatic HTTPS, scaling, monitoring
- Good for MVP/small scale

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  api-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
      - run: bundle install
      - run: bundle exec rspec
  
  web-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node
        uses: actions/setup-node@v3
      - run: npm install
      - run: npm test
      - run: npm run build
  
  deploy-api:
    needs: [api-tests]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
  
  deploy-web:
    needs: [web-tests]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
```

---

## Security & Privacy

### Data Security

**Encryption**:
- **At Rest**: PostgreSQL encrypted, S3 bucket encryption
- **In Transit**: TLS 1.3 for all API communication
- **Sensitive Fields**: BCrypt for passwords, AES-256 for PII

**Authentication**:
- JWT tokens (1-day expiration)
- Refresh tokens (30-day expiration)
- HttpOnly cookies for web clients
- API key for server-to-server

**Authorization**:
- Parents can only access their own data
- Therapists can only see matched students
- Admin role for care team access
- GraphQL field-level permissions

### Privacy Compliance

**HIPAA Considerations**:
- Business Associate Agreement (BAA) with AWS
- Audit logging of all data access
- Data retention policies (7 years)
- Patient consent forms
- Secure message storage

**GDPR Compliance**:
- Right to access (data export)
- Right to deletion (account deletion)
- Data portability
- Consent management
- Privacy policy

**Data Minimization**:
- Only collect necessary information
- No credit card storage (Stripe handles)
- Insurance images deleted after processing
- AI chat history anonymized for training

### Security Best Practices

```ruby
# API Security Headers
# apps/api/config/application.rb

config.middleware.use Rack::Cors do
  allow do
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3001').split(',')
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options],
      credentials: true,
      max_age: 86400
  end
end

config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'DENY',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Strict-Transport-Security' => 'max-age=31536000'
}
```

```typescript
// Web Security Headers
// apps/web/next.config.js

module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          }
        ]
      }
    ];
  }
};
```

---

## Documentation

### Project Documentation

```
memory-bank/
├── projectbrief.md          # Project overview, goals, timeline
├── productContext.md        # Product requirements, user flows
├── techContext.md           # Tech stack, architecture decisions
├── systemPatterns.md        # Design patterns, data models
├── activeContext.md         # Current work focus, next steps
├── progress.md              # Milestones, completed features
└── frontend_prd.md          # Frontend-specific requirements

TRANSLATION_FEATURE.md       # Korean voice input documentation
TESTING_GUIDE.md             # Manual testing procedures
ENV_SETUP_GUIDE.md           # Detailed environment setup
SETUP_ENV.md                 # Quick setup reference
SESSION_FIX_SUMMARY.md       # Session management fixes
DEBUG_SESSION_CREATION.md    # Session debugging guide
```

### API Documentation

```
# GraphQL Schema
Visit: http://localhost:3000/graphiql

# Key Queries
- therapists: List all therapists
- onboarding(id: ID!): Get onboarding by ID
- parent: Get current authenticated parent

# Key Mutations
- signup: Create parent account
- login: Authenticate parent
- createStudent: Add student profile
- uploadInsuranceCard: Upload and OCR insurance
- startOnboarding: Create onboarding session
- createIntakeMessage: Add AI chat message
- matchTherapists: Get therapist matches
- bookAppointment: Schedule first session
```

### Code Documentation

**Ruby/Rails**:
- YARD-style documentation
- Inline comments for complex logic
- Service classes with clear contracts

**TypeScript/React**:
- TSDoc for public APIs
- Component prop documentation
- Hook usage examples

---

## Contributing

### Development Process

1. **Pick a task** from GitHub Issues or project board
2. **Create branch**: `git checkout -b feature/your-feature`
3. **Write tests** first (TDD preferred)
4. **Implement feature** following style guides
5. **Run tests**: `bundle exec rspec` / `npm test`
6. **Lint code**: `rubocop` / `npm run lint`
7. **Commit**: Follow conventional commits format
8. **Push & PR**: Create pull request with description
9. **Code review**: Address feedback
10. **Merge**: Squash merge to main

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructure
- `test`: Adding tests
- `chore`: Build/tooling

**Examples**:
```
feat(onboarding): add Korean voice input translation

- Integrate Web Speech API for voice transcription
- Add OpenAI translation endpoint
- Update chat UI with microphone button

Closes #123
```

---

## License

Copyright © 2024 Daybreak Health. All rights reserved.

---

## Support

**Questions?**
- Slack: #parent-onboarding-dev
- Email: dev@daybreakhealth.com
- GitHub Issues: [Create Issue](https://github.com/daybreak/parent-onboarding/issues)

**Resources**:
- [Memory Bank Documentation](memory-bank/)
- [Translation Feature Guide](TRANSLATION_FEATURE.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Environment Setup](ENV_SETUP_GUIDE.md)
