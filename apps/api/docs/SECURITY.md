# Security and Privacy Documentation

## Overview

This document outlines the security and privacy measures implemented in the Parent Onboarding AI system to ensure HIPAA compliance and protect Protected Health Information (PHI).

## Encryption

### Data in Transit
- **TLS 1.2+**: All data transmission is encrypted using TLS 1.2 or higher
- **Force SSL**: Production environment enforces HTTPS for all connections
- **HSTS**: HTTP Strict Transport Security is enabled with preload support

### Data at Rest
- **Field-Level Encryption**: PHI fields are encrypted using Rails built-in encryption (AES-256)
- **Database Encryption**: Sensitive fields use `encrypts` attribute in models
- **Encryption Keys**: Stored securely using Rails credentials or environment variables

## Access Control

### Role-Based Access Control (RBAC)
- **Roles**: `parent`, `staff`, `admin`
- **Permissions**: Defined in `Authorizable` concern
- **Resource-Based Access**: Users can only access resources they own or are authorized for

### Authentication
- **JWT Tokens**: Secure token-based authentication
- **Magic Links**: Email/SMS-based authentication for session resumption
- **Token Expiration**: Tokens expire after 24 hours

## Audit Logging

### Comprehensive Logging
- **All PHI Access**: Logged in `audit_logs` table
- **User Actions**: Tracked with user ID, timestamp, action type
- **Entity Tracking**: Records what resource was accessed/modified
- **Before/After States**: Captures data changes for audit trail

### Log Retention
- **Retention Period**: 7 years (HIPAA requirement)
- **Automated Cleanup**: Weekly cleanup of logs older than retention period
- **Backup**: Weekly backups of audit logs

## PHI De-Identification

### Prompt Hygiene
- **PII Redaction**: All PII stripped from AI prompts before processing
- **Pseudonymization**: User identifiers replaced with pseudonyms
- **Service**: `PhiDeidentificationService` handles all de-identification

### Data Minimization
- **Minimal Storage**: Only necessary PHI is stored
- **Summary Extraction**: Structured summaries instead of full conversations
- **Anonymization**: Old data can be anonymized instead of deleted

## Secrets Management

### Current Implementation
- **Rails Credentials**: Used for sensitive configuration
- **Environment Variables**: For API keys and secrets
- **Future**: Integration with Vault/Aptible recommended for production

### Best Practices
- Never commit secrets to version control
- Rotate keys regularly
- Use different keys for development/staging/production

## Data Retention and Deletion

### Retention Policies
- **PHI**: Retained for 7 years (HIPAA minimum)
- **Audit Logs**: Retained for 7 years
- **Anonymization**: Option to anonymize instead of delete

### Automated Cleanup
- **Weekly Tasks**: Scheduled via whenever/cron
- **Rake Tasks**: `data_retention:cleanup` and `data_retention:anonymize`
- **Audit Trail**: All deletions logged

## Backup and Recovery

### Backup Strategy
- **Daily Backups**: Database backups created daily
- **Weekly Backups**: Audit log backups weekly
- **Encryption**: Backups encrypted before storage
- **Offsite Storage**: Backups stored in secure, access-controlled locations

### Recovery Procedures
- **Rake Task**: `backup:restore[backup_file]` for database restoration
- **Testing**: Regular restore drills to verify procedures
- **Documentation**: Recovery procedures documented and tested

## Compliance

### HIPAA Requirements
- ✅ Encryption of PHI in transit and at rest
- ✅ Access controls and authentication
- ✅ Comprehensive audit logging
- ✅ Data retention and deletion policies
- ✅ Backup and recovery procedures
- ✅ PHI de-identification in AI processing

### Security Testing
- Regular penetration testing recommended
- SSL Labs testing for TLS configuration
- Audit log integrity verification
- Access control testing

## Incident Response

### Security Incidents
1. Immediately revoke affected credentials
2. Review audit logs for unauthorized access
3. Notify affected users if PHI was compromised
4. Document incident and remediation steps
5. Update security measures to prevent recurrence

## Contact

For security concerns or questions, contact the security team.

