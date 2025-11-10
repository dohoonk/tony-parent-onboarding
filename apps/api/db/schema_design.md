# Database Schema Design - Parent Onboarding AI

## Overview

This document defines the complete database schema for the Parent Onboarding AI system, including all tables, relationships, and constraints.

## Schema Diagram

```
parents (1) --- (*) students
                    |
                    |-- (*) onboarding_sessions
                                |
                                |-- (*) intake_messages
                                |-- (1) intake_summaries
                                |-- (*) screener_responses
                                |-- (*) insurance_cards
                                |-- (1) insurance_policies
                                |-- (1) cost_estimates
                                |-- (*) appointments

screeners (1) --- (*) screener_responses

audit_logs (tracks all PHI access)
```

## Tables

### 1. parents
Primary user table for parents/guardians.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| email | string | NOT NULL, UNIQUE, INDEX | Email address |
| phone | string | NULL | Phone number |
| first_name | string | NOT NULL | First name |
| last_name | string | NOT NULL | Last name |
| auth_provider | string | NOT NULL, DEFAULT 'magic_link' | Authentication method |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- email (unique)
- created_at

---

### 2. students
Child/student records associated with parents.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| parent_id | uuid | FK(parents), NOT NULL, INDEX | Parent reference |
| first_name | string | NOT NULL | First name |
| last_name | string | NOT NULL | Last name |
| date_of_birth | date | NOT NULL | Birth date |
| grade | string | NULL | Current grade |
| school | string | NULL | School name |
| language | string | NOT NULL, DEFAULT 'en' | Preferred language |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- parent_id
- date_of_birth

**Associations:**
- belongs_to :parent

---

### 3. onboarding_sessions
Tracks onboarding progress for each student.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| parent_id | uuid | FK(parents), NOT NULL, INDEX | Parent reference |
| student_id | uuid | FK(students), NOT NULL, INDEX | Student reference |
| status | enum | NOT NULL, DEFAULT 'draft' | Session status: draft, active, completed, abandoned |
| current_step | integer | NOT NULL, DEFAULT 1 | Current step (1-5) |
| eta_seconds | integer | NULL | Estimated time remaining |
| completed_at | timestamp | NULL | Completion time |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- parent_id
- student_id
- status
- created_at

**Associations:**
- belongs_to :parent
- belongs_to :student
- has_many :intake_messages
- has_one :intake_summary
- has_many :screener_responses
- has_many :insurance_cards
- has_one :insurance_policy
- has_one :cost_estimate
- has_many :appointments

---

### 4. intake_messages
Conversational intake chat messages.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, INDEX | Session reference |
| role | enum | NOT NULL | Message role: user, assistant, system |
| content | text | NOT NULL | Message content |
| de_identified_content | text | NULL | PHI-stripped version for AI |
| created_at | timestamp | NOT NULL | Message timestamp |

**Indexes:**
- session_id
- created_at

**Associations:**
- belongs_to :onboarding_session

**Notes:**
- `content` contains full message with potential PHI
- `de_identified_content` is scrubbed for AI processing
- TTL policy: may be purged after session completion

---

### 5. intake_summaries
AI-generated summaries of intake conversations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, UNIQUE, INDEX | Session reference |
| concerns_json | jsonb | NULL | Array of concerns |
| goals_json | jsonb | NULL | Array of goals |
| risk_flags_json | jsonb | NULL | Array of risk indicators |
| summary_text | text | NULL | Natural language summary |
| created_at | timestamp | NOT NULL | Summary generation time |

**Indexes:**
- session_id (unique)

**Associations:**
- belongs_to :onboarding_session

---

### 6. screeners
Clinical screener definitions (PHQ-9, GAD-7, etc.).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| key | string | NOT NULL, UNIQUE | Screener key (e.g., 'phq9') |
| title | string | NOT NULL | Display title |
| version | string | NOT NULL | Screener version |
| items_json | jsonb | NOT NULL | Questions and scoring |
| created_at | timestamp | NOT NULL | Record creation time |

**Indexes:**
- key (unique)

**Associations:**
- has_many :screener_responses

---

### 7. screener_responses
Student responses to clinical screeners.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, INDEX | Session reference |
| screener_id | uuid | FK(screeners), NOT NULL, INDEX | Screener reference |
| answers_json | jsonb | NOT NULL | Answer data |
| score | integer | NULL | Calculated score |
| interpretation_text | text | NULL | AI interpretation |
| created_at | timestamp | NOT NULL | Response time |

**Indexes:**
- session_id
- screener_id

