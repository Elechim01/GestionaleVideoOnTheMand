//
//  NewHome.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct NewHome: View {
    
    @StateObject var model = ViewModel()
    @State private var columsVisibility = NavigationSplitViewVisibility.all
    @Environment(\.openWindow) var openWindow
    @State var homeSection: HomeSection = .film
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columsVisibility) {
            
            VStack(alignment: .leading) {
                
                InfoUser(name: "Michele")
                
                ListButton(text: "Film", imageName: "film",section: .film) {
                    print("Ciao")
                }
                
                ListButton(text: "Spazio", imageName: "opticaldiscdrive",section: .spazio) {
                    print("Ciao")
                }
                
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
    }
    
    @ViewBuilder
    func ListButton(text: String,
                    imageName: String,
                    section: HomeSection,
                    onTap: @escaping ()->()
    ) -> some View {
        
        CustomButton(condition: homeSection == section ,
                     trueColor: .blue,
                     falseColor: .clear,
                     action: {
            homeSection = section
            onTap()
        },label: {
            HStack(alignment: .center) {
                Image(systemName: imageName)
                    .padding(.leading,5)
                Text(text)
                Spacer()
            }
        })
        /*
        Button {
           
            
        } label: {
            HStack(alignment: .center) {
                Image(systemName: imageName)
                    .padding(.leading,5)
                Text(text)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical,5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(?  : .clear)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal,5)
        .padding(.top,5)
        */
    }
    
    @ViewBuilder
    func InfoUser(name: String) -> some View {
        CustomButton(falseColor: .green.opacity(0.6), action: {
         #warning("Open Window Info User")
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
        
//        Button {
//
//
//        } label: {
//
//
//        }
//        .frame(maxWidth: .infinity)
//        .buttonStyle(PlainButtonStyle())
//        .padding(.vertical,5)
//        .background {
//            RoundedRectangle(cornerRadius: 4)
//                .fill(.green.opacity(0.6))
////                .frame(height: 30)
//        }
//        .padding(.vertical,10)
//        .padding(.horizontal,5)
        
        Divider()
    }
    
}

struct NewHome_Previews: PreviewProvider {
    static var previews: some View {
        NewHome()
    }
}

extension View {
    func CustomButton(condition: Bool = false,
                      trueColor: Color = .white,
                      falseColor: Color,
                      action: @escaping () ->(),
                      label: @escaping () -> some View) -> some View {
        Button(action: {
            action()
        }, label: {
            label()
        })
        .frame(maxWidth: .infinity)
        .padding(.vertical,5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(condition ? trueColor : falseColor)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal,5)
        .padding(.top,5)
    }
}
