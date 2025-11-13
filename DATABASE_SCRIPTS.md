# 📊 Database Inspection & Management Scripts

Quick reference for inspecting and managing your Railway database.

---

## 🔍 **Step 1: Inspect Current Database**

First, let's see what's already in your database:

### **Run in Railway Dashboard:**

1. Go to: https://railway.app/project/4c595645-6ca4-4ac5-9403-f2ab7ac80d46
2. Click **"api"** service
3. Click **"Shell"** tab
4. Run this command:

```bash
rails runner scripts/inspect_database.rb
```

**This will show you:**
- ✅ All existing therapists with their details
- ✅ Availability windows
- ✅ Insurance plans
- ✅ Parents, students, appointments
- ✅ Complete database summary

---

## 📤 **Step 2: Export Existing Therapists**

If you want to preserve existing therapist data and add it to your seed file:

### **Run in Railway Dashboard:**

```bash
rails runner scripts/export_existing_therapists.rb
```

**This will output:**
- ✅ Ruby code for all existing therapists
- ✅ Their availability windows
- ✅ Insurance plan associations
- ✅ Ready to copy/paste into `db/seeds.rb`

**Then:**
1. Copy the output
2. Edit `apps/api/db/seeds.rb` locally
3. Paste the exported data into the seed file
4. Commit and push

---

## 🌱 **Step 3: Seed Demo Data**

### **Option A: Preserve Existing Data (Default)**

This will ADD demo therapists without deleting existing ones:

```bash
rails db:seed
```

### **Option B: Clean Slate (Wipe & Recreate)**

This will DELETE all therapists and insurance, then create demo data:

```bash
CLEAN_SEED=true rails db:seed
```

---

## 📋 **Quick Command Reference**

### **Inspect Database**
```bash
rails runner scripts/inspect_database.rb
```

### **Export Current Therapists**
```bash
rails runner scripts/export_existing_therapists.rb
```

### **Seed Demo Data (Keep Existing)**
```bash
rails db:seed
```

### **Seed Demo Data (Clean Start)**
```bash
CLEAN_SEED=true rails db:seed
```

### **Count Records**
```bash
rails runner "puts Therapist.count"
rails runner "puts Parent.count"
rails runner "puts Student.count"
rails runner "puts Appointment.count"
```

### **List All Therapists**
```bash
rails runner "Therapist.all.each { |t| puts '#{t.display_name} - #{t.email}' }"
```

### **Delete All Therapists (Careful!)**
```bash
rails runner "Therapist.destroy_all"
```

---

## 🎯 **Recommended Workflow**

### **For a New Deployment:**

1. **Inspect database** (likely empty):
   ```bash
   rails runner scripts/inspect_database.rb
   ```

2. **Seed demo data**:
   ```bash
   rails db:seed
   ```

3. **Verify**:
   ```bash
   rails runner scripts/inspect_database.rb
   ```

### **If You Have Existing Data:**

1. **Inspect current data**:
   ```bash
   rails runner scripts/inspect_database.rb
   ```

2. **Export it** (optional, for backup):
   ```bash
   rails runner scripts/export_existing_therapists.rb > existing_data_backup.txt
   ```

3. **Add demo data without deleting**:
   ```bash
   rails db:seed
   ```

4. **Verify combined data**:
   ```bash
   rails runner scripts/inspect_database.rb
   ```

---

## 🔧 **Troubleshooting**

### **Script Not Found**
```bash
# Make sure you're in the right directory
cd /rails

# Or use full path
rails runner /rails/scripts/inspect_database.rb
```

### **Permission Denied**
```bash
# Scripts should be executable after git pull
# If not, run in Railway shell:
chmod +x scripts/*.rb
```

### **Database Connection Error**
```bash
# Check DATABASE_URL is set
echo $DATABASE_URL

# Verify database is running in Railway dashboard
```

---

## 📊 **What Demo Data Includes**

Running `rails db:seed` creates:

### **3 Therapists:**
1. **Dr. Sarah Smith** - LMFT
   - Specialties: Anxiety, Family Therapy, Adolescent Counseling
   - States: CA, NY, TX
   - Languages: English, Spanish
   - Capacity: 10/15 available

2. **Dr. Michael Chen** - PsyD
   - Specialties: ADHD, Behavioral Issues, Social Skills
   - States: CA, WA, OR
   - Languages: English, Mandarin
   - Capacity: 8/20 available

3. **Emily Rodriguez** - LCSW
   - Specialties: LGBTQ+ Youth, Depression, Self-Esteem
   - States: CA, NY
   - Languages: English, Spanish
   - Capacity: 9/12 available

### **8 Insurance Plans:**
- Blue Cross Blue Shield (CA & NY)
- Aetna (CA & NY)
- UnitedHealthcare (CA)
- Cigna (CA)
- Kaiser Permanente (CA)
- Medicaid (CA)

### **Availability Windows:**
- Each therapist has 3-month availability calendars
- Different days/times for realistic scheduling

### **2 Screeners:**
- PHQ-9 Modified for Teens
- GAD-7 for Teens

---

## 🚀 **Next Steps**

After seeding:

1. ✅ Visit your frontend: https://web-5pvg50uaf-tony-kims-projects-66df8e1c.vercel.app
2. ✅ Complete parent onboarding
3. ✅ See therapist matches
4. ✅ Book appointments

---

**All scripts are in:** `apps/api/scripts/`

**Seed file is in:** `apps/api/db/seeds.rb`

**Need more help?** See `DEMO_DATA_GUIDE.md` for detailed documentation!

