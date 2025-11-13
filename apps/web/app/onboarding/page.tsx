'use client';

import React, { useMemo, useState, useCallback } from 'react';
import { useMutation } from '@apollo/client';
import { OnboardingProvider, useOnboarding } from '@/contexts/OnboardingContext';
import { LemonadeLayout } from '@/components/onboarding/lemonade/LemonadeLayout';
import { QuestionRenderer } from '@/components/onboarding/lemonade/QuestionRenderer';
import { CHAPTERS, ChapterConfig, QuestionConfig } from '@/flows/onboarding/chapters';
import type { StudentInfoData } from '@/components/onboarding/steps/StudentInfoStep';
import { SIGNUP, UPLOAD_INSURANCE_CARD } from '@/lib/graphql/mutations';

type AnswerMap = Record<string, any>;

const PERSONA_NAME = 'Daybreak Coach';

type FileValue = {
  file?: File;
  base64?: string;
  name?: string;
};

const fileToBase64 = (file: File): Promise<string> =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result;
      if (typeof result === 'string') {
        resolve(result);
      } else {
        reject(new Error('Failed to read file'));
      }
    };
    reader.onerror = (event) => {
      reject(event instanceof Error ? event : new Error('Failed to read file'));
    };
    reader.readAsDataURL(file);
  });

const normalizeFileValue = async (input: any): Promise<FileValue> => {
  if (!input) {
    return {};
  }

  if (input.base64 && input.name) {
    return {
      file: input.file,
      base64: input.base64,
      name: input.name,
    };
  }

  if (input instanceof File) {
    return {
      file: input,
      base64: await fileToBase64(input),
      name: input.name,
    };
  }

  if (input.file instanceof File) {
    return {
      file: input.file,
      base64: input.base64 ?? (await fileToBase64(input.file)),
      name: input.name ?? input.file.name,
    };
  }

  if (typeof input === 'object' && input !== null && input.name) {
    return {
      base64: input.base64,
      name: input.name,
    };
  }

  return {};
};

const buildInitialAnswers = (existingAnswers: AnswerMap): AnswerMap => {
  return { ...existingAnswers };
};

const useDerivedAnswers = (data: ReturnType<typeof useOnboarding>['data']): AnswerMap => {
  const parentInfo = (data.parentInfo ?? {}) as any;
  const studentInfo = (data.studentInfo ?? {}) as any;
  const intakeResponses = (data.intakeResponses ?? {}) as any;
  const screenerResponses = (data.screenerResponses ?? {}) as any;
  const insuranceInfo = (data.insuranceInfo ?? {}) as any;
  const schedulingPreferences = (data.schedulingPreferences ?? {}) as any;

  const initial: AnswerMap = {
    'parent-first-name': parentInfo.firstName ?? '',
    'parent-last-name': parentInfo.lastName ?? '',
    'parent-email': parentInfo.email ?? '',
    'parent-password': '',
    'parent-phone': parentInfo.phone ?? '',
    'parent-dob': parentInfo.dateOfBirth ?? '',
    'parent-relationship': parentInfo.relationship ?? '',
    'parent-address': {
      street: parentInfo.street ?? '',
      city: parentInfo.city ?? '',
      state: parentInfo.state ?? '',
      postalCode: parentInfo.postalCode ?? '',
    },
    'parent-consent': data.consentsAccepted ?? false,
    'student-first-name': studentInfo.firstName ?? '',
    'student-last-name': studentInfo.lastName ?? '',
    'student-dob': studentInfo.dateOfBirth ?? '',
    'student-grade': studentInfo.grade ?? '',
    'student-school': studentInfo.school ?? '',
    'student-language': studentInfo.language ?? '',
    'goals': studentInfo.primaryGoal ?? '',
    'intake-feelings': intakeResponses.feeling ?? '',
    'screener-energy': screenerResponses.energy ?? '',
    'screener-focus': screenerResponses.focus ?? '',
    'insurance-provider': insuranceInfo.provider ?? '',
    'insurance-policy-holder': insuranceInfo.policyHolder ?? '',
    'insurance-member-id': insuranceInfo.memberId ?? '',
    'insurance-upload-front': insuranceInfo.frontImage ?? null,
    'insurance-upload-back': insuranceInfo.backImage ?? null,
    'schedule-contact-name':
      schedulingPreferences.contactName ??
      [parentInfo.firstName, parentInfo.lastName].filter(Boolean).join(' ').trim(),
    'schedule-contact-email': schedulingPreferences.contactEmail ?? parentInfo.email ?? '',
    'schedule-date': schedulingPreferences.preferredDate ?? '',
    'schedule-time-window': schedulingPreferences.preferredTime ?? '',
    'schedule-therapist-preference': schedulingPreferences.therapistPreference ?? '',
    'schedule-therapist-match': schedulingPreferences.therapistSelection ?? null,
  };

  return initial;
};

