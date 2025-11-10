# Parent Onboarding AI

AI-powered onboarding experience for parents seeking mental health services for their children at Daybreak Health.

## Project Overview

This project transforms Daybreak Health's clinical onboarding process into a warm, supportive journey through:
- AI-guided conversational assessment
- Streamlined multi-step onboarding flow
- Insurance OCR and auto-extraction
- AI-assisted therapist matching
- Cost transparency and estimation

## Monorepo Structure

```
root/
├── apps/
│   ├── api/           # Rails 7 API-only (GraphQL, Sidekiq, Redis, PostgreSQL)
│   └── web/           # Next.js 15 (App Router, React 18, Tailwind, shadcn/ui)
├── packages/
│   ├── shared-types/  # Zod/TypeScript schemas
│   ├── prompts/       # AI prompt templates
│   └── ui/            # Shared UI components (optional)
├── infra/
│   ├── docker/        # Dockerfiles
│   └── terraform/     # Infrastructure as Code
├── scripts/           # Development scripts, seeders
└── memory-bank/       # Project documentation
```

## Technology Stack

**Backend:**
- Rails 7 (API-only)
- GraphQL (graphql-ruby)
- PostgreSQL
- Redis + Sidekiq
- OpenAI (GPT-4o/GPT-4o-mini)

**Frontend:**
- Next.js 15 (App Router)
- React 18
- TypeScript
- Tailwind CSS
- shadcn/ui

## Quick Start

### Prerequisites
- Ruby 3.2+
- Node.js 18+
- PostgreSQL 14+
- Redis 7+
- Docker (recommended)

### Development Setup

Detailed setup instructions coming soon as we complete the infrastructure setup.

## Project Goals

- **↑30%** increase in service requests
- **↓50%** reduction in insurance drop-offs
- **↑40%** improvement in onboarding completion
- **15 min** average completion time
- **70+ NPS** post-onboarding

## Documentation

See `/memory-bank/` for detailed project documentation:
- `projectbrief.md` - Project overview and goals
- `productContext.md` - Product requirements and user experience
- `techContext.md` - Technical stack and architecture
- `systemPatterns.md` - Architecture patterns and data models
- `activeContext.md` - Current work focus
- `progress.md` - Project status and milestones

## License

Copyright © 2024 Daybreak Health. All rights reserved.

