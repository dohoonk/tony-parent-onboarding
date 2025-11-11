# Skeleton Loader Implementation Guide

**Date:** November 11, 2025  
**Purpose:** Add contextual skeleton loading states to async onboarding steps

---

## Overview

Replace generic spinners with contextual skeleton loaders that match the layout of the actual content. This provides better visual feedback during async operations.

---

## Components to Update

### 1. AIIntakeStep (`components/onboarding/steps/AIIntakeStep.tsx`)

**Loading States:**
- While processing AI intake
- While generating questions
- While analyzing responses

**Skeleton Pattern:**
```tsx
import { Skeleton } from "@/components/ui/skeleton";
import { Card } from "@/components/ui/card";

function AIIntakeSkeleton() {
  return (
    <div className="space-y-4">
      {/* Message bubbles skeleton */}
      <Card className="p-4">
        <Skeleton className="h-4 w-3/4 mb-2" />
        <Skeleton className="h-4 w-1/2" />
      </Card>
      <Card className="ml-auto p-4 w-3/4">
        <Skeleton className="h-4 w-full mb-2" />
        <Skeleton className="h-4 w-2/3" />
      </Card>
      {/* Input skeleton */}
      <Skeleton className="h-10 w-full rounded-md" />
    </div>
  );
}
```

### 2. SchedulingStep (`components/onboarding/steps/SchedulingStep.tsx`)

**Loading States:**
- While loading available therapists
- While loading time slots
- While submitting booking

**Skeleton Pattern:**
```tsx
function SchedulingSkeleton() {
  return (
    <div className="space-y-6">
      {/* Therapist cards skeleton */}
      <div className="grid gap-4 md:grid-cols-2">
        {[1, 2, 3, 4].map((i) => (
          <Card key={i} className="p-6">
            <div className="flex items-center gap-4 mb-4">
              <Skeleton className="h-12 w-12 rounded-full" />
              <div className="flex-1">
                <Skeleton className="h-5 w-32 mb-2" />
                <Skeleton className="h-4 w-24" />
              </div>
            </div>
            <Skeleton className="h-4 w-full mb-2" />
            <Skeleton className="h-4 w-3/4" />
          </Card>
        ))}
      </div>
      
      {/* Time slots skeleton */}
      <div className="grid grid-cols-3 gap-3 md:grid-cols-4">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <Skeleton key={i} className="h-10 rounded-md" />
        ))}
      </div>
    </div>
  );
}
```

### 3. InsuranceStep (`components/onboarding/steps/InsuranceStep.tsx`)

**Loading States:**
- While uploading insurance card images
- While running OCR on images
- While validating insurance information

**Skeleton Pattern:**
```tsx
function InsuranceSkeleton() {
  return (
    <div className="space-y-6">
      {/* Upload preview skeleton */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card className="p-4">
          <Skeleton className="aspect-video w-full mb-3" />
          <Skeleton className="h-4 w-32" />
        </Card>
        <Card className="p-4">
          <Skeleton className="aspect-video w-full mb-3" />
          <Skeleton className="h-4 w-32" />
        </Card>
      </div>
      
      {/* Form fields skeleton */}
      <div className="space-y-4">
        <div>
          <Skeleton className="h-4 w-24 mb-2" />
          <Skeleton className="h-10 w-full" />
        </div>
        <div>
          <Skeleton className="h-4 w-32 mb-2" />
          <Skeleton className="h-10 w-full" />
        </div>
        <div className="grid gap-4 md:grid-cols-2">
          <div>
            <Skeleton className="h-4 w-20 mb-2" />
            <Skeleton className="h-10 w-full" />
          </div>
          <div>
            <Skeleton className="h-4 w-28 mb-2" />
            <Skeleton className="h-10 w-full" />
          </div>
        </div>
      </div>
    </div>
  );
}
```

---

## Implementation Pattern

### 1. State-Based Rendering

```tsx
function YourStep() {
  const [isLoading, setIsLoading] = useState(true);
  const [data, setData] = useState(null);

  useEffect(() => {
    async function fetchData() {
      setIsLoading(true);
      try {
        const result = await yourAsyncFunction();
        setData(result);
      } finally {
        setIsLoading(false);
      }
    }
    fetchData();
  }, []);

  if (isLoading) {
    return <YourStepSkeleton />;
  }

  return <YourActualContent data={data} />;
}
```

### 2. Transition Animation

Add smooth fade-in when content loads:

```tsx
<div className={cn(
  "transition-opacity duration-300",
  isLoading ? "opacity-0" : "animate-in fade-in"
)}>
  {/* Actual content */}
</div>
```

### 3. Skeleton Component Best Practices

