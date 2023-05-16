//
//  DocumentReference+EXT.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/27/23.
//

import Combine
import FirebaseFirestore
import Foundation

extension DocumentReference {
    func addSnapshotListener<T>(as _: T.Type) -> (AnyPublisher<T, Error>, ListenerRegistration) where T: Decodable {
        let publisher = PassthroughSubject<T, Error>()

        let listener = addSnapshotListener { documentSnapshot, _ in
            guard let document = documentSnapshot,
                  let data: T = try? document.data(as: T.self)
            else {
                return
            }

            publisher.send(data)
        }

        return (publisher.eraseToAnyPublisher(), listener)
    }
}
