//
//  ChronologyView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import SwiftUI
import ElechimCore

struct ChronologyView: View {
    @EnvironmentObject var chronologyViewModel: ChronologyViewModel
    @Environment(\.isPreview) var isPreview
    
    var body: some View {
        ZStack {
            if chronologyViewModel.isLoading && chronologyViewModel.chronologyList.isEmpty {
                ProgressView()
                    .controlSize(.large)
            } else if chronologyViewModel.chronologyList.isEmpty {
                contentUnavailable
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: row(width: geometry.size.width), spacing: 16) {
                            ForEach(chronologyViewModel.chronologyList) { item in
                                ChronologyCardView(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        // Spostiamo il titolo nella Toolbar
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Cronologia")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .padding()
            }
        }
        .task {
            await chronologyViewModel.loadChronology()
        }
    }
    
    private var contentUnavailable: some View {
        VStack(spacing: 15) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("Nessun elemento ancora visto!!")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    // Ripristiniamo il calcolo delle colonne
    func row(width: CGFloat) -> [GridItem] {
        let minWidth: CGFloat = 300 // Larghezza minima desiderata per card testuale
        let spacing: CGFloat = 16
        
        // Calcoliamo quante colonne fisse ci stanno
        let count = max(Int(width / (minWidth + spacing)), 1)
        
        // Usiamo .flexible invece di .adaptive per avere il controllo totale sul numero
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
}

#Preview {
    ChronologyView()
        .frame(width: 650, height: 400)
        .environmentObject(PreviewDependecyInjection.shared.makeChronologyViewModel())
}
