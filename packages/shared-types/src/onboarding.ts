import { z } from 'zod'

export const OnboardingStatusSchema = z.enum([
  'draft',
  'active',
  'completed',
  'abandoned',
])

export type OnboardingStatus = z.infer<typeof OnboardingStatusSchema>

export const OnboardingSessionSchema = z.object({
  id: z.string().uuid(),
  parentId: z.string().uuid(),
  studentId: z.string().uuid(),
  status: OnboardingStatusSchema,
  currentStep: z.number().int().min(1).max(5),
  etaSeconds: z.number().int().optional(),
  completedAt: z.date().optional(),
  createdAt: z.date(),
  updatedAt: z.date(),
})

export type OnboardingSession = z.infer<typeof OnboardingSessionSchema>

