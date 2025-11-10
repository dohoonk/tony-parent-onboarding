# Manual Testing Guide - Parent Onboarding AI

This guide provides step-by-step instructions for manually testing the complete onboarding flow.

## Prerequisites

### 1. Environment Setup

**Backend (Rails API):**
```bash
cd apps/api
bundle install
rails db:create db:migrate
rails credentials:edit  # Add OpenAI API key, AWS credentials
rails server  # Runs on http://localhost:3000
```

**Frontend (Next.js):**
```bash
cd apps/web
npm install
npm run dev  # Runs on http://localhost:3001
```

**Required Services:**
- PostgreSQL (running locally or via Docker)
- Redis (for Sidekiq)
- Sidekiq worker: `bundle exec sidekiq` (in apps/api)

**Environment Variables:**
- `OPENAI_API_KEY` - For AI features
- AWS credentials for S3 uploads
- Database connection strings

### 2. Test Data Setup

You can use Rails console to create test data:
```bash
cd apps/api
rails console

# Create a test parent
parent = Parent.create!(
  email: 'test@example.com',
  first_name: 'Test',
  last_name: 'Parent',
  phone: '+1234567890',
  auth_provider: 'magic_link'
)

# Create a test screener
Screener.create!(
  key: 'phq_a',
  name: 'PHQ-A',
  items_json: [
    { id: 1, text: 'Feeling down or hopeless', type: 'scale', options: [0, 1, 2, 3] }
  ]
)
```

## Complete Flow Testing

### Step 1: Welcome Screen

**URL:** `http://localhost:3001/onboarding`

**What to Test:**
- [ ] Page loads correctly
- [ ] Progress bar shows "Step 1 of 9"
- [ ] ETA display is visible
- [ ] Welcome message is clear and reassuring
- [ ] "Get Started" button works
- [ ] Reassurance banner appears (if implemented)
- [ ] Inline FAQ button is visible (bottom right)
- [ ] Support chat button is visible (bottom right)

**Expected Behavior:**
- Clicking "Get Started" advances to Step 2
- Analytics event is tracked (check browser console)

---

### Step 2: Parent Information

**What to Test:**
- [ ] All required fields are marked
- [ ] Email validation works (try invalid emails)
- [ ] Phone number formatting (if implemented)
- [ ] Form validation prevents submission with empty fields
- [ ] "Back" button returns to Step 1
- [ ] "Continue" button advances to Step 3
- [ ] Progress updates to "Step 2 of 9"
- [ ] Data persists when navigating back/forward

**Test Cases:**
- Valid email: `parent@example.com`
- Invalid email: `notanemail` (should show error)
- Phone: `+1-555-123-4567`
- Required fields: First name, Last name, Email

---

### Step 3: Student Information

**What to Test:**
- [ ] Student name fields
- [ ] Date of birth picker works
- [ ] Grade selection (if applicable)
- [ ] Form validation
- [ ] Navigation (Back/Continue)
- [ ] Progress updates

**Test Cases:**
- Valid DOB: `2010-05-15`
- Future date: Should show validation error
- Required fields validation

---

### Step 4: Consent

**What to Test:**
- [ ] Consent checkboxes are present
- [ ] Cannot proceed without checking required consents
- [ ] Consent text is readable
- [ ] "I understand" checkbox works
- [ ] Navigation works

**Test Cases:**
- Try to continue without checking boxes (should fail)
- Check all boxes and continue (should succeed)

---

### Step 5: AI-Powered Conversational Intake

**What to Test:**
- [ ] Chat interface loads
- [ ] Initial AI greeting appears
- [ ] Can type and send messages
- [ ] AI responses stream in real-time (typing indicator)
- [ ] Messages appear in chat history
- [ ] AI tone is warm and supportive
- [ ] Can send multiple messages
- [ ] Conversation persists when navigating away/back

**Test Messages to Try:**
```
"I'm worried about my child's anxiety"
"My daughter has been struggling at school"
"She seems sad lately"
```

**Expected Behavior:**
- AI responds in "Reassuring Parenting Coach" tone
- Responses are 1-3 sentences (concise)
- No clinical jargon
- Supportive and validating

**Check Backend:**
```bash
rails console
session = OnboardingSession.last
session.intake_messages  # Should show conversation
```

---

### Step 6: Clinical Screener

**What to Test:**
- [ ] Screener questions load
- [ ] Radio buttons/scale inputs work
- [ ] Can select answers for all questions
- [ ] "Submit" button works
- [ ] AI interpretation appears after submission
- [ ] Interpretation is in plain language
- [ ] Severity level is displayed
- [ ] Can proceed to next step

