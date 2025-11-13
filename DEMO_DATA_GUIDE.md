# 🎭 Demo Data Setup Guide

This guide explains how to populate your deployed application with demo therapists and other necessary data.

---

## 📋 What Demo Data Will Be Created?

Running the seed script will create:

### **3 Demo Therapists:**
1. **Dr. Sarah Smith** - LMFT specializing in Anxiety, Family Therapy, Adolescent Counseling
   - Licensed in: CA, NY, TX
   - Languages: English, Spanish
   - Availability: Monday, Wednesday, Friday

2. **Dr. Michael Chen** - PsyD specializing in ADHD, Behavioral Issues, Social Skills
   - Licensed in: CA, WA, OR
   - Languages: English, Mandarin
   - Availability: Tuesday, Thursday

3. **Emily Rodriguez** - LCSW specializing in LGBTQ+ Youth, Depression, Self-Esteem
   - Licensed in: CA, NY
   - Languages: English, Spanish
   - Availability: Monday-Thursday

### **8 Insurance Plans:**
- Blue Cross Blue Shield (CA & NY)
- Aetna (CA & NY)
- UnitedHealthcare (CA)
- Cigna (CA)
- Kaiser Permanente (CA)
- Medicaid (CA)

### **2 Clinical Screeners:**
- PHQ-9 (Modified for Teens) - Depression screening
- GAD-7 for Teens - Anxiety screening

### **Availability Windows:**
- Each therapist has a 3-month availability calendar

---

## 🚀 How to Create Demo Data on Railway

### **Method 1: Using Railway CLI (Recommended)**

```bash
# 1. Link to your Railway project
railway link

# 2. Select the "api" service
railway service api

# 3. Run the seed script
railway run rails db:seed
```

### **Method 2: Using Railway Dashboard Console**

1. Go to your Railway dashboard: https://railway.app
2. Select your project
3. Click on the **"api"** service
4. Click **"Shell"** tab at the top
5. Run this command:
   ```bash
   rails db:seed
   ```

### **Method 3: SSH into Railway (Advanced)**

```bash
# SSH into your API service
railway shell --service api

# Once connected, run:
rails db:seed
```

---

## 📊 Verify Demo Data Was Created

After running the seed script, verify in the Railway console:

```bash
# Count therapists
rails runner "puts 'Therapists: ' + Therapist.count.to_s"

# List therapists
rails runner "Therapist.all.each { |t| puts t.display_name }"

# Count insurance plans
rails runner "puts 'Insurance Plans: ' + CredentialedInsurance.count.to_s"

# Count screeners
rails runner "puts 'Screeners: ' + Screener.count.to_s"
```

Or use Rails console for interactive exploration:

```bash
railway run rails console

# In the console:
Therapist.all
Therapist.first.specialties
Therapist.first.availability_windows
CredentialedInsurance.count
```

---

## 🧹 Resetting Demo Data

If you want to clear and recreate demo data:

```bash
# This will destroy existing therapists and insurances, then recreate them
railway run rails db:seed
```

**⚠️ Warning:** The seed script includes cleanup code that will delete ALL therapists and insurance plans before creating new ones. Comment out these lines in `db/seeds.rb` if you want to preserve existing data:

```ruby
# Comment these out to keep existing data:
# Therapist.destroy_all
# CredentialedInsurance.destroy_all
```

---

## 🔍 Manually Creating Additional Therapists

If you need to create more therapists manually, use Rails console:

```bash
railway run rails console
```

```ruby
# Create a new therapist
Therapist.create!(
  email: "therapist@example.com",
  first_name: "Jane",
  last_name: "Doe",
  phone: "+1-555-0104",
  title: "LMFT",
  npi_number: "1111111111",
  licensed_states: ["CA"],
  primary_state: "CA",
  specialties: ["Anxiety", "Depression"],
  modalities: ["CBT"],
  care_languages: ["English"],
  clinical_role: "Therapist",
  capacity_total: 10,
  capacity_filled: 0,
  active: true,
  bio: "A caring therapist specializing in anxiety and depression."
)
```

---

## 📝 Creating Availability Windows for Therapists

```ruby
# In Rails console
therapist = Therapist.find_by(email: "therapist@example.com")

therapist.availability_windows.create!(
  start_date: Date.today,
  end_date: Date.today + 3.months,
  timezone: "America/Los_Angeles",
  availability_json: {
    "monday" => ["09:00-12:00", "13:00-17:00"],
    "tuesday" => ["09:00-12:00", "13:00-17:00"],
    "wednesday" => ["09:00-12:00", "13:00-17:00"],
    "thursday" => ["09:00-12:00", "13:00-17:00"],
    "friday" => ["09:00-12:00", "14:00-16:00"]
  }
)
```

---

## 🏥 Adding Insurance Plans to Therapists

```ruby
# In Rails console
therapist = Therapist.find_by(email: "therapist@example.com")
insurance = CredentialedInsurance.find_by(name: "Blue Cross Blue Shield", state: "CA")

# Link therapist to insurance
therapist.clinician_credentialed_insurances.create!(
  credentialed_insurance: insurance
)
```

---

## 🔐 Creating Test Parent/Student Accounts

**Note:** Parents and students are created through the onboarding flow in the frontend. However, you can create them manually for testing:

```ruby
# In Rails console
parent = Parent.create!(
  email: "parent@example.com",
  first_name: "John",
  last_name: "Doe",
  phone: "+1-555-0200",
  password: "SecurePassword123!",
  password_confirmation: "SecurePassword123!"
)

student = Student.create!(
  parent: parent,
  first_name: "Alex",
  last_name: "Doe",
  date_of_birth: Date.new(2010, 5, 15),
  grade: "8th Grade",
  school: "Demo Middle School",
  language: "en"
)
```

---

## 🎯 Testing the Onboarding Flow

After creating demo data:

1. **Visit your frontend:** https://web-5pvg50uaf-tony-kims-projects-66df8e1c.vercel.app
2. **Start onboarding** as a parent
3. **Complete the intake questions** - The AI will process them
4. **Review therapist matches** - Your demo therapists should appear
5. **Book an appointment** - Available times will show based on availability windows

---

## 🐛 Troubleshooting

### **Seed Script Fails**
```bash
# Check for errors
railway logs --service api

# Try running migrations first
railway run rails db:migrate

# Then retry seed
railway run rails db:seed
```

### **No Therapists Showing in Frontend**
```bash
# Verify therapists exist and are active
railway run rails runner "puts Therapist.active.count"

# Check availability windows
railway run rails runner "puts AvailabilityWindow.count"
```

### **Insurance Not Working**
```bash
# Verify insurance plans exist
railway run rails runner "puts CredentialedInsurance.count"

# Check therapist-insurance links
railway run rails runner "puts ClinicianCredentialedInsurance.count"
```

---

## 📚 Additional Resources

- **Rails Console Commands:** Use `railway run rails console` for interactive database access
- **Database Queries:** Use `railway run rails runner "YourRubyCode"` for one-off commands
- **View Logs:** Use `railway logs --service api` to debug issues

---

## ✅ Next Steps

After creating demo data:

1. ✅ Test the onboarding flow end-to-end
2. ✅ Book a demo appointment
3. ✅ Review the therapist matching algorithm
4. ✅ Test insurance verification (if integrated)
5. ✅ Add custom therapist profiles as needed

---

**Need help?** Check Railway logs or run `railway shell` to access the Rails console directly!

