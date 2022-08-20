//
//  HomeView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var model : ViewModel
    @EnvironmentObject var loginModel: LoginViewModel
    @State var showProgressView : Bool = false
    var body: some View {
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
            
            HStack {
                Button {
                    model.getListFiles()
                } label: {
                    Text("Ottieni la lista di elementi")
                }
                .padding()
                if showProgressView{
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
               
            }
           
            ScrollView(.horizontal,showsIndicators: false) {
                HStack {
                    ForEach(model.elencoFilm, id:\.self){ film in
                        Text(film)
                            .contextMenu{let extractedExpr = Button(action: {
                                //                                Elimino il film
                                showProgressView.toggle()
                                model.deleteFile(nomeFile: film)
                                //                                Elimino la migniatura
                                let nameThumbnail = Extensions.getThumbnailName(nameOfElement: film)
                                model.deleteFile(nomeFile: nameThumbnail)
                                let element =  model.films.first { filmRead in
                                    let value = filmRead.nome
                                    return value == film
                                }
                                if(element != nil){
                                    model.removeDocument(film: element!)
                                }else{
                                    print("Error")
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                                    showProgressView.toggle()
                                    model.getListFiles()
                                })
                                
                            }, label: {
                                Text("Remove Element")
                                
                            })
                                extractedExpr
                                
                        }
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if model.localUser.isEmply {
                model.recuperoUtente(email: model.email, password: model.password, id: model.idUser) {
//                    Recupero i film da firestore
                    model.recuperoFilms()
//                    Recupero i film da firebase storage
                    model.getListFiles()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ViewModel())
            .environmentObject(LoginViewModel())
    }
}