**Test Cases:**
- Answer all questions with different values
- Submit and verify interpretation appears
- Check that interpretation is supportive (not clinical)

**Check Backend:**
```bash
rails console
response = ScreenerResponse.last
response.interpretation_text  # Should have AI-generated interpretation
```

---

### Step 7: Insurance Card Upload

**What to Test:**
- [ ] Upload buttons for front/back images
- [ ] File picker opens correctly
- [ ] Can select image files
- [ ] Upload progress indicator
- [ ] OCR extraction runs automatically
- [ ] Extracted fields display with confidence badges
- [ ] High confidence fields are pre-filled
- [ ] Medium/low confidence fields require confirmation
- [ ] Can edit extracted fields
- [ ] Manual entry form works (if OCR fails)
- [ ] Field-level help tooltips appear
- [ ] Can confirm and proceed

**Test Images:**
- Use a sample insurance card image (front and back)
- Try with blurry/poor quality image (should trigger manual entry)
- Try with clear image (should extract successfully)

**Check Backend:**
```bash
rails console
card = InsuranceCard.last
card.s3_key  # Should have S3 path
policy = InsurancePolicy.last
policy.payer_name  # Should have extracted data
```

---

### Step 8: Cost Estimation

**What to Test:**
- [ ] Cost estimate displays after insurance confirmation
- [ ] Shows min/max range (e.g., "$20 - $50")
- [ ] Insurance information is displayed
- [ ] Provisional disclaimer is visible
- [ ] Clear messaging about estimate nature
- [ ] Can proceed to scheduling

**Expected Display:**
- Estimated cost per session
- Insurance payer and plan type
- Clear disclaimers about provisional nature

---

### Step 9: Scheduling & Therapist Matching

**What to Test:**
- [ ] Time slot selection (Morning/Afternoon/Evening)
- [ ] Therapist matches appear after selecting time
- [ ] 2-4 therapists are suggested
- [ ] Each therapist shows:
  - Name
  - Bio
  - Specialties
  - Languages
  - Match score
  - Match rationale
- [ ] Can select a therapist
- [ ] "Book Appointment" button works
- [ ] Booking confirmation appears
- [ ] Session status updates to "completed"

**Test Flow:**
1. Select "Afternoon" time slot
2. Wait for therapist matches to load
3. Review therapist information
4. Select a therapist
5. Click "Book Appointment"
6. Verify confirmation message

**Check Backend:**
```bash
rails console
appointment = Appointment.last
appointment.status  # Should be 'scheduled'
appointment.scheduled_at  # Should have date/time
```

---

### Step 10: Post-Onboarding Summary

**What to Test:**
- [ ] Summary page displays after booking
- [ ] Shows appointment details:
  - Therapist name
  - Date and time
  - Estimated cost
- [ ] "What Happens Next" section is clear
- [ ] Timeline is displayed
- [ ] Support contact information
- [ ] "Complete Onboarding" button works
- [ ] Notifications are sent (check logs)

**Check Notifications:**
```bash
# Check Sidekiq logs
# Check Rails logs for email/SMS sending
rails console
AuditLog.where(action: 'notify').last  # Should show notification sent
```

---

## Feature-Specific Testing

### Inline FAQ Testing

**What to Test:**
- [ ] FAQ button is visible (bottom right)
- [ ] Clicking opens FAQ widget
- [ ] Can type questions
- [ ] AI responses are helpful
- [ ] Responses match "Reassuring Parenting Coach" tone
- [ ] Can close and reopen widget
- [ ] Works on all steps

**Test Questions:**
- "How long does this take?"
- "What if I need to stop?"
- "Is my information secure?"

---

### Support Chat Testing

**What to Test:**
- [ ] Chat button is visible (bottom right, different from FAQ)
- [ ] Clicking opens chat window
- [ ] Can send messages
- [ ] AI FAQ responds first
- [ ] Escalation triggers for urgent keywords:
  - "urgent"
  - "emergency"
  - "help me"
- [ ] Escalation message appears
- [ ] Chat transcript is logged

**Test Escalation:**
- Send: "This is urgent, I need help"
- Should escalate to staff
- Should show escalation message

**Check Backend:**
```bash
rails console
AuditLog.where("after LIKE ?", "%support_chat%").last
```

---

### Reassurance Banners Testing

**What to Test:**
- [ ] Banners appear at stress points:
  - Step 1: "starting_onboarding"
  - Steps 2-3: "completing_forms"
  - Step 7: "insurance_verification"
  - Step 8: "scheduling"
  - Step 9: "almost_done"