**Associations:**
- belongs_to :onboarding_session
- belongs_to :screener

---

### 8. insurance_cards
Uploaded insurance card images and OCR data.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, INDEX | Session reference |
| front_image_url | string | NOT NULL | S3 URL for front |
| back_image_url | string | NULL | S3 URL for back |
| ocr_json | jsonb | NULL | OCR extraction results |
| confidence_json | jsonb | NULL | Confidence scores per field |
| created_at | timestamp | NOT NULL | Upload time |

**Indexes:**
- session_id

**Associations:**
- belongs_to :onboarding_session

---

### 9. insurance_policies
Confirmed insurance policy information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, UNIQUE, INDEX | Session reference |
| payer_name | string | NOT NULL | Insurance company |
| member_id | string | NOT NULL, ENCRYPTED | Member ID (PHI) |
| group_number | string | NULL, ENCRYPTED | Group number |
| plan_type | string | NULL | Plan type |
| subscriber_name | string | NULL | Subscriber name |
| verified_at | timestamp | NULL | Verification time |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- session_id (unique)

**Associations:**
- belongs_to :onboarding_session

**Security:**
- `member_id` and `group_number` are encrypted at rest

---

### 10. cost_estimates
Estimated therapy costs based on insurance.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, UNIQUE, INDEX | Session reference |
| min_cost_cents | integer | NOT NULL | Minimum cost (cents) |
| max_cost_cents | integer | NOT NULL | Maximum cost (cents) |
| basis | string | NULL | Estimation basis |
| created_at | timestamp | NOT NULL | Estimate time |

**Indexes:**
- session_id (unique)

**Associations:**
- belongs_to :onboarding_session

---

### 11. availability_windows
Parent/therapist availability for scheduling.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| owner_type | string | NOT NULL | 'Parent' or 'Therapist' |
| owner_id | uuid | NOT NULL, INDEX | Polymorphic owner reference |
| rrule | string | NULL | Recurrence rule (iCal format) |
| start_date | date | NOT NULL | Availability start |
| end_date | date | NULL | Availability end |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- [owner_type, owner_id]
- start_date

---

### 12. appointments
Scheduled therapy sessions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| session_id | uuid | FK(onboarding_sessions), NOT NULL, INDEX | Session reference |
| student_id | uuid | FK(students), NOT NULL, INDEX | Student reference |
| therapist_id | uuid | NOT NULL, INDEX | Therapist reference (TBD: users table) |
| scheduled_at | timestamp | NOT NULL | Appointment time |
| duration_minutes | integer | NOT NULL, DEFAULT 50 | Session duration |
| status | enum | NOT NULL, DEFAULT 'scheduled' | Status: scheduled, confirmed, completed, cancelled, no_show |
| notes | text | NULL | Appointment notes |
| created_at | timestamp | NOT NULL | Record creation time |
| updated_at | timestamp | NOT NULL | Record update time |

**Indexes:**
- session_id
- student_id
- therapist_id
- scheduled_at
- status

**Associations:**
- belongs_to :onboarding_session
- belongs_to :student

---

### 13. audit_logs
PHI/PII access audit trail for HIPAA compliance.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Unique identifier |
| actor_id | uuid | NULL | User who performed action |
| actor_type | string | NULL | Actor type (Parent, Staff, System) |
| action | string | NOT NULL | Action: read, write, update, delete |
| entity_type | string | NOT NULL | Entity accessed |
| entity_id | uuid | NOT NULL | Entity ID |
| before_json | jsonb | NULL | State before change |
| after_json | jsonb | NULL | State after change |
| ip_address | string | NULL | Request IP |
| user_agent | text | NULL | Request user agent |
| created_at | timestamp | NOT NULL | Action timestamp |

**Indexes:**
- actor_id
- entity_type, entity_id
- created_at

**Notes:**
- Immutable (no updates/deletes)
- Retention policy: 7 years minimum (HIPAA requirement)

---

## Encryption Strategy

**Encrypted Fields:**
- `insurance_policies.member_id`
- `insurance_policies.group_number`

**Method:**
- Rails 7+ built-in encryption via `encrypts` attribute
- OR: Lockbox gem for additional features

---

## Data Retention

- **intake_messages**: May be purged after 90 days (configurable)
- **audit_logs**: Retain for 7+ years (HIPAA requirement)
- All other data: Retain indefinitely unless parent requests deletion

---

## Migration Strategy

1. Create tables in order of dependencies (parents first, audit_logs last)
2. Add indexes after table creation
3. Enable encryption on sensitive columns
4. Seed screener definitions

