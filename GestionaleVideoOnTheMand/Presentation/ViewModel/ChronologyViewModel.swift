//
//  ChronologyViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation
import SwiftUI
import ElechimCore
import Services

@MainActor
final class ChronologyViewModel: ObservableObject {
    
    @Published var chronologyList: [Chronology] = []
    @Published var alertMessagge: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    
    private let fetchChronologyUseCase: FetchChronologyUseCase
    private let sessionManager: SessionManager
    
    
    init(fetchChronologyUseCase: FetchChronologyUseCase,
         sessionManager: SessionManager
    ) {
        self.fetchChronologyUseCase = fetchChronologyUseCase
        self.sessionManager = sessionManager
    }
    
    func loadChronology() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let stream = await fetchChronologyUseCase.execute(localUser: sessionManager.currentUser?.id ?? "")
            for try await chronology in stream {
                isLoading = false
                chronologyList = chronology.sorted(by: { $0.date > $1.date })
                
            }
        } catch  {
            isLoading = false
            ErrorReporter.shared.report(error, category: .VM)
            Utils.showError(alertMessage: &alertMessagge, showAlert: &showAlert, from: error)
        }
        
    }
    
}
