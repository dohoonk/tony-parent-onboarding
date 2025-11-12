"use client";

import { ChangeEvent, FormEvent, useEffect, useState } from "react";
import { useMutation } from "@apollo/client";
import { Loader2 } from "lucide-react";

import { QuestionConfig } from "@/flows/onboarding/chapters";
import { LEMONADE_PRIMARY_BUTTON_CLASSES, QuestionFrame } from "./QuestionFrame";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { LOGIN } from "@/lib/graphql/mutations";

type AccountCheckValue = {
  hasAccount: boolean | null;
  authenticated?: boolean;
  parent?: {
    firstName?: string | null;
    lastName?: string | null;
    email?: string | null;
  };
  email?: string;
};

interface AccountCheckQuestionProps {
  question: QuestionConfig;
  value?: AccountCheckValue;
  onChange: (value: AccountCheckValue) => void;
  onContinue: () => Promise<void> | void;
  isSubmitting?: boolean;
  externalError?: string | null;
}

const selectionFromValue = (value?: AccountCheckValue): "yes" | "no" | null => {
  if (!value || value.hasAccount === null || value.hasAccount === undefined) {
    return null;
  }
  return value.hasAccount ? "yes" : "no";
};

export function AccountCheckQuestion({
  question,
  value,
  onChange,
  onContinue,
  isSubmitting,
  externalError,
}: AccountCheckQuestionProps) {
  const [selection, setSelection] = useState<"yes" | "no" | null>(selectionFromValue(value));
  const [email, setEmail] = useState<string>(value?.parent?.email ?? value?.email ?? "");
  const [password, setPassword] = useState<string>("");
  const [localError, setLocalError] = useState<string | null>(null);

  const [login, { loading: loginLoading }] = useMutation(LOGIN);

  useEffect(() => {
    setSelection(selectionFromValue(value));
    if (value?.parent?.email) {
      setEmail(value.parent.email);
    } else if (value?.email) {
      setEmail(value.email);
    }
  }, [value]);

  const handleSelect = (choice: "yes" | "no") => {
    if (selection === choice) return;
    setSelection(choice);
    setLocalError(null);
    setPassword("");

    if (choice === "yes") {
      const nextEmail = value?.parent?.email ?? value?.email ?? email ?? "";
      setEmail(nextEmail);
      onChange({
        hasAccount: true,
        authenticated: value?.authenticated ?? false,
        parent: value?.parent,
        email: nextEmail,
      });
    } else {
      setEmail("");
      onChange({
        hasAccount: false,
        authenticated: false,
      });
    }
  };

  const handleEmailChange = (event: ChangeEvent<HTMLInputElement>) => {
    const nextEmail = event.target.value;
    setEmail(nextEmail);
    setLocalError(null);

    if (selection === "yes") {
      onChange({
        hasAccount: true,
        authenticated: value?.authenticated ?? false,
        parent: value?.parent,
        email: nextEmail,
      });
    }
  };

  const handlePasswordChange = (event: ChangeEvent<HTMLInputElement>) => {
    setPassword(event.target.value);
    setLocalError(null);
  };

  const handleLogin = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!email || !password) {
      setLocalError("Please enter both your email and password.");
      return;
    }

    setLocalError(null);
    try {
      const { data } = await login({
        variables: {
          email,
          password,
        },
      });

      const loginErrors = data?.login?.errors ?? [];
      if (loginErrors.length > 0) {
        setLocalError(loginErrors.join(", "));
        return;
      }

      const token = data?.login?.token ?? null;
      const parent = data?.login?.parent ?? null;

      if (!token || !parent) {
        setLocalError("We couldn’t log you in. Please double-check your details and try again.");
        return;
      }

      localStorage.setItem("auth_token", token);

      const nextValue: AccountCheckValue = {
        hasAccount: true,
        authenticated: true,
        parent: {
          firstName: parent.firstName ?? "",
          lastName: parent.lastName ?? "",
          email: parent.email ?? email,
        },
        email,
      };

      onChange(nextValue);
      await Promise.resolve(onContinue());
    } catch (error: any) {
      setLocalError(error?.message ?? "Something went wrong while signing in. Please try again.");
    }
  };

  const handleContinueWithoutAccount = () => {
    setLocalError(null);
    onChange({
      hasAccount: false,
      authenticated: false,
    });
    void Promise.resolve(onContinue());
  };

  const displayError = localError ?? externalError ?? null;
  const disableControls = Boolean(isSubmitting) || loginLoading;

  return (
    <QuestionFrame
      title={question.prompt}
      description={question.helperText}
      errorMessage={displayError}
      primaryAction={
        selection === "no"
          ? {
              label: question.ctaLabel ?? "Continue",
              onClick: handleContinueWithoutAccount,
              disabled: disableControls,
              loading: Boolean(isSubmitting),
            }
          : undefined
      }
    >
      <div className="flex flex-col gap-6">
        <div className="grid gap-3 sm:grid-cols-2">
          <Button
            type="button"
            onClick={() => handleSelect("yes")}
            variant="outline"
            className={cn(
              "h-14 justify-center rounded-full px-7 text-base font-semibold transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:ring-offset-2",
              selection === "yes"
                ? "bg-primary text-primary-foreground shadow-lg shadow-primary/30 hover:-translate-y-0.5 hover:shadow-xl"
                : "border border-primary/10 bg-white text-foreground hover:border-primary/40 hover:bg-primary/5",
              disableControls && "pointer-events-none opacity-60",
            )}
            disabled={disableControls}
          >
            Yes, I already have an account
          </Button>
          <Button
            type="button"
            onClick={() => handleSelect("no")}
            variant="outline"
            className={cn(
              "h-14 justify-center rounded-full px-7 text-base font-semibold transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:ring-offset-2",
              selection === "no"
                ? "bg-primary text-primary-foreground shadow-lg shadow-primary/30 hover:-translate-y-0.5 hover:shadow-xl"
                : "border border-primary/10 bg-white text-foreground hover:border-primary/40 hover:bg-primary/5",
              disableControls && "pointer-events-none opacity-60",
            )}
            disabled={disableControls}
          >
            No, I'm new here
          </Button>
        </div>

        {selection === "yes" && (
          <form
            onSubmit={handleLogin}
            className="space-y-4 rounded-3xl border border-muted/60 bg-muted/40 p-6 shadow-sm"
          >
            <div className="space-y-2">
              <Label htmlFor="account-check-email">Email address</Label>
              <Input
                id="account-check-email"
                type="email"
                value={email}
                onChange={handleEmailChange}
                placeholder="you@example.com"
                autoComplete="email"
                disabled={disableControls}
                className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="account-check-password">Password</Label>
              <Input
                id="account-check-password"
                type="password"
                value={password}
                onChange={handlePasswordChange}
                placeholder="••••••••"
                autoComplete="current-password"
                disabled={disableControls}
                className="h-12 rounded-2xl border-2 border-muted bg-white text-base"
              />
              <p className="text-xs text-muted-foreground">
                We’ll log you in securely so you can pick up where you left off.
              </p>
            </div>
            <Button
              type="submit"
              size="lg"
              className={cn(LEMONADE_PRIMARY_BUTTON_CLASSES, "w-full justify-center")}
              disabled={disableControls}
            >
              {loginLoading ? (
                <>
                  <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                  Signing in…
                </>
              ) : (
                "Sign in and continue"
              )}
            </Button>
          </form>
        )}
      </div>
    </QuestionFrame>
  );
}


