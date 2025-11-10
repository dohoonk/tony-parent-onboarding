'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { ParentInfoData } from '@/components/onboarding/steps/ParentInfoStep';
import { StudentInfoData } from '@/components/onboarding/steps/StudentInfoStep';
import { analytics } from '@/lib/analytics';

export interface OnboardingData {
  parentInfo?: ParentInfoData;
  studentInfo?: StudentInfoData;
  consentsAccepted?: boolean;
  aiIntakeComplete?: boolean;
  screenersComplete?: boolean;
  insuranceComplete?: boolean;
  schedulingComplete?: boolean;
  onboardingComplete?: boolean;
}

export interface Step {
  id: number;
  title: string;
  description?: string;
  estimatedSeconds: number;
}

interface OnboardingContextValue {
  currentStep: number;
  totalSteps: number;
  steps: Step[];
  data: OnboardingData;
  estimatedSecondsRemaining: number;
  isLoading: boolean;
  error: string | null;
  lastSaveTime: Date | null;
  
  // Navigation
  goToStep: (step: number) => void;
  nextStep: () => void;
  prevStep: () => void;
  
  // Data management
  updateData: (updates: Partial<OnboardingData>) => void;
  clearProgress: () => void;
  
  // Persistence
  saveProgress: () => Promise<void>;
  loadProgress: () => Promise<void>;
  hasSavedProgress: () => boolean;
}

const OnboardingContext = createContext<OnboardingContextValue | undefined>(undefined);

const STEPS: Step[] = [
  { id: 1, title: 'Welcome', description: 'Get started', estimatedSeconds: 60 },
  { id: 2, title: 'Parent Info', description: 'Your information', estimatedSeconds: 120 },
  { id: 3, title: 'Student Info', description: 'About your child', estimatedSeconds: 120 },
  { id: 4, title: 'Consent', description: 'Review and accept', estimatedSeconds: 180 },
  { id: 5, title: 'AI Intake', description: 'Tell us your story', estimatedSeconds: 300 },
  { id: 6, title: 'Screeners', description: 'Quick assessment', estimatedSeconds: 180 },
  { id: 7, title: 'Insurance', description: 'Coverage information', estimatedSeconds: 120 },
  { id: 8, title: 'Scheduling', description: 'Book first session', estimatedSeconds: 120 },
  { id: 9, title: 'Summary', description: 'Review and complete', estimatedSeconds: 60 }
];

const STORAGE_KEY = 'daybreak-onboarding-progress';

export const OnboardingProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentStep, setCurrentStep] = useState(1);
  const [data, setData] = useState<OnboardingData>({});
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastSaveTime, setLastSaveTime] = useState<Date | null>(null);
  const stepStartTime = useRef<Record<number, number>>({});
  const onboardingStartTime = useRef<number | null>(null);

  // Calculate remaining time based on current step
  const estimatedSecondsRemaining = STEPS
    .filter((step) => step.id >= currentStep)
    .reduce((sum, step) => sum + step.estimatedSeconds, 0);

  // Load progress from localStorage on mount
  useEffect(() => {
    loadProgress();
    // Track onboarding start
    onboardingStartTime.current = Date.now();
    analytics.trackOnboardingStart('session_' + Date.now());
  }, []);

  // Track step changes
  useEffect(() => {
    const step = STEPS.find(s => s.id === currentStep);
    if (step) {
      // Track step start
      stepStartTime.current[currentStep] = Date.now();
      analytics.trackStepStart(currentStep, step.title);
    }
  }, [currentStep]);

  // Auto-save progress whenever data changes
  useEffect(() => {
    if (Object.keys(data).length > 0) {
      saveProgress();
    }
  }, [data, currentStep]);

  const loadProgress = useCallback(async () => {
    try {
      setIsLoading(true);
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        const { step, data: storedData } = JSON.parse(stored);
        setCurrentStep(step);
        setData(storedData);
      }
    } catch (err) {
      console.error('Failed to load progress:', err);
      setError('Failed to load saved progress');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const saveProgress = useCallback(async () => {
    try {
      const now = new Date();
      const progress = {
        step: currentStep,
        data,
        timestamp: now.toISOString()
      };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
      setLastSaveTime(now);
    } catch (err) {
      console.error('Failed to save progress:', err);
      throw err; // Throw to allow caller to handle
    }
  }, [currentStep, data]);

  const goToStep = useCallback((step: number) => {
    if (step >= 1 && step <= STEPS.length) {
      setCurrentStep(step);
    }
  }, []);

  const nextStep = useCallback(() => {
    if (currentStep < STEPS.length) {
      // Track step completion
      const step = STEPS.find(s => s.id === currentStep);
      if (step && stepStartTime.current[currentStep]) {
        const timeSpent = (Date.now() - stepStartTime.current[currentStep]) / 1000;
        analytics.trackStepComplete(currentStep, step.title, timeSpent);
      }
      
      setCurrentStep((prev) => {
        const next = prev + 1;
        
        // Track onboarding completion if this is the last step
        if (next > STEPS.length && onboardingStartTime.current) {
          const totalTime = (Date.now() - onboardingStartTime.current) / 1000;
          analytics.trackOnboardingComplete('session_' + Date.now(), totalTime, STEPS.length);
        }
        
        return next;
      });
    }
  }, [currentStep]);

  const prevStep = useCallback(() => {
    if (currentStep > 1) {
      setCurrentStep((prev) => prev - 1);
    }
  }, [currentStep]);

  const updateData = useCallback((updates: Partial<OnboardingData>) => {
    setData((prev) => ({ ...prev, ...updates }));
  }, []);

  const clearProgress = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
    setCurrentStep(1);
    setData({});
    setLastSaveTime(null);
  }, []);

  const hasSavedProgress = useCallback((): boolean => {
    return localStorage.getItem(STORAGE_KEY) !== null;
  }, []);

  const value: OnboardingContextValue = {
    currentStep,
    totalSteps: STEPS.length,
    steps: STEPS,
    data,
    estimatedSecondsRemaining,
    isLoading,
    error,
    lastSaveTime,
    goToStep,
    nextStep,
    prevStep,
    updateData,
    clearProgress,
    saveProgress,
    loadProgress,
    hasSavedProgress
  };

  return <OnboardingContext.Provider value={value}>{children}</OnboardingContext.Provider>;
};

export const useOnboarding = (): OnboardingContextValue => {
  const context = useContext(OnboardingContext);
  if (!context) {
    throw new Error('useOnboarding must be used within OnboardingProvider');
  }
  return context;
};

