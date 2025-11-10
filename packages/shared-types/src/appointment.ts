import { z } from 'zod'

export const AppointmentStatusSchema = z.enum([
  'scheduled',
  'confirmed',
  'completed',
  'cancelled',
  'no_show',
])

export type AppointmentStatus = z.infer<typeof AppointmentStatusSchema>

export const AppointmentSchema = z.object({
  id: z.string().uuid(),
  sessionId: z.string().uuid(),
  studentId: z.string().uuid(),
  therapistId: z.string().uuid(),
  scheduledAt: z.date(),
  duration: z.number().int(), // minutes
  status: AppointmentStatusSchema,
  notes: z.string().optional(),
  createdAt: z.date(),
  updatedAt: z.date(),
})

export type Appointment = z.infer<typeof AppointmentSchema>

