//
//  RestorePassword.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/04/26.
//

import SwiftUI
import ElechimCore

struct RestorePassword: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ripristina password")
                .font(.headline)
            Text("Inserisci l'email associata al tuo account per ricevere le istruzioni.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            TextField("Email", text: $loginViewModel.emailToRestore)
                .modifier(LoginTextFieldStyle())
            
            if !loginViewModel.checkEmailToRestore && !loginViewModel.emailToRestore.isEmpty {
                Text("Email inserita non valida!")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.red.opacity(0.8))
            }
            
            HStack {
                Button("Annulla") {
                  dismiss()
                }
                .modifier(LoginButtonStyle(color: .gray))
                .keyboardShortcut(.cancelAction)
                
                Button("Invia Email") {
                    Task {
                        await loginViewModel.restorePassword()
                      
                        dismiss()
                    }
                }
                .modifier(LoginButtonStyle(color: .green))
                .buttonStyle(.borderedProminent)
                .disabled(!loginViewModel.checkEmailToRestore)
            }
            .padding()
        }
        .padding()
        .frame(width: 350)
        .background(Color("Blue").ignoresSafeArea())
    }
    
}

#Preview {
    RestorePassword()
        .environmentObject(PreviewDependecyInjection().makeLoginViewModel())
    
}
