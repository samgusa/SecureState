//
//  UniversalCard.swift
//  SecureState
//
//  Created by Sam Greenhill on 7/8/25.
//

import SwiftUI

struct UniversalCard: View {
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
                if case .score(let score, let maxScore, let color, _) = style {
                    ProgressBar(score: score, maxScore: maxScore, color: color)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder var trailingContent: some View {
        switch style {
        case .score(let score, let maxScore, _, _):
            Text("\(score)/\(maxScore)")
                .font(.caption)
                .foregroundColor(.secondary)
        case .action(_, let isRecommended):
            HStack(spacing: 4) {
                if isRecommended {
                    Text("Recommended").font(.caption2).fontWeight(.medium)
                        .foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4)
                        .background(iconColor).cornerRadius(6)
                }
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
        case .toggle(let binding):
            Toggle("", isOn: binding)
        }
    }

    private var iconColor: Color {
        switch style {
        case .score(_, _, let color, _): return color
        case .action(let color, _): return color
        case .toggle: return .blue
        }
    }

    private var buttonAction: () -> Void {
        switch style {
        case .score(_, _, _, let action): return action
        default: return { }
        }
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
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: geometry.size.width * Double(score) / Double(maxScore), height: 6)
            }
        }
        .frame(height: 6)
    }
}


#Preview {
    UniversalCard(
        icon: "shield",
        title: "Device",
        subtitle: "",
        style: .score(8, 10, .green, {
            withAnimation(.spring()) {

            }
        })
    )
}
