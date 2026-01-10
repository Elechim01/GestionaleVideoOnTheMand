//
//  FilmView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 29/07/23.
//

import SwiftUI
import CachedAsyncImage

struct FilmView: View {
    @EnvironmentObject var homeModel: ViewModel
    @Environment(\.isPreview) var isPreview
    @Environment(\.openWindow) var openWindow
    
    
    var body: some View {
        VStack{
            ZStack(alignment: .center){
                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: rows(for: geo.size.width),alignment: .center,spacing: 0) {
                            ForEach(isPreview ? filmsPreview : homeModel.films , id: \.id) { film in
                               cardView(film: film)
                            }
                        }
                    }
                    .padding(.horizontal,5)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Films")
                    .font(.title)
                    .padding()
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openWindow(id: "uploadFilm")
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glass)
            }
        }
        
        
    }
    
    @ViewBuilder
   private func cardView(film: Film) -> some View {
        VStack {
            Text(film.nome)
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .glassEffect()

            CachedAsyncImageView(url: URL(string: film.thumbnail)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)

                  
            } Placeholder: {
                ProgressView()
                    .glassEffect()
            }

            
            Text(Utils.formatStorage(film.size))
                .font(.subheadline)
                .padding()
                .glassEffect()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
              
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: 300, height: 400)
        .contextMenu {
            Button(action: {
                Task {
                    await homeModel.deleteFile(film: film)
                }
            }, label: {
                Text("Remove Element")
            })
            .glassEffect()
        }
    }
   
    private func rows(for width: CGFloat) -> [GridItem] {
        guard !isPreview else {
            return Array(repeating: GridItem(.flexible()), count: 3).map { _ in
                GridItem(.flexible())
            }
        }
        
        if(homeModel.films.isEmpty){ return [] }
        
        let minLengh =  300
        print("elenco elementi \(homeModel.films.count)")
        let count = max(Int(Int(width) / minLengh), 1)
        return Array(repeating: GridItem(.adaptive(minimum: 220), spacing: 16), count: count)
        
    }
    
    
}

struct FilmView_Previews: PreviewProvider {
    static var previews: some View {
        FilmView()
            .environmentObject(ViewModel())
            .frame(width: 900, height: 700)
    }
}
