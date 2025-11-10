import { z } from 'zod'

export const ScreenerSchema = z.object({
  id: z.string().uuid(),
  key: z.string(),
  title: z.string(),
  version: z.string(),
  itemsJson: z.record(z.unknown()),
  createdAt: z.date(),
})

export type Screener = z.infer<typeof ScreenerSchema>

export const ScreenerResponseSchema = z.object({
  id: z.string().uuid(),
  sessionId: z.string().uuid(),
  screenerId: z.string().uuid(),
  answersJson: z.record(z.unknown()),
  score: z.number().optional(),
  interpretation: z.string().optional(),
  createdAt: z.date(),
})

export type ScreenerResponse = z.infer<typeof ScreenerResponseSchema>

