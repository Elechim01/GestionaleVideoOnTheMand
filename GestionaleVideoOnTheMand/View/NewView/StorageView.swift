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
            
            Text("Storage")
                .font(.title)
            Divider()
            ScrollView {
                Chart(isPreview ? filmsPreview  :homeModel.films) { film in
                    BarMark(
                        x: .value("Size", film.size)
                    )
                    .foregroundStyle(by: .value("Name", film.nome))
                }
                .chartLegend(position: .automatic,
                             alignment: .leading,
                             spacing: 10)
                .padding(.horizontal,5)
                
                Text("Size \(String.twoDecimal(number: homeModel.totalSize)) / \( String.twoDecimal(number: homeModel.totalSizeFilm)) ")
                    .padding()
            }
        }
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView()
            .environmentObject(ViewModel())
            .frame(width: 500, height: 400)
    }
}
