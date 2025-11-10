'use client';

import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { HelpCircle } from 'lucide-react';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';

interface ManualInsuranceFormProps {
  initialData?: Record<string, string>;
  onSubmit: (data: Record<string, string>) => void;
  onCancel: () => void;
}

const FIELD_HELP: Record<string, string> = {
  payer_name: 'The name of your insurance company (e.g., Blue Cross Blue Shield, Aetna, UnitedHealthcare)',
  member_id: 'Your member ID or policy number. This is usually found on the front of your insurance card, often labeled as "Member ID" or "Policy Number"',
  group_number: 'Your group number if you have employer-sponsored insurance. This may be labeled as "Group #" or "Group Number" on your card',
  subscriber_name: 'The full name of the person who holds the insurance policy',
  plan_type: 'The type of plan you have, such as PPO (Preferred Provider Organization), HMO (Health Maintenance Organization), or EPO (Exclusive Provider Organization)',
  effective_date: 'The date your insurance coverage began (if known)'
};

export const ManualInsuranceForm: React.FC<ManualInsuranceFormProps> = ({
  initialData = {},
  onSubmit,
  onCancel
}) => {
  const [formData, setFormData] = useState({
    payer_name: initialData.payer_name || '',
    member_id: initialData.member_id || '',
    group_number: initialData.group_number || '',
    subscriber_name: initialData.subscriber_name || '',
    plan_type: initialData.plan_type || '',
    effective_date: initialData.effective_date || ''
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors((prev) => {
        const { [field]: _, ...rest } = prev;
        return rest;
      });
    }
  };

  const validate = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.payer_name.trim()) {
      newErrors.payer_name = 'Insurance company name is required';
    }
    if (!formData.member_id.trim()) {
      newErrors.member_id = 'Member ID is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onSubmit(formData);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Enter Insurance Information Manually</CardTitle>
        <CardDescription>
          Please fill in your insurance information. Fields marked with * are required.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {Object.entries(formData).map(([key, value]) => {
            const isRequired = key === 'payer_name' || key === 'member_id';
            const helpText = FIELD_HELP[key];

            return (
              <div key={key} className="space-y-2">
                <div className="flex items-center gap-2">
                  <Label htmlFor={key} className="capitalize">
                    {key.replace(/_/g, ' ')}
                    {isRequired && <span className="text-destructive ml-1">*</span>}
                  </Label>
                  {helpText && (
                    <TooltipProvider>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <HelpCircle className="h-4 w-4 text-muted-foreground cursor-help" />
                        </TooltipTrigger>
                        <TooltipContent className="max-w-xs">
                          <p className="text-sm">{helpText}</p>
                        </TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  )}
                </div>
                <Input
                  id={key}
                  value={value}
                  onChange={(e) => handleChange(key, e.target.value)}
                  aria-invalid={!!errors[key]}
                  aria-required={isRequired}
                  aria-describedby={errors[key] ? `${key}-error` : helpText ? `${key}-help` : undefined}
                />
                {errors[key] && (
                  <p id={`${key}-error`} className="text-sm text-destructive">
                    {errors[key]}
                  </p>
                )}
                {helpText && !errors[key] && (
                  <p id={`${key}-help`} className="text-xs text-muted-foreground">
                    {helpText}
                  </p>
                )}
              </div>
            );
          })}

          <div className="flex gap-3 pt-4">
            <Button type="button" variant="outline" onClick={onCancel} className="flex-1">
              Cancel
            </Button>
            <Button type="submit" className="flex-1">
              Save Insurance Information
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
};

