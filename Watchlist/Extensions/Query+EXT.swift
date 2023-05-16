//
//  Query+EXT.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/17/23.
//

import Combine
import FirebaseFirestore
import Foundation

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        try await getDocumentsWithSnapshot(as: type).data
    }

    func getDocumentsWithSnapshot<T>(as _: T.Type) async throws -> (data: [T], lastDocument: DocumentSnapshot?)
    where T: Decodable {
        let snapshot = try await getDocuments()
        let data = try snapshot.documents.map { document in
            try document.data(as: T.self)
        }

        return (data, snapshot.documents.last)
    }

    func start(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return start(afterDocument: lastDocument)
    }

    func aggregateCount() async throws -> Int {
        let snapshot = try await count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }

    func addSnapshotListener<T>(as _: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T: Decodable {
        let publisher = PassthroughSubject<[T], Error>()

        let listener = addSnapshotListener { querySnapshot, _ in
            guard let documents = querySnapshot?.documents else {
                return
            }
            let data: [T] = documents.compactMap { try? $0.data(as: T.self) }
            publisher.send(data)
        }

        return (publisher.eraseToAnyPublisher(), listener)
    }
}
