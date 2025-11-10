# @parent-onboarding/prompts

AI prompt templates for the Parent Onboarding AI project.

## Purpose

Centralized, testable prompt templates for all AI interactions in the system.

## Prompts

### Intake System Prompt
Used for the conversational intake with "Reassuring Parenting Coach" tone.

```typescript
import { buildIntakePrompt } from '@parent-onboarding/prompts'

const prompt = buildIntakePrompt({
  parentName: 'Jane',
  childName: 'Alex',
  childAge: 14
})
```

### Screener Interpretation
Translates clinical scores (PHQ-9, GAD-7, etc.) into plain language.

```typescript
import { buildScreenerInterpretationPrompt } from '@parent-onboarding/prompts'

const prompt = buildScreenerInterpretationPrompt({
  childName: 'Alex',
  childAge: 14,
  screenerType: 'GAD-7',
  score: 12,
  severity: 'moderate'
})
```

### Cost Estimation
Explains cost estimates transparently.

### Therapist Matching
Provides clear rationale for therapist recommendations.

## Testing

All prompts should be tested for:
- Tone consistency
- Clarity and accessibility
- Absence of jargon
- Appropriate framing

```bash
npm test
```

## Development

When adding new prompts:
1. Create a new file in `src/`
2. Export the prompt template and any builder functions
3. Add tests to verify prompt quality
4. Update the index.ts export
5. Document usage in this README

