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
  insurance_company_name: 'Full insurance company name (may be same as payer name)',
  member_id: 'Your member ID or policy number. This is usually found on the front of your insurance card, often labeled as "Member ID" or "Policy Number"',
  group_number: 'Your group number if you have employer-sponsored insurance. This may be labeled as "Group #" or "Group Number" on your card',
  group_id: 'Group ID (may be different from group number)',
  subscriber_name: 'The full name of the person who holds the insurance policy',
  plan_type: 'The type of plan you have, such as PPO (Preferred Provider Organization), HMO (Health Maintenance Organization), or EPO (Exclusive Provider Organization)',
  effective_date: 'The date your insurance coverage began (if known)',
  plan_holder_first_name: 'First name of the plan holder (if different from subscriber)',
  plan_holder_last_name: 'Last name of the plan holder',
  plan_holder_dob: 'Date of birth of the plan holder (format: YYYY-MM-DD)',
  plan_holder_country: 'Country of the plan holder (default: US)',
  plan_holder_state: 'State of the plan holder (2-letter code, e.g., CA, NY)',
  plan_holder_city: 'City of the plan holder',
  plan_holder_street_address: 'Street address of the plan holder',
  plan_holder_zip_code: 'ZIP code of the plan holder',
  plan_holder_legal_gender: 'Legal gender of the plan holder (M, F, or other)',
  kind: 'Policy type: Individual or Family',
  level: 'Plan level: Bronze, Silver, or Gold',
  eligibility: 'Eligibility status: Active, Pending, Expired, or Terminated'
};

export const ManualInsuranceForm: React.FC<ManualInsuranceFormProps> = ({
  initialData = {},
  onSubmit,
  onCancel
}) => {
  const [formData, setFormData] = useState({
    // Basic insurance information
    payer_name: initialData.payer_name || '',
    insurance_company_name: initialData.insurance_company_name || '',
    member_id: initialData.member_id || '',
    group_number: initialData.group_number || '',
    group_id: initialData.group_id || '',
    subscriber_name: initialData.subscriber_name || '',
    plan_type: initialData.plan_type || '',
    effective_date: initialData.effective_date || '',
    // Plan holder information
    plan_holder_first_name: initialData.plan_holder_first_name || '',
    plan_holder_last_name: initialData.plan_holder_last_name || '',
    plan_holder_dob: initialData.plan_holder_dob || '',
    plan_holder_country: initialData.plan_holder_country || 'US',
    plan_holder_state: initialData.plan_holder_state || '',
    plan_holder_city: initialData.plan_holder_city || '',
    plan_holder_street_address: initialData.plan_holder_street_address || '',
    plan_holder_zip_code: initialData.plan_holder_zip_code || '',
    plan_holder_legal_gender: initialData.plan_holder_legal_gender || '',
    // Policy metadata
    kind: initialData.kind || '',
    level: initialData.level || '',
    eligibility: initialData.eligibility || '1' // Default to active
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [showPlanHolderSection, setShowPlanHolderSection] = useState(
    !!(initialData.plan_holder_first_name || initialData.plan_holder_last_name)
  );

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

  const renderField = (key: string, value: string, isRequired: boolean) => {
    const helpText = FIELD_HELP[key];
    const fieldType = key.includes('dob') || key.includes('date') ? 'date' : 
                     key.includes('gender') ? 'select' : 
                     key === 'kind' || key === 'level' || key === 'eligibility' ? 'select' : 'text';

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
        {fieldType === 'select' ? (
          <select
            id={key}
            value={value}
            onChange={(e) => handleChange(key, e.target.value)}
            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            aria-invalid={!!errors[key]}
            aria-required={isRequired}
          >
            {key === 'kind' && (
              <>
                <option value="">Select policy type</option>
                <option value="0">Unknown</option>
                <option value="1">Individual</option>
                <option value="2">Family</option>
              </>
            )}
            {key === 'level' && (
              <>
                <option value="">Select plan level</option>
                <option value="0">Unknown</option>
                <option value="1">Bronze</option>
                <option value="2">Silver</option>
                <option value="3">Gold</option>
              </>
            )}
            {key === 'eligibility' && (
              <>
                <option value="0">Unknown</option>
                <option value="1">Active</option>
                <option value="2">Pending</option>
                <option value="3">Expired</option>
                <option value="4">Terminated</option>
              </>
            )}
            {key === 'plan_holder_legal_gender' && (
              <>
                <option value="">Select gender</option>
                <option value="M">Male</option>
                <option value="F">Female</option>
                <option value="Other">Other</option>
              </>
            )}
          </select>
        ) : (
          <Input
            id={key}
            type={fieldType}
            value={value}
            onChange={(e) => handleChange(key, e.target.value)}
            aria-invalid={!!errors[key]}
            aria-required={isRequired}
            aria-describedby={errors[key] ? `${key}-error` : helpText ? `${key}-help` : undefined}
          />
        )}
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
  };

  const basicFields = ['payer_name', 'insurance_company_name', 'member_id', 'group_number', 'group_id', 'subscriber_name', 'plan_type', 'effective_date'];
  const planHolderFields = ['plan_holder_first_name', 'plan_holder_last_name', 'plan_holder_dob', 'plan_holder_country', 'plan_holder_state', 'plan_holder_city', 'plan_holder_street_address', 'plan_holder_zip_code', 'plan_holder_legal_gender'];
  const metadataFields = ['kind', 'level', 'eligibility'];

  return (
    <Card>
      <CardHeader>
        <CardTitle>Enter Insurance Information Manually</CardTitle>
        <CardDescription>
          Please fill in your insurance information. Fields marked with * are required.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Basic Insurance Information */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Basic Insurance Information</h3>
            <div className="grid gap-4 sm:grid-cols-2">
              {basicFields.map((key) => renderField(key, formData[key as keyof typeof formData], key === 'payer_name' || key === 'member_id'))}
            </div>
          </div>

          {/* Plan Holder Information */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold">Plan Holder Information</h3>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => setShowPlanHolderSection(!showPlanHolderSection)}
              >
                {showPlanHolderSection ? 'Hide' : 'Show'} Plan Holder Details
              </Button>
            </div>
            {showPlanHolderSection && (
              <div className="grid gap-4 sm:grid-cols-2">
                {planHolderFields.map((key) => renderField(key, formData[key as keyof typeof formData], false))}
              </div>
            )}
          </div>

          {/* Policy Metadata */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Policy Details</h3>
            <div className="grid gap-4 sm:grid-cols-3">
              {metadataFields.map((key) => renderField(key, formData[key as keyof typeof formData], false))}
            </div>
          </div>

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

