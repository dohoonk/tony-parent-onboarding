import { z } from 'zod'

export const IntakeMessageRoleSchema = z.enum(['user', 'assistant', 'system'])

export type IntakeMessageRole = z.infer<typeof IntakeMessageRoleSchema>

export const IntakeMessageSchema = z.object({
  id: z.string().uuid(),
  sessionId: z.string().uuid(),
  role: IntakeMessageRoleSchema,
  content: z.string(),
  createdAt: z.date(),
})

export type IntakeMessage = z.infer<typeof IntakeMessageSchema>

export const IntakeSummarySchema = z.object({
  id: z.string().uuid(),
  sessionId: z.string().uuid(),
  concerns: z.array(z.string()),
  goals: z.array(z.string()),
  riskFlags: z.array(z.string()).optional(),
  summaryText: z.string(),
  createdAt: z.date(),
})

export type IntakeSummary = z.infer<typeof IntakeSummarySchema>

