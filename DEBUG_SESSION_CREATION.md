# Debug Guide: Session Creation Issues

## Current Errors

### Error 1: "Student ID is required to start onboarding session"
**Cause**: The `createStudent` mutation is failing or not returning a student ID

### Error 2: StreamingController - "Authorization header: MISSING"
**Cause**: Token not being sent to streaming endpoint

## Debugging Steps

### Step 1: Check Authentication

**Browser Console:**
```javascript
// Check if token exists
localStorage.getItem('auth_token')

// Should return: "eyJhbGciOiJIUzI1..." or null
```

**If null:**
- User is not logged in
- Need to complete Welcome step (signup/login)
- Token should be saved after successful signup/login

### Step 2: Check Network Requests

**Open DevTools → Network Tab**

1. **Look for `createStudent` mutation**:
   - Should see POST to `/graphql`
   - Check Request Headers → Should have `authorization: Bearer <token>`
   - Check Request Payload:
     ```json
     {
       "operationName": "CreateStudent",
       "variables": {
         "input": {
           "firstName": "Alex",
           "lastName": "Test",
           "dateOfBirth": "2015-01-01",
           "grade": "5",
           "school": "Test School",
           "language": "en"
         }
       }
     }
     ```
   - Check Response:
     ```json
     {
       "data": {
         "createStudent": {
           "student": {
             "id": "<uuid>",
             "firstName": "Alex",
             ...
           },
           "errors": []
         }
       }
     }
     ```

2. **Common Issues**:
   - **401 Unauthorized**: Token missing or invalid
   - **422 Unprocessable Entity**: Validation error (check error details)
   - **500 Server Error**: Backend issue (check Rails logs)
   - **GraphQL Error**: Check `errors` array in response

### Step 3: Check Console Logs

**Expected Flow:**
```
[OnboardingContext] Creating student with data: {...}
[Apollo] Setting Authorization header: Bearer <token>...
[OnboardingContext] createStudent response: {...}
[OnboardingContext] createStudent errors: null
[OnboardingContext] ✅ Student created successfully: <uuid>
[OnboardingContext] Starting onboarding session for student: <uuid>
[OnboardingContext] startOnboarding response: {...}
[OnboardingContext] startOnboarding errors: null
[OnboardingContext] ✅ Onboarding session created successfully: <uuid>
```

**Error Scenarios:**

**Scenario A: No auth token**
```
[OnboardingContext] Creating student with data: {...}
[Apollo] Auth token from localStorage: NOT FOUND
❌ GraphQL error: Authentication required
```

**Scenario B: Token invalid**
```
[OnboardingContext] Creating student with data: {...}
[Apollo] Setting Authorization header: Bearer <token>...
❌ GraphQL error: Invalid or expired token
```

**Scenario C: Validation error**
```
[OnboardingContext] Creating student with data: {...}
[OnboardingContext] createStudent response: { createStudent: { student: null, errors: ["Date of birth is required"] } }
❌ Student creation error: Date of birth is required
```

## Quick Fixes

### Fix 1: Missing Authentication

**Problem**: User not logged in
```
Error: GraphQL error: Authentication required
```

**Solution**:
1. Go back to Welcome step
2. Complete signup or login
3. Verify token in localStorage
4. Continue onboarding

### Fix 2: Expired Token

**Problem**: Token expired
```
Error: GraphQL error: Invalid or expired token
```

**Solution**:
```javascript
// Clear old token
localStorage.removeItem('auth_token');

// Go back and login again
window.location.href = '/onboarding';
```

### Fix 3: Validation Errors

**Problem**: Invalid student data
```
Error: Student creation error: Date of birth cannot be in the future
```

**Solution**:
1. Go back to Student Info step
2. Fix the validation issue
3. Try again

## Testing Commands

### Check Current State
```javascript
// In browser console

// 1. Check auth
console.log('Token:', localStorage.getItem('auth_token'));

// 2. Check onboarding progress
const progress = JSON.parse(localStorage.getItem('daybreak-onboarding-progress') || '{}');
console.log('Current Step:', progress.step);
console.log('Student Info:', progress.data?.studentInfo);
console.log('Student ID:', progress.studentId);
console.log('Session ID:', progress.sessionId);
```

### Manual GraphQL Test

**In GraphiQL (http://localhost:3000/graphiql)**:

1. Set auth header:
   ```json
   {
     "Authorization": "Bearer YOUR_TOKEN_HERE"
   }
   ```

2. Test createStudent:
   ```graphql
   mutation TestCreateStudent {
     createStudent(input: {
       firstName: "Test"
       lastName: "Student"
       dateOfBirth: "2015-01-01"
       grade: "5"
       school: "Test School"
       language: "en"
     }) {
       student {
         id
         firstName
         lastName
         dateOfBirth
         grade
       }
       errors
     }
   }
   ```

3. If successful, test startOnboarding:
   ```graphql
   mutation TestStartOnboarding {
     startOnboarding(input: {
       studentId: "STUDENT_ID_FROM_ABOVE"
     }) {
       session {
         id
         status
         currentStep
       }
       errors
     }
   }
   ```

### Check Rails Logs

```bash
tail -f apps/api/log/development.log
```

**Look for**:
```
Processing by GraphqlController#execute as */*
Parameters: {"operationName"=>"CreateStudent", ...}
Authorization header: Bearer eyJh...
✅ Authentication successful for parent: <parent-uuid>
Student Create (...)  INSERT INTO "students" ...
```

**Error indicators**:
```
❌ Authorization header: MISSING
❌ Invalid or expired token
❌ ActiveRecord::RecordInvalid: Validation failed: ...
```

## Root Cause Analysis

### Most Likely Causes

1. **Authentication Not Working** (90% of cases)
   - Token not saved after login
   - Token not being sent with requests
   - Token expired

2. **Validation Errors** (8% of cases)
   - Invalid date format
   - Missing required fields
   - Data type mismatches

3. **Backend Issues** (2% of cases)
   - Database connection
   - Migration not run
   - Mutation not registered

## Emergency Workaround

If you need to test quickly and skip session creation:

```javascript
// TEMPORARY WORKAROUND - DO NOT USE IN PRODUCTION

// 1. Create student manually in Rails console:
// rails console
// parent = Parent.find_by(email: 'your-email@example.com')
// student = parent.students.create!(
//   first_name: 'Test',
//   last_name: 'Student',
//   date_of_birth: 10.years.ago,
//   language: 'en'
// )
// student.id  # Copy this UUID

// 2. Create session manually:
// session = parent.onboarding_sessions.create!(
//   student: student,
//   status: 'active',
//   current_step: 1
// )
// session.id  # Copy this UUID

// 3. Inject into localStorage:
localStorage.setItem('daybreak-onboarding-progress', JSON.stringify({
  step: 4,  // Skip to after student info
  data: {
    studentInfo: {
      firstName: 'Test',
      lastName: 'Student',
      dateOfBirth: '2015-01-01',
      grade: '5',
      school: 'Test School'
    }
  },
  studentId: 'PASTE_STUDENT_UUID_HERE',
  sessionId: 'PASTE_SESSION_UUID_HERE',
  timestamp: new Date().toISOString()
}));

// 4. Refresh page
location.reload();
```

## Next Steps After Fixing

Once you see the success messages:
1. Verify student created in database
2. Verify session created in database
3. Continue to scheduling step
4. Test therapist matching
5. Celebrate! 🎉


