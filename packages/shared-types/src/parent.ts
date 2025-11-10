import { z } from 'zod'

export const ParentSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  phone: z.string().optional(),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  createdAt: z.date(),
  updatedAt: z.date(),
})

export type Parent = z.infer<typeof ParentSchema>

export const CreateParentInputSchema = ParentSchema.omit({ 
  id: true, 
  createdAt: true, 
  updatedAt: true 
})

export type CreateParentInput = z.infer<typeof CreateParentInputSchema>

