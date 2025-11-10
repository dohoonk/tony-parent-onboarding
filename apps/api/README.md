# Parent Onboarding AI - Rails API

Rails 8 API-only backend with GraphQL, Sidekiq, Redis, and PostgreSQL.

## Setup

### Prerequisites
- Ruby 3.3.5
- PostgreSQL 14+
- Redis 7+

### Installation

```bash
# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start server
rails server
```

### GraphQL Endpoint

- **Development**: http://localhost:3000/graphql
- **GraphiQL IDE**: http://localhost:3000/graphiql (development only)

### Environment Variables

Create a `.env` file in the root:

```
DATABASE_URL=postgresql://localhost/parent_onboarding_development
REDIS_URL=redis://localhost:6379/0
OPENAI_API_KEY=sk-...
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_S3_BUCKET=...
SECRET_KEY_BASE=...
```

## Architecture

### GraphQL API
- Schema definition: `app/graphql/api_schema.rb`
- Types: `app/graphql/types/`
- Mutations: `app/graphql/mutations/`
- Queries: `app/graphql/types/query_type.rb`

### Background Jobs
- Sidekiq for asynchronous processing
- Job definitions: `app/jobs/`

### Services
- AI Intake Service: `app/services/ai_intake_service.rb`
- OCR Service: `app/services/ocr_service.rb`
- Cost Estimator: `app/services/cost_estimator_service.rb`

## Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/parent_spec.rb
```

## API Documentation

See GraphiQL IDE at http://localhost:3000/graphiql for interactive API documentation.

