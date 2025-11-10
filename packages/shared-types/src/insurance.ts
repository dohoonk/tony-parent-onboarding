import { z } from 'zod'

export const InsuranceCardSchema = z.object({
  id: z.string().uuid(),
  sessionId: z.string().uuid(),
  frontImageUrl: z.string().url(),
  backImageUrl: z.string().url().optional(),
  ocrJson: z.record(z.unknown()).optional(),
  confidenceJson: z.record(z.unknown()).optional(),
  createdAt: z.date(),
})

export type InsuranceCard = z.infer<typeof InsuranceCardSchema>

export const InsurancePolicySchema = z.object({
  id: z.string().uuid(),
  sessionId: z.string().uuid(),
  payerName: z.string(),
  memberId: z.string(),
  groupNumber: z.string().optional(),
  planType: z.string().optional(),
  subscriberName: z.string().optional(),
  verifiedAt: z.date().optional(),
  createdAt: z.date(),
  updatedAt: z.date(),
})

export type InsurancePolicy = z.infer<typeof InsurancePolicySchema>

