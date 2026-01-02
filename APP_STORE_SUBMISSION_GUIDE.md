# 🚀 App Store Submission Guide - Mood Tracker

## 📋 **Pre-Submission Checklist**

### ✅ **What You Have:**
- [x] Complete iOS app with SwiftUI
- [x] App icons (all sizes)
- [x] Supabase backend integration
- [x] Calendar sync feature
- [x] Onboarding tutorial
- [x] Professional design (iOS 26 style)

### ⚠️ **What You Need:**
- [ ] Apple Developer Account ($99/year)
- [ ] Privacy Policy URL (required for App Store)
- [ ] App screenshots (5 sizes)
- [ ] App description and metadata
- [ ] Test account credentials (for App Review)

---

## 🎯 **Phase 1: Apple Developer Account Setup**

### **Step 1: Enroll in Apple Developer Program**

1. Go to: https://developer.apple.com/programs/enroll/
2. Sign in with your Apple ID
3. Click **"Start Your Enrollment"**
4. Complete the enrollment form
5. Pay **$99 USD** (annual fee)
6. Wait for approval (24-48 hours)

**Important:** You cannot submit apps without this!

---

## 📱 **Phase 2: Prepare Your App in Xcode**

### **Step 2: Configure App Identifier**

1. Open your project in **Xcode**
2. Select the **MoodApp** target
3. Go to **"Signing & Capabilities"** tab
4. Set a unique **Bundle Identifier**:
   - Example: `com.yourname.moodtracker`
   - Must be unique across all App Store apps
   - Cannot be changed after first submission

5. **Enable "Automatically manage signing"**
   - Select your **Team** (your Apple Developer account)
   - Xcode will create certificates and provisioning profiles

### **Step 3: Set Version & Build Number**

In Xcode, under **General** tab:
- **Version**: `1.0.0` (this is what users see)
- **Build**: `1` (internal build number, increment for each upload)

### **Step 4: Configure App Category**

In **Info.plist**, you can add:
- **LSApplicationCategoryType**: `public.app-category.healthcare-fitness`

---

## 🖼️ **Phase 3: Create Required Assets**

### **Step 5: App Screenshots (REQUIRED)**

You need screenshots for these device sizes:

#### **6.7" Display (iPhone 14 Pro Max, 15 Pro Max)**
- Size: **1290 x 2796 pixels**
- Required: 3-10 screenshots

#### **6.5" Display (iPhone 11 Pro Max, XS Max)**
- Size: **1242 x 2688 pixels**
- Required: 3-10 screenshots

#### **5.5" Display (iPhone 8 Plus)**
- Size: **1242 x 2208 pixels**
- Required: 3-10 screenshots

**How to Create Screenshots:**

1. Run app in **Simulator** (Command + R)
2. Choose device: **iPhone 15 Pro Max**
3. Navigate to key screens:
   - Login screen
   - Main mood logger with circle
   - Calendar view with moods
   - Account settings
   - Tutorial screen
4. Press **Command + S** to save screenshot
5. Screenshots save to **Desktop**
6. Repeat for each device size

**Pro Tip:** Use Simulator → Window → Scale → 100% for best quality

---

### **Step 6: Create Privacy Policy (REQUIRED)**

Since you collect user data (email, moods), you **must** have a privacy policy.

**Quick Options:**

1. **Use a Generator:**
   - https://www.privacypolicygenerator.info/
   - https://www.freeprivacypolicy.com/

2. **Host it:**
   - Create a simple webpage
   - Host on GitHub Pages (free)
   - Or use Notion/Google Docs with public link

**What to Include:**
- What data you collect (email, mood logs)
- How you use it (tracking emotional wellbeing)
- Third-party services (Supabase)
- User rights (deletion, export)
- Contact information

**Example Privacy Policy Structure:**
```
1. Information We Collect
   - Email address (for account creation)
   - Mood entries (date, mood type, notes)
   - Calendar data (if sync enabled)

2. How We Use Information
   - To provide mood tracking service
   - To sync with your iOS calendar (optional)
   - To maintain your account

3. Data Storage
   - Stored securely on Supabase servers
   - Encrypted in transit and at rest
   - Not shared with third parties

4. Your Rights
   - Delete account and all data
   - Export your data
   - Opt-out of calendar sync

5. Contact
   - Email: your@email.com
```

---

## 🌐 **Phase 4: App Store Connect Setup**

### **Step 7: Create App in App Store Connect**

