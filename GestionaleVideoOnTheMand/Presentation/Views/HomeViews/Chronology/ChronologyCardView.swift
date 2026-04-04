//
//  ChronologyCardView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import SwiftUI
import ElechimCore

struct ChronologyCardView: View {
    let item: Chronology
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    )
                
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
            .frame(width: 25, height: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.filmName)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(Utils.formatFullDate(item.date))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Icona di stato opzionale (es. visto)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.green.opacity(isHovering ? 0.9 : 0.4))
                .animation(.easeInOut, value: isHovering)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovering ? Color.white.opacity(0.1) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHovering ? Color.white.opacity(0.2) : Color.clear, lineWidth: 0.5)
                )
        )
        // Leggero spostamento laterale invece dello zoom (più adatto alle liste)
        .offset(x: isHovering ? 5 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    ChronologyCardView(item: mockChronology.first!)
}