const computeChaptersProgress = (
  chapters: ChapterConfig[],
  answers: AnswerMap,
  currentChapterIndex: number,
  currentQuestionIndex: number,
) =>
  chapters.map((chapter, index) => {
    const answeredInChapter = chapter.questions.reduce((count, question, qIndex) => {
      const isBeforeCurrent =
        index < currentChapterIndex ||
        (index === currentChapterIndex && qIndex < currentQuestionIndex);
      if (!isBeforeCurrent) {
        return count;
      }
      const value = answers[question.id];
      const hasValue =
        value !== undefined &&
        value !== '' &&
        !(typeof value === 'object' && value !== null && Object.keys(value).length === 0);
      return hasValue ? count + 1 : count;
    }, 0);

    return {
      id: chapter.id,
      label: chapter.label,
      completedQuestions: answeredInChapter,
      totalQuestions: chapter.questions.length,
    };
  });

const isMeaningfulValue = (value: any): boolean => {
  if (value === null || value === undefined) return false;
  if (typeof value === 'boolean') return true;
  if (value instanceof File) return true;
  if (typeof value === 'string') return value.trim().length > 0;
  if (typeof value === 'object') return Object.keys(value).length > 0;
  return true;
};

const OnboardingContent: React.FC = () => {
  const onboarding = useOnboarding();
  const { updateData } = onboarding;

  const derivedAnswers = useDerivedAnswers(onboarding.data);
  const [answers, setAnswers] = useState<AnswerMap>(() => buildInitialAnswers(derivedAnswers));
  const [chapterIndex, setChapterIndex] = useState(0);
  const [questionIndex, setQuestionIndex] = useState(0);
  const [flowComplete, setFlowComplete] = useState(false);
  const [isAdvancing, setIsAdvancing] = useState(false);
  const [inlineError, setInlineError] = useState<string | null>(null);
  const [uploadInsuranceCard] = useMutation(UPLOAD_INSURANCE_CARD);
  const [signupMutation] = useMutation(SIGNUP);

  const activeChapter = CHAPTERS[chapterIndex];
  const activeQuestion: QuestionConfig | undefined = activeChapter?.questions[questionIndex];

  const chaptersProgress = useMemo(
    () => computeChaptersProgress(CHAPTERS, answers, chapterIndex, questionIndex),
    [answers, chapterIndex, questionIndex],
  );

  const setAnswerForQuestion = useCallback((questionId: string, value: any) => {
    setAnswers((prev) => {
      const nextAnswers = { ...prev, [questionId]: value };

      if (questionId === "account-check" && value && typeof value === "object") {
        if (value.parent) {
          nextAnswers["parent-first-name"] = value.parent.firstName ?? "";
          nextAnswers["parent-last-name"] = value.parent.lastName ?? "";
          nextAnswers["parent-email"] = value.parent.email ?? "";

          const fullName = [value.parent.firstName, value.parent.lastName].filter(Boolean).join(" ").trim();
          if (!prev["schedule-contact-name"] || prev["schedule-contact-name"].trim() === "") {
            nextAnswers["schedule-contact-name"] = fullName;
          }
          if (!prev["schedule-contact-email"] || prev["schedule-contact-email"].trim() === "") {
            nextAnswers["schedule-contact-email"] = value.parent.email ?? "";
          }
        }
      }

      if (questionId === "parent-first-name" || questionId === "parent-last-name") {
        const first = questionId === "parent-first-name" ? value : nextAnswers["parent-first-name"];
        const last = questionId === "parent-last-name" ? value : nextAnswers["parent-last-name"];
        const fullName = [first, last].filter(Boolean).join(" ").trim();
        if (!prev["schedule-contact-name"] || prev["schedule-contact-name"].trim() === "") {
          nextAnswers["schedule-contact-name"] = fullName;
        }
      }

      if (questionId === "parent-email") {
        if (!prev["schedule-contact-email"] || prev["schedule-contact-email"].trim() === "") {
          nextAnswers["schedule-contact-email"] = value ?? "";
        }
      }

      return nextAnswers;
    });
    setInlineError(null);
  }, []);

  const applyAnswerToContext = useCallback(
    (question: QuestionConfig | undefined, value: any) => {
      if (!question) {
        return;
      }

      const currentData = onboarding.data;

      if (question.id === 'parent-address') {
        if (!isMeaningfulValue(value)) return;
        updateData({
          parentInfo: {
            ...(currentData.parentInfo ?? {}),
            street: value?.street ?? '',
            city: value?.city ?? '',
            state: value?.state ?? '',
            postalCode: value?.postalCode ?? '',
          },
        });
        return;
      }

      if (!question.mapTo) {
        return;
      }

      const { section, field } = question.mapTo;
      const shouldUpdate = question.optional ? isMeaningfulValue(value) : true;
      if (!shouldUpdate) {
        return;
      }

      switch (section) {
        case 'parent':
          updateData({
            parentInfo: {
              ...(currentData.parentInfo ?? {}),
              [field]: value ?? '',
            },
          });
          break;
        case 'student':
          updateData({
            studentInfo: {
              ...(currentData.studentInfo ?? {}),
              [field]: value ?? '',
            },
          });
          break;
        case 'consent':
          updateData({ consentsAccepted: Boolean(value) });
          break;
        case 'intake':
          updateData({
            intakeResponses: {
              ...(currentData.intakeResponses ?? {}),
              [field]: value,
            },
          });
          break;
        case 'screeners':
          updateData({
            screenerResponses: {
              ...(currentData.screenerResponses ?? {}),
              [field]: value,
            },
          });
          break;
        case 'insurance':
          {
            let storedValue = value;
            if (value instanceof File) {
              storedValue = { name: value.name };
            } else if (value && typeof value === 'object') {
              const possibleFile = (value as FileValue).file;
              const possibleName = (value as FileValue).name;
              if (possibleFile instanceof File) {
                storedValue = { name: possibleName ?? possibleFile.name };
              } else if (possibleName) {
                storedValue = { name: possibleName };
              } else {
                storedValue = { name: 'Uploaded card' };
              }
            }
          updateData({
            insuranceInfo: {
              ...(currentData.insuranceInfo ?? {}),
                [field]: storedValue,
            },
          });
          }
          break;
        case 'scheduling':
          updateData({
            schedulingPreferences: {
              ...(currentData.schedulingPreferences ?? {}),
              [field]: value,
            },
          });
          break;
        default:
          break;
      }
    },
    [onboarding.data, updateData],
  );

  const handleAdvance = useCallback(async () => {
    if (!activeChapter || !activeQuestion) {
      return;
    }

    const currentValue = answers[activeQuestion.id];
    setInlineError(null);
    setIsAdvancing(true);
    try {
      let valueForContext = currentValue;

      if (activeQuestion.id === "account-check" && currentValue && typeof currentValue === "object") {
        const parentInfo = currentValue.parent;
        if (parentInfo) {
          updateData({
            parentInfo: {
              ...(onboarding.data.parentInfo ?? {}),
              firstName: parentInfo.firstName ?? "",
              lastName: parentInfo.lastName ?? "",
              email: parentInfo.email ?? "",
            },
          });
        }
      }

      if (activeQuestion.id === "parent-password") {
        const accountCheckAnswer = answers["account-check"];
        const alreadyAuthenticated =
          accountCheckAnswer?.hasAccount && accountCheckAnswer?.authenticated;

        if (!alreadyAuthenticated) {
          const email = (answers["parent-email"] ?? "").trim();
          const firstName = (answers["parent-first-name"] ?? "").trim();
          const lastName = (answers["parent-last-name"] ?? "").trim();
          const password = typeof currentValue === "string" ? currentValue : "";

          if (!password) {
            setInlineError("Please create a password so we can secure your account.");
            return;
          }

          if (password.length < 8) {
            setInlineError("Your password needs to be at least 8 characters.");
            return;
          }

          if (!email) {
            setInlineError("We need an email address to finish creating your account.");
            return;
          }

          try {
            const { data, errors } = await signupMutation({
              variables: {
                email,
                password,
                firstName,
                lastName,
              },
            });

            if (errors?.length) {
              throw new Error(errors[0].message);
            }

            const signupErrors = data?.signup?.errors ?? [];
            if (signupErrors.length > 0) {
              setInlineError(signupErrors.join(", "));
              return;
            }

            const token = data?.signup?.token ?? null;
            const parent = data?.signup?.parent ?? null;

            if (token) {
              localStorage.setItem("auth_token", token);
            }

            setAnswers((prev) => ({
              ...prev,
              "account-check": {
                hasAccount: true,
                authenticated: true,
                parent: {
                  firstName: parent?.firstName ?? firstName,
                  lastName: parent?.lastName ?? lastName,
                  email: parent?.email ?? email,
                },
                email: parent?.email ?? email,
              },
              "parent-password": "",
            }));

            updateData({
              parentInfo: {
                ...(onboarding.data.parentInfo ?? {}),
                firstName: parent?.firstName ?? firstName,
                lastName: parent?.lastName ?? lastName,
                email: parent?.email ?? email,
              },
            });

            valueForContext = "";
          } catch (signupError: any) {
            console.error(signupError);
            setInlineError(
              signupError?.message ?? "We couldn’t create your account. Please try again or use a different email.",
            );
            return;
          }
        }
      }

      if (activeChapter.id === 'insurance' && activeQuestion.type === 'upload') {
        const sessionId = onboarding.sessionId;
        if (!sessionId) {
          throw new Error('We need to create your secure session before verifying insurance. Please go back and try again.');
        }

        const frontData = await normalizeFileValue(
          activeQuestion.id === 'insurance-upload-front' ? currentValue : answers['insurance-upload-front'],
        );

        if (!frontData.base64) {
          throw new Error('Please upload the front of your insurance card before continuing.');
        }

        const backData = await normalizeFileValue(
          activeQuestion.id === 'insurance-upload-back' ? currentValue : answers['insurance-upload-back'],
        );

        const { data, errors } = await uploadInsuranceCard({
          variables: {
            input: {
              sessionId,
              frontImageUrl: frontData.base64,
              backImageUrl: backData.base64 ?? null,
            },
          },
        });

        if (errors?.length) {
          throw new Error(errors[0].message);
        }

        const mutationErrors = data?.uploadInsuranceCard?.errors ?? [];
        if (mutationErrors.length) {
          const combinedMessage = mutationErrors.join(', ');
          if (mutationErrors.includes('Session not found')) {
            setInlineError(
              "We’re still creating your secure session. Please wait a moment, then refresh this step or try again.",
            );
            return;
          }
          throw new Error(combinedMessage);
        }

        const extracted = data?.uploadInsuranceCard?.insuranceCard?.extractedData ?? {};
        const provider =
          extracted?.payer_name?.value ??
          extracted?.insurance_company_name?.value ??
          '';
        const memberId = extracted?.member_id?.value ?? '';
        const subscriberRaw = extracted?.subscriber_name?.value;
        const subscriberNames = [
          extracted?.plan_holder_first_name?.value,
          extracted?.plan_holder_last_name?.value,
        ].filter(Boolean);
        const subscriber =
          subscriberRaw ??
          (subscriberNames.length > 0 ? subscriberNames.join(' ') : '');

        setAnswers((prev) => ({
          ...prev,
          'insurance-upload-front': frontData.base64
            ? { file: frontData.file, base64: frontData.base64, name: frontData.name }
            : prev['insurance-upload-front'],
          ...(backData.base64
            ? {
                'insurance-upload-back': {
                  file: backData.file,
                  base64: backData.base64,
                  name: backData.name,
                },
              }
            : {}),
          ...(provider ? { 'insurance-provider': provider } : {}),
          ...(memberId ? { 'insurance-member-id': memberId } : {}),
          ...(subscriber ? { 'insurance-policy-holder': subscriber } : {}),
        }));

        updateData({
          insuranceInfo: {
            ...(onboarding.data.insuranceInfo ?? {}),
            ...(provider ? { provider } : {}),
            ...(memberId ? { memberId } : {}),
            ...(subscriber ? { policyHolder: subscriber } : {}),
          },
        });

        if (!provider && !memberId && !subscriber) {
          setInlineError('We couldn’t read every detail—double-check the next fields before you continue.');
        }

        if (activeQuestion.id === 'insurance-upload-back') {
          valueForContext = backData.base64
            ? { name: backData.name ?? backData.file?.name ?? '' }
            : undefined;
        } else {
          valueForContext = { name: frontData.name ?? frontData.file?.name ?? '' };
        }
      }

      applyAnswerToContext(activeQuestion, valueForContext);

      const isLastInChapter = questionIndex === activeChapter.questions.length - 1;

      if (isLastInChapter && activeChapter.id === 'student') {
        const studentForSession: StudentInfoData = {
          firstName: answers['student-first-name'] ?? '',
          lastName: answers['student-last-name'] ?? '',
          dateOfBirth: answers['student-dob'] ?? '',
          grade: answers['student-grade'] ?? '',
          school: answers['student-school'] ?? '',
        };
        await onboarding.createSession(studentForSession);
      }

      if (isLastInChapter) {
        switch (activeChapter.id) {
          case 'intake':
            updateData({ aiIntakeComplete: true });
            break;
          case 'screeners':
            updateData({ screenersComplete: true });
            break;
          case 'insurance':
            updateData({ insuranceComplete: true });
            break;
          case 'scheduling':
            updateData({ schedulingComplete: true });
            break;
          case 'finish':
            updateData({ onboardingComplete: true });
            break;
          default:
            break;
        }
      }

      if (!isLastInChapter) {
        setQuestionIndex((prev) => prev + 1);
      } else if (chapterIndex < CHAPTERS.length - 1) {
        setChapterIndex((prev) => prev + 1);
        setQuestionIndex(0);
      } else {
        setFlowComplete(true);
      }
    } catch (error: any) {
      console.error(error);
      setInlineError(error.message ?? 'Something went wrong. Please try again.');
      return;
    } finally {
      setIsAdvancing(false);
    }
  }, [
    activeChapter,
    activeQuestion,
    answers,
    applyAnswerToContext,
    chapterIndex,
    onboarding,
    questionIndex,
    updateData,
    uploadInsuranceCard,
    signupMutation,
  ]);

  const handleSkip = useCallback(async () => {
    await handleAdvance();
  }, [handleAdvance]);

  const handleStepSelect = useCallback(
    (stepId: string) => {
      if (isAdvancing) return;
      const stepToChapters: Record<string, string[]> = {
        you: ["you"],
        child: ["student"],
        assessment: ["intake", "screeners"],
        insurance: ["insurance"],
        schedule: ["scheduling", "finish"],
      };

      const targetChapters = stepToChapters[stepId];
      if (!targetChapters || targetChapters.length === 0) {
        return;
      }

      const nextChapterId = targetChapters.find((chapterId) =>
        CHAPTERS.some((chapter) => chapter.id === chapterId),
      );

      if (!nextChapterId) {
        return;
      }

      const targetChapterIndex = CHAPTERS.findIndex((chapter) => chapter.id === nextChapterId);
      if (targetChapterIndex === -1) {
        return;
      }

      setChapterIndex(targetChapterIndex);
      setQuestionIndex(0);
      setFlowComplete(false);
      setInlineError(null);
    },
    [isAdvancing],
  );

  return (
    <LemonadeLayout
      personaName={PERSONA_NAME}
      personaTitle={activeChapter?.personaTitle}
      chapters={chaptersProgress}
      activeChapterId={activeChapter?.id ?? 'complete'}
      activeQuestionId={activeQuestion?.id}
      onStepSelect={handleStepSelect}
    >
      {flowComplete ? (
        <div className="flex flex-col items-center gap-6 text-center">
          <h2 className="text-3xl font-semibold">You’re officially in!</h2>
          <p className="max-w-md text-muted-foreground">
            We’re matching you with the right clinician and double-checking insurance. Keep an eye on
            your inbox—next steps are on their way.
          </p>
        </div>
      ) : activeQuestion ? (
        <QuestionRenderer
          question={activeQuestion}
          value={answers[activeQuestion.id]}
          onChange={(value) => setAnswerForQuestion(activeQuestion.id, value)}
          onNext={handleAdvance}
          onSkip={activeQuestion.optional ? handleSkip : undefined}
          isSubmitting={isAdvancing}
          errorMessage={inlineError}
          answers={answers}
          sessionId={onboarding.sessionId ?? onboarding.data.sessionId ?? null}
        />
      ) : (
        <div />
      )}
    </LemonadeLayout>
  );
};

export default function OnboardingPage() {
  return (
    <OnboardingProvider>
      <OnboardingContent />
    </OnboardingProvider>
  );
}

