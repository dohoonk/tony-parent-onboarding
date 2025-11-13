# Session Fix Testing Guide

## What Was Fixed

The "Session not found" error in the `matchTherapists` mutation was caused by the frontend generating temporary session IDs (`temp-session-...`) instead of creating real database-backed sessions.

### Changes Made

1. **Backend (Rails API)**
   - Created `CreateStudent` mutation (`app/graphql/mutations/create_student.rb`)
   - Created `CreateStudentInput` type (`app/graphql/types/inputs/create_student_input.rb`)
   - Registered mutation in `MutationType`

2. **Frontend (Next.js)**
   - Added `START_ONBOARDING` and `CREATE_STUDENT` mutations to GraphQL mutations file
   - Updated `OnboardingContext` to use real API calls instead of generating temp IDs
   - Added `studentId` tracking to context state
   - Modified `createSession()` to:
     1. Create a student record via `createStudent` mutation
     2. Start an onboarding session via `startOnboarding` mutation
     3. Store the real UUID session ID

## Testing Steps

### Prerequisites

1. **Restart Rails server** to load new GraphQL mutations:
   ```bash
   cd apps/api
   rails server
   ```

2. **Restart Next.js dev server**:
   ```bash
   cd apps/web
   npm run dev
   ```

3. **Clear browser storage** (to start fresh):
   - Open DevTools (F12)
   - Application tab → Local Storage
   - Delete `daybreak-onboarding-progress` item
   - Or run in console: `localStorage.clear()`

### Test Scenario 1: Fresh Onboarding Flow

1. **Navigate to onboarding**: http://localhost:3001/onboarding

2. **Complete Welcome Step** (Step 1):
   - Sign up or log in with test credentials
   - Click "Begin Onboarding"

3. **Complete Parent Info** (Step 2):
   - Fill in parent information
   - Click "Continue"

4. **Complete Student Info** (Step 3):
   - Fill in student information:
     - First Name: "Alex"
     - Last Name: "Test"
     - Date of Birth: Pick a date
     - Grade: "5"
     - School: "Test School"
   - Click "Continue"
   - **Watch console**: Should see:
     ```
     [OnboardingContext] Creating student...
     [OnboardingContext] Student created: <student-uuid>
     [OnboardingContext] Starting onboarding session...
     [OnboardingContext] Onboarding session created: <session-uuid>
     ```

5. **Complete Consent** (Step 4):
   - Accept consents
   - Click "Continue"

6. **Skip to Scheduling** (Step 8):
   - You can skip steps 5-7 for this test
   - Or complete them normally

7. **Test Scheduling** (Step 8):
   - Select a time slot (Morning/Afternoon/Evening)
   - **Watch Network tab**: Should see GraphQL mutation `MatchTherapists`
   - **Verify request variables**:
     ```json
     {
       "sessionId": "<real-uuid-here>",
       "availabilityWindowId": "temp-morning-<session-uuid>",
       "insurancePolicyId": null
     }
     ```
   - **Expected**: Therapist matches load successfully
   - **No more "Session not found" error!**

8. **Select a therapist and book**:
   - Choose a therapist
   - Click "Book Appointment"
   - **Expected**: Appointment books successfully

### Test Scenario 2: Resume After Refresh

1. **Complete steps 1-3** as above (creates student + session)

2. **Refresh the page** (F5)

3. **Verify**:
   - Should resume at correct step
   - `sessionId` and `studentId` loaded from localStorage
   - Console shows: `[Apollo] Auth token from localStorage: <token>...`

4. **Continue to scheduling**:
   - Should work without creating a new session
   - Uses existing session UUID

### Test Scenario 3: Multiple Students

1. **Complete full flow** for first student

2. **Clear onboarding progress** (keep auth token):
   ```javascript
   localStorage.removeItem('daybreak-onboarding-progress');
   ```

3. **Start new onboarding** with different student info:
   - Should create a new student record
   - Should create a new onboarding session
   - Each session is linked to its respective student

## Debugging

### Check Browser Console

Look for these log messages:
- `[OnboardingContext] Creating student...`
- `[OnboardingContext] Student created: <uuid>`
- `[OnboardingContext] Starting onboarding session...`
- `[OnboardingContext] Onboarding session created: <uuid>`
- `[Apollo] Auth token from localStorage: <token>...`
- `[Apollo] Setting Authorization header: Bearer <token>...`

### Check Network Tab

1. **CreateStudent mutation**:
   ```graphql
   mutation CreateStudent($input: CreateStudentInput!) {
     createStudent(input: $input) {
       student { id firstName lastName dateOfBirth grade school language }
       errors
     }
   }
   ```

2. **StartOnboarding mutation**:
   ```graphql
   mutation StartOnboarding($input: StartOnboardingInput!) {
     startOnboarding(input: $input) {
       session { id status currentStep student { id firstName lastName } }
       errors
     }
   }
   ```

3. **MatchTherapists mutation** (should now work):
   - `sessionId` should be a real UUID (not `temp-session-...`)
   - Response should return therapist matches
   - No errors

### Check Rails Logs

Watch `apps/api/log/development.log` for:

```
Processing by GraphqlController#execute as */*
  Parameters: {"operationName"=>"CreateStudent", ...}
  Student Create (...)  INSERT INTO "students" ...
  
Processing by GraphqlController#execute as */*
  Parameters: {"operationName"=>"StartOnboarding", ...}
  OnboardingSession Create (...)  INSERT INTO "onboarding_sessions" ...
  
Processing by GraphqlController#execute as */*
  Parameters: {"operationName"=>"MatchTherapists", ...}
  OnboardingSession Load (...)  SELECT "onboarding_sessions".* FROM "onboarding_sessions" WHERE ... AND "id" = '<real-uuid>'
```

### Common Issues

1. **"Authentication required"**:
   - Check that JWT token is in localStorage: `localStorage.getItem('auth_token')`
   - Verify Authorization header is being sent in Network tab

2. **"Student not found"** when starting onboarding:
   - Check that `createStudent` mutation succeeded
   - Verify `studentId` is in context state

3. **"Session not found"** still happening:
   - Verify `sessionId` is a real UUID (not `temp-session-...`)
   - Check Rails logs to see if session was created
   - Verify localStorage has correct session ID

4. **Session created but not persisted across refresh**:
   - Check `saveProgress()` is being called
   - Verify localStorage has `sessionId` and `studentId` fields

## Database Verification

### Check Created Records

```bash
cd apps/api
rails console
```

```ruby
# Find the parent (replace email)
parent = Parent.find_by(email: 'test@example.com')

# Check students
parent.students
# Should show the created student

# Check onboarding sessions
parent.onboarding_sessions
# Should show the session with status 'active'

# Get the session
session = parent.onboarding_sessions.last
session.id  # This is the UUID being used
session.student  # Should match the created student
session.status  # Should be 'active'
session.current_step  # Should be 1 (or current step)
```

## Success Criteria

✅ No more "Session not found" errors
✅ Real UUIDs in sessionId (not temp-session-...)
✅ Student record created in database
✅ OnboardingSession record created in database
✅ Session persists across page refreshes
✅ Therapist matching works correctly
✅ Appointment booking works correctly

## Rollback (if needed)

If you need to revert changes:

1. **Frontend**: Revert `OnboardingContext.tsx` and `mutations.ts`
2. **Backend**: Delete the new mutation files:
   ```bash
   rm apps/api/app/graphql/mutations/create_student.rb
   rm apps/api/app/graphql/types/inputs/create_student_input.rb
   ```
3. Revert `mutation_type.rb`
4. Restart both servers