- [ ] Messages are warm and supportive
- [ ] Auto-hide after 6 seconds
- [ ] Can manually dismiss
- [ ] Don't appear too frequently

---

### Save/Resume Testing

**What to Test:**
- [ ] Progress saves automatically
- [ ] Can close browser and return
- [ ] Magic link request page works (`/resume`)
- [ ] Can request magic link via email
- [ ] Can request magic link via SMS
- [ ] Magic link restores progress
- [ ] Resume dialog appears if saved progress exists

**Test Flow:**
1. Complete steps 1-3
2. Close browser
3. Go to `/resume`
4. Request magic link
5. Click link in email/SMS
6. Verify progress is restored

---

### Analytics Testing

**What to Test:**
- [ ] Events are tracked in browser console
- [ ] Check localStorage for stored events
- [ ] Visit `/analytics` dashboard
- [ ] Funnel chart displays
- [ ] Drop-off points are visible
- [ ] Time metrics are accurate

**Check Analytics:**
```javascript
// In browser console
localStorage.getItem('analytics_events')
// Should show array of tracked events
```

---

## Error Scenarios Testing

### Network Errors
- [ ] Disconnect internet during AI intake
- [ ] Should show error message
- [ ] Can retry after reconnecting

### Validation Errors
- [ ] Submit forms with invalid data
- [ ] Error messages are clear
- [ ] Can correct and resubmit

### API Errors
- [ ] Simulate 500 errors in backend
- [ ] User-friendly error messages
- [ ] Can retry or contact support

---

## Accessibility Testing

### Keyboard Navigation
- [ ] Can navigate entire flow with keyboard only
- [ ] Tab order is logical
- [ ] Focus indicators are visible
- [ ] Can submit forms with Enter key

### Screen Reader
- [ ] Use VoiceOver (Mac) or NVDA (Windows)
- [ ] All content is announced
- [ ] Form labels are read correctly
- [ ] Buttons have descriptive names

### Visual
- [ ] High contrast mode works
- [ ] Text is readable at 200% zoom
- [ ] Color is not the only indicator

---

## Performance Testing

### Load Times
- [ ] Initial page load < 2 seconds
- [ ] Step transitions are smooth
- [ ] AI responses appear within 3 seconds
- [ ] Images load quickly

### Mobile Testing
- [ ] Test on actual mobile device
- [ ] Touch targets are large enough
- [ ] Forms are easy to fill on mobile
- [ ] Images upload correctly on mobile

---

## Backend Verification

### Database Checks
```bash
rails console

# Check all records were created
Parent.count
Student.count
OnboardingSession.count
IntakeMessage.count
ScreenerResponse.count
InsuranceCard.count
InsurancePolicy.count
Appointment.count
AuditLog.count

# Verify encryption
policy = InsurancePolicy.last
policy.policy_number  # Should be encrypted in DB, readable in app
```

### GraphQL Testing
Visit `http://localhost:3000/graphiql` and test queries:

```graphql
query {
  onboardingSession(id: "1") {
    id
    status
    currentStep
    parent {
      email
      firstName
    }
    students {
      firstName
      lastName
    }
  }
}
```

---

## Common Issues & Solutions

### Issue: AI responses not streaming
**Solution:** Check SSE endpoint is accessible, verify OpenAI API key

### Issue: Insurance OCR not working
**Solution:** Verify OpenAI Vision API access, check S3 credentials

### Issue: Therapist matches not appearing
**Solution:** Check matching service, verify student data is complete

### Issue: Notifications not sending
**Solution:** Check Sidekiq is running, verify Postmark/Twilio credentials

---

## Quick Test Checklist

Use this checklist for a quick smoke test:

- [ ] Can start onboarding
- [ ] Can complete all 9 steps
- [ ] AI intake conversation works
- [ ] Screener submission works
- [ ] Insurance upload works (or manual entry)
- [ ] Cost estimate displays
- [ ] Can book appointment
- [ ] Summary page shows
- [ ] FAQ widget works
- [ ] Support chat works
- [ ] Progress saves/resumes
- [ ] Mobile responsive
- [ ] Keyboard accessible

---

## Next Steps After Testing

1. **Fix any bugs found**
2. **Update test documentation**
3. **Create automated tests** for critical paths
4. **Performance optimization** if needed
5. **User acceptance testing** with real users

---

## Support

If you encounter issues during testing:
1. Check browser console for errors
2. Check Rails logs: `tail -f log/development.log`
3. Check Sidekiq logs
4. Verify all services are running
5. Review this guide for common solutions

