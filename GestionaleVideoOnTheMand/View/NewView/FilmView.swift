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
    @State var showProgressView: Bool = false
    
    var rows: [GridItem] {
        if isPreview{
            return (1...(filmsPreview.count/4)).map { _ in
                 GridItem(.flexible())
             }
        }else{
            if(homeModel.films.isEmpty){ return []}
            print("elenco elementi \(homeModel.films.count)")
            if homeModel.films.count < 4 { return [ GridItem() ]}
            return (1...(homeModel.films.count / 4)).map { _ in
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
                    LazyVGrid(columns: rows,alignment: .center,spacing: 20) {
                        ForEach(isPreview ? filmsPreview : homeModel.films , id: \.id) { film in
                           cardView(film: film)
                        }
                    }
                }
                .padding(.horizontal,5)
                if showProgressView {
                    ProgressView()
                }
            }
        }
        .onAppear {
            guard !isPreview else { return }
                if homeModel.localUser.isEmply {
                    Task {
                        DispatchQueue.main.async {
                            showProgressView.toggle()
                        }
                        homeModel.recuperoUtente(email: homeModel.email, password: homeModel.password, id: homeModel.idUser) {
                            //                    Recupero i film da firestore
                            homeModel.recuperoFilms {
                                DispatchQueue.main.async {
                                    showProgressView.toggle()
                                }
                            }
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    func cardView(film: Film) -> some View {
        VStack {
            Text(film.nome)
                .font(.title3)
                .fontWeight(.bold)

            Text(String.twoDecimal(number: film.size))
                .font(.subheadline)
                .padding(.top,3)
    
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        }
        .contextMenu {
            Button(action: {
                //                                Elimino il film
                showProgressView.toggle()
                homeModel.deleteFile(nomeFile: film.nome)
//                                Elimino la migniatura
                let nameThumbnail = Extensions.getThumbnailName(nameOfElement: film.nome)
                homeModel.deleteFile(nomeFile: nameThumbnail)
                let element = homeModel.films.first { filmRead in
                    let value = filmRead.nome
                    return value == film.nome
                }
                if(element != nil){
                    homeModel.removeDocument(film: element!)
                }else{
                    print("Error")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    showProgressView.toggle()
                  //  model.getListFiles()
                })
                
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
            .frame(width: 600, height: 400)
    }
}
