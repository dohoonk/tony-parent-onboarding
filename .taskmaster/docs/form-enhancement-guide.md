# Form Component Enhancement Guide

**Date:** November 11, 2025  
**Purpose:** Standardize form styling across all onboarding steps to match Daybreak Health design system

---

## Design System Standards

### Input Fields
```tsx
<Input
  className="h-10 px-3 text-body rounded-md border-input focus:border-ring focus:ring-2 focus:ring-ring/20"
  aria-invalid={hasError}
  aria-describedby={hasError ? `${id}-error` : undefined}
/>
```

### Labels
```tsx
<Label className="text-body-small font-medium text-foreground mb-2">
  Field Name {required && <span className="text-destructive">*</span>}
</Label>
```

### Error States
```tsx
{error && (
  <div className="flex items-center gap-1.5 mt-1.5 text-destructive" id={`${id}-error`}>
    <AlertCircle className="h-3.5 w-3.5" />
    <span className="text-body-small">{error}</span>
  </div>
)}
```

### Field Grouping
```tsx
<div className="space-y-4">  {/* Vertical spacing between fields */}
  <div>  {/* Individual field wrapper */}
    <Label>...</Label>
    <Input>...</Input>
    {error && <ErrorMessage>...</ErrorMessage>}
  </div>
</div>
```

---

## Component Patterns

### 1. Text Input Field

**Complete Pattern:**
```tsx
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { AlertCircle } from "lucide-react";

interface TextFieldProps {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  error?: string;
  required?: boolean;
  placeholder?: string;
  type?: "text" | "email" | "tel" | "password";
}

export function TextField({
  id,
  label,
  value,
  onChange,
  error,
  required = false,
  placeholder,
  type = "text",
}: TextFieldProps) {
  return (
    <div>
      <Label htmlFor={id} className="text-body-small font-medium text-foreground mb-2">
        {label}
        {required && <span className="text-destructive ml-0.5">*</span>}
      </Label>
      <Input
        id={id}
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className={cn(
          "h-10 touch-target",
          error && "border-destructive focus:border-destructive focus:ring-destructive/20"
        )}
        aria-invalid={!!error}
        aria-describedby={error ? `${id}-error` : undefined}
        aria-required={required}
      />
      {error && (
        <div
          className="flex items-center gap-1.5 mt-1.5 text-destructive"
          id={`${id}-error`}
          role="alert"
        >
          <AlertCircle className="h-3.5 w-3.5 flex-shrink-0" />
          <span className="text-body-small">{error}</span>
        </div>
      )}
    </div>
  );
}
```

### 2. Select/Dropdown Field

**Pattern:**
```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

<div>
  <Label htmlFor={id}>
    {label}
    {required && <span className="text-destructive ml-0.5">*</span>}
  </Label>
  <Select value={value} onValueChange={onChange}>
    <SelectTrigger
      id={id}
      className={cn(
        "h-10 touch-target",
        error && "border-destructive"
      )}
      aria-invalid={!!error}
    >
      <SelectValue placeholder={placeholder} />
    </SelectTrigger>
    <SelectContent>
      {options.map((option) => (
        <SelectItem key={option.value} value={option.value}>
          {option.label}
        </SelectItem>
      ))}
    </SelectContent>
  </Select>
  {error && <ErrorMessage id={`${id}-error`}>{error}</ErrorMessage>}
</div>
```

### 3. Checkbox Field

**Pattern:**
```tsx
import { Checkbox } from "@/components/ui/checkbox";

<div className="flex items-start gap-3">
  <Checkbox
    id={id}
    checked={checked}
    onCheckedChange={onChange}
    className="mt-0.5 touch-target"
    aria-invalid={!!error}
  />
  <div className="flex-1">
    <Label
      htmlFor={id}
      className="text-body font-normal cursor-pointer"
    >
      {label}
    </Label>
    {description && (
      <p className="text-body-small text-muted-foreground mt-1">
        {description}
      </p>
    )}
    {error && <ErrorMessage id={`${id}-error`}>{error}</ErrorMessage>}
  </div>
</div>
```

### 4. Radio Group

**Pattern:**
```tsx
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";

<div>
  <Label className="text-body-small font-medium mb-3 block">
    {label}
    {required && <span className="text-destructive ml-0.5">*</span>}
  </Label>
  <RadioGroup
    value={value}
    onValueChange={onChange}
    className="space-y-3"
    aria-invalid={!!error}
  >
    {options.map((option) => (
      <div key={option.value} className="flex items-center gap-3">
        <RadioGroupItem
          value={option.value}
          id={`${id}-${option.value}`}
          className="touch-target"
        />
        <Label
          htmlFor={`${id}-${option.value}`}
          className="text-body font-normal cursor-pointer"
        >
          {option.label}
        </Label>
      </div>
    ))}
  </RadioGroup>
  {error && <ErrorMessage id={`${id}-error`}>{error}</ErrorMessage>}
</div>
```

### 5. Textarea Field

