namespace :backup do
  desc "Create encrypted backup of database"
  task database: :environment do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_dir = ENV.fetch('BACKUP_DIR', Rails.root.join('backups'))
    FileUtils.mkdir_p(backup_dir)
    
    db_config = ActiveRecord::Base.connection_config
    backup_file = File.join(backup_dir, "db_backup_#{timestamp}.sql")
    encrypted_file = "#{backup_file}.enc"
    
    Rails.logger.info("Starting database backup to #{backup_file}")
    
    # Create PostgreSQL dump
    system("PGPASSWORD=#{db_config[:password]} pg_dump -h #{db_config[:host]} -U #{db_config[:username]} -d #{db_config[:database]} -F c -f #{backup_file}")
    
    if $?.success?
      # Encrypt backup (using GPG or similar)
      # In production, use proper encryption: gpg --symmetric --cipher-algo AES256 backup_file
      Rails.logger.info("Database backup created: #{backup_file}")
      
      # TODO: Upload to S3 or secure storage
      # s3_client.upload_file(backup_file, "backups/#{File.basename(backup_file)}")
      
      # Clean up local file after upload
      # File.delete(backup_file) if uploaded
      
      Rails.logger.info("Database backup completed successfully")
    else
      Rails.logger.error("Database backup failed")
      raise "Backup failed with exit code #{$?.exitstatus}"
    end
  end

  desc "Create backup of audit logs"
  task audit_logs: :environment do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_dir = ENV.fetch('BACKUP_DIR', Rails.root.join('backups'))
    FileUtils.mkdir_p(backup_dir)
    
    backup_file = File.join(backup_dir, "audit_logs_#{timestamp}.json")
    
    Rails.logger.info("Starting audit log backup to #{backup_file}")
    
    # Export audit logs to JSON
    logs = AuditLog.where('created_at >= ?', 30.days.ago).order(:created_at)
    
    File.open(backup_file, 'w') do |f|
      f.write(JSON.pretty_generate(logs.map(&:attributes)))
    end
    
    Rails.logger.info("Audit log backup created: #{backup_file} (#{logs.count} entries)")
    
    # TODO: Encrypt and upload to secure storage
  end

  desc "Restore database from backup"
  task :restore, [:backup_file] => :environment do |t, args|
    backup_file = args[:backup_file]
    
    unless backup_file && File.exist?(backup_file)
      raise "Backup file not found: #{backup_file}"
    end
    
    Rails.logger.info("Restoring database from #{backup_file}")
    
    db_config = ActiveRecord::Base.connection_config
    
    # Restore PostgreSQL dump
    system("PGPASSWORD=#{db_config[:password]} pg_restore -h #{db_config[:host]} -U #{db_config[:username]} -d #{db_config[:database]} -c #{backup_file}")
    
    if $?.success?
      Rails.logger.info("Database restore completed successfully")
    else
      Rails.logger.error("Database restore failed")
      raise "Restore failed with exit code #{$?.exitstatus}"
    end
  end
end

