//
//  DomainTests.swift
//  DomainTests
//
//  Created by Aries Prasetyo on 27/03/25.
//

import Combine
import Foundation
import Core

final class MockNetworkService: NetworkService {
    var mockResponse: SongResponseDTO?
    var mockError: NetworkError?

    func request<T: Decodable>(_ request: URLRequest, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }

        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        return Fail(error: .unknown(NSError(domain: "MockNetworkService", code: -1, userInfo: nil)))
            .eraseToAnyPublisher()
    }
}


