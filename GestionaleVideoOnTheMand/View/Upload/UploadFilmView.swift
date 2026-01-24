//
//  UploadFilmView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct UploadFilmView: View {
    
    @EnvironmentObject var model: ViewModel
    @EnvironmentObject var loadFilmViewModel: LoadFilmViewModel
    
    #warning("Quando è completato chiudere la finestra")
    #warning("Enumerare gli step e dare un valore totale")

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            if loadFilmViewModel.stato == .loadFilm {
                SimpleButton(color:  .green.opacity(0.4), action: {
                    loadFilmViewModel.uploadFileToDb(localUser: model.localUser)
                }, label: {
                    Text("Seleziona i  film da caricare")
                        .padding()
                        .font(.title)
                })
                .frame(width: 300)
            }
            
            if loadFilmViewModel.stato != .loadFilm {
                
                if loadFilmViewModel.stato == .succes {
                    
                    SimpleButton(color:  .green.opacity(0.4), action: {
                        loadFilmViewModel.stato = .loadFilm
                    }, label: {
                        Text("Carica Film")
                            .padding()
                            .font(.title)
                    })
                    .frame(width: 300)
                    
                } else {
                    
                    if(loadFilmViewModel.thumbnail != nil){
                        Image(nsImage: loadFilmViewModel.thumbnail!)
                    }
                    
                    Text("File: \(loadFilmViewModel.fileName)")
                        .padding()
                    
                    
                    StepView()
                        // Use maxWidth to let the view expand, not an infinite concrete width
                        .frame(maxWidth: .infinity)
                        .environmentObject(loadFilmViewModel)
                    
                    
                    if loadFilmViewModel.stato == .end {
                        SimpleButton(color: .brown, action: {
                            loadFilmViewModel.resetCurrentUpload()
                            loadFilmViewModel.stato = .loadFilm
                        }, label: {
                            Text("Carica film")
                        })
                    }
                }
            }
            
        }
        .alert(loadFilmViewModel.alertMessage, isPresented: $loadFilmViewModel.showAlert, actions: {
            Button("OK",role: .cancel) {
                loadFilmViewModel.showAlert.toggle()
            }
        })
        .frame(width: 450, height: 250)
        .onDisappear {
            loadFilmViewModel.stato = .loadFilm
            loadFilmViewModel.resetCurrentUpload()
        }
    }
}

struct UploadFilmView_Previews: PreviewProvider {
    static var previews: some View {
        UploadFilmView()
            .frame(width: 650, height: 250)
            .environmentObject(ViewModel())
            .environmentObject(LoadFilmViewModel())
           
    }
}
