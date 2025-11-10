'use client';

import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select';

interface StudentInfoStepProps {
  onNext: (data: StudentInfoData) => void;
  onPrev: () => void;
  initialData?: Partial<StudentInfoData>;
}

export interface StudentInfoData {
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  grade: string;
  school: string;
}

const GRADES = ['K', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

export const StudentInfoStep: React.FC<StudentInfoStepProps> = ({
  onNext,
  onPrev,
  initialData = {}
}) => {
  const [formData, setFormData] = useState<StudentInfoData>({
    firstName: initialData.firstName || '',
    lastName: initialData.lastName || '',
    dateOfBirth: initialData.dateOfBirth || '',
    grade: initialData.grade || '',
    school: initialData.school || ''
  });

  const [errors, setErrors] = useState<Partial<Record<keyof StudentInfoData, string>>>({});

  const validate = (): boolean => {
    const newErrors: Partial<Record<keyof StudentInfoData, string>> = {};

    if (!formData.firstName.trim()) {
      newErrors.firstName = 'First name is required';
    }
    if (!formData.lastName.trim()) {
      newErrors.lastName = 'Last name is required';
    }
    if (!formData.dateOfBirth) {
      newErrors.dateOfBirth = 'Date of birth is required';
    }
    if (!formData.grade) {
      newErrors.grade = 'Grade is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onNext(formData);
    }
  };

  const handleChange = (field: keyof StudentInfoData, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="space-y-4">
        <div className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="studentFirstName">
              Student First Name <span className="text-destructive">*</span>
            </Label>
            <Input
              id="studentFirstName"
              value={formData.firstName}
              onChange={(e) => handleChange('firstName', e.target.value)}
              aria-invalid={!!errors.firstName}
              aria-describedby={errors.firstName ? 'studentFirstName-error' : undefined}
            />
            {errors.firstName && (
              <p id="studentFirstName-error" className="text-sm text-destructive">
                {errors.firstName}
              </p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="studentLastName">
              Student Last Name <span className="text-destructive">*</span>
            </Label>
            <Input
              id="studentLastName"
              value={formData.lastName}
              onChange={(e) => handleChange('lastName', e.target.value)}
              aria-invalid={!!errors.lastName}
              aria-describedby={errors.lastName ? 'studentLastName-error' : undefined}
            />
            {errors.lastName && (
              <p id="studentLastName-error" className="text-sm text-destructive">
                {errors.lastName}
              </p>
            )}
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="dateOfBirth">
              Date of Birth <span className="text-destructive">*</span>
            </Label>
            <Input
              id="dateOfBirth"
              type="date"
              value={formData.dateOfBirth}
              onChange={(e) => handleChange('dateOfBirth', e.target.value)}
              aria-invalid={!!errors.dateOfBirth}
              aria-describedby={errors.dateOfBirth ? 'dateOfBirth-error' : undefined}
            />
            {errors.dateOfBirth && (
              <p id="dateOfBirth-error" className="text-sm text-destructive">
                {errors.dateOfBirth}
              </p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="grade">
              Grade <span className="text-destructive">*</span>
            </Label>
            <Select value={formData.grade} onValueChange={(value) => handleChange('grade', value)}>
              <SelectTrigger id="grade" aria-invalid={!!errors.grade}>
                <SelectValue placeholder="Select grade" />
              </SelectTrigger>
              <SelectContent>
                {GRADES.map((grade) => (
                  <SelectItem key={grade} value={grade}>
                    {grade === 'K' ? 'Kindergarten' : `Grade ${grade}`}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.grade && (
              <p id="grade-error" className="text-sm text-destructive">
                {errors.grade}
              </p>
            )}
          </div>
        </div>

        <div className="space-y-2">
          <Label htmlFor="school">School (Optional)</Label>
          <Input
            id="school"
            value={formData.school}
            onChange={(e) => handleChange('school', e.target.value)}
          />
        </div>
      </div>

      <div className="flex justify-between">
        <Button type="button" variant="outline" onClick={onPrev}>
          Back
        </Button>
        <Button type="submit">Continue</Button>
      </div>
    </form>
  );
};

