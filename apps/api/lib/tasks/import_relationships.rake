namespace :import do
  desc "Import referrals from CSV"
  task referrals: :environment do
    importer = Importers::ReferralImporter.new
    importer.import
    
    # Post-import: Validate relationships
    puts "\nValidating referral relationships..."
    Referral.find_each do |referral|
      unless Parent.exists?(id: referral.submitter_id)
        puts "Warning: Submitter #{referral.submitter_id} not found for referral #{referral.id}"
      end
      unless Organization.exists?(id: referral.organization_id)
        puts "Warning: Organization #{referral.organization_id} not found for referral #{referral.id}"
      end
    end
  end

  desc "Import referral members from CSV"
  task referral_members: :environment do
    importer = Importers::ReferralMemberImporter.new
    importer.import
    
    # Post-import: Validate relationships
    puts "\nValidating referral member relationships..."
    ReferralMember.find_each do |member|
      unless Referral.exists?(id: member.referral_id)
        puts "Warning: Referral #{member.referral_id} not found for member #{member.id}"
        member.destroy
      end
      user_class = member.user_type.constantize
      unless user_class.exists?(id: member.user_id)
        puts "Warning: #{member.user_type} #{member.user_id} not found for member #{member.id}"
        member.destroy
      end
    end
  end

  desc "Import kinships from CSV"
  task kinships: :environment do
    importer = Importers::KinshipImporter.new
    importer.import
    
    # Post-import: Validate relationships
    puts "\nValidating kinship relationships..."
    Kinship.find_each do |kinship|
      user_0_class = kinship.user_0_type.constantize
      user_1_class = kinship.user_1_type.constantize
      
      unless user_0_class.exists?(id: kinship.user_0_id)
        puts "Warning: #{kinship.user_0_type} #{kinship.user_0_id} not found for kinship #{kinship.id}"
        kinship.destroy
      end
      unless user_1_class.exists?(id: kinship.user_1_id)
        puts "Warning: #{kinship.user_1_type} #{kinship.user_1_id} not found for kinship #{kinship.id}"
        kinship.destroy
      end
    end
  end

  desc "Import memberships from CSV"
  task memberships: :environment do
    importer = Importers::MembershipImporter.new
    importer.import
    
    # Post-import: Validate relationships
    puts "\nValidating membership relationships..."
    Membership.find_each do |membership|
      unless Organization.exists?(id: membership.organization_id)
        puts "Warning: Organization #{membership.organization_id} not found for membership #{membership.id}"
        membership.destroy
      end
      user_class = membership.user_type.constantize
      unless user_class.exists?(id: membership.user_id)
        puts "Warning: #{membership.user_type} #{membership.user_id} not found for membership #{membership.id}"
        membership.destroy
      end
    end
  end

  desc "Import all referral and relationship data"
  task relationships: :environment do
    puts "Importing referral and relationship data in dependency order..."
    puts "\n=== Step 1: Referrals ==="
    Rake::Task['import:referrals'].invoke
    
    puts "\n=== Step 2: Referral Members ==="
    Rake::Task['import:referral_members'].invoke
    
    puts "\n=== Step 3: Kinships ==="
    Rake::Task['import:kinships'].invoke
    
    puts "\n=== Step 4: Memberships ==="
    Rake::Task['import:memberships'].invoke
    
    puts "\n\nAll referral and relationship data imported successfully!"
  end
end

