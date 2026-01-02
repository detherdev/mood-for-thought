# iOS Calendar Sync Setup

## Required: Add Calendar Permission to Your Xcode Project

To enable Calendar sync functionality, you need to add the calendar permission to your app:

### Steps in Xcode:

1. **Open your project in Xcode**
2. **Select your app target** (MoodApp) in the project navigator
3. **Go to the "Info" tab**
4. **Add a new entry to "Custom iOS Target Properties":**
   - **Key:** `NSCalendarsUsageDescription` (or select "Privacy - Calendars Usage Description" from the dropdown)
   - **Type:** String
   - **Value:** `We'd like to add your daily mood entries to your calendar so you can track your emotional wellbeing alongside your other events.`

5. **Add another entry:**
   - **Key:** `NSCalendarsFullAccessUsageDescription` (iOS 17+)
   - **Type:** String
   - **Value:** `Full calendar access allows the app to create and update mood entries in your calendar.`

### Alternative Method (if Info.plist file exists):

Add these lines to your `Info.plist` file:

```xml
<key>NSCalendarsUsageDescription</key>
<string>We'd like to add your daily mood entries to your calendar so you can track your emotional wellbeing alongside your other events.</string>
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Full calendar access allows the app to create and update mood entries in your calendar.</string>
```

## How It Works

Once set up, when users enable "Sync with Calendar" in the Account tab:

1. The app will request calendar permission
2. It creates a new calendar called "Mood Tracker" (or uses existing one)
3. Each saved mood creates an all-day event in that calendar
4. Events are named like: "Mood: 😊 Good" or "Mood: 😔 Bad"
5. Any notes are added to the event description
6. When viewing the iOS Calendar app, users will see their mood for each day

## Features

- ✅ Creates dedicated "Mood Tracker" calendar
- ✅ Syncs to iCloud if available
- ✅ Updates existing entries when mood changes
- ✅ Adds emojis for visual recognition
- ✅ Includes notes in event description
- ✅ Works with all iOS calendar views (day/week/month)

