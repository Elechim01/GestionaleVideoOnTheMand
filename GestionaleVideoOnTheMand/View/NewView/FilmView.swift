//
//  FilmView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 29/07/23.
//

import SwiftUI

struct FilmView: View {
    @EnvironmentObject var homeModel: ViewModel
    @Environment(\.isPreview) var isPreview
    @Environment(\.openWindow) var openWindow
    
    var rows: [GridItem] {
        if isPreview{
            return Array(repeating: GridItem(.flexible()), count: 3).map { _ in
                 GridItem(.flexible())
             }
        } else {
            if(homeModel.films.isEmpty){ return []}
            let filmCount = homeModel.films.count
            print("elenco elementi \(homeModel.films.count)")
            if filmCount < 3 { return [ GridItem() ]}
            return Array(repeating: GridItem(.flexible()), count: 3).map { _ in
                GridItem(.flexible())
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Films")
                    .font(.title)
                
                Spacer()
                
                Button {
                    openWindow(id: "uploadFilm")
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.trailing)
            }
            .padding(.vertical)
            Divider()
            ZStack(alignment: .center){
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: rows,alignment: .center,spacing: 0) {
                        ForEach(isPreview ? filmsPreview : homeModel.films , id: \.id) { film in
                           cardView(film: film)
                        }
                    }
                }
                .padding(.horizontal,5)
               
            }
        }
        
    }
    
    @ViewBuilder
    func cardView(film: Film) -> some View {
        VStack {
            Text(film.nome)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)

            AsyncImage(url: URL(string: film.thumbnail)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 200)
                    .clipped()
                    
            } placeholder: {
                ProgressView()
            }

            
            Text(String.twoDecimal(number: film.size))
                .font(.subheadline)
                .padding(.top,3)
                .foregroundColor(.black)
    
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        }
        .contextMenu {
            Button(action: {
                Task {
                    await homeModel.deleteFile(film: film)
                }
            }, label: {
                Text("Remove Element")
            })
        }
    }
    
}

struct FilmView_Previews: PreviewProvider {
    static var previews: some View {
        FilmView()
            .environmentObject(ViewModel())
            .frame(width: 800, height: 400)
    }
}
