//
//  NewHome.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct NewHome: View {
    
    @EnvironmentObject var model: ViewModel 
    @State private var columsVisibility = NavigationSplitViewVisibility.all
    @Environment(\.openWindow) var openWindow
    @State var homeSection: HomeSection = .film
    
    var body: some View {
        
            NavigationSplitView(columnVisibility: $columsVisibility) {
                
                VStack(alignment: .leading) {
                    
                    InfoUser(name: model.localUser?.nome ?? "")
                    
                    ListButton(text: "Film", imageName: "film",section: .film, onTap: nil)

                    
                    ListButton(text: "Spazio", imageName: "opticaldiscdrive",section: .spazio, onTap: nil)
                    
                    Spacer()
                }
                
            } detail: {
                switch homeSection {
                case .film:
                    FilmView()
                        .environmentObject(model)
                case .spazio:
                    StorageView()
                        .environmentObject(model)
                }
            }
            .navigationSplitViewStyle(.balanced)
            .alert(model.alertMessage, isPresented: $model.showAlert, actions: {
                Button("OK",role: .cancel) {
                    model.showAlert.toggle()
                }
            })
    }
    
    @ViewBuilder
    func ListButton(text: String,
                    imageName: String,
                    section: HomeSection,
                    onTap: (()->())?
    ) -> some View {
        
        CustomButton(condition: homeSection == section ,
                     trueColor: .blue,
                     falseColor: .clear,
                     action: {
            homeSection = section
            onTap?()
        },label: {
            HStack(alignment: .center) {
                Image(systemName: imageName)
                    .padding(.leading,5)
                Text(text)
                Spacer()
            }
        })
    }
    
    @ViewBuilder
    func InfoUser(name: String) -> some View {
        CustomButton(falseColor: .green.opacity(0.6), action: {
            openWindow(id:"infoUser")
        }, label: {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.black)
                    .padding(.leading,5)
                Text("\(name)")
                    .foregroundColor(.black)
                Spacer()
            }
        })
        
        Divider()
    }
    
}

struct NewHome_Previews: PreviewProvider {
    static var previews: some View {
        NewHome()
            .environmentObject(ViewModel())
    }
}


