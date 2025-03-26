//
//  NetworkError.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//

import Foundation
import Alamofire

public enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidRequest
    case requestFailed(description: String)
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlyingError: Error)
    case unknown(Error)
    
    static func fromAFError(_ error: AFError) -> NetworkError {
        switch error {
        case .invalidURL: return .invalidURL
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return .invalidResponse(statusCode: code)
            }
            return .requestFailed(description: error.localizedDescription)
        default: return .unknown(error)
        }
    }

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidRequest, .invalidRequest):
            return true
        case (.requestFailed(let lhsDescription), .requestFailed(let rhsDescription)):
            return lhsDescription == rhsDescription
        case (.invalidResponse(let lhsCode), .invalidResponse(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingFailed, .decodingFailed):
            return true // We don't compare underlying errors directly
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

