//
//  StorageView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 29/07/23.
//

import SwiftUI
import Charts

struct StorageView: View {
    @EnvironmentObject var homeModel: ViewModel
    @Environment(\.isPreview) var isPreview
    var body: some View {
        VStack {
                Chart(isPreview ? filmsPreview : homeModel.films) { film in
                    BarMark(
                        x: .value("Size", film.size),
                        y: .value("Film", film.nome)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Film", film.nome))
                    .annotation(position: .overlay, alignment: .trailing) {
                            Text("\(film.size, format: .number.precision(.fractionLength(1)))")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                        }
                }
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks(position: .automatic) {
                        AxisGridLine().foregroundStyle(.quaternary)
                        AxisTick()
                       AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .automatic) {
                        AxisGridLine().foregroundStyle(.quaternary)
                        AxisValueLabel()
                    }
                }
                .chartYScale()
                .frame(minHeight: 220)
                
            Text("Size \(Utils.formatStorage(homeModel.totalSize)) / \( Utils.formatStorage(homeModel.totalSizeFilm)) ")
                    .padding()
                    .glassEffect()
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Storage")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
    }
    
   
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView()
            .environmentObject(ViewModel())
            .frame(width: 500, height: 400)
    }
}
