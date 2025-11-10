// Analytics tracking for onboarding funnel

export interface AnalyticsEvent {
  event: string;
  properties?: Record<string, any>;
  timestamp?: Date;
}

class Analytics {
  private events: AnalyticsEvent[] = [];

  // Track onboarding step start
  trackStepStart(step: number, stepName: string) {
    this.track('onboarding_step_start', {
      step,
      step_name: stepName,
      timestamp: new Date().toISOString()
    });
  }

  // Track onboarding step complete
  trackStepComplete(step: number, stepName: string, timeSpent: number) {
    this.track('onboarding_step_complete', {
      step,
      step_name: stepName,
      time_spent_seconds: timeSpent,
      timestamp: new Date().toISOString()
    });
  }

  // Track onboarding start
  trackOnboardingStart(sessionId: string) {
    this.track('onboarding_start', {
      session_id: sessionId,
      timestamp: new Date().toISOString()
    });
  }

  // Track onboarding complete
  trackOnboardingComplete(sessionId: string, totalTime: number, stepsCompleted: number) {
    this.track('onboarding_complete', {
      session_id: sessionId,
      total_time_seconds: totalTime,
      steps_completed: stepsCompleted,
      timestamp: new Date().toISOString()
    });
  }

  // Track drop-off
  trackDropOff(step: number, stepName: string, timeSpent: number) {
    this.track('onboarding_drop_off', {
      step,
      step_name: stepName,
      time_spent_seconds: timeSpent,
      timestamp: new Date().toISOString()
    });
  }

  // Track insurance drop-off specifically
  trackInsuranceDropOff(reason?: string) {
    this.track('insurance_drop_off', {
      reason,
      timestamp: new Date().toISOString()
    });
  }

  // Track error
  trackError(step: number, errorType: string, errorMessage: string) {
    this.track('onboarding_error', {
      step,
      error_type: errorType,
      error_message: errorMessage,
      timestamp: new Date().toISOString()
    });
  }

  // Generic track method
  track(event: string, properties?: Record<string, any>) {
    const eventData: AnalyticsEvent = {
      event,
      properties,
      timestamp: new Date()
    };

    this.events.push(eventData);

    // In production, send to analytics service (e.g., Segment, Mixpanel, PostHog)
    // For now, log to console and store locally
    if (typeof window !== 'undefined') {
      console.log('[Analytics]', event, properties);
      
      // Store in localStorage for persistence
      const stored = localStorage.getItem('analytics_events');
      const events = stored ? JSON.parse(stored) : [];
      events.push(eventData);
      localStorage.setItem('analytics_events', JSON.stringify(events.slice(-100))); // Keep last 100
    }
  }

  // Get all events (for debugging/export)
  getEvents(): AnalyticsEvent[] {
    return [...this.events];
  }

  // Clear events
  clearEvents() {
    this.events = [];
    if (typeof window !== 'undefined') {
      localStorage.removeItem('analytics_events');
    }
  }

  // Export events as JSON
  exportEvents(): string {
    return JSON.stringify(this.events, null, 2);
  }
}

export const analytics = new Analytics();

