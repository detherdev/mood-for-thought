import Foundation

enum MoodType: String, Codable {
    case good = "good"
    case mid = "mid"
    case bad = "bad"
    
    var emoji: String {
        switch self {
        case .good: return "😊"
        case .mid: return "😐"
        case .bad: return "😔"
        }
    }
}

struct Mood: Identifiable, Codable {
    var id: UUID = UUID()
    let userId: UUID
    let date: String // ISO string YYYY-MM-DD
    let mood: MoodType
    let note: String?
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case mood
        case note
        case updatedAt = "updated_at"
    }
}

