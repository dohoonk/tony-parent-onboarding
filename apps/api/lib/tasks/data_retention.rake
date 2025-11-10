namespace :data_retention do
  desc "Delete PHI and audit logs older than retention period"
  task cleanup: :environment do
    retention_period = ENV.fetch('DATA_RETENTION_DAYS', '2555').to_i.days # Default: 7 years for HIPAA
    
    cutoff_date = Time.current - retention_period
    
    Rails.logger.info("Starting data retention cleanup. Cutoff date: #{cutoff_date}")
    
    # Delete old audit logs
    deleted_logs = AuditLog.where('created_at < ?', cutoff_date).delete_all
    Rails.logger.info("Deleted #{deleted_logs} audit log entries")
    
    # Delete old completed onboarding sessions (anonymized)
    # Note: In production, you may want to anonymize rather than delete
    deleted_sessions = OnboardingSession
      .where(status: 'completed')
      .where('completed_at < ?', cutoff_date)
      .delete_all
    Rails.logger.info("Deleted #{deleted_sessions} old onboarding sessions")
    
    # Log the cleanup operation
    AuditLog.create!(
      user_id: nil,
      user_type: 'System',
      action: 'delete',
      entity_type: 'DataRetention',
      entity_id: nil,
      before: { cutoff_date: cutoff_date },
      after: { deleted_logs: deleted_logs, deleted_sessions: deleted_sessions }
    )
    
    Rails.logger.info("Data retention cleanup completed")
  end

  desc "Anonymize old PHI data instead of deleting"
  task anonymize: :environment do
    retention_period = ENV.fetch('DATA_RETENTION_DAYS', '2555').to_i.days
    cutoff_date = Time.current - retention_period
    
    Rails.logger.info("Starting data anonymization. Cutoff date: #{cutoff_date}")
    
    # Anonymize old parent records
    anonymized = Parent.where('created_at < ?', cutoff_date)
      .where(anonymized: false)
      .update_all(
        email: "anonymized_#{SecureRandom.hex(8)}@deleted.local",
        first_name: 'Anonymized',
        last_name: 'User',
        phone: nil,
        anonymized: true,
        anonymized_at: Time.current
      )
    
    Rails.logger.info("Anonymized #{anonymized} parent records")
    
    # Anonymize old student records
    Student.joins(:parent)
      .where('parents.created_at < ?', cutoff_date)
      .where(anonymized: false)
      .update_all(
        first_name: 'Anonymized',
        last_name: 'Student',
        date_of_birth: nil,
        anonymized: true,
        anonymized_at: Time.current
      )
    
    Rails.logger.info("Data anonymization completed")
  end
end

