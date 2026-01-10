//
//  SimpleButton.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 06/01/26.
//

import SwiftUI

struct SimpleButton<Label: View>: View {
    var color: Color
    var action: () -> ()
    @ViewBuilder var label: Label
    
    init(color: Color, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.color = color
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        
        Button(action: {
            action()
        }, label: {
            label
                .frame(maxWidth: .infinity)
                .frame(height: 30)
        })
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(color).interactive())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal,5)
        .padding(.top,5)
        
        
    }
}

#Preview {
    SimpleButton(color: .red, action: {
        
    }, label: {
        
        HStack(alignment: .center) {
            Image(systemName: "person")
                .padding(.leading,5)
            Text("TEST")
            Spacer()
        }
    })
}
