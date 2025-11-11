#!/usr/bin/env ruby
# Test script for insurance card upload GraphQL mutation
# Usage: rails runner test_insurance_upload.rb

require 'graphql'

puts "=" * 80
puts "TESTING INSURANCE CARD UPLOAD GRAPHQL MUTATION"
puts "=" * 80

# Step 1: Create test data
puts "\n1. Creating test parent and student..."
parent = Parent.find_or_create_by!(email: "test@example.com") do |p|
  p.first_name = "Test"
  p.last_name = "Parent"
  p.auth_provider = "magic_link"
  p.account_status = "active"
end

student = parent.students.find_or_create_by!(first_name: "Test", last_name: "Student") do |s|
  s.date_of_birth = 10.years.ago
  s.language = "eng"
  s.account_status = "active"
end

puts "   ✅ Parent ID: #{parent.id}"
puts "   ✅ Student ID: #{student.id}"

# Step 2: Create onboarding session
puts "\n2. Creating onboarding session..."
session = OnboardingSession.find_or_create_by!(
  parent: parent,
  student: student,
  status: 'active'
) do |s|
  s.current_step = 5 # Insurance step (max is 5)
end

puts "   ✅ Session ID: #{session.id}"

# Step 3: Prepare GraphQL mutation
puts "\n3. Preparing GraphQL mutation..."
mutation = <<~GQL
  mutation UploadInsuranceCard($input: UploadInsuranceCardInput!) {
    uploadInsuranceCard(input: $input) {
      insuranceCard {
        id
        frontImageUrl
        backImageUrl
        ocrData
        confidenceScores
      }
      errors
    }
  }
GQL

variables = {
  input: {
    sessionId: session.id.to_s,
    frontImageUrl: "https://www.tdi.texas.gov/artwork/compliance/bcbstx.png",
    backImageUrl: nil
  }
}

# Step 4: Execute mutation
puts "\n4. Executing GraphQL mutation..."
puts "   Front Image URL: #{variables[:input][:frontImageUrl]}"
puts "   This may take 10-30 seconds for OCR extraction..."

context = {
  current_user: parent,
  controller: nil
}

# Temporarily disable audit logging for test
original_log_access = AuditLog.method(:log_access)
AuditLog.define_singleton_method(:log_access) do |**kwargs|
  # Skip audit logging in test
  Rails.logger.debug("Skipping audit log in test: #{kwargs[:action]} on #{kwargs[:entity].class.name}")
end

begin
  result = ApiSchema.execute(
    mutation,
    variables: variables,
    context: context
  )

  if result['errors']
    puts "\n❌ GraphQL Errors:"
    result['errors'].each do |error|
      puts "   - #{error['message']}"
    end
  else
    data = result['data']['uploadInsuranceCard']
    
    if data['errors'].any?
      puts "\n⚠️  Mutation returned errors:"
      data['errors'].each { |e| puts "   - #{e}" }
    end
    
    if data['insuranceCard']
      card = data['insuranceCard']
      puts "\n✅ Insurance Card Uploaded Successfully!"
      puts "   Card ID: #{card['id']}"
      puts "   Front Image: #{card['frontImageUrl']}"
      
      if card['ocrData']
        puts "\n📋 Extracted OCR Data:"
        card['ocrData'].each do |key, value|
          confidence = card['confidenceScores']&.[](key) || 'unknown'
          puts "   - #{key}: #{value} (confidence: #{confidence})"
        end
      else
        puts "\n⚠️  No OCR data found (extraction may have failed)"
      end
    else
      puts "\n❌ No insurance card returned"
    end
  end
  
  puts "\n" + "=" * 80
  puts "TEST COMPLETE"
  puts "=" * 80
  
rescue StandardError => e
  puts "\n❌ ERROR: #{e.class.name}"
  puts "   Message: #{e.message}"
  puts "   Backtrace:"
  puts e.backtrace.first(5).map { |l| "     #{l}" }.join("\n")
ensure
  # Restore original audit logging
  AuditLog.define_singleton_method(:log_access, original_log_access)
end

