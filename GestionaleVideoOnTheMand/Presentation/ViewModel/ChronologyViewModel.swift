//
//  ChronologyViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation
import SwiftUI
import ElechimCore

@MainActor
final class ChronologyViewModel: ObservableObject {
    
    @Published var chronologyList: [Chronology] = []
    @Published var alertMessagge: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    
    #warning("Implement Session")
    @AppStorage("IDUser") internal var idUser = ""
    let fetchChronologyUseCase: FetchChronologyUseCase
    
    
    init(fetchChronologyUseCase: FetchChronologyUseCase) {
        self.fetchChronologyUseCase = fetchChronologyUseCase
    }
    
    func loadChronology() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let stream = await fetchChronologyUseCase.execute(localUser: idUser)
            for try await chronology in stream {
                isLoading = false
                chronologyList = chronology.sorted(by: { $0.date > $1.date })
               
            }
        } catch  {
            isLoading = false
            Utils.showError(alertMessage: &alertMessagge, showAlert: &showAlert, from: error)
        }
      
    }
    
}