1. Go to: https://appstoreconnect.apple.com/
2. Click **"My Apps"**
3. Click **"+"** → **"New App"**
4. Fill in:
   - **Platform**: iOS
   - **Name**: "Mood Tracker" (or your preferred name)
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select the one from Xcode
   - **SKU**: Any unique identifier (e.g., "moodtracker001")
   - **User Access**: Full Access

### **Step 8: Complete App Information**

#### **App Information:**
- **Name**: Mood Tracker
- **Subtitle** (optional): Track Your Daily Emotional Wellbeing
- **Category**: 
  - Primary: **Health & Fitness**
  - Secondary: **Lifestyle**

#### **Pricing and Availability:**
- **Price**: Free (or set a price)
- **Availability**: All countries (or select specific ones)

#### **Privacy:**
- **Privacy Policy URL**: [Your privacy policy URL]
- **Data Collection**: 
  - ✅ Health & Fitness (mood data)
  - ✅ User Content (notes)
  - ✅ Identifiers (email)
  - ✅ Usage Data (calendar sync)

### **Step 9: Create App Description**

**Example App Description:**

```
Track your daily mood and discover patterns in your emotional wellbeing.

FEATURES:
• Simple swipe gesture to log your mood (Good, Mid, or Bad)
• Beautiful, minimal design with smooth animations
• Calendar view to see your mood history at a glance
• Optional sync with iOS Calendar app
• Add notes for context
• Secure cloud backup with Supabase
• Interactive onboarding tutorial

PRIVACY FIRST:
Your mood data is private and secure. We only use your data to provide the service, never for advertising or selling to third parties.

HOW IT WORKS:
1. Open the app
2. Swipe to select your mood
3. Add optional context notes
4. Track your patterns over time

Perfect for:
• Mental health awareness
• Identifying emotional patterns
• Tracking therapy progress
• General wellbeing

Download now and start your emotional wellbeing journey!
```

**Keywords** (100 characters max):
```
mood,tracker,journal,mental,health,wellbeing,emotions,diary,calendar,feelings
```

### **Step 10: Upload Screenshots**

