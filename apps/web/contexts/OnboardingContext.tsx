'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { useMutation } from '@apollo/client';
import { ParentInfoData } from '@/components/onboarding/steps/ParentInfoStep';
import { StudentInfoData } from '@/components/onboarding/steps/StudentInfoStep';
import { analytics } from '@/lib/analytics';
import { CREATE_STUDENT, START_ONBOARDING } from '@/lib/graphql/mutations';

export interface OnboardingData {
  parentInfo?: ParentInfoData;
  studentInfo?: StudentInfoData;
  consentsAccepted?: boolean;
  aiIntakeComplete?: boolean;
  screenersComplete?: boolean;
  insuranceComplete?: boolean;
  schedulingComplete?: boolean;
  onboardingComplete?: boolean;
  sessionId?: string;
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
  sessionId: string | null;
  
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
  
  // Session management
  createSession: (studentInfoOverride?: StudentInfoData) => Promise<void>;
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
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [studentId, setStudentId] = useState<string | null>(null);
  const stepStartTime = useRef<Record<number, number>>({});
  const onboardingStartTime = useRef<number | null>(null);

  // GraphQL mutations
  const [createStudentMutation] = useMutation(CREATE_STUDENT);
  const [startOnboardingMutation] = useMutation(START_ONBOARDING);

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
        const { step, data: storedData, sessionId: storedSessionId, studentId: storedStudentId } = JSON.parse(stored);
        setCurrentStep(step);
        setData(storedData);
        if (storedSessionId) {
          setSessionId(storedSessionId);
        }
        if (storedStudentId) {
          setStudentId(storedStudentId);
        }
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
        sessionId,
        studentId,
        timestamp: now.toISOString()
      };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
      setLastSaveTime(now);
    } catch (err) {
      console.error('Failed to save progress:', err);
      throw err; // Throw to allow caller to handle
    }
  }, [currentStep, data, sessionId, studentId]);

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
    setSessionId(null);
  }, []);

  // Create a real session by calling the backend API
  const createSession = useCallback(async (studentInfoOverride?: StudentInfoData) => {
    if (sessionId) {
      return; // Session already exists
    }

    try {
      setIsLoading(true);
      setError(null);

      const studentInfoData = studentInfoOverride || data.studentInfo;

      if (studentInfoOverride) {
        updateData({ studentInfo: studentInfoOverride });
      }

      // Verify we have student info
      if (!studentInfoData) {
        throw new Error('Student information is required before creating session');
      }

      // Step 1: Create student if we don't have studentId yet
      let currentStudentId = studentId;
      
      if (!currentStudentId) {
        console.log('[OnboardingContext] Creating student with data:', {
          firstName: studentInfoData.firstName,
          lastName: studentInfoData.lastName,
          dateOfBirth: studentInfoData.dateOfBirth,
          grade: studentInfoData.grade,
          school: studentInfoData.school
        });

        try {
          const studentInput: Record<string, any> = {
            firstName: studentInfoData.firstName,
            lastName: studentInfoData.lastName,
            dateOfBirth: studentInfoData.dateOfBirth,
            language: 'en'
          };

          if (studentInfoData.grade) {
            studentInput.grade = studentInfoData.grade;
          }

          if (studentInfoData.school) {
            studentInput.school = studentInfoData.school;
          }

          const { data: studentData, errors: mutationErrors } = await createStudentMutation({
            variables: {
              input: studentInput
            }
          });

          console.log('[OnboardingContext] createStudent response:', studentData);
          console.log('[OnboardingContext] createStudent errors:', mutationErrors);

          if (mutationErrors && mutationErrors.length > 0) {
            throw new Error(`GraphQL error: ${mutationErrors[0].message}`);
          }

          if (studentData?.createStudent?.errors && studentData.createStudent.errors.length > 0) {
            throw new Error(`Student creation error: ${studentData.createStudent.errors.join(', ')}`);
          }

          if (!studentData?.createStudent?.student?.id) {
            console.error('[OnboardingContext] No student ID in response:', studentData);
            throw new Error('Failed to create student: No student ID returned');
          }

          currentStudentId = studentData.createStudent.student.id;
          setStudentId(currentStudentId);
          console.log('[OnboardingContext] ✅ Student created successfully:', currentStudentId);
        } catch (createError: any) {
          console.error('[OnboardingContext] Student creation failed:', createError);
          throw new Error(`Failed to create student: ${createError.message}`);
        }
      }

      // Step 2: Start onboarding session with the student ID
      if (!currentStudentId) {
        throw new Error('Student ID is still missing after creation attempt');
      }

      console.log('[OnboardingContext] Starting onboarding session for student:', currentStudentId);
      
      try {
        const { data: sessionData, errors: mutationErrors } = await startOnboardingMutation({
          variables: {
            input: {
              studentId: currentStudentId
            }
          }
        });

        console.log('[OnboardingContext] startOnboarding response:', sessionData);
        console.log('[OnboardingContext] startOnboarding errors:', mutationErrors);

        if (mutationErrors && mutationErrors.length > 0) {
          throw new Error(`GraphQL error: ${mutationErrors[0].message}`);
        }

        if (sessionData?.startOnboarding?.errors && sessionData.startOnboarding.errors.length > 0) {
          throw new Error(`Session creation error: ${sessionData.startOnboarding.errors.join(', ')}`);
        }

        if (!sessionData?.startOnboarding?.session?.id) {
          console.error('[OnboardingContext] No session ID in response:', sessionData);
          throw new Error('Failed to create onboarding session: No session ID returned');
        }

        const newSessionId = sessionData.startOnboarding.session.id;
        setSessionId(newSessionId);
        updateData({ sessionId: newSessionId });
        
        console.log('[OnboardingContext] ✅ Onboarding session created successfully:', newSessionId);
      } catch (sessionError: any) {
        console.error('[OnboardingContext] Session creation failed:', sessionError);
        throw new Error(`Failed to start onboarding: ${sessionError.message}`);
      }
    } catch (err: any) {
      console.error('[OnboardingContext] ❌ Failed to create session:', err);
      const errorMessage = err.message || 'Failed to create onboarding session';
      setError(errorMessage);
      
      // Show user-friendly error
      alert(`Error: ${errorMessage}\n\nPlease check that you are logged in and try again.`);
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, [sessionId, studentId, data.studentInfo, createStudentMutation, startOnboardingMutation, updateData]);

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
    sessionId,
    goToStep,
    nextStep,
    prevStep,
    updateData,
    clearProgress,
    saveProgress,
    loadProgress,
    hasSavedProgress,
    createSession
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

