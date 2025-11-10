# Use this file to define scheduled tasks for whenever gem
# Learn more: http://github.com/javan/whenever

# Run data retention cleanup weekly
every 1.week, at: '2:00 am' do
  rake 'data_retention:cleanup'
end

# Create daily database backups
every 1.day, at: '3:00 am' do
  rake 'backup:database'
end

# Create weekly audit log backups
every 1.week, at: '4:00 am' do
  rake 'backup:audit_logs'
end

