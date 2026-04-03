//
//  ChronologyRepository.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation
import Services

final class ChronologyRepository: ChronologyRepositoryProtocol {
    func loadChronology(localUser: String) async -> AsyncThrowingStream<[Chronology], any Error> {
        return await FirebaseUtils.shared.recuperoChronology(localUser: localUser)
    }
    
    
}
