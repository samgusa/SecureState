//
//  UniversalCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/8/25.
//

import SwiftUI
import SwiftData

struct UniversalCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var proManager: ProStatusManager
    @EnvironmentObject var achievementsManager: AchievementsManager
    enum Style {
        case score(_ score: Int, _ maxScore: Int, _ color: Color, _ action: () -> Void)
        case action(_ color: Color, _ isRecommended: Bool)
        case toggle(Binding<Bool>)
    }

    let icon: String
    let title: String
    let subtitle: String?
    var style: Style
    
    var body: some View {
        Button(action: buttonAction) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if !icon.isEmpty {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(iconColor)
                            .frame(width: 24)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if let subtitle = subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    trailingContent
                }
                // Add progress bar for score style
                if case .score(let score, let maxScore, _, _) = style {
                    ThemedProgressBar(
                        progress: Double(score) / Double(maxScore),
                        color: themedProgressColor
                    )
                }
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder var trailingContent: some View {
        switch style {
        case .score(let score, let maxScore, _, _):
            Text("\(score)/\(maxScore)")
                .contentTransition(.numericText())
                .font(.caption)
                .foregroundColor(.secondary)
        case .action(_, let isRecommended):
            HStack(spacing: 4) {
                if isRecommended {
                    Text("Recommended")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(iconColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
        case .toggle(let binding):
            Toggle("", isOn: binding)
        }
    }

    private var iconColor: Color {
        switch style {
        case .score(let score, let maxScore, _, _):
            let percentage = Double(score) / Double(maxScore)
            if percentage >= 0.8 { return themeManager.currentTheme.successColor }
            if percentage >= 0.5 { return themeManager.currentTheme.warningColor }
            return themeManager.currentTheme.dangerColor
        case .action:
            return themeManager.currentTheme.primary
        case .toggle:
            return themeManager.currentTheme.infoColor
        }
    }

    private var buttonAction: () -> Void {
        switch style {
        case .score(_, _, _, let action): return action
        default: return { }
        }
    }

    private var themedProgressColor: Color {
        if case .score(let score, let maxScore, _, _) = style {
            let percentage = Double(score) / Double(maxScore)
            if percentage >= 0.8 { return themeManager.currentTheme.successColor }
            if percentage >= 0.5 { return themeManager.currentTheme.warningColor }
            return themeManager.currentTheme.dangerColor
        }
        return themeManager.currentTheme.primary
    }
}

struct ProgressBar: View {
    let score: Int
    let maxScore: Int
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: geometry.size.width * Double(score) / Double(maxScore), height: 4)
            }
        }
        .frame(height: 4)
    }
}

struct ThemedProgressBar: View {
    @Environment(\.colorScheme) var colorScheme
    let progress: Double
    let color: Color
    let height: CGFloat

    init(progress: Double, color: Color, height: CGFloat = 8) {
            self.progress = progress
            self.color = color
            self.height = height
        }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(colorScheme == .dark ?
                          Color(.systemGray5).opacity(0.5) :
                            Color(.systemGray4).opacity(0.4))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * min(max(progress, 0), 1.0),
                        height: height
                    )
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}


#Preview("Free User") {
    // We wrap setup code in a closure that returns the view.
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let freeProManager = ProStatusManager(storeManager: mockStoreManager)
        freeProManager.isPro = false  // not pro

        return UniversalCard(
                icon: "shield",
                title: "Device",
                subtitle: "",
                style: .score(8, 10, .green, {
                    withAnimation(.spring()) {

                    }
                })
            )
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(freeProManager)

    }()
    return view
}

#Preview("Pro User") {
    let mockThemeManager = ThemeManager()

    let container: ModelContainer = {
        let schema = Schema([StoredTrendData.self]) // Ensure StoredTrendData is in your schema
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        return container
    }()

    let view: some View = {
        let achievementManager = AchievementsManager(modelContext: container.mainContext)
        let mockStoreManager = EnhancedStoreManager()
        let proManager = ProStatusManager(storeManager: mockStoreManager, debug: true)

        return UniversalCard(
                icon: "shield",
                title: "Device",
                subtitle: "",
                style: .score(8, 10, .green, {
                    withAnimation(.spring()) {

                    }
                })
            )
            .environmentObject(mockThemeManager)
            .environmentObject(achievementManager)
            .environmentObject(mockStoreManager)
            .environmentObject(proManager)

    }()
    return view
}
