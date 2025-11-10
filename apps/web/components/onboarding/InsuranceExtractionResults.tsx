'use client';

import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { CheckCircle2, AlertCircle, HelpCircle } from 'lucide-react';
import { cn } from '@/lib/utils';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';

interface ExtractedField {
  value: string;
  confidence: 'high' | 'medium' | 'low';
}

interface ExtractedData {
  // Basic insurance information
  payer_name?: ExtractedField;
  insurance_company_name?: ExtractedField;
  member_id?: ExtractedField;
  group_number?: ExtractedField;
  group_id?: ExtractedField;
  subscriber_name?: ExtractedField;
  plan_type?: ExtractedField;
  effective_date?: ExtractedField;
  // Plan holder information
  plan_holder_first_name?: ExtractedField;
  plan_holder_last_name?: ExtractedField;
  plan_holder_dob?: ExtractedField;
  plan_holder_country?: ExtractedField;
  plan_holder_state?: ExtractedField;
  plan_holder_city?: ExtractedField;
  plan_holder_street_address?: ExtractedField;
  plan_holder_zip_code?: ExtractedField;
  plan_holder_legal_gender?: ExtractedField;
  // Policy metadata
  kind?: ExtractedField;
  level?: ExtractedField;
  eligibility?: ExtractedField;
}

interface InsuranceExtractionResultsProps {
  extractedData: ExtractedData;
  onConfirm: (data: Record<string, string>) => void;
  onEdit: () => void;
}

