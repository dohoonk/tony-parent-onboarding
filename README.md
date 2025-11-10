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
│   ├── api/           # Rails 8 API-only (GraphQL, Sidekiq, Redis, PostgreSQL)
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
- Rails 8 (API-only)
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

#### Option 1: Docker (Recommended)

The easiest way to get started is with Docker:

```bash
# Clone the repository
git clone <repository-url>
cd parent-onboarding

# Start all services (API, Web, PostgreSQL, Redis, Sidekiq)
docker-compose up

# The services will be available at:
# - Rails API: http://localhost:3000
# - GraphiQL: http://localhost:3000/graphiql
# - Next.js Web: http://localhost:3001
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
```

#### Option 2: Local Development

**1. Set up the API (Rails):**

```bash
cd apps/api

# Install dependencies
bundle install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Create and migrate database
rails db:create
rails db:migrate
rails db:seed

# Start the server
rails server
```

**2. Set up the Web App (Next.js):**

```bash
cd apps/web

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your configuration

# Start the development server
npm run dev
```

**3. Set up Background Jobs (Sidekiq):**

```bash
cd apps/api

# Start Sidekiq worker
bundle exec sidekiq -C config/sidekiq.yml
```

### Environment Variables

**API (.env):**
```
DATABASE_URL=postgresql://localhost/parent_onboarding_development
REDIS_URL=redis://localhost:6379/0
OPENAI_API_KEY=sk-your-key-here
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=parent-onboarding-uploads
SECRET_KEY_BASE=your-secret-key-base-here
```

**Web (.env.local):**
```
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
NEXT_PUBLIC_API_URL=http://localhost:3000
```

### Common Commands

**API:**
```bash
# Run tests
bundle exec rspec

# Run console
rails console

# Generate migration
rails generate migration AddFieldToModel field:type

# Run linter
rubocop
```

**Web:**
```bash
# Run tests
npm test

# Type check
npm run type-check

# Build for production
npm run build

# Run linter
npm run lint
```

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