**Pattern:**
```tsx
import { Textarea } from "@/components/ui/textarea";

<div>
  <Label htmlFor={id}>
    {label}
    {required && <span className="text-destructive ml-0.5">*</span>}
  </Label>
  <Textarea
    id={id}
    value={value}
    onChange={(e) => onChange(e.target.value)}
    placeholder={placeholder}
    rows={rows || 4}
    className={cn(
      "min-h-[80px] resize-y",
      error && "border-destructive"
    )}
    aria-invalid={!!error}
    aria-describedby={error ? `${id}-error` : undefined}
  />
  {error && <ErrorMessage id={`${id}-error`}>{error}</ErrorMessage>}
</div>
```

---

## Mobile Optimizations

### Touch Targets
All interactive elements should be at least **44x44px**:

```tsx
// Add to buttons, inputs, checkboxes, radio buttons
className="touch-target min-h-[44px] min-w-[44px]"

// Or use the utility class from globals.css
className="touch-target"
```

### Keyboard Handling
```tsx
<Input
  onKeyDown={(e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleSubmit();
    }
  }}
/>
```

### Input Types for Mobile Keyboards
```tsx
<Input type="email" inputMode="email" />       {/* Email keyboard */}
<Input type="tel" inputMode="tel" />           {/* Phone keyboard */}
<Input type="number" inputMode="numeric" />    {/* Number keyboard */}
<Input type="url" inputMode="url" />           {/* URL keyboard */}
```

---

## Validation Patterns

### Real-time Validation
```tsx
const [errors, setErrors] = useState<Record<string, string>>({});

const validateField = (name: string, value: any) => {
  const newErrors = { ...errors };
  
  switch (name) {
    case 'email':
      if (!value) {
        newErrors.email = 'Email is required';
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
        newErrors.email = 'Please enter a valid email address';
      } else {
        delete newErrors.email;
      }
      break;
    
    case 'phone':
      if (!value) {
        newErrors.phone = 'Phone number is required';
      } else if (!/^\d{10}$/.test(value.replace(/\D/g, ''))) {
        newErrors.phone = 'Please enter a valid 10-digit phone number';
      } else {
        delete newErrors.phone;
      }
      break;
  }
  
  setErrors(newErrors);
};

const handleChange = (name: string, value: any) => {
  setFormData({ ...formData, [name]: value });
  validateField(name, value);
};
```

### Submit Validation
```tsx
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  
  // Validate all fields
  const newErrors: Record<string, string> = {};
  
  if (!formData.name) {
    newErrors.name = 'Name is required';
  }
  
  if (!formData.email) {
    newErrors.email = 'Email is required';
  }
  
  if (Object.keys(newErrors).length > 0) {
    setErrors(newErrors);
    // Focus first error field
    const firstErrorField = Object.keys(newErrors)[0];
    document.getElementById(firstErrorField)?.focus();
    return;
  }
  
  // Submit form
  await submitForm(formData);
};
```

---

## Accessibility Checklist

### Required Elements
- [ ] All inputs have associated `<Label>` with `htmlFor`
- [ ] Required fields marked with `aria-required` and visual indicator
- [ ] Error states use `aria-invalid` and `aria-describedby`
- [ ] Error messages have `role="alert"` for screen readers
- [ ] Form has proper `<form>` wrapper with `onSubmit`
- [ ] Submit buttons have descriptive text (not just "Submit")

### Keyboard Navigation
- [ ] Tab order is logical (top to bottom, left to right)
- [ ] All interactive elements are keyboard accessible
- [ ] Enter key submits form from input fields
- [ ] Escape key clears/cancels where appropriate
- [ ] Focus indicators are visible (ring-2 ring-ring)

### Screen Readers
- [ ] Form has descriptive `aria-label` or heading
- [ ] Field groups use `<fieldset>` and `<legend>` where appropriate
- [ ] Helper text uses `aria-describedby`
- [ ] Loading states announce with `aria-busy` and `aria-live`

---

## Form Steps to Update

### 1. **WelcomeStep** (`components/onboarding/steps/WelcomeStep.tsx`)
- Standard text inputs (name, email, phone)
- Add phone number validation with formatting
- Improve placeholder text: "Enter your email address"
- Add icons to input fields (Mail, Phone icons)

### 2. **StudentInfoStep** (`components/onboarding/steps/StudentInfoStep.tsx`)
- Student name input
- Grade level select dropdown
- Add helpful descriptions under each field
- Implement proper error handling

### 3. **InsuranceStep** (`components/onboarding/steps/InsuranceStep.tsx`)
- Insurance provider input with autocomplete
- Member ID and Group ID inputs
- File upload for insurance cards
- Add OCR result validation
- Improve error messages for failed OCR

### 4. **SchedulingStep** (`components/onboarding/steps/SchedulingStep.tsx`)
- Date picker with better styling
- Time slot selection (radio buttons or cards)
- Timezone display/selection
- Improve therapist selection cards

### 5. **ManualInsuranceForm** (`components/onboarding/ManualInsuranceForm.tsx`)
- All form fields need consistent styling
- Add field-level validation
- Improve layout and spacing
- Better error messaging