export const InsuranceExtractionResults: React.FC<InsuranceExtractionResultsProps> = ({
  extractedData,
  onConfirm,
  onEdit
}) => {
  const [editedData, setEditedData] = useState<Record<string, string>>({});
  const [needsConfirmation, setNeedsConfirmation] = useState(false);

  // Check if any fields need confirmation
  React.useEffect(() => {
    const hasLowConfidence = Object.values(extractedData).some(
      (field) => field?.confidence === 'low' || field?.confidence === 'medium'
    );
    setNeedsConfirmation(hasLowConfidence);
  }, [extractedData]);

  const handleFieldChange = (field: string, value: string) => {
    setEditedData((prev) => ({ ...prev, [field]: value }));
  };

  const handleConfirm = () => {
    const finalData: Record<string, string> = {};
    
    Object.entries(extractedData).forEach(([key, field]) => {
      finalData[key] = editedData[key] || field?.value || '';
    });
    
    onConfirm(finalData);
  };

  const getConfidenceBadge = (confidence?: string) => {
    if (!confidence) return null;

    const variants = {
      high: { variant: 'default' as const, icon: CheckCircle2, label: 'High Confidence' },
      medium: { variant: 'secondary' as const, icon: AlertCircle, label: 'Medium Confidence' },
      low: { variant: 'destructive' as const, icon: HelpCircle, label: 'Low Confidence' }
    };

    const config = variants[confidence as keyof typeof variants] || variants.low;
    const Icon = config.icon;

    return (
      <Badge variant={config.variant} className="ml-2">
        <Icon className="mr-1 h-3 w-3" />
        {config.label}
      </Badge>
    );
  };

  const getFieldHelp = (field: string): string => {
    const helpTexts: Record<string, string> = {
      payer_name: 'The name of your insurance company',
      insurance_company_name: 'Full insurance company name',
      member_id: 'Your member ID or policy number, usually found on the front of the card',
      group_number: 'Group number if provided by your employer or organization',
      group_id: 'Group ID (may be different from group number)',
      subscriber_name: 'The name of the policyholder',
      plan_type: 'Type of plan such as PPO, HMO, or EPO',
      effective_date: 'The date your insurance coverage began',
      plan_holder_first_name: 'First name of the plan holder',
      plan_holder_last_name: 'Last name of the plan holder',
      plan_holder_dob: 'Date of birth of the plan holder',
      plan_holder_country: 'Country of the plan holder',
      plan_holder_state: 'State of the plan holder (2-letter code)',
      plan_holder_city: 'City of the plan holder',
      plan_holder_street_address: 'Street address of the plan holder',
      plan_holder_zip_code: 'ZIP code of the plan holder',
      plan_holder_legal_gender: 'Legal gender of the plan holder',
      kind: 'Policy type: Individual or Family',
      level: 'Plan level: Bronze, Silver, or Gold',
      eligibility: 'Eligibility status: Active, Pending, Expired, or Terminated'
    };
    return helpTexts[field] || '';
  };

  // Organize fields into sections
  const basicFields = ['payer_name', 'insurance_company_name', 'member_id', 'group_number', 'group_id', 'subscriber_name', 'plan_type', 'effective_date'];
  const planHolderFields = ['plan_holder_first_name', 'plan_holder_last_name', 'plan_holder_dob', 'plan_holder_country', 'plan_holder_state', 'plan_holder_city', 'plan_holder_street_address', 'plan_holder_zip_code', 'plan_holder_legal_gender'];
  const metadataFields = ['kind', 'level', 'eligibility'];

  const hasPlanHolderData = planHolderFields.some(field => extractedData[field as keyof ExtractedData]);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Extracted Insurance Information</CardTitle>
        <CardDescription>
          Please review the information we extracted from your card. Fields with medium or low confidence need your confirmation.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Basic Insurance Information */}
        <div className="space-y-4">
          <h3 className="text-lg font-semibold">Basic Insurance Information</h3>
          <div className="grid gap-4 sm:grid-cols-2">
            {basicFields.map((key) => {
              const field = extractedData[key as keyof ExtractedData];
              if (!field) return null;

              const isEditable = field.confidence === 'low' || field.confidence === 'medium';
              const displayValue = editedData[key] || field.value || '';

              return (
                <div key={key} className="space-y-2">
                  <div className="flex items-center justify-between">
                    <Label htmlFor={key} className="capitalize text-sm">
                      {key.replace(/_/g, ' ')}
                      {getConfidenceBadge(field.confidence)}
                    </Label>
                    {getFieldHelp(key) && (
                      <TooltipProvider>
                        <Tooltip>
                          <TooltipTrigger asChild>
                            <HelpCircle className="h-4 w-4 text-muted-foreground cursor-help" />
                          </TooltipTrigger>
                          <TooltipContent className="max-w-xs">
                            <p className="text-sm">{getFieldHelp(key)}</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>
                    )}
                  </div>
                  {isEditable ? (
                    <Input
                      id={key}
                      value={displayValue}
                      onChange={(e) => handleFieldChange(key, e.target.value)}
                      className={cn(
                        field.confidence === 'low' && 'border-yellow-500',
                        field.confidence === 'medium' && 'border-orange-500'
                      )}
                      aria-describedby={`${key}-help`}
                    />
                  ) : (
                    <div className="rounded-md border bg-muted px-3 py-2 text-sm">
                      {displayValue || 'Not found'}
                    </div>
                  )}
                  {isEditable && (
                    <p id={`${key}-help`} className="text-xs text-muted-foreground">
                      {getFieldHelp(key)}
                    </p>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Plan Holder Information */}
        {hasPlanHolderData && (
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Plan Holder Information</h3>
            <div className="grid gap-4 sm:grid-cols-2">
              {planHolderFields.map((key) => {
                const field = extractedData[key as keyof ExtractedData];
                if (!field) return null;

                const isEditable = field.confidence === 'low' || field.confidence === 'medium';
                const displayValue = editedData[key] || field.value || '';

                return (
                  <div key={key} className="space-y-2">
                    <div className="flex items-center justify-between">
                      <Label htmlFor={key} className="capitalize text-sm">
                        {key.replace(/_/g, ' ')}
                        {getConfidenceBadge(field.confidence)}
                      </Label>
                      {getFieldHelp(key) && (
                        <TooltipProvider>
                          <Tooltip>
                            <TooltipTrigger asChild>
                              <HelpCircle className="h-4 w-4 text-muted-foreground cursor-help" />
                            </TooltipTrigger>
                            <TooltipContent className="max-w-xs">
                              <p className="text-sm">{getFieldHelp(key)}</p>
                            </TooltipContent>
                          </Tooltip>
                        </TooltipProvider>
                      )}
                    </div>
                    {isEditable ? (
                      <Input
                        id={key}
                        value={displayValue}
                        onChange={(e) => handleFieldChange(key, e.target.value)}
                        className={cn(
                          field.confidence === 'low' && 'border-yellow-500',
                          field.confidence === 'medium' && 'border-orange-500'
                        )}
                        aria-describedby={`${key}-help`}
                      />
                    ) : (
                      <div className="rounded-md border bg-muted px-3 py-2 text-sm">
                        {displayValue || 'Not found'}
                      </div>
                    )}
                    {isEditable && (
                      <p id={`${key}-help`} className="text-xs text-muted-foreground">
                        {getFieldHelp(key)}
                      </p>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Policy Metadata */}
        {(extractedData.kind || extractedData.level || extractedData.eligibility) && (
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Policy Details</h3>
            <div className="grid gap-4 sm:grid-cols-3">
              {metadataFields.map((key) => {
                const field = extractedData[key as keyof ExtractedData];
                if (!field) return null;

                const isEditable = field.confidence === 'low' || field.confidence === 'medium';
                const displayValue = editedData[key] || field.value || '';

                return (
                  <div key={key} className="space-y-2">
                    <div className="flex items-center justify-between">
                      <Label htmlFor={key} className="capitalize text-sm">
                        {key.replace(/_/g, ' ')}
                        {getConfidenceBadge(field.confidence)}
                      </Label>
                      {getFieldHelp(key) && (
                        <TooltipProvider>
                          <Tooltip>
                            <TooltipTrigger asChild>
                              <HelpCircle className="h-4 w-4 text-muted-foreground cursor-help" />
                            </TooltipTrigger>
                            <TooltipContent className="max-w-xs">
                              <p className="text-sm">{getFieldHelp(key)}</p>
                            </TooltipContent>
                          </Tooltip>
                        </TooltipProvider>
                      )}
                    </div>
                    {isEditable ? (
                      <Input
                        id={key}
                        value={displayValue}
                        onChange={(e) => handleFieldChange(key, e.target.value)}
                        className={cn(
                          field.confidence === 'low' && 'border-yellow-500',
                          field.confidence === 'medium' && 'border-orange-500'
                        )}
                        aria-describedby={`${key}-help`}
                      />
                    ) : (
                      <div className="rounded-md border bg-muted px-3 py-2 text-sm">
                        {displayValue || 'Not found'}
                      </div>
                    )}
                    {isEditable && (
                      <p id={`${key}-help`} className="text-xs text-muted-foreground">
                        {getFieldHelp(key)}
                      </p>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {needsConfirmation && (
          <div className="rounded-md bg-yellow-50 border border-yellow-200 p-4">
            <div className="flex items-start gap-2">
              <AlertCircle className="h-5 w-5 text-yellow-600 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-yellow-800">
                  Please review and confirm
                </p>
                <p className="text-xs text-yellow-700 mt-1">
                  Some fields have medium or low confidence. Please verify they are correct before continuing.
                </p>
              </div>
            </div>
          </div>
        )}

        <div className="flex gap-3">
          <Button type="button" variant="outline" onClick={onEdit} className="flex-1">
            Enter Manually Instead
          </Button>
          <Button onClick={handleConfirm} className="flex-1">
            Confirm and Continue
          </Button>
        </div>
      </CardContent>
    </Card>
  );
};

