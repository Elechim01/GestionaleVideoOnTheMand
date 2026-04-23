//
//  FetchChronologyUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation
import Services

final class FetchChronologyUseCase {

    private let chronologyRepository: ChronologyRepositoryProtocol

    init(chronologyRepository: ChronologyRepositoryProtocol) {
        self.chronologyRepository = chronologyRepository
    }
    
    func execute(localUser: String) async -> AsyncThrowingStream<[Chronology],Error> {
       await chronologyRepository.loadChronology(localUser: localUser)
    }
}
