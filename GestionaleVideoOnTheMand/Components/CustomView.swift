//
//  CustomView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/08/23.
//

import SwiftUI

public struct CustomButton<Label: View>: View {
    var isActive: Bool = false
    var trueColor: Color = .white
    var falseColor: Color = .white
    var action: () -> ()
    @ViewBuilder var label: Label
    
    
   public init(isActive: Bool,
         trueColor: Color,
         falseColor: Color,
         action: @escaping () -> Void,
         @ViewBuilder label: () -> Label) {
        self.isActive = isActive
        self.trueColor = trueColor
        self.falseColor = falseColor
        self.action = action
        self.label = label()
    }
    
    
    
   public var body: some View {
        Button(action: {
            action()
        }, label: {
            label
                .frame(maxWidth: .infinity)
                .frame(height: 30)
        })
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(isActive))
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(isActive ? trueColor : falseColor)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        }

        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal,5)
        .padding(.top,5)
      
    }
}


#Preview {
    
    
    CustomButton(isActive: true,
                 trueColor: .green,
                 falseColor: .blue,
                 action: {
    
    },label: {
        HStack(alignment: .center) {
            Image(systemName: "person")
                .padding(.leading,5)
            Text("TEST")
            Spacer()
        }
    })
    .padding()
}
#Preview {
    CustomButton(isActive: false,
                 trueColor: .blue,
                 falseColor: .blue,
                 action: {
    
    },label: {
        HStack(alignment: .center) {
            Image(systemName: "person")
                .padding(.leading,5)
            Text("TEST")
            Spacer()
        }
    })
    .padding()
}
