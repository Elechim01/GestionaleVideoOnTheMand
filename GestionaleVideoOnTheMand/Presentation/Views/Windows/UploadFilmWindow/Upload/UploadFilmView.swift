//
//  UploadFilmView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct UploadFilmView: View {
    @EnvironmentObject var loadFilmViewModel: LoadFilmViewModel
    
    #warning("Quando è completato chiudere la finestra")

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            if loadFilmViewModel.stato == .loadFilm {
                SimpleButton(color:  .green.opacity(0.4), action: {
                    loadFilmViewModel.startUploadProcess()
                }, label: {
                    Text("system.button.select.film.to.upload")
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
                        Text("system.button.upload.film")
                            .padding()
                            .font(.title)
                    })
                    .frame(width: 300)
                    
                } else {
                    
                    if(loadFilmViewModel.thumbnail != nil){
                        Image(nsImage: loadFilmViewModel.thumbnail!)
                    }
                    
                    Text("info.file.name \(loadFilmViewModel.fileName)")
                        .padding()
                    
                    
                    StepView()
                        // Use maxWidth to let the view expand, not an infinite concrete width
                        .frame(maxWidth: .infinity)
                        .environmentObject(loadFilmViewModel)
                    
                    
                    if loadFilmViewModel.stato == .end {
                        SimpleButton(color: .brown, action: {
                           // loadFilmViewModel.re
                            loadFilmViewModel.stato = .loadFilm
                        }, label: {
                            Text("info.end.button")
                        })
                    }
                }
            }
            
        }
        .alert(loadFilmViewModel.alertMessage, isPresented: $loadFilmViewModel.showAlert, actions: {
            Button("system.alert.ok",role: .cancel) {
                loadFilmViewModel.showAlert.toggle()
            }
        })
        .frame(width: 450, height: 250)
        .onDisappear {
            loadFilmViewModel.stato = .loadFilm
           // loadFilmViewModel.resetCurrentUpload()
        }
    }
}

struct UploadFilmView_Previews: PreviewProvider {
    static var previews: some View {
        UploadFilmView()
            .frame(width: 650, height: 250)
            .environmentObject(PreviewDependecyInjection.shared.makeLoadFilmViewModel())
           
    }
}
