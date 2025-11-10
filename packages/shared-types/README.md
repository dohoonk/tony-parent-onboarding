# @parent-onboarding/shared-types

Shared TypeScript types and Zod schemas for the Parent Onboarding AI project.

## Usage

```typescript
import { Parent, StudentSchema, type OnboardingSession } from '@parent-onboarding/shared-types'

// Use Zod schema for validation
const result = StudentSchema.parse(data)

// Use TypeScript types
const session: OnboardingSession = {
  // ...
}
```

## Exports

- **Parent**: Parent user types and schemas
- **Student**: Student (child) types and schemas
- **Onboarding**: Onboarding session types and schemas
- **Intake**: AI intake message and summary types
- **Screener**: Clinical screener types
- **Insurance**: Insurance card and policy types
- **Appointment**: Appointment scheduling types

## Development

```bash
# Type check
npm run type-check

# Run tests
npm test
```

