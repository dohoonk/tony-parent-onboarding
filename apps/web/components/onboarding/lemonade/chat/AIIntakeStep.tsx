"use client";

import React, { useEffect, useState } from "react";
import { AIChatPanel } from "@/components/onboarding/steps/AIChatPanel";
import { ChatMessage } from "@/components/onboarding/steps/AIIntakeChat";
import { IntakeSummaryReview } from "@/components/onboarding/steps/IntakeSummaryReview";
import { Button } from "@/components/ui/button";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { cn } from "@/lib/utils";

type ConversationSummary = {
  concerns: string[];
  goals: string[];
  riskFlags: string[];
  summaryText: string;
  transcript: ChatMessage[];
};

interface AIIntakeStepProps {
  onComplete: (summary: ConversationSummary) => void | Promise<void>;
  onExit?: () => void | Promise<void>;
  className?: string;
  tone?: "default" | "supportive";
}

const INITIAL_MESSAGE: ChatMessage = {
  id: "welcome",
  role: "assistant",
  content:
    "Hi! I'm here to help you share what's going on. Everything you tell me stays private with the care team. What made you decide to reach out today?",
  timestamp: new Date(),
};

const buildSummaryFromTranscript = (messages: ChatMessage[]): ConversationSummary => {
  const userMessages = messages.filter((msg) => msg.role === "user");
  const combined = userMessages.map((msg) => msg.content).join(" ").toLowerCase();

  const concerns: string[] = [];
  if (combined.includes("anxiety") || combined.includes("worry")) concerns.push("Anxiety / worry");
  if (combined.includes("sad") || combined.includes("depress")) concerns.push("Sadness / low mood");
  if (combined.includes("school") || combined.includes("grade")) concerns.push("School challenges");
  if (combined.includes("friend") || combined.includes("social")) concerns.push("Friendship / social concerns");
  if (concerns.length === 0) concerns.push("Mental health support");

  const goals: string[] = [];
  if (combined.includes("cope") || combined.includes("help")) goals.push("Build coping skills");
  if (combined.includes("confident") || combined.includes("happy")) goals.push("Improve confidence / happiness");
  if (combined.includes("focus") || combined.includes("calm")) goals.push("Improve focus / regulation");
  if (goals.length === 0) goals.push("Get the right support");

  return {
    concerns,
    goals,
    riskFlags: [],
    summaryText: `Family shared about ${concerns.join(" and ").toLowerCase()}. They’re hoping for ${goals
      .join(" and ")
      .toLowerCase()}.`,
    transcript: messages,
  };
};
export const AIIntakeStep: React.FC<AIIntakeStepProps> = ({ onComplete, onExit, className, tone = "supportive" }) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [isStreaming, setIsStreaming] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [conversationDone, setConversationDone] = useState(false);
  const [showSummary, setShowSummary] = useState(false);
  const [cachedSummary, setCachedSummary] = useState<ConversationSummary | null>(null);

  useEffect(() => {
    if (messages.length === 0) {
      setMessages([INITIAL_MESSAGE]);
    }
  }, [messages.length]);

  const appendMessage = (message: ChatMessage) => setMessages((prev) => [...prev, message]);

  const simulateAssistantResponse = async (userMessage: string) => {
    setIsStreaming(true);

    const lower = userMessage.toLowerCase();
    let reply =
      "Thank you for sharing that. Can you tell me more about when you first started noticing these changes and how they're affecting day-to-day life?";

    if (lower.includes("ready") || lower.includes("done") || lower.includes("finish")) {
      reply =
        "Thanks for opening up. I think I have enough for now. If you'd like to continue, just type more, otherwise let me know when you're ready to wrap up.";
      setConversationDone(true);
    } else if (lower.includes("school")) {
      reply =
        "School stuff can be really tough. Are there particular classes or situations that seem harder than others?";
    } else if (lower.includes("friend")) {
      reply = "It sounds like friendships are on your mind. How are social situations feeling these days?";
    } else if (lower.includes("anxiety") || lower.includes("worry")) {
      reply = "Feeling anxious can be exhausting. When do you notice it the most?";
    }

    await new Promise((resolve) => setTimeout(resolve, 600));

    appendMessage({
      id: `assistant-${Date.now()}`,
      role: "assistant",
      content: reply,
      timestamp: new Date(),
    });
    setIsStreaming(false);
  };

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = input.trim();
    if (!trimmed) return;

    setError(null);
    appendMessage({
      id: `user-${Date.now()}`,
      role: "user",
      content: trimmed,
      timestamp: new Date(),
    });
    setInput("");

    try {
      await simulateAssistantResponse(trimmed);
    } catch (err: any) {
      console.error(err);
      setError(err.message ?? "Sorry, something went wrong.");
      setIsStreaming(false);
    }
  };

  const handleComplete = async () => {
    const summary = buildSummaryFromTranscript(messages);
    setCachedSummary(summary);
    setShowSummary(true);
  };

  if (showSummary && cachedSummary) {
    return (
      <IntakeSummaryReview
        summary={{
          concerns: cachedSummary.concerns,
          goals: cachedSummary.goals,
          risk_flags: cachedSummary.riskFlags,
          summary_text: cachedSummary.summaryText,
        }}
        onEdit={() => setShowSummary(false)}
        onContinue={async () => {
          await onComplete(cachedSummary);
        }}
      />
    );
  }

  return (
    <div className={cn("space-y-6", className)}>
      <div className="rounded-md border bg-muted/40 p-4">
        <p className="text-sm text-muted-foreground">
          Share whatever feels most important. When you’re ready to wrap up, just type “ready” or click Continue.
        </p>
      </div>

      <AIChatPanel
        messages={messages}
        input={input}
        setInput={setInput}
        isLoading={isStreaming}
        isStreaming={isStreaming}
        error={error}
        onSend={handleSend}
      />

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        {onExit ? (
          <Button variant="outline" onClick={() => void onExit()} className="w-full sm:w-auto">
            Back
          </Button>
        ) : (
          <div />
        )}
        <div className="flex w-full flex-col gap-2 sm:w-auto sm:flex-row">
          <Button
            variant="outline"
            onClick={handleComplete}
            disabled={messages.filter((msg) => msg.role === "user").length === 0}
            className="w-full sm:w-auto"
          >
            Skip & Summarize
          </Button>
          <Button onClick={handleComplete} disabled={isStreaming} className="w-full sm:w-auto">
            {conversationDone ? "Continue" : "Continue"}
          </Button>
        </div>
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertTitle>Something went wrong</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}
    </div>
  );
};


