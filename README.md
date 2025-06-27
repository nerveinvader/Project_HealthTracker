# Project_HealthTracker
Health Tracking Application for HTN, DM, HLP

# High level roadmap:
User types: patient, physician, admin
Labs: HbA1c, FBS, 2HPP, Lipid Profile, BP (S,D)
Deploying platform >>> ???
	[Supabase/Appwrite on Iranian cloud such as Liara or Arvan]
	[Iranina SMS gateway such as Kavenegar]
	[Push notification and Analytics such as Pushe or Push-Pole + Metrix]
Authentication >>> ???
Patient profile CRUD
Lab entry
Med entry
Screens (
	Login + Auth, >>> INCOMPLETE
	Home, Settings, About/Contact, Charts, Disease Dashboard,
	Add or Edit Lab/Med, Edit Profile, >>> INCOMPLETE!
)
Metrics (
	Acquisition (new install + source),
	Activation (profile and first entry),
	Engagement (average entries per month)
	Retention (week and month retention)
)

# Extra features
Calorie tracker
Article recommendation
Physician interface
AI
Subscription

# Screens in the App for Client Side
# Some DONE pages are still in need of fine-tuning and final touches.
1. *** Welcome page
2. DONE *** Login page
3. *** OTP page (login code via SMS)
4. DONE *** Create Profile page
5. WIP *** Patient Home page (main page to navigate)
6. DONE *** Setting page
7. DONE *** About Us page
8. DONE *** Contact page
9. WIP *** Add/Edit Medication page (plain text imput for physician to look up)
10. WIP *** Add/Edit Labs page (has all lab types)
11. *** Profile Edit page (maybe reuse the same as create_profile page)
12. DONE *** Chart View page (one for all labs getting data to show)
13. DONE *** Specific Disease page (DM, HTN, HLP with specific labs for each)

# Screens in the App for Admin Side
1. Welcome, Login, OTP, Setting, About Us, Contact pages
2. *** Patients Form page
3. *** Patients List page
4. *** Patient Detail page
5. *** Lab Entry Form page
