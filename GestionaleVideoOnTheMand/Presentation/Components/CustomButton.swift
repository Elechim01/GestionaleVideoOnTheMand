//
//  CustomButton.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/08/23.
//

/*import SwiftUI

/// A button that shows a liquid‑glass background that reacts to an `isActive` flag.
public struct CustomButton<Label: View>: View {
    // MARK: Public configuration
    
    /// Indicates whether the button is in its “active” state.
    var isActive: Bool = false
    
    /// Background colour when `isActive` is `true`.
    var trueColor: Color = .white
    
    /// Background colour when `isActive` is `false`.
    var falseColor: Color = .white
    
    /// Action executed when the button is tapped.
    var action: () -> ()
    
    /// Content of the button (typically a label with icon + text).
    @ViewBuilder var label: Label
    
    // MARK: Body
    
    public var body: some View {
        Button(action: action) {
            label
                .frame(maxWidth: .infinity, minHeight: 30)
        }
        .buttonStyle(.plain)                     // removes default styling
        .background {
            GlassBackground(isActive: isActive,
                            activeColor: trueColor,
                            inactiveColor: falseColor)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10)) // enlarges tap target
        .padding(.horizontal, 5)
        .padding(.top, 5)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

// MARK: - GlassBackground (private)

/// A view that renders the “liquid glass” effect.
/// It mixes a material, a blur, a colour overlay, an inner stroke
/// and a subtle drop‑shadow. All parameters are driven by the button’s
/// `isActive` flag to keep the animation smooth.
private struct GlassBackground: View {
    let isActive: Bool
    let activeColor: Color
    let inactiveColor: Color
    
    // Choose a material that looks good on both light and dark modes.
    @Environment(\.colorScheme) private var colorScheme
    
    var material: Material {
        // `.ultraThinMaterial` appears clearer on light mode,
        // while `.regularMaterial` gives a richer dark look.
        colorScheme == .light ? .ultraThinMaterial : .regularMaterial
    }
    
    // The colour overlay that tells the button if it’s active.
    var overlayColor: Color {
        (isActive ? activeColor : inactiveColor)
            .opacity(0.25) // keep the glass‑like translucency
    }
    
    var body: some View {
        ZStack {
            // Base material + blur
            RoundedRectangle(cornerRadius: 20)
                .fill(material)
                .blur(radius: isActive ? 4 : 6) // a bit sharper when active
                .animation(.easeInOut(duration: 0.2), value: isActive)
            
            // Colour overlay for the “active” hue
            RoundedRectangle(cornerRadius: 20)
                .fill(overlayColor)
                .animation(.easeInOut(duration: 0.2), value: isActive)
            
            // Optional white inner stroke – gives that glass edge gleam
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
        }
        .shadow(color: Color.black.opacity(0.15),
                radius: 4, x: 0, y: 2) // soft depth
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 12) {
        CustomButton(isActive: true,
                     trueColor: .green,
                     falseColor: .blue,
                     action: {}) {
            HStack {
                Image(systemName: "person")
                    .padding(.leading, 5)
                Text("ACTIVE")
                Spacer()
            }
        }
        
        CustomButton(isActive: false,
                     trueColor: .blue,
                     falseColor: .blue,
                     action: {}) {
            HStack {
                Image(systemName: "person")
                    .padding(.leading, 5)
                Text("INACTIVE")
                Spacer()
            }
        }
    }
    .padding()
}
*/
