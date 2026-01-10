//
//  ExtensionView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 10/01/26.
//

import Foundation
import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

    func alwaysOnTop() -> some View {
        self.background(WindowAccessor { window in
            window?.level = .floating
        })
    }
}

