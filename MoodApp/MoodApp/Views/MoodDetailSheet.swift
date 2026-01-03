import SwiftUI

struct MoodDetailSheet: View {
    let mood: Mood
    @Environment(\.dismiss) private var dismiss
    
    private let goodColor = Color(red: 0.2, green: 0.78, blue: 0.55)
    private let badColor = Color(red: 0.95, green: 0.45, blue: 0.45)
    private let midColor = Color(red: 0.6, green: 0.65, blue: 0.7)
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Mood Circle
                    ZStack {
                        Circle()
                            .fill(moodColor)
                            .frame(width: 120, height: 120)
                            .shadow(color: moodColor.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: 4) {
                            Text(mood.mood.emoji)
                                .font(.system(size: 50))
                            
                            Text(mood.mood.rawValue.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 32)
                    
                    // Date
                    VStack(spacing: 4) {
                        Text(formattedDate)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        
                        Text(relativeDateString)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    // Note (if exists)
                    if let note = mood.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("Context")
                                    .font(.system(size: 12, weight: .bold))
                                    .textCase(.uppercase)
                                    .tracking(2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(note)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.black.opacity(0.03))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Metadata
                    VStack(spacing: 12) {
                        metadataRow(icon: "clock", label: "Logged at", value: formattedTime)
                        metadataRow(icon: "calendar", label: "Day of week", value: dayOfWeek)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var moodColor: Color {
        switch mood.mood {
        case .good: return goodColor
        case .bad: return badColor
        case .mid: return midColor
        }
    }
    
    private var formattedDate: String {
        let components = mood.date.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return mood.date
        }
        
        let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private var relativeDateString: String {
        let components = mood.date.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return ""
        }
        
        let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            if daysAgo > 0 {
                return "\(daysAgo) days ago"
            } else {
                return "Future date"
            }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: mood.updatedAt)
    }
    
    private var dayOfWeek: String {
        let components = mood.date.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return ""
        }
        
        let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 8)
    }
}

