'use client';

import { useState, useEffect, useCallback } from 'react';

interface ReassuranceContext {
  stepName?: string;
  progressPercent?: number;
  timeSpent?: string;
}

interface UseReassuranceOptions {
  context: ReassuranceContext;
  triggerPoints?: string[];
}

export const useReassurance = ({ context, triggerPoints = [] }: UseReassuranceOptions) => {
  const [reassuranceMessage, setReassuranceMessage] = useState<string | null>(null);
  const [isGenerating, setIsGenerating] = useState(false);

  const generateReassurance = useCallback(async (triggerPoint: string) => {
    if (!triggerPoints.includes(triggerPoint)) return;

    setIsGenerating(true);
    try {
      // TODO: Call GraphQL query to generate reassurance
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      // Mock reassurance messages based on trigger point
      const messages: Record<string, string> = {
        'starting_onboarding': "You're taking an important step for your child's wellbeing. We're here to support you every step of the way.",
        'completing_forms': "Filling out forms can feel overwhelming, but you're doing great. Each step brings you closer to getting your child the support they need.",
        'insurance_verification': "Insurance can be confusing, but we're here to help make it as simple as possible. You've got this!",
        'scheduling': "Finding the right therapist is important, and we're here to help you find the perfect match for your child.",
        'almost_done': "You're almost there! You've made it through the entire process. We're so proud of you for taking this step."
      };

      const message = messages[triggerPoint] || "You're doing great! We're here to support you every step of the way.";
      setReassuranceMessage(message);
    } catch (error) {
      console.error('Failed to generate reassurance:', error);
    } finally {
      setIsGenerating(false);
    }
  }, [triggerPoints]);

  const clearReassurance = useCallback(() => {
    setReassuranceMessage(null);
  }, []);

  return {
    reassuranceMessage,
    isGenerating,
    generateReassurance,
    clearReassurance
  };
};

