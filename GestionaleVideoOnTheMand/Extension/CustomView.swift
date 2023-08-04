//
//  CustomView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/08/23.
//

import SwiftUI

struct CustomButton<Label: View>: View {
    var condition: Bool = false
    var trueColor: Color = .white
    var falseColor: Color
    var action: () -> ()
    @ViewBuilder var label: Label
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            label
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
    
