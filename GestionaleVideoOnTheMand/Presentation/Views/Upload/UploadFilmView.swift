//
//  UploadFilmView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct UploadFilmView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var loadFilmHomeViewModel: LoadFilmHomeViewModel
    
    #warning("Quando è completato chiudere la finestra")
    #warning("Enumerare gli step e dare un valore totale")

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            if loadFilmHomeViewModel.stato == .loadFilm {
                SimpleButton(color:  .green.opacity(0.4), action: {
                    loadFilmHomeViewModel.startUploadProcess(localUser: homeViewModel.localUser)
                }, label: {
                    Text("system.button.select.film.to.upload")
                        .padding()
                        .font(.title)
                })
                .frame(width: 300)
            }
            
            if loadFilmHomeViewModel.stato != .loadFilm {
                
                if loadFilmHomeViewModel.stato == .succes {
                    
                    SimpleButton(color:  .green.opacity(0.4), action: {
                        loadFilmHomeViewModel.stato = .loadFilm
                    }, label: {
                        Text("system.button.upload.film")
                            .padding()
                            .font(.title)
                    })
                    .frame(width: 300)
                    
                } else {
                    
                    if(loadFilmHomeViewModel.thumbnail != nil){
                        Image(nsImage: loadFilmHomeViewModel.thumbnail!)
                    }
                    
                    Text("info.file.name \(loadFilmHomeViewModel.fileName)")
                        .padding()
                    
                    
                    StepView()
                        // Use maxWidth to let the view expand, not an infinite concrete width
                        .frame(maxWidth: .infinity)
                        .environmentObject(loadFilmHomeViewModel)
                    
                    
                    if loadFilmHomeViewModel.stato == .end {
                        SimpleButton(color: .brown, action: {
                           // loadFilmHomeViewModel.re
                            loadFilmHomeViewModel.stato = .loadFilm
                        }, label: {
                            Text("info.end.button")
                        })
                    }
                }
            }
            
        }
        .alert(loadFilmHomeViewModel.alertMessage, isPresented: $loadFilmHomeViewModel.showAlert, actions: {
            Button("system.alert.ok",role: .cancel) {
                loadFilmHomeViewModel.showAlert.toggle()
            }
        })
        .frame(width: 450, height: 250)
        .onDisappear {
            loadFilmHomeViewModel.stato = .loadFilm
           // loadFilmHomeViewModel.resetCurrentUpload()
        }
    }
}

struct UploadFilmView_Previews: PreviewProvider {
    static var previews: some View {
        UploadFilmView()
            .frame(width: 650, height: 250)
            .environmentObject(PreviewDependecyInjection.shared.makeHomeViewModel())
            .environmentObject(PreviewDependecyInjection.shared.makeLoadFilmHomeViewModel())
           
    }
}
