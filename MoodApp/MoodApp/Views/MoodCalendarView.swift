import SwiftUI

struct MoodCalendarView: View {
    var onDateSelected: (Date) -> Void
    
    @State private var viewType: ViewType = .month
    @State private var currentDate = Date()
    @State private var moods: [String: Mood] = [:]
    @State private var isLoading = true
    @State private var isRefreshing = false
    @State private var selectedMood: Mood? = nil
    @State private var showMoodDetail = false
    
    enum ViewType: String, CaseIterable {
        case week, month, year
    }
    
    private let impact = UISelectionFeedbackGenerator()
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    // Professional colors
    private let goodColor = Color(red: 0.2, green: 0.78, blue: 0.55)
    private let badColor = Color(red: 0.95, green: 0.45, blue: 0.45)
    private let midColor = Color(red: 0.6, green: 0.65, blue: 0.7)
    
    var body: some View {
        VStack(spacing: 0) {
            // View Type Toggle (Segmented Control)
            HStack(spacing: 0) {
                ForEach(ViewType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewType = type
                        }
                        impact.selectionChanged()
                    }) {
                        Text(type.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewType == type ? Color.white : Color.clear)
                            .foregroundColor(viewType == type ? .black : .secondary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(4)
            .background(Color.black.opacity(0.03))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            
            // Date Navigation Header
            HStack {
                Button(action: { navigateDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
                
                Text(headerTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .tracking(-0.5)
                
                Spacer()
                
                Button(action: { navigateDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Calendar Grid
            if isLoading {
                skeletonView
            } else if moods.isEmpty {
                emptyStateView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        if viewType == .month {
                            monthView
                        } else if viewType == .week {
                            weekView
                        } else {
                            yearView
                        }
                        
                        moodLegend
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
                .refreshable {
                    await refreshMoods()
                }
            }
        }
        .onAppear {
            loadMoods()
            impact.prepare()
            impactLight.prepare()
        }
        .sheet(isPresented: $showMoodDetail) {
            if let mood = selectedMood {
                MoodDetailSheet(mood: mood)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Views
    
    private var monthView: some View {
        VStack(spacing: 16) {
            // Weekday Labels
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            
            let days = getDaysInMonth()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<days.count, id: \.self) { index in
                    if let day = days[index] {
                        dayCell(for: day)
                    } else {
                        Color.clear.aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var weekView: some View {
        VStack(spacing: 16) {
            // Weekday Labels
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            
            let days = getWeekDays()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    dayCell(for: day)
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var yearView: some View {
        let months = getYearMonths()
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: columns, spacing: 20) {
            ForEach(months, id: \.self) { month in
                let summary = getMonthMoodSummary(for: month)
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(moodColor(for: summary))
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text(month.format("MMM"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(summary != nil ? .white : .primary)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func dayCell(for date: Date) -> some View {
        let dateString = date.format("yyyy-MM-dd")
        let mood = moods[dateString]
        let isToday = Calendar.current.isDateInToday(date)
        
        return Button(action: {
            onDateSelected(date)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(moodColor(for: mood?.mood))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isToday ? Color.primary : Color.clear, lineWidth: 2)
                    )
                
                Text(date.format("d"))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(mood != nil ? .white : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            if let mood = mood {
                Button {
                    selectedMood = mood
                    showMoodDetail = true
                    impactLight.impactOccurred()
                } label: {
                    Label("View Details", systemImage: "info.circle")
                }
                
                Button(role: .destructive) {
                    deleteMood(mood)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } else {
                Text("No mood logged")
            }
        }
    }
    
    private var moodLegend: some View {
        HStack(spacing: 24) {
            legendItem(color: goodColor, label: "Good")
            legendItem(color: midColor, label: "Mid")
            legendItem(color: badColor, label: "Bad")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(Color.black.opacity(0.03))
        .cornerRadius(24)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .textCase(.uppercase)
                .tracking(1)
                .opacity(0.5)
        }
    }
    
    private var skeletonView: some View {
        VStack(spacing: 16) {
            // Skeleton weekday labels
            HStack {
                ForEach(0..<7) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 12)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            
            // Skeleton grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<35) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.08))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal, 12)
            
            Spacer()
        }
        .padding(.top, 8)
        .shimmer()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 70))
                .foregroundColor(.secondary.opacity(0.3))
            
            Text("No Moods Logged Yet")
                .font(.system(size: 20, weight: .bold))
            
            Text("Start tracking your daily mood in the Log tab")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private var headerTitle: String {
        switch viewType {
        case .week:
            let days = getWeekDays()
            let start = days.first?.format("MMM d") ?? ""
            let end = days.last?.format("MMM d") ?? ""
            return "\(start) - \(end)"
        case .month:
            return currentDate.format("MMMM yyyy")
        case .year:
            return currentDate.format("yyyy")
        }
    }
    
    private func moodColor(for type: MoodType?) -> Color {
        guard let type = type else { return Color.black.opacity(0.04) }
        switch type {
            case .good: return goodColor
            case .bad: return badColor
            case .mid: return midColor
        }
    }
    
    private func refreshMoods() async {
        impactLight.impactOccurred()
        isRefreshing = true
        
        let isLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
        
        if isLocalMode {
            // Load from local storage
            let localMoods = LocalMoodStorage.shared.getAllMoods()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let moodDict = Dictionary(uniqueKeysWithValues: localMoods.map { localMood in
                let dateString = formatter.string(from: localMood.date)
                let mood = Mood(
                    id: UUID(),
                    userId: UUID(),
                    date: dateString,
                    mood: localMood.mood,
                    note: localMood.note,
                    updatedAt: localMood.date
                )
                return (dateString, mood)
            })
            
            await MainActor.run {
                withAnimation {
                    self.moods = moodDict
                }
                isRefreshing = false
            }
        } else {
            // Load from cloud storage
            do {
                let fetchedMoods = try await SupabaseManager.shared.fetchMoods()
                await MainActor.run {
                    withAnimation {
                        self.moods = Dictionary(uniqueKeysWithValues: fetchedMoods.map { ($0.date, $0) })
                    }
                    isRefreshing = false
                }
            } catch {
                print("Failed to refresh moods: \(error)")
                await MainActor.run {
                    isRefreshing = false
                }
            }
        }
    }
    
    private func deleteMood(_ mood: Mood) {
        impactLight.impactOccurred()
        
        Task {
            let isLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
            
            if isLocalMode {
                // Delete from local storage
                if let date = dateFromString(mood.date) {
                    LocalMoodStorage.shared.deleteMood(for: date)
                    
                    // Also remove from calendar if sync is enabled
                    let _ = await CalendarManager.shared.removeMoodFromCalendar(date: date)
                    
                    await MainActor.run {
                        withAnimation {
                            moods.removeValue(forKey: mood.date)
                        }
                    }
                }
            } else {
                // Delete from cloud storage
                do {
                    try await SupabaseManager.shared.deleteMood(date: mood.date)
                    
                    // Also remove from calendar if sync is enabled
                    let _ = await CalendarManager.shared.removeMoodFromCalendar(date: dateFromString(mood.date) ?? Date())
                    
                    await MainActor.run {
                        withAnimation {
                            moods.removeValue(forKey: mood.date)
                        }
                    }
                } catch {
                    print("Failed to delete mood: \(error)")
                }
            }
        }
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return nil
        }
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }
    
    private func loadMoods() {
        Task {
            let isLocalMode = UserDefaults.standard.bool(forKey: "useLocalMode")
            
            if isLocalMode {
                // Load from local storage
                let localMoods = LocalMoodStorage.shared.getAllMoods()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let moodDict = Dictionary(uniqueKeysWithValues: localMoods.map { localMood in
                    let dateString = formatter.string(from: localMood.date)
                    let mood = Mood(
                        id: UUID(),
                        userId: UUID(),
                        date: dateString,
                        mood: localMood.mood,
                        note: localMood.note,
                        updatedAt: localMood.date
                    )
                    return (dateString, mood)
                })
                
                await MainActor.run {
                    self.moods = moodDict
                    self.isLoading = false
                }
            } else {
                // Load from cloud storage
                do {
                    let fetchedMoods = try await SupabaseManager.shared.fetchMoods()
                    await MainActor.run {
                        self.moods = Dictionary(uniqueKeysWithValues: fetchedMoods.map { ($0.date, $0) })
                        self.isLoading = false
                    }
                } catch {
                    print("Failed to load moods: \(error)")
                }
            }
        }
    }
    
    private func navigateDate(by value: Int) {
        impact.selectionChanged()
        withAnimation {
            if let newDate = Calendar.current.date(byAdding: viewType == .week ? .weekOfYear : (viewType == .month ? .month : .year), value: value, to: currentDate) {
                currentDate = newDate
            }
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let firstOfMonth = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    private func getWeekDays() -> [Date] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        let startOfWeek = calendar.date(from: components)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private func getYearMonths() -> [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: year, month: month, day: 1))
        }
    }
    
    private func getMonthMoodSummary(for month: Date) -> MoodType? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: month)
        let monthNum = calendar.component(.month, from: month)
        
        let monthMoods = moods.values.filter { mood in
            let components = mood.date.split(separator: "-")
            return components.count == 3 && Int(components[0]) == year && Int(components[1]) == monthNum
        }
        
        if monthMoods.isEmpty { return nil }
        
        let goodCount = monthMoods.filter { $0.mood == .good }.count
        let badCount = monthMoods.filter { $0.mood == .bad }.count
        let midCount = monthMoods.filter { $0.mood == .mid }.count
        
        if goodCount >= badCount && goodCount >= midCount { return .good }
        if badCount >= goodCount && badCount >= midCount { return .bad }
        return .mid
    }
}