---

## Example: Complete Enhanced Form

```tsx
'use client';

import { useState } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { AlertCircle, Mail, Phone, User } from 'lucide-react';
import { cn } from '@/lib/utils';

export function EnhancedContactForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validateField = (name: string, value: string) => {
    const newErrors = { ...errors };
    
    if (name === 'email' && value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
      newErrors.email = 'Please enter a valid email address';
    } else {
      delete newErrors[name];
    }
    
    setErrors(newErrors);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const newErrors: Record<string, string> = {};
    if (!formData.name) newErrors.name = 'Name is required';
    if (!formData.email) newErrors.email = 'Email is required';
    if (!formData.phone) newErrors.phone = 'Phone is required';
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    
    setIsSubmitting(true);
    try {
      await submitForm(formData);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6" aria-label="Contact information form">
      {/* Name Field */}
      <div>
        <Label htmlFor="name" className="text-body-small font-medium text-foreground mb-2">
          Full Name
          <span className="text-destructive ml-0.5">*</span>
        </Label>
        <div className="relative">
          <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            id="name"
            value={formData.name}
            onChange={(e) => {
              setFormData({ ...formData, name: e.target.value });
              validateField('name', e.target.value);
            }}
            placeholder="John Doe"
            className={cn(
              "h-10 pl-10 touch-target",
              errors.name && "border-destructive focus:border-destructive focus:ring-destructive/20"
            )}
            aria-invalid={!!errors.name}
            aria-describedby={errors.name ? "name-error" : undefined}
            aria-required
          />
        </div>
        {errors.name && (
          <div className="flex items-center gap-1.5 mt-1.5 text-destructive" id="name-error" role="alert">
            <AlertCircle className="h-3.5 w-3.5 flex-shrink-0" />
            <span className="text-body-small">{errors.name}</span>
          </div>
        )}
      </div>

      {/* Email Field */}
      <div>
        <Label htmlFor="email" className="text-body-small font-medium text-foreground mb-2">
          Email Address
          <span className="text-destructive ml-0.5">*</span>
        </Label>
        <div className="relative">
          <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            id="email"
            type="email"
            inputMode="email"
            value={formData.email}
            onChange={(e) => {
              setFormData({ ...formData, email: e.target.value });
              validateField('email', e.target.value);
            }}
            placeholder="john@example.com"
            className={cn(
              "h-10 pl-10 touch-target",
              errors.email && "border-destructive focus:border-destructive focus:ring-destructive/20"
            )}
            aria-invalid={!!errors.email}
            aria-describedby={errors.email ? "email-error" : undefined}
            aria-required
          />
        </div>
        {errors.email && (
          <div className="flex items-center gap-1.5 mt-1.5 text-destructive" id="email-error" role="alert">
            <AlertCircle className="h-3.5 w-3.5 flex-shrink-0" />
            <span className="text-body-small">{errors.email}</span>
          </div>
        )}
      </div>

      {/* Phone Field */}
      <div>
        <Label htmlFor="phone" className="text-body-small font-medium text-foreground mb-2">
          Phone Number
          <span className="text-destructive ml-0.5">*</span>
        </Label>
        <div className="relative">
          <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            id="phone"
            type="tel"
            inputMode="tel"
            value={formData.phone}
            onChange={(e) => {
              setFormData({ ...formData, phone: e.target.value });
              validateField('phone', e.target.value);
            }}
            placeholder="(555) 123-4567"
            className={cn(
              "h-10 pl-10 touch-target",
              errors.phone && "border-destructive focus:border-destructive focus:ring-destructive/20"
            )}
            aria-invalid={!!errors.phone}
            aria-describedby={errors.phone ? "phone-error" : undefined}
            aria-required
          />
        </div>
        {errors.phone && (
          <div className="flex items-center gap-1.5 mt-1.5 text-destructive" id="phone-error" role="alert">
            <AlertCircle className="h-3.5 w-3.5 flex-shrink-0" />
            <span className="text-body-small">{errors.phone}</span>
          </div>
        )}
      </div>

      {/* Submit Button */}
      <Button
        type="submit"
        size="lg"
        className="w-full touch-target"
        disabled={isSubmitting}
      >
        {isSubmitting ? 'Submitting...' : 'Continue'}
      </Button>
    </form>
  );
}
```

---

## Testing Checklist

For each form component:

- [ ] Visual appearance matches design system
- [ ] All fields have proper labels
- [ ] Error states display correctly
- [ ] Validation works (real-time and on submit)
- [ ] Touch targets are 44x44px minimum
- [ ] Tab navigation works correctly
- [ ] Enter key submits form
- [ ] Screen reader announces errors
- [ ] Mobile keyboard types are correct
- [ ] Form works on mobile devices
- [ ] Loading states are clear
- [ ] Success/error feedback is provided

---

**Status:** Documentation complete, ready for implementation  
**Priority:** High (affects core user flow)  
**Estimated Time:** 4-6 hours for all form steps  
**Dependencies:** Design system (complete), shadcn components (installed)



