import Foundation

/// Local storage manager for mood data (no account required!)
/// Stores moods in UserDefaults for users who prefer not to create an account
class LocalMoodStorage {
    static let shared = LocalMoodStorage()
    
    private let moodsKey = "local_moods"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Save Mood
    
    func saveMood(date: Date, mood: MoodType, note: String? = nil) {
        var moods = getAllMoods()
        
        // Remove existing mood for this date if any
        moods.removeAll { $0.date == date.startOfDay }
        
        // Add new mood
        let newMood = LocalMood(
            date: date.startOfDay,
            mood: mood,
            note: note,
            isSyncedToCalendar: false
        )
        moods.append(newMood)
        
        // Save to UserDefaults
        saveMoods(moods)
    }
    
    // MARK: - Fetch Moods
    
    func getMood(for date: Date) -> LocalMood? {
        let moods = getAllMoods()
        return moods.first { $0.date == date.startOfDay }
    }
    
    func getAllMoods() -> [LocalMood] {
        guard let data = userDefaults.data(forKey: moodsKey) else {
            return []
        }
        
        do {
            let moods = try JSONDecoder().decode([LocalMood].self, from: data)
            return moods
        } catch {
            print("❌ Error decoding moods: \(error)")
            return []
        }
    }
    
    func getMoods(from startDate: Date, to endDate: Date) -> [LocalMood] {
        let allMoods = getAllMoods()
        return allMoods.filter { mood in
            mood.date >= startDate.startOfDay && mood.date <= endDate.startOfDay
        }
    }
    
    // MARK: - Delete Mood
    
    func deleteMood(for date: Date) {
        var moods = getAllMoods()
        moods.removeAll { $0.date == date.startOfDay }
        saveMoods(moods)
    }
    
    // MARK: - Update Calendar Sync
    
    func updateCalendarSync(for date: Date, synced: Bool) {
        var moods = getAllMoods()
        if let index = moods.firstIndex(where: { $0.date == date.startOfDay }) {
            moods[index].isSyncedToCalendar = synced
            saveMoods(moods)
        }
    }
    
    // MARK: - Clear All Data
    
    func clearAllMoods() {
        userDefaults.removeObject(forKey: moodsKey)
    }
    
    // MARK: - Private Helpers
    
    private func saveMoods(_ moods: [LocalMood]) {
        do {
            let data = try JSONEncoder().encode(moods)
            userDefaults.set(data, forKey: moodsKey)
        } catch {
            print("❌ Error encoding moods: \(error)")
        }
    }
}

// MARK: - Local Mood Model

struct LocalMood: Codable, Identifiable {
    var id: String { date.ISO8601Format() }
    let date: Date
    let mood: MoodType
    let note: String?
    var isSyncedToCalendar: Bool
}

// MARK: - Date Extension

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

