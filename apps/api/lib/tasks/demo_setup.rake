namespace :demo do
  desc "Credential all therapists with Blue Cross Blue Shield for demo purposes"
  task setup_bcbs: :environment do
    puts "\n" + "=" * 80
    puts "DEMO SETUP: Credentialing all therapists with Blue Cross Blue Shield"
    puts "=" * 80

    # Find Blue Cross Blue Shield credentialed insurance
    # Use any BCBS variant (preferably in-network)
    bcbs = CredentialedInsurance.where("name ILIKE ?", "%blue%cross%shield%")
                                .where(network_status: :in_network)
                                .first ||
           CredentialedInsurance.where("name ILIKE ?", "%blue%cross%shield%").first

    unless bcbs
      puts "\n❌ ERROR: Could not find Blue Cross Blue Shield in database"
      puts "Available insurance options:"
      CredentialedInsurance.limit(10).each do |insurance|
        puts "  - #{insurance.name} (#{insurance.state || 'N/A'}) - ID: #{insurance.id}"
      end
      exit 1
    end

    puts "\n✓ Found: #{bcbs.name} (#{bcbs.state}) - Network Status: #{bcbs.network_status}"
    puts "  ID: #{bcbs.id}"
    puts "  In-network: #{bcbs.in_network?}"

    # Get all therapists
    therapists = Therapist.all
    puts "\n📋 Found #{therapists.count} therapists to credential"

    created_count = 0
    existing_count = 0

    therapists.each do |therapist|
      # Check if already credentialed
      existing = ClinicianCredentialedInsurance.find_by(
        care_provider_profile_id: therapist.id,
        credentialed_insurance_id: bcbs.id
      )

      if existing
        existing_count += 1
        print "."
      else
        ClinicianCredentialedInsurance.create!(
          care_provider_profile_id: therapist.id,
          credentialed_insurance_id: bcbs.id
        )
        created_count += 1
        print "+"
      end
    end

    puts "\n\n✅ COMPLETE!"
    puts "   #{created_count} new credentials created"
    puts "   #{existing_count} therapists already credentialed"
    puts "   #{created_count + existing_count} total therapists now accept BCBS"
    puts "\n" + "=" * 80
  end

  desc "Remove Blue Cross Blue Shield credentials from all therapists"
  task teardown_bcbs: :environment do
    puts "\n" + "=" * 80
    puts "DEMO TEARDOWN: Removing BCBS credentials"
    puts "=" * 80

    bcbs = CredentialedInsurance.find_by(
      name: "BCBS",
      state: "TX",
      line_of_business: "1"
    )

    unless bcbs
      puts "\n❌ ERROR: Could not find BCBS insurance"
      exit 1
    end

    count = ClinicianCredentialedInsurance.where(credentialed_insurance_id: bcbs.id).count
    ClinicianCredentialedInsurance.where(credentialed_insurance_id: bcbs.id).destroy_all

    puts "\n✅ Removed #{count} BCBS credentials"
    puts "=" * 80
  end
end