In App Store Connect:
1. Go to **App Store** tab
2. Scroll to **App Previews and Screenshots**
3. Select device size (6.7", 6.5", 5.5")
4. Drag and drop your screenshots
5. Arrange in order (most important first)

---

## 🏗️ **Phase 5: Build and Upload**

### **Step 11: Archive Your App**

1. In **Xcode**, select **Any iOS Device (arm64)** as destination
   - Do NOT use Simulator
2. **Product** → **Archive**
3. Wait for archive to complete (2-5 minutes)
4. **Organizer** window will open automatically

### **Step 12: Upload to App Store Connect**

1. In **Organizer**, select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Click **"Upload"**
5. Choose:
   - ✅ Upload symbols (for crash reports)
   - ✅ Manage version and build number
6. Click **"Next"**
7. Review and **"Upload"**
8. Wait for processing (10-30 minutes)

---

## 📝 **Phase 6: Submit for Review**

### **Step 13: Select Build**

1. Go back to **App Store Connect**
2. Go to your app → **App Store** tab
3. Under **Build**, click **"+ "**
4. Select your uploaded build (may take 10-30 min to appear)
5. Click **"Done"**

### **Step 14: App Review Information**

Provide test account credentials:

```
Email: test@yourdomain.com
Password: YourTestPassword123

Notes for Reviewer:
"This app requires a test account to login. Please use the credentials above.

Key features to test:
1. Swipe gesture to select mood (left/right/up)
2. View calendar history
3. Enable calendar sync in Account settings (optional)
4. Tutorial appears on first launch

No special configuration needed. All features are self-explanatory."
```

**Important:** Create a real test account in your Supabase database!

### **Step 15: Age Rating**

Answer the questionnaire:
- Violence: None
- Mature/Suggestive: None
- Horror/Fear: None
- Medical/Treatment: None
- Alcohol/Tobacco: None
- Gambling: None
- Profanity: None

**Likely Rating: 4+** (No restrictions)

### **Step 16: Submit!**

1. Review all information
2. Click **"Add for Review"**
3. Click **"Submit to App Review"**
4. Wait for review (typically 24-48 hours)

---

## ⏳ **Phase 7: Review Process**

### **What Happens Next:**

1. **In Review** (24-48 hours)
   - Apple tests your app
   - Checks for guideline violations
   - Tests core functionality

2. **Possible Outcomes:**
   - ✅ **Approved**: App goes live immediately (or on your chosen date)
   - ❌ **Rejected**: You'll get specific reasons why
     - Fix issues
     - Re-submit (usually faster review, 12-24 hours)

### **Common Rejection Reasons to Avoid:**

- Missing privacy policy
- Incomplete app information
- Crashes on launch
- Non-functional features
- Misleading screenshots
- Missing test account
- Using placeholder content

---

## 🎉 **Phase 8: Post-Approval**

### **Your App is Live!**

Once approved:
- App appears on App Store within 24 hours
- Users can download it
- You'll see downloads in App Store Connect Analytics

### **Updating Your App:**

For future updates:
1. Increment **Build Number** (2, 3, 4...)
2. Optionally update **Version** (1.0.1, 1.1.0, 2.0.0)
3. Archive and upload new build
4. Submit update with "What's New" description
5. Reviews are typically faster (12-24 hours)

---

## 📊 **Quick Timeline:**

| Phase | Time |
|-------|------|
| Developer account approval | 24-48 hours |
| Create screenshots | 1-2 hours |
| Write privacy policy | 1-2 hours |
| Set up App Store Connect | 30 minutes |
| Archive and upload | 15-30 minutes |
| Processing in App Store Connect | 10-30 minutes |
| App Review | 24-48 hours |
| **Total (if no rejections)** | **3-5 days** |

---

## 🛠️ **Tools You'll Need:**

1. **Xcode** (for archiving/uploading) ✅ You have this
2. **Apple Developer Account** ($99/year) ⚠️ Need to create
3. **Screenshot tool** (built into Simulator) ✅ You have this
4. **Web hosting** (for privacy policy) ⚠️ Need to create
5. **Test Supabase account** ⚠️ Need to create

---

## 🚨 **Before You Submit - Final Checklist:**

### **Technical:**
- [ ] App builds without errors
- [ ] All features work on real device (not just simulator)
- [ ] No crashes on launch
- [ ] Calendar permissions work correctly
- [ ] Login/Signup flow works
- [ ] Tutorial appears on first launch
- [ ] All icons display correctly

### **Assets:**
- [ ] App icons (all sizes) ✅ Done!
- [ ] Screenshots (3 device sizes)
- [ ] Privacy policy (hosted with URL)

### **App Store Connect:**
- [ ] App description written
- [ ] Keywords added
- [ ] Categories selected
- [ ] Screenshots uploaded
- [ ] Test account created and working
- [ ] Build uploaded and selected
- [ ] Age rating completed

### **Legal:**
- [ ] Privacy policy covers all data collection
- [ ] Terms of Service (optional but recommended)
- [ ] Contact email provided

---

## 💡 **Pro Tips:**

1. **Test on a Real Device:**
   - Borrow an iPhone if you don't have one
   - TestFlight allows testing before submission

2. **Use App Store Connect API:**
   - Automate screenshots with tools like Fastlane
   - Saves hours for future updates

3. **Soft Launch Strategy:**
   - Release in one country first
   - Fix any issues
   - Then release worldwide

4. **Monitor Reviews:**
   - Respond to user feedback
   - Fix bugs quickly
   - Update regularly

5. **Marketing:**
   - Share on social media
   - Create a landing page
   - Ask friends to download and review

---

## ❓ **Common Questions:**

**Q: How much does it cost?**
A: $99/year for Apple Developer Program. No other fees if app is free.

**Q: How long does review take?**
A: Typically 24-48 hours for first submission, 12-24 hours for updates.

**Q: Can I test before submitting?**
A: Yes! Use TestFlight (internal testing, up to 100 users).

**Q: What if my app gets rejected?**
A: Fix the issues and resubmit. You can resubmit unlimited times.

**Q: Do I need a company?**
A: No! You can submit as an individual.

**Q: Can I update after launch?**
A: Yes! You can push updates anytime (they go through review too).

---

## 🎯 **Next Steps for You:**

### **Immediate (Today):**
1. ✅ Sign up for Apple Developer Program
2. ✅ Create test account in Supabase
3. ✅ Write privacy policy (use template above)
4. ✅ Host privacy policy (GitHub Pages, Notion, etc.)

### **While Waiting for Approval (1-2 days):**
5. ✅ Take app screenshots in Simulator
6. ✅ Write app description and keywords
7. ✅ Test app thoroughly on real device (if possible)

### **After Developer Account Approval:**
8. ✅ Configure signing in Xcode
9. ✅ Archive and upload build
10. ✅ Complete App Store Connect setup
11. ✅ Submit for review!

---

## 📞 **Need Help?**

If you get stuck:
- Apple Developer Support: https://developer.apple.com/contact/
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

---

**Good luck with your submission! 🚀**

Your app is well-built, beautifully designed, and ready for the App Store. The process might seem complex, but take it step by step and you'll have it live in less than a week!

