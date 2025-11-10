import { z } from 'zod'

export const StudentSchema = z.object({
  id: z.string().uuid(),
  parentId: z.string().uuid(),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  dateOfBirth: z.date(),
  grade: z.string().optional(),
  school: z.string().optional(),
  language: z.string().default('en'),
  createdAt: z.date(),
  updatedAt: z.date(),
})

export type Student = z.infer<typeof StudentSchema>

export const CreateStudentInputSchema = StudentSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
})

export type CreateStudentInput = z.infer<typeof CreateStudentInputSchema>

