//
//  UploadFilmView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct UploadFilmView: View {
    
    @EnvironmentObject var model: ViewModel
    
    #warning("Quando è completato chiudere la finestra")
    #warning("Enumerare gli step e dare un valore totale")

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            CustomButton(falseColor: .green, action: {
                model.uploadFileToDb()
            }, label: {
                Text("Carica i film")
                    .font(.title)
            })
            .frame(width: 300)
            
            if model.stato != nil {
                
                if(model.thumbnail != nil){
                    Image(nsImage: model.thumbnail!)
                }
                
                Text("File: \(model.fileName)")
                ProgressView(value: model.progress, total: 100) {
                    Text(model.stato?.rawValue ?? "")
                        .font(.title3)
                        .padding(.leading)
                }
                .padding(.horizontal)
                
                HStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        guard model.taskUploadImage != nil else { return }
                        model.taskUploadImage!.pause()
                        
                    }, label: {
                        Image(systemName: "pause")
                    })
                    
                    Button(action: {
                        guard model.taskUploadImage != nil else { return }
                        model.taskUploadImage!.resume()
                        
                    }, label: {
                        Image(systemName: "play")
                    })
                    
                    Button(action: {
                        guard model.taskUploadImage != nil else { return }
                        model.taskUploadImage!.cancel()
                        
                    }, label: {
                        Image(systemName: "stop")
                    })
                }
            }
            
        }
        .frame(width: 450, height: 250)
    }
}

struct UploadFilmView_Previews: PreviewProvider {
    static var previews: some View {
        UploadFilmView()
            .environmentObject(ViewModel())
           
    }
}
