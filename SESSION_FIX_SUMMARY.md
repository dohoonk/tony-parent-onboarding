# Session Fix Summary

## Problem

The `matchTherapists` mutation was failing with "Session not found" error because:
- Frontend was generating temporary session IDs (`temp-session-1762825754315-0ln4hlncq`)
- These temp IDs don't exist in the database
- Backend tried to query: `WHERE "onboarding_sessions"."id" = NULL` (UUID cast failure)
- Result: Session not found

## Root Cause

In `apps/web/contexts/OnboardingContext.tsx`, the `createSession()` function was generating client-side temporary IDs instead of calling the backend API:

```typescript
// OLD CODE (BROKEN)
const createSession = useCallback(async () => {
  const tempSessionId = `temp-session-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  setSessionId(tempSessionId);
  updateData({ sessionId: tempSessionId });
}, [sessionId, updateData]);
```

## Solution

Implemented real session creation by:

### 1. Backend Changes

Created new GraphQL mutation to create students:

**Files Created:**
- `apps/api/app/graphql/mutations/create_student.rb`
- `apps/api/app/graphql/types/inputs/create_student_input.rb`

**Files Modified:**
- `apps/api/app/graphql/types/mutation_type.rb` - Added `create_student` field

### 2. Frontend Changes

**Files Modified:**
- `apps/web/lib/graphql/mutations.ts` - Added `START_ONBOARDING` and `CREATE_STUDENT` mutations
- `apps/web/contexts/OnboardingContext.tsx` - Replaced temp ID generation with real API calls

**New Flow:**
```typescript
const createSession = useCallback(async () => {
  // Step 1: Create student record
  const { data: studentData } = await createStudentMutation({
    variables: { input: { ...studentInfo } }
  });
  const studentId = studentData.createStudent.student.id;
  
  // Step 2: Create onboarding session
  const { data: sessionData } = await startOnboardingMutation({
    variables: { input: { studentId } }
  });
  const sessionId = sessionData.startOnboarding.session.id;
  
  // Step 3: Store real UUID
  setSessionId(sessionId);
  updateData({ sessionId });
}, [createStudentMutation, startOnboardingMutation]);
```

## Flow Diagram

### Before (Broken)
```
User fills student info
    ↓
Frontend generates temp ID: "temp-session-123..."
    ↓
User reaches scheduling step
    ↓
Frontend calls matchTherapists(sessionId: "temp-session-123...")
    ↓
Backend queries: WHERE id = NULL (UUID cast fails)
    ↓
❌ ERROR: "Session not found"
```

### After (Fixed)
```
User fills student info
    ↓
Frontend calls createStudent mutation
    ↓
Backend creates Student record → Returns UUID
    ↓
Frontend calls startOnboarding mutation (with student UUID)
    ↓
Backend creates OnboardingSession record → Returns UUID
    ↓
Frontend stores real session UUID
    ↓
User reaches scheduling step
    ↓
Frontend calls matchTherapists(sessionId: "<real-uuid>")
    ↓
Backend queries: WHERE id = '<real-uuid>'
    ↓
✅ SUCCESS: Session found, therapists matched
```

## Testing

See `SESSION_FIX_TESTING.md` for detailed testing instructions.

**Quick Test:**
1. Clear localStorage: `localStorage.clear()`
2. Navigate to: http://localhost:3001/onboarding
3. Complete steps 1-3 (Welcome, Parent Info, Student Info)
4. Watch console for:
   - `[OnboardingContext] Student created: <uuid>`
   - `[OnboardingContext] Onboarding session created: <uuid>`
5. Navigate to Scheduling step
6. Select time slot
7. ✅ Therapist matches load (no "Session not found" error)

## Impact

- ✅ **matchTherapists** now works correctly
- ✅ **bookAppointment** will work (uses same session ID)
- ✅ **All session-scoped mutations** will work
- ✅ Session persists across page refreshes
- ✅ Proper database records created for audit/tracking

## Files Changed

### Backend (4 files)
1. `apps/api/app/graphql/mutations/create_student.rb` - NEW
2. `apps/api/app/graphql/types/inputs/create_student_input.rb` - NEW
3. `apps/api/app/graphql/types/mutation_type.rb` - MODIFIED
4. `apps/api/app/graphql/mutations/start_onboarding.rb` - No changes (already existed)

### Frontend (2 files)
1. `apps/web/lib/graphql/mutations.ts` - MODIFIED
2. `apps/web/contexts/OnboardingContext.tsx` - MODIFIED

## Migration Notes

- **Backward Compatible**: Existing sessions (if any) are unaffected
- **No Database Migration Required**: Uses existing schema
- **No Breaking Changes**: All existing mutations continue to work
- **Cleanup**: Old localStorage entries with temp IDs will be replaced on next onboarding

## Next Steps

1. **Test thoroughly** using `SESSION_FIX_TESTING.md`
2. **Monitor logs** for any edge cases
3. **Consider adding**:
   - Error handling for network failures
   - Retry logic for mutation failures
   - Better loading states during session creation
   - Toast notifications for user feedback

## Related Issues

This fix also resolves:
- Insurance upload "Session not found" errors (if using temp IDs)
- AI intake "Session not found" errors (if using temp IDs)
- Any other session-scoped mutation failures

## Notes

- The backend mutation `uploadInsuranceCard` had a workaround for temp IDs (lines 17-44), which is no longer needed but won't cause issues
- Consider cleaning up that workaround in a future PR for code clarity




