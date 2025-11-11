#!/usr/bin/env ruby
# Test script for specific insurance card image
# Usage: rails runner test_specific_card.rb [image_url]

require 'graphql'

image_url = ARGV[0] || "https://www.tdi.texas.gov/artwork/compliance/bcbstx.png"

puts "=" * 80
puts "TESTING SPECIFIC INSURANCE CARD OCR EXTRACTION"
puts "=" * 80
puts "\nImage URL: #{image_url}"
puts "\nExpected values from card:"
puts "  - Member Name: JAMIE DOE"
puts "  - Identification Number: ABC123456789"
puts "  - Group Number: 123456"
puts "  - Plan Type: PPO Plan"
puts "=" * 80

begin
  result = InsuranceOcrService.extract(
    front_image_url: image_url,
    back_image_url: nil
  )

  puts "\n✅ OCR Extraction Completed!"
  puts "\n📋 Extracted Data:"
  puts "-" * 80
  
  extracted = result[:extracted_data]
  confidence = result[:confidence_scores]
  
  # Check each expected field
  expected_fields = {
    "Member Name" => { key: :subscriber_name, expected: "JAMIE DOE" },
    "Identification Number" => { key: :member_id, expected: "ABC123456789" },
    "Group Number" => { key: :group_number, expected: "123456" },
    "Plan Type" => { key: :plan_type, expected: "PPO" },
    "Payer Name" => { key: :payer_name, expected: "Blue Cross Blue Shield" }
  }
  
  expected_fields.each do |label, info|
    key = info[:key]
    expected = info[:expected]
    actual = extracted[key.to_s] || extracted[key]
    conf = confidence[key.to_s] || confidence[key] || 'unknown'
    
    match = actual.to_s.upcase.include?(expected.upcase) || expected.upcase.include?(actual.to_s.upcase)
    status = match ? "✅" : "❌"
    
    puts "#{status} #{label}:"
    puts "   Expected: #{expected}"
    puts "   Extracted: #{actual || '(not found)'}"
    puts "   Confidence: #{conf}"
    puts "   Match: #{match ? 'YES' : 'NO'}"
    puts ""
  end
  
  puts "\n📊 All Extracted Fields:"
  extracted.each do |key, value|
    conf = confidence[key.to_s] || confidence[key] || 'unknown'
    puts "   - #{key}: #{value} (confidence: #{conf})"
  end
  
  puts "\n" + "=" * 80
  puts "TEST COMPLETE"
  puts "=" * 80
  
rescue StandardError => e
  puts "\n❌ ERROR: #{e.class.name}"
  puts "   Message: #{e.message}"
  puts "   Backtrace:"
  puts e.backtrace.first(10).map { |l| "     #{l}" }.join("\n")
end

