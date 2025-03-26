//
//  APIClient.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

//
//  APIClient.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 25/03/25.
//

import Alamofire
import Combine
import Foundation


// MARK: - Networking Abstraction (DIP)
public protocol NetworkService {
    func request<T: Decodable>(_ urlRequest: URLRequest, responseType: T.Type) -> AnyPublisher<T, NetworkError>
}


// MARK: - APIClient Implementation
public final class APIClient: NetworkService {
    private let session: Session
    public static let shared = APIClient()
    
    public init(session: Session = .default) {
        self.session = session
    }
    
    public func request<T: Decodable>(
        _ urlRequest: URLRequest,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        return session.request(urlRequest)
            .validate()
            .publishDecodable(type: T.self)
            .tryMap { response in
                switch response.result {
                case .success(let value): return value
                case .failure(let error): throw NetworkErrorMapper.map(error)
                }
            }
            .mapError { $0 as? NetworkError ?? .unknown($0) }
            .eraseToAnyPublisher()
    }
}


// MARK: - Network Error Mapping (SRP)
public struct NetworkErrorMapper {
    static func map(_ error: AFError) -> NetworkError {
        return NetworkError.fromAFError(error)
    }
}

