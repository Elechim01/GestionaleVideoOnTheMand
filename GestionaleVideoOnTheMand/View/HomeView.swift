//
//  HomeView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var model : ViewModel
    @EnvironmentObject var loginModel: LoginViewModel
    @State var showProgressView : Bool = false
    @State var isLoading: Bool = false
    
    @Environment(\.isPreview) var isPreview
    var rows: [GridItem] {
        if isPreview{
           return (1...(22/4)).map { _ in
                 GridItem(.flexible())
             }
        }else{
            if(model.films.isEmpty){ return []}
            print("elenco elementi \(model.films.count)")
            if model.films.count < 4 { return [ GridItem() ]}
            return (1...(model.films.count / 4)).map { _ in
                GridItem(.flexible())
            }
        }
    }
   
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    Text("Carica video sul db UUID: \(model.localUser.id)")
                        .font(.title)
                        .padding()
                    Text("Nome:\(model.fileName)")
                    Text("Path:\(model.file.absoluteString)")
                    Text("Url file uplodato:\(model.urlFileUplodato)")
                    if(model.progress > 0){
                        ProgressView(model.stato, value: model.progress,total: 100)
                            .frame(width: 400)
                            .padding(.leading)
                            .padding(.trailing)
                    }
                    
                    HStack {
                        Button("select File")
                        {
                            model.uploadFileToDb()
                        }
                        Button {
                            loginModel.logOut()
                        } label: {
                            Text("Logout")
                        }
                        
                    }
                    
                    if(model.thumbnail != nil){
                        Image(nsImage: model.thumbnail!)
                    }
                    Group {
                        
                        HStack{
                            Button {
                                if(model.taskUploadImage != nil){
                                    model.taskUploadImage!.pause()
                                }
                            } label: {
                                Text("Metti in Pausa il caricamento")
                            }
                            
                            Button {
                                if(model.taskUploadImage != nil){
                                    model.taskUploadImage!.resume()
                                }
                            } label: {
                                Text("Riprendi il caricamento")
                            }
                            
                            Button {
                                if(model.taskUploadImage != nil){
                                    model.taskUploadImage!.cancel()
                                }
                            } label: {
                                Text("Cancella il caricamento")
                            }
                        }
                    }
                    Group{
                        Chart(model.films) { film in
                            BarMark(
                                x: .value("Size", film.size)
                            )
                            .foregroundStyle(by: .value("Name", film.nome))
                        }
                        .chartLegend(position: .automatic,
                                     alignment: .leading,
                                     spacing: 10)
                        Text("Size \(String.twoDecimal(number: model.totalSize)) / \( String.twoDecimal(number: model.totalSizeFilm)) ")
                    }
                    scrollView()
                 
                }
                if isLoading {
                    ProgressView()
                }
            }
            
        }
      
        .alert(model.alertMessage, isPresented: $model.showAlert, actions: {
            Button("OK",role: .cancel) {
                model.showAlert.toggle()
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if !isPreview{
                if model.localUser.isEmply {
                    Task {
                        DispatchQueue.main.async {
                            isLoading = true
                        }
                        model.recuperoUtente(email: model.email, password: model.password, id: model.idUser) {
                            //                    Recupero i film da firestore
                            model.recuperoFilms {
                                DispatchQueue.main.async {
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
            } else {
                model.films = filmsPreview
            }
        }
    }
    
    @ViewBuilder
    func scrollView() -> some View {
        ScrollView(.vertical,showsIndicators: false) {
            LazyVGrid(columns: rows,alignment: .center,spacing: 20) {
                if isPreview{
                    ForEach(1...10, id: \.self) { number in
                            Text("\(number)")
                        }
                }else{
                    ForEach(model.films, id:\.id){ film in
                        VStack {
                            Text(film.nome)
                                .contextMenu{let extractedExpr = Button(action: {
                                    //                                Elimino il film
                                    showProgressView.toggle()
                                    model.deleteFile(nomeFile: film.nome)
    //                                Elimino la migniatura
                                    let nameThumbnail = Extensions.getThumbnailName(nameOfElement: film.nome)
                                    model.deleteFile(nomeFile: nameThumbnail)
                                    let element =  model.films.first { filmRead in
                                        let value = filmRead.nome
                                        return value == film.nome
                                    }
                                    if(element != nil){
                                        model.removeDocument(film: element!)
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
                                    extractedExpr
                                    
                                }
                                .padding()
                            Text(String.twoDecimal(number: film.size))
                        }
                     
                        
                    }
                }
            }
        }
        .padding()
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .frame(width: 600, height: 600)
            .environmentObject(ViewModel())
            .environmentObject(LoginViewModel())
    }
}

