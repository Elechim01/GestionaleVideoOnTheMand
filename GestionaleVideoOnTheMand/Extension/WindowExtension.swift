//
//  WindowExtension.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 08/12/25.
//

import SwiftUI

struct BringToFront: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.orderFrontRegardless()
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func bringToFront() -> some View {
        background(BringToFront())
    }
}
