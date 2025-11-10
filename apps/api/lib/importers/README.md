# CSV Import System

This directory contains the CSV import infrastructure for loading test data into the database.

## Overview

All importers extend `BaseCsvImporter`, which provides:
- Idempotent imports (safe to run multiple times)
- Consistent error handling and reporting
- Progress tracking
- Post-import validation

## BaseCsvImporter

The base class provides common functionality:

### Methods to Override

- `build_attributes(row)` - **Required**: Build the attributes hash for the model
- `extract_id(row)` - Extract the record ID (default: `row['id']`)
- `record_exists?(id)` - Check if record exists (default: `model_class.exists?(id: id)`)
- `deleted?(row)` - Check if record is deleted (default: `row['_fivetran_deleted'] == 'true'`)

### Helper Methods

- `parse_json_field(row, field_name, default: {})` - Parse JSONB fields
- `parse_array_field(row, field_name, default: [])` - Parse array fields
- `parse_timestamp(row, field_name)` - Parse timestamp strings
- `parse_date(row, field_name)` - Parse date strings
- `parse_integer(row, field_name, default: nil)` - Parse integer fields
- `parse_boolean(row, field_name, default: false)` - Parse boolean fields
- `parse_uuid(row, field_name)` - Extract UUID fields
- `find_record(model_class, id, required: false)` - Find a related record

## Importers

### Core Entities

- **OrganizationImporter** - Imports organizations (districts and schools)
- **ContractImporter** - Imports contracts
- **OrgContractImporter** - Imports organization-contract relationships
- **CredentialedInsuranceImporter** - Imports insurance credentialing data
- **TherapistImporter** - Imports therapist/clinician data
- **ClinicianCredentialedInsuranceImporter** - Imports therapist-insurance relationships
- **DocumentImporter** - Imports consent forms and documents

### Patients and Guardians

- **PatientGuardianImporter** - Imports both Parent and Student records
  - Uses `role` field: 0 = student, 1 = parent/guardian
  - For students: finds parent via kinship relationships or creates placeholder

### Relationships

- **KinshipImporter** - Imports polymorphic user relationships (parent-child, etc.)
- **MembershipImporter** - Imports user-organization memberships
- **ReferralImporter** - Imports referrals
- **ReferralMemberImporter** - Imports referral-user relationships

### Availability

- **ClinicianAvailabilityImporter** - Imports therapist availability windows
- **PatientAvailabilityImporter** - Imports parent/student availability windows

### Insurance

- **InsurancePolicyImporter** - Imports insurance policies
- **InsuranceCoverageImporter** - Imports insurance coverage details

### Questionnaires

- **QuestionnaireImporter** - Imports questionnaire responses

## Usage

### Master Import

Import all data in the correct order:

```bash
bundle exec rake import:all
```

### Individual Imports

Run specific imports:

```bash
# Core entities
bundle exec rake import:organizations
bundle exec rake import:therapists
bundle exec rake import:documents

# Patients and guardians
bundle exec rake import:patients_guardians

# Relationships
bundle exec rake import:kinships
bundle exec rake import:referrals

# Availability
bundle exec rake import:availabilities

# Insurance
bundle exec rake import:insurance

# Questionnaires
bundle exec rake import:questionnaires
```

### Help

View all available import tasks and dependencies:

```bash
bundle exec rake import:help
```

## Import Order

The master import task (`import:all`) runs imports in this order:

1. **Phase 1: Core Entities** (no dependencies)
   - Organizations
   - Contracts
   - Org Contracts
   - Credentialed Insurances
   - Therapists
   - Clinician Credentialed Insurances
   - Documents

2. **Phase 2: Patients and Guardians**
   - Patients and Guardians (creates Parents and Students)

3. **Phase 3: Relationships** (depends on Phase 2)
   - Kinships
   - Memberships

4. **Phase 4: Referrals** (depends on Phases 1, 2, 3)
   - Referrals
   - Referral Members

5. **Phase 5: Availability** (depends on Phase 1, 2)
   - Clinician Availabilities
   - Patient Availabilities

6. **Phase 6: Insurance** (depends on Phase 2)
   - Insurance Policies
   - Insurance Coverages

7. **Phase 7: Questionnaires** (depends on Phase 2)
   - Questionnaires

## CSV File Locations

All CSV files are expected in: `../../devdocs/` (relative to `apps/api/`)

Required files:
- `organizations.csv`
- `contracts.csv`
- `org_contracts.csv`
- `credentialed_insurances.csv`
- `therapists.csv`
- `clinician_credentialed_insurances.csv`
- `documents.csv`
- `patients_and_guardians_anonymized.csv`
- `kinships.csv`
- `memberships.csv`
- `referrals.csv`
- `referral_members.csv`
- `clinician_availabilities.csv`
- `patient_availabilities.csv`
- `insurance_policies.csv`
- `insurance_coverages.csv`
- `questionnaires.csv`

## Features

### Idempotency

All imports are idempotent - safe to run multiple times. Records are skipped if they already exist (based on ID).

### Error Handling

- Errors are collected and reported at the end
- Import continues even if individual rows fail
- Error details include row number and specific error messages

### Progress Tracking

- Progress dots printed every 10 imported records
- Summary statistics at the end (imported, skipped, errors)

### Post-Import Validation

Many importers include post-import validation:
- Verifies foreign key relationships
- Cleans up orphaned records
- Reports warnings for missing relationships

## Troubleshooting

### Common Issues

1. **CSV file not found**
   - Verify CSV files exist in `../../devdocs/` directory
   - Check file names match expected names

2. **Foreign key violations**
   - Ensure dependencies are imported first
   - Use `import:all` to import in correct order

3. **Validation errors**
   - Check error messages for specific field issues
   - Verify CSV data format matches expected schema

4. **Missing relationships**
   - Some imports create placeholder records (e.g., parents for orphaned students)
   - Check post-import validation warnings

### Debugging

Run individual import tasks to isolate issues:

```bash
# Run with verbose output
bundle exec rake import:therapists

# Check specific importer
bundle exec rails runner "importer = Importers::TherapistImporter.new; puts importer.class.name"
```

## Extending the System

To create a new importer:

1. Create a new file: `lib/importers/my_model_importer.rb`

2. Extend `BaseCsvImporter`:

```ruby
module Importers
  class MyModelImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/my_model.csv')
      super(csv_path, MyModel)
    end

    protected

    def build_attributes(row)
      {
        id: row['id'],
        name: row['name'],
        # ... other attributes
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end
```

3. Create a rake task: `lib/tasks/import_my_model.rake`

```ruby
namespace :import do
  desc "Import my models from CSV"
  task my_models: :environment do
    importer = Importers::MyModelImporter.new
    importer.import
  end
end
```

4. Add to `import:all` task in the correct dependency order

## Notes

- All timestamps are parsed from ISO 8601 format
- UUIDs are preserved as strings
- JSONB fields are parsed from JSON strings
- Array fields can be JSON arrays or comma-separated strings
- Boolean fields accept: true, 1, yes, t (case-insensitive)
- Deleted records (`_fivetran_deleted == 'true'`) are skipped

