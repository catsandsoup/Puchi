import SwiftUI

struct InsightsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Header
                        InsightsHeaderView()
                        
                        // Streak Cards
                        StreakCardsView()
                        
                        // Statistics Grid
                        StatisticsGridView()
                        
                        // Calendar Heatmap
                        CalendarHeatmapView()
                        
                        // Top Insights
                        TopInsightsView()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("💕 Insights")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
        }
    }
}

struct InsightsHeaderView: View {
    @Environment(AppState.self) private var appState
    
    private var insights: JournalInsights {
        appState.insights
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Current streak highlight
            if insights.currentStreak > 0 {
                VStack(spacing: 8) {
                    Text("🔥 Current Streak")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("\(insights.currentStreak)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(insights.currentStreak == 1 ? "day" : "days")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Journey summary
            if let firstEntry = insights.firstEntryDate {
                VStack(spacing: 4) {
                    Text("Your Love Story Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Started \(DateFormatter.journeyStart.string(from: firstEntry))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct StreakCardsView: View {
    @Environment(AppState.self) private var appState
    
    private var insights: JournalInsights {
        appState.insights
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Current Streak
            StreakCard(
                title: "Current",
                value: insights.currentStreak,
                subtitle: "day streak",
                icon: "flame.fill",
                color: .orange
            )
            
            // Longest Streak
            StreakCard(
                title: "Best Ever",
                value: insights.longestStreak,
                subtitle: "day streak",
                icon: "trophy.fill",
                color: .yellow
            )
        }
    }
}

struct StreakCard: View {
    let title: String
    let value: Int
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.1))
                .stroke(Color(.systemGray5).opacity(0.2), lineWidth: 0.5)
        )
    }
}

struct StatisticsGridView: View {
    @Environment(AppState.self) private var appState
    
    private var insights: JournalInsights {
        appState.insights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Memories",
                    value: "\(insights.totalEntries)",
                    icon: "heart.text.square",
                    color: .pink
                )
                
                StatCard(
                    title: "Words",
                    value: "\(insights.totalWords)",
                    icon: "textformat",
                    color: .blue
                )
                
                StatCard(
                    title: "Photos",
                    value: "\(insights.totalPhotos)",
                    icon: "photo",
                    color: .green
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(insights.entriesThisWeek)",
                    icon: "calendar",
                    color: .purple
                )
                
                if insights.totalVoiceNotes > 0 {
                    StatCard(
                        title: "Voice Notes",
                        value: "\(insights.totalVoiceNotes)",
                        icon: "waveform",
                        color: .orange
                    )
                }
                
                if insights.totalVideos > 0 {
                    StatCard(
                        title: "Videos",
                        value: "\(insights.totalVideos)",
                        icon: "video",
                        color: .red
                    )
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.1))
                .stroke(Color(.systemGray5).opacity(0.2), lineWidth: 0.5)
        )
    }
}

struct CalendarHeatmapView: View {
    @Environment(AppState.self) private var appState
    
    private var insights: JournalInsights {
        appState.insights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Journaling Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Simple month view showing recent activity
            CalendarGridView(journalingDays: insights.journalingDays)
        }
    }
}

struct CalendarGridView: View {
    let journalingDays: [Date]
    @State private var currentMonth = Date()
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var daysInMonth: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? Date()
        
        var days: [Date] = []
        var currentDate = startOfMonth
        
        while currentDate < endOfMonth {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.pink)
                }
                
                Spacer()
                
                Text(monthFormatter.string(from: currentMonth))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.pink)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 30)
                }
                
                // Days
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        hasEntry: journalingDays.contains { calendar.isDate($0, inSameDayAs: date) }
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.1))
                .stroke(Color(.systemGray5).opacity(0.2), lineWidth: 0.5)
        )
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct CalendarDayView: View {
    let date: Date
    let hasEntry: Bool
    
    private var dayNumber: String {
        DateFormatter.dayNumber.string(from: date)
    }
    
    var body: some View {
        ZStack {
            if hasEntry {
                Circle()
                    .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 28, height: 28)
            }
            
            Text(dayNumber)
                .font(.caption)
                .foregroundColor(hasEntry ? .white : .gray)
        }
        .frame(height: 30)
    }
}

struct TopInsightsView: View {
    @Environment(AppState.self) private var appState
    
    private var insights: JournalInsights {
        appState.insights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Top Insights")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Top Moods
            if !insights.topMoods.isEmpty {
                InsightSection(
                    title: "Favorite Moods",
                    icon: "face.smiling",
                    items: insights.topMoods.map { "\($0.emoji) \($0.rawValue.capitalized)" }
                )
            }
            
            // Top Tags
            if !insights.topTags.isEmpty {
                InsightSection(
                    title: "Popular Tags",
                    icon: "tag",
                    items: insights.topTags.map { "#\($0)" }
                )
            }
            
            // Favorite Locations
            if !insights.favoriteLocations.isEmpty {
                InsightSection(
                    title: "Favorite Places",
                    icon: "location",
                    items: insights.favoriteLocations
                )
            }
        }
    }
}

struct InsightSection: View {
    let title: String
    let icon: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.pink)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.prefix(5)), id: \.self) { item in
                    Text(item)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.pink.opacity(0.1))
                                .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.1))
                .stroke(Color(.systemGray5).opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let journeyStart: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let dayNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}

#Preview {
    InsightsView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}