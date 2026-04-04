//
//  ChronologyRepositoryProtocol.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation

protocol ChronologyRepositoryProtocol: Sendable {
    func loadChronology(localUser: String) async -> AsyncThrowingStream<[Chronology],Error>
}