- **Match Layout**: Skeleton should match the actual content layout
- **Use Cards**: Wrap skeleton groups in Card components if actual content uses cards
- **Pulse Animation**: Skeleton component includes pulse by default
- **Responsive**: Use same responsive classes as actual content
- **Spacing**: Match gap/space classes between skeleton elements

---

## Common Skeleton Patterns

### Text Lines
```tsx
<Skeleton className="h-4 w-full" />      {/* Full width */}
<Skeleton className="h-4 w-3/4" />       {/* 75% width */}
<Skeleton className="h-4 w-1/2" />       {/* 50% width */}
```

### Buttons
```tsx
<Skeleton className="h-10 w-24 rounded-md" />  {/* Primary button */}
<Skeleton className="h-9 w-20 rounded-md" />   {/* Secondary button */}
```

### Images/Avatars
```tsx
<Skeleton className="h-12 w-12 rounded-full" />     {/* Avatar */}
<Skeleton className="aspect-video w-full" />         {/* 16:9 image */}
<Skeleton className="aspect-square w-full" />        {/* Square image */}
```

### Cards
```tsx
<Card className="p-6">
  <Skeleton className="h-6 w-32 mb-3" />  {/* Title */}
  <Skeleton className="h-4 w-full mb-2" /> {/* Description line 1 */}
  <Skeleton className="h-4 w-3/4" />       {/* Description line 2 */}
</Card>
```

### Forms
```tsx
<div className="space-y-4">
  <div>
    <Skeleton className="h-4 w-20 mb-2" />  {/* Label */}
    <Skeleton className="h-10 w-full" />    {/* Input */}
  </div>
  <div>
    <Skeleton className="h-4 w-24 mb-2" />  {/* Label */}
    <Skeleton className="h-10 w-full" />    {/* Input */}
  </div>
</div>
```

---

## Integration Checklist

For each async step component:

- [ ] Identify all loading states (initial load, actions, submissions)
- [ ] Create skeleton component matching actual layout
- [ ] Add loading state management
- [ ] Replace spinner with skeleton
- [ ] Add fade-in transition for actual content
- [ ] Test loading → loaded transition
- [ ] Verify responsive behavior
- [ ] Ensure accessibility (aria-busy, aria-live)

---

## Accessibility Considerations

```tsx
<div 
  aria-busy={isLoading}
  aria-live="polite"
  role="status"
>
  {isLoading ? (
    <>
      <span className="sr-only">Loading content...</span>
      <YourSkeleton />
    </>
  ) : (
    <YourContent />
  )}
</div>
```

---

## Example: Full AIIntakeStep Integration

```tsx
'use client';

import { useState, useEffect } from 'react';
import { Skeleton } from '@/components/ui/skeleton';
import { Card } from '@/components/ui/card';
import { cn } from '@/lib/utils';

function AIIntakeSkeleton() {
  return (
    <div className="space-y-4" role="status" aria-label="Loading AI intake">
      <span className="sr-only">Loading conversation...</span>
      <Card className="p-4">
        <Skeleton className="h-4 w-3/4 mb-2" />
        <Skeleton className="h-4 w-1/2" />
      </Card>
      <Card className="ml-auto p-4 w-3/4">
        <Skeleton className="h-4 w-full mb-2" />
        <Skeleton className="h-4 w-2/3" />
      </Card>
      <Skeleton className="h-10 w-full rounded-md" />
    </div>
  );
}

export function AIIntakeStep() {
  const [isLoading, setIsLoading] = useState(true);
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    async function initializeChat() {
      setIsLoading(true);
      try {
        const initialMessages = await fetchInitialMessages();
        setMessages(initialMessages);
      } finally {
        setIsLoading(false);
      }
    }
    initializeChat();
  }, []);

  if (isLoading) {
    return <AIIntakeSkeleton />;
  }

  return (
    <div className="animate-in fade-in duration-300">
      {/* Actual chat interface */}
      {messages.map((msg) => (
        <MessageBubble key={msg.id} message={msg} />
      ))}
    </div>
  );
}
```

---

## Performance Notes

- Skeleton loaders are lightweight (pure CSS animations)
- No JavaScript animation overhead
- Better perceived performance than spinners
- Users can see the structure of upcoming content
- Reduces "flash" when content loads quickly

---

## Next Steps

1. Update `AIIntakeStep.tsx` with skeleton loaders
2. Update `SchedulingStep.tsx` with skeleton loaders
3. Update `InsuranceStep.tsx` with skeleton loaders
4. Test all loading states
5. Verify smooth transitions
6. Check accessibility with screen readers
7. Test on mobile devices

---

**Status:** Documentation complete, ready for implementation  
**Priority:** Medium (improves UX but not blocking)  
**Estimated Time:** 2-3 hours for all three steps

