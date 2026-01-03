# 🐙 Octomood

> Track your mood with an adorable octopus companion

Octomood is a beautiful, minimal iOS app for tracking your daily emotional wellbeing. Simple swipe gestures make logging your mood effortless, while a stunning calendar view helps you discover patterns over time. Features an adorable animated octopus that responds to your emotions!

## ✨ Features

- **🎯 Simple Mood Tracking**
  - Swipe right for good days
  - Swipe left for bad days
  - Swipe up for mid days
  
- **📊 Beautiful Calendar View**
  - Week, month, and year views
  - Color-coded mood history
  - Interactive day selection
  
- **📅 iOS Calendar Integration**
  - Optional sync with native Calendar app
  - View moods alongside your schedule
  - Automatic calendar management
  
- **💭 Add Context**
  - Optional notes for each day
  - Remember what influenced your mood
  
- **🔒 Private & Secure**
  - End-to-end encryption
  - Secure cloud backup with Supabase
  - Your data is yours alone
  
- **✨ Modern Design**
  - iOS 26 design aesthetic
  - Glassmorphism effects
  - Smooth 60FPS animations
  - Haptic feedback
  - Interactive tutorial
  
- **🐙 Octopus Mode**
  - Adorable animated octopus companion
  - 161 frames of smooth animation
  - Transitions from happy to sad
  - Toggle in Account settings

## 🛠️ Tech Stack

- **Frontend:** SwiftUI
- **Backend:** Supabase (PostgreSQL, Auth, Realtime)
- **Calendar:** EventKit
- **Design:** iOS 26 design principles

## 🚀 Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 17.0+ deployment target
- Supabase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/detherdev/octomood.git
cd octomood
```

2. Open the project in Xcode:
```bash
open MoodApp/MoodApp.xcodeproj
```

3. Add your Supabase credentials:
   - Open `MoodApp/Managers/SupabaseManager.swift`
   - Replace the placeholder URL and API key with your own:
   ```swift
   private let supabaseURL = "YOUR_SUPABASE_URL"
   private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
   ```

4. Add Supabase Swift package:
   - In Xcode, go to File → Add Package Dependencies
   - Enter: `https://github.com/supabase/supabase-swift`
   - Select all products: Supabase, Auth, PostgREST, Realtime, Storage

5. Build and run! (⌘ + R)

### Database Setup

Run this SQL in your Supabase SQL Editor:

```sql
-- Create moods table
create table public.moods (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  date date not null,
  mood text not null check (mood in ('good', 'mid', 'bad')),
  note text,
  is_synced_to_calendar boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, date)
);

-- Enable RLS
alter table public.moods enable row level security;

-- Create policy for users to manage their own moods
create policy "Users can manage their own moods"
  on public.moods
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Create index for faster queries
create index moods_user_id_date_idx on public.moods(user_id, date desc);
```

## 📸 Screenshots

Coming soon!

## 🔐 Privacy

We take your privacy seriously. Read our [Privacy Policy](https://detherdev.github.io/octomood/privacy-policy.html) to learn how we protect your data.

**Key Points:**
- We never sell or share your data
- End-to-end encryption
- You control your data (view, edit, delete, export)
- Optional calendar sync (you control it)
- Secure cloud backup with Supabase

## 📱 App Store

Coming soon to the App Store!

<!-- Uncomment when live:
<a href="https://apps.apple.com/app/octomood/idXXXXXXXXX">
  <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on App Store" height="50">
</a>
-->

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

- **Support:** support@octomood.app
- **Privacy:** privacy@octomood.app
- **Website:** https://detherdev.github.io/octomood

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Backend powered by [Supabase](https://supabase.com)
- Inspired by the importance of emotional awareness and mental health

---

**Made with 💜 and 🐙 for your emotional wellbeing**

