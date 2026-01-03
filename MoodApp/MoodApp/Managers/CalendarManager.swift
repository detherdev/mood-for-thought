import Foundation
import EventKit
import UIKit

class CalendarManager {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    private let calendarTitle = "Mood Tracker"
    
    private init() {}
    
    // Request calendar access
    func requestAccess() async -> Bool {
        print("📅 Requesting calendar access...")
        if #available(iOS 17.0, *) {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                print("📅 Calendar access granted: \(granted)")
                return granted
            } catch {
                print("❌ Calendar access error: \(error)")
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        print("❌ Calendar access error: \(error)")
                    } else {
                        print("📅 Calendar access granted: \(granted)")
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    // Get or create the Mood Tracker calendar
    private func getMoodCalendar() -> EKCalendar? {
        // Check if calendar already exists
        let calendars = eventStore.calendars(for: .event)
        print("📅 Found \(calendars.count) calendars")
        
        if let existing = calendars.first(where: { $0.title == calendarTitle }) {
            print("📅 Using existing '\(calendarTitle)' calendar")
            return existing
        }
        
        print("📅 Creating new '\(calendarTitle)' calendar...")
        
        // Create new calendar
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = calendarTitle
        // Use emerald green to match the app
        calendar.cgColor = UIColor(red: 0.2, green: 0.78, blue: 0.55, alpha: 1.0).cgColor
        
        // Set source (iCloud or local)
        print("📅 Available sources: \(eventStore.sources.map { "\($0.title) (\($0.sourceType.rawValue))" })")
        
        if let source = eventStore.sources.first(where: { $0.sourceType == .calDAV && $0.title == "iCloud" }) {
            print("📅 Using iCloud source")
            calendar.source = source
        } else if let source = eventStore.sources.first(where: { $0.sourceType == .local }) {
            print("📅 Using local source")
            calendar.source = source
        } else {
            print("📅 Using default calendar source")
            calendar.source = eventStore.defaultCalendarForNewEvents?.source
        }
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            print("✅ Calendar created successfully!")
            return calendar
        } catch {
            print("❌ Failed to create calendar: \(error)")
            return nil
        }
    }
    
    // Sync a mood entry to the calendar
    func syncMoodToCalendar(date: Date, mood: MoodType, note: String?) async -> Bool {
        let syncEnabled = UserDefaults.standard.bool(forKey: "calendarSyncEnabled")
        print("📅 Calendar sync enabled: \(syncEnabled)")
        
        guard syncEnabled else {
            print("📅 Calendar sync is disabled, skipping")
            return false
        }
        
        print("📅 Syncing mood to calendar...")
        let hasAccess = await requestAccess()
        
        guard hasAccess else {
            print("❌ No calendar access, cannot sync")
            return false
        }
        
        guard let calendar = getMoodCalendar() else {
            print("❌ Could not get/create calendar")
            return false
        }
        
        print("📅 Calendar ready, creating event...")
        
        // Check if event already exists for this date
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate).filter { 
            $0.title.hasPrefix("Mood:") 
        }
        
        // Delete existing mood events for this date
        for event in existingEvents {
            do {
                try eventStore.remove(event, span: .thisEvent)
            } catch {
                print("Failed to remove event: \(error)")
            }
        }
        
        // Create new event
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = "Mood: \(mood.emoji) \(mood.rawValue.capitalized)"
        event.startDate = startOfDay
        event.endDate = startOfDay.addingTimeInterval(60) // 1 minute duration
        event.isAllDay = true
        event.notes = note
        
        print("📅 Event details:")
        print("   Title: \(event.title ?? "nil")")
        print("   Date: \(startOfDay)")
        print("   All day: \(event.isAllDay)")
        print("   Calendar: \(calendar.title)")
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("✅ Event saved successfully!")
            return true
        } catch {
            print("❌ Failed to save event: \(error)")
            return false
        }
    }
    
    // Remove a mood entry from calendar
    func removeMoodFromCalendar(date: Date) async -> Bool {
        let hasAccess = await requestAccess()
        guard hasAccess, let calendar = getMoodCalendar() else {
            return false
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate).filter { 
            $0.title.hasPrefix("Mood:") 
        }
        
        for event in existingEvents {
            do {
                try eventStore.remove(event, span: .thisEvent)
            } catch {
                print("Failed to remove event: \(error)")
                return false
            }
        }
        
        return true
    }
}

