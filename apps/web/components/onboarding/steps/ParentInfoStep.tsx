'use client';

import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface ParentInfoStepProps {
  onNext: (data: ParentInfoData) => void;
  onPrev: () => void;
  initialData?: Partial<ParentInfoData>;
}

export interface ParentInfoData {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  street: string;
  city: string;
  state: string;
  postalCode: string;
  dateOfBirth?: string;
  relationship?: string;
}

export const ParentInfoStep: React.FC<ParentInfoStepProps> = ({
  onNext,
  onPrev,
  initialData = {}
}) => {
  const [formData, setFormData] = useState<ParentInfoData>({
    firstName: initialData.firstName || '',
    lastName: initialData.lastName || '',
    email: initialData.email || '',
    phone: initialData.phone || '',
    street: initialData.street || '',
    city: initialData.city || '',
    state: initialData.state || '',
    postalCode: initialData.postalCode || '',
    dateOfBirth: initialData.dateOfBirth || '',
    relationship: initialData.relationship || ''
  });

  const [errors, setErrors] = useState<Partial<Record<keyof ParentInfoData, string>>>({});

  const validate = (): boolean => {
    const newErrors: Partial<Record<keyof ParentInfoData, string>> = {};

    if (!formData.firstName.trim()) {
      newErrors.firstName = 'First name is required';
    }
    if (!formData.lastName.trim()) {
      newErrors.lastName = 'Last name is required';
    }
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email';
    }
    if (!formData.phone.trim()) {
      newErrors.phone = 'Phone number is required';
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

  const handleChange = (field: keyof ParentInfoData, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="space-y-4">
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="firstName">
              First Name <span className="text-destructive">*</span>
            </Label>
            <Input
              id="firstName"
              value={formData.firstName}
              onChange={(e) => handleChange('firstName', e.target.value)}
              aria-invalid={!!errors.firstName}
              aria-required="true"
              aria-describedby={errors.firstName ? 'firstName-error' : undefined}
            />
            {errors.firstName && (
              <p id="firstName-error" className="text-sm text-destructive">
                {errors.firstName}
              </p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="lastName">
              Last Name <span className="text-destructive">*</span>
            </Label>
            <Input
              id="lastName"
              value={formData.lastName}
              onChange={(e) => handleChange('lastName', e.target.value)}
              aria-invalid={!!errors.lastName}
              aria-required="true"
              aria-describedby={errors.lastName ? 'lastName-error' : undefined}
            />
            {errors.lastName && (
              <p id="lastName-error" className="text-sm text-destructive">
                {errors.lastName}
              </p>
            )}
          </div>
        </div>

        <div className="space-y-2">
          <Label htmlFor="email">
            Email <span className="text-destructive">*</span>
          </Label>
          <Input
            id="email"
            type="email"
            value={formData.email}
            onChange={(e) => handleChange('email', e.target.value)}
            aria-invalid={!!errors.email}
            aria-required="true"
            aria-describedby={errors.email ? 'email-error' : undefined}
          />
          {errors.email && (
            <p id="email-error" className="text-sm text-destructive">
              {errors.email}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label htmlFor="phone">
            Phone Number <span className="text-destructive">*</span>
          </Label>
          <Input
            id="phone"
            type="tel"
            value={formData.phone}
            onChange={(e) => handleChange('phone', e.target.value)}
            aria-invalid={!!errors.phone}
            aria-required="true"
            aria-describedby={errors.phone ? 'phone-error' : undefined}
          />
          {errors.phone && (
            <p id="phone-error" className="text-sm text-destructive">
              {errors.phone}
            </p>
          )}
        </div>

        <div>
          <h3 className="text-sm font-semibold text-muted-foreground">Home Address</h3>
          <p className="text-xs text-muted-foreground">
            This helps us match you with clinicians in your area.
          </p>
          <div className="mt-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="street">Street address</Label>
              <Input
                id="street"
                value={formData.street}
                onChange={(e) => handleChange('street', e.target.value)}
              />
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="city">City</Label>
                <Input
                  id="city"
                  value={formData.city}
                  onChange={(e) => handleChange('city', e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="state">State</Label>
                <Input
                  id="state"
                  value={formData.state}
                  onChange={(e) => handleChange('state', e.target.value)}
                  placeholder="CA"
                />
              </div>
            </div>
            <div className="space-y-2 sm:w-1/2">
              <Label htmlFor="postalCode">ZIP / Postal code</Label>
              <Input
                id="postalCode"
                value={formData.postalCode}
                onChange={(e) => handleChange('postalCode', e.target.value)}
              />
            </div>
          </div>
        </div>
      </div>

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
        <Button type="submit" className="w-full sm:w-auto">Continue</Button>
      </div>
    </form>
  );
};

